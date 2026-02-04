#!/bin/bash
#
# mkhdimg.sh - Create bootable MS-DOS 4 disk images
#
# Produces bootable disk images from the compiled binaries in this directory.
#
# Image types:
#   (default)  FAT16 hard disk image (bootable in QEMU, dosemu, VirtualBox)
#   --floppy   Minimal 1.44MB FAT12 boot floppy (IO.SYS, MSDOS.SYS, COMMAND.COM)
#
# Strategy: Uses dosemu with mkfatimage16 to create a properly formatted
# disk image, then runs SYS inside dosemu to write the authentic MS-DOS 4
# boot sector and system files.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Defaults
OUTPUT=""
SIZE_KB=65536  # 64MB in KB
FLOPPY=false

usage() {
    cat <<EOF
Usage: $(basename "$0") [--floppy] [-o output.img] [--size SIZE_MB]

Options:
  --floppy       Create a minimal 1.44MB boot floppy instead of a hard disk
  -o FILE        Output image file (default: dos4.img)
  --size SIZE    Disk size in MB (default: 64, ignored for --floppy)
  -h, --help     Show this help

The binaries must be present in this directory (run the build first).
Requires: dosemu2, mtools, mkfatimage16
EOF
    exit "${1:-0}"
}

# Parse arguments
while [ $# -gt 0 ]; do
    case "$1" in
        --floppy) FLOPPY=true; shift ;;
        -o)       OUTPUT="$2"; shift 2 ;;
        --size)   SIZE_KB=$(( $2 * 1024 )); shift 2 ;;
        -h|--help) usage 0 ;;
        *) echo "Unknown option: $1" >&2; usage 1 ;;
    esac
done

if [ -z "$OUTPUT" ]; then
    if $FLOPPY; then
        OUTPUT="$SCRIPT_DIR/dos4-boot.img"
    else
        OUTPUT="$SCRIPT_DIR/dos4.img"
    fi
fi

# Sanity checks - verify key system files exist
for f in io.sys msdos.sys command.com; do
    if [ ! -f "$SCRIPT_DIR/$f" ]; then
        echo "Error: $f not found. Run the build first." >&2
        exit 1
    fi
done

if $FLOPPY; then
    REQUIRED_CMDS="dosemu mformat"
else
    REQUIRED_CMDS="dosemu mkfatimage16"
fi
for cmd in $REQUIRED_CMDS; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Error: $cmd not found. Install dosemu2 and mtools." >&2
        exit 1
    fi
done

if $FLOPPY; then
    echo "Creating MS-DOS 4 boot floppy image..."
    echo "  Output: $OUTPUT"
else
    echo "Creating MS-DOS 4 hard disk image..."
    echo "  Output: $OUTPUT"
    echo "  Size:   $(( SIZE_KB / 1024 ))MB"
fi

# Create temporary working directory
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

STAGING="$TMPDIR/staging"
mkdir -p "$STAGING/DOS"

# --- Phase 1: Build staging directory ---

echo "Preparing staging directory..."

# Copy system files to root
cp "$SCRIPT_DIR/io.sys"      "$STAGING/IO.SYS"
cp "$SCRIPT_DIR/msdos.sys"   "$STAGING/MSDOS.SYS"
cp "$SCRIPT_DIR/command.com" "$STAGING/COMMAND.COM"

if $FLOPPY; then
    # Floppy only needs SYS.COM in the DOS directory so the staging
    # boot can find it on PATH
    cp "$SCRIPT_DIR/sys.com" "$STAGING/DOS/SYS.COM"
else
    # Hard disk image: full file layout

    # Generate CONFIG.SYS
    printf 'FILES=30\r\n' > "$STAGING/CONFIG.SYS"
    printf 'BUFFERS=20\r\n' >> "$STAGING/CONFIG.SYS"

    # Generate AUTOEXEC.BAT
    printf '@ECHO OFF\r\n' > "$STAGING/REAL_AE.BAT"
    printf 'PROMPT $p$g\r\n' >> "$STAGING/REAL_AE.BAT"
    printf 'PATH C:\\DOS\r\n' >> "$STAGING/REAL_AE.BAT"

    # Copy DOS utilities to DOS subdirectory
    echo "Copying DOS utilities..."

    # Commands (COM files)
    for f in assign backup chkdsk comp debug diskcomp diskcopy edlin \
             format graftabl graphics label mode more print recover \
             restore sys tree keyb; do
        [ -f "$SCRIPT_DIR/$f.com" ] && cp "$SCRIPT_DIR/$f.com" "$STAGING/DOS/$(echo $f | tr 'a-z' 'A-Z').COM"
    done

    # Commands (EXE files)
    for f in append attrib exe2bin fastopen filesys fdisk find fc \
             ifsfunc join mem nlsfunc replace select share sort subst xcopy; do
        [ -f "$SCRIPT_DIR/$f.exe" ] && cp "$SCRIPT_DIR/$f.exe" "$STAGING/DOS/$(echo $f | tr 'a-z' 'A-Z').EXE"
    done

    # Device drivers
    for f in ansi country display keyboard printer smartdrv ramdrive \
             driver xma2ems xmaem emm386; do
        [ -f "$SCRIPT_DIR/$f.sys" ] && cp "$SCRIPT_DIR/$f.sys" "$STAGING/DOS/$(echo $f | tr 'a-z' 'A-Z').SYS"
    done

    # Code page information files
    for f in ega lcd 4201 4208 5202; do
        [ -f "$SCRIPT_DIR/$f.cpi" ] && cp "$SCRIPT_DIR/$f.cpi" "$STAGING/DOS/$(echo $f | tr 'a-z' 'A-Z').CPI"
    done

    # Profile files
    [ -f "$SCRIPT_DIR/graphics.pro" ] && cp "$SCRIPT_DIR/graphics.pro" "$STAGING/DOS/GRAPHICS.PRO"

    # SELECT installer files (unique to DOS 4)
    [ -f "$SCRIPT_DIR/select.com" ] && cp "$SCRIPT_DIR/select.com" "$STAGING/DOS/SELECT.COM"
    [ -f "$SCRIPT_DIR/select.dat" ] && cp "$SCRIPT_DIR/select.dat" "$STAGING/DOS/SELECT.DAT"
    [ -f "$SCRIPT_DIR/select.prt" ] && cp "$SCRIPT_DIR/select.prt" "$STAGING/DOS/SELECT.PRT"
    [ -f "$SCRIPT_DIR/select.hlp" ] && cp "$SCRIPT_DIR/select.hlp" "$STAGING/DOS/SELECT.HLP"

    echo "  Staged $(ls "$STAGING/DOS/" | wc -l) files in DOS directory"
fi

# --- Phase 2: Create target disk image ---

echo "Creating disk image..."

if $FLOPPY; then
    # Create a blank 1.44MB raw floppy image and format as FAT12
    dd if=/dev/zero of="$TMPDIR/floppy.img" bs=512 count=2880 2>/dev/null
    mformat -f 1440 -v MSDOS4 -i "$TMPDIR/floppy.img" ::
else
    # mkfatimage16 creates a dosemu-compatible hdimage with MBR + FAT16 partition
    mkfatimage16 -l MSDOS4 -k "$SIZE_KB" -f "$TMPDIR/target.img" -p

    # mkfatimage16 leaves the partition status as 0x00 (inactive).
    # Patch it to 0x80 (active/bootable) so DOS can boot from it.
    # The partition table entry starts at offset 574 (128-byte dosemu header + 446).
    printf '\x80' | dd of="$TMPDIR/target.img" bs=1 seek=574 count=1 conv=notrunc 2>/dev/null
fi

# --- Phase 3: Run dosemu to transfer system and files ---

echo "Running dosemu to install DOS onto image..."

# Minimal staging CONFIG.SYS for the dosemu boot environment.
# For HD images, the real CONFIG.SYS is saved as REAL_CF.SYS.
if ! $FLOPPY; then
    mv "$STAGING/CONFIG.SYS" "$STAGING/REAL_CF.SYS"
fi
printf 'FILES=40\r\n' > "$STAGING/CONFIG.SYS"
printf 'BUFFERS=30\r\n' >> "$STAGING/CONFIG.SYS"
printf 'SHELL=C:\\COMMAND.COM /E:2048 /P\r\n' >> "$STAGING/CONFIG.SYS"

# AUTOEXEC.BAT must have DOS line endings (\r\n)
printf '@ECHO OFF\r\n' > "$STAGING/AUTOEXEC.BAT"
printf 'PATH C:\\DOS\r\n' >> "$STAGING/AUTOEXEC.BAT"

if $FLOPPY; then
    # Floppy: just SYS to A:
    printf 'ECHO Transferring system to A: ...\r\n' >> "$STAGING/AUTOEXEC.BAT"
    printf 'SYS C: A:\r\n' >> "$STAGING/AUTOEXEC.BAT"
    printf 'ECHO Done! Floppy image is ready.\r\n' >> "$STAGING/AUTOEXEC.BAT"
else
    # Hard disk: SYS + copy all files to D:
    printf 'ECHO Transferring system to D: ...\r\n' >> "$STAGING/AUTOEXEC.BAT"
    printf 'SYS C: D:\r\n' >> "$STAGING/AUTOEXEC.BAT"
    printf 'MD D:\\DOS\r\n' >> "$STAGING/AUTOEXEC.BAT"
    printf 'ECHO Copying DOS utilities...\r\n' >> "$STAGING/AUTOEXEC.BAT"
    printf 'COPY C:\\DOS\\*.* D:\\DOS > NUL\r\n' >> "$STAGING/AUTOEXEC.BAT"
    printf 'ECHO Copying root files...\r\n' >> "$STAGING/AUTOEXEC.BAT"
    printf 'COPY C:\\REAL_CF.SYS D:\\CONFIG.SYS > NUL\r\n' >> "$STAGING/AUTOEXEC.BAT"
    printf 'COPY C:\\REAL_AE.BAT D:\\AUTOEXEC.BAT > NUL\r\n' >> "$STAGING/AUTOEXEC.BAT"
    printf 'ECHO Setting file attributes...\r\n' >> "$STAGING/AUTOEXEC.BAT"
    printf 'ATTRIB +R +H +S D:\\IO.SYS\r\n' >> "$STAGING/AUTOEXEC.BAT"
    printf 'ATTRIB +R +H +S D:\\MSDOS.SYS\r\n' >> "$STAGING/AUTOEXEC.BAT"
    printf 'ATTRIB +R D:\\COMMAND.COM\r\n' >> "$STAGING/AUTOEXEC.BAT"
    printf 'ECHO Done! Image is ready.\r\n' >> "$STAGING/AUTOEXEC.BAT"
fi
printf 'exitemu\r\n' >> "$STAGING/AUTOEXEC.BAT"

# Create dosemu config
if $FLOPPY; then
    # Staging dir is C: (boot drive), floppy image is A:
    cat > "$TMPDIR/dosemurc" << EOF
\$_hdimage = "$STAGING"
\$_floppy_a = "$TMPDIR/floppy.img:threeinch"
EOF
else
    # Staging dir is C: (boot drive), target image is D:
    cat > "$TMPDIR/dosemurc" << EOF
\$_hdimage = "$STAGING $TMPDIR/target.img"
EOF
fi

# Run dosemu in dumb terminal mode
dosemu -f "$TMPDIR/dosemurc" -dumb -td -kt < /dev/null

# --- Phase 4: Finalize ---

if $FLOPPY; then
    # Floppy image is already raw — just copy it out
    cp "$TMPDIR/floppy.img" "$OUTPUT"

    echo ""
    echo "Success!"
    echo ""
    echo "  Type:     1.44MB boot floppy"
    echo "  Files:    IO.SYS, MSDOS.SYS, COMMAND.COM"
    echo ""
    echo "  $OUTPUT   (raw 1.44MB floppy image)"
    echo ""
    echo "To boot with dosemu:"
    echo "  dosemu -f <(echo '\$_floppy_a = \"$OUTPUT:boot\"')"
    echo ""
    echo "To boot with QEMU:"
    echo "  qemu-system-i386 -fda $OUTPUT"
else
    # The dosemu hdimage format is a raw disk image with a 128-byte header.
    # Output both: the dosemu image as-is, and a raw image with the header stripped
    # for use in QEMU, VirtualBox, bochs, etc.
    cp "$TMPDIR/target.img" "$OUTPUT"

    RAW_OUTPUT="${OUTPUT%.img}.raw.img"
    dd if="$TMPDIR/target.img" of="$RAW_OUTPUT" bs=128 skip=1 2>/dev/null

    NUM_FILES="$(ls "$STAGING/DOS/" | wc -l)"

    echo ""
    echo "Success!"
    echo ""
    echo "  Size:     $(( SIZE_KB / 1024 ))MB"
    echo "  Files:    $NUM_FILES utilities in \\DOS"
    echo ""
    echo "  $OUTPUT         (dosemu hdimage format)"
    echo "  $RAW_OUTPUT     (raw disk image)"
    echo ""
    echo "To boot with dosemu:"
    echo "  dosemu -f <(echo '\$_hdimage = \"$OUTPUT\"')"
    echo ""
    echo "To boot with QEMU:"
    echo "  qemu-system-i386 -hda $RAW_OUTPUT"
fi
