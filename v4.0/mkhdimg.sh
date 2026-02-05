#!/bin/bash
#
# mkhdimg.sh - Create bootable MS-DOS 4 disk images
#
# Produces bootable disk images from the compiled binaries in this directory.
#
# Image types:
#   (default)        FAT16 hard disk image (bootable in QEMU, dosemu, VirtualBox)
#   --floppy         Minimal 1.44MB FAT12 boot floppy (system files only)
#   --floppy=SIZE    Floppy of specified size (360, 720, 1200, 1440)
#   --floppy-full    Include utilities that fit on the floppy
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
FLOPPY_SIZE=1440  # KB (options: 360, 720, 1200, 1440)
FLOPPY_FULL=false

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  --floppy[=SIZE]  Create a boot floppy (default: 1440KB)
                   SIZE can be: 360, 720, 1200, 1440
  --floppy-full    Include utilities that fit (default: system files only)
  -o FILE          Output image file (default: dos4.img or dos4-boot.img)
  --size SIZE      Hard disk size in MB (default: 64, ignored for --floppy)
  -h, --help       Show this help

Floppy sizes:
  360KB   5.25" DD - System + essential utilities only
  720KB   3.5" DD  - System + most utilities
  1200KB  5.25" HD - System + all utilities
  1440KB  3.5" HD  - System + all utilities (default)

The binaries must be present in this directory (run the build first).
Requires: dosemu2, mtools, mkfatimage16
EOF
    exit "${1:-0}"
}

# Parse arguments
while [ $# -gt 0 ]; do
    case "$1" in
        --floppy)
            FLOPPY=true
            shift
            ;;
        --floppy=*)
            FLOPPY=true
            FLOPPY_SIZE="${1#--floppy=}"
            case "$FLOPPY_SIZE" in
                360|720|1200|1440) ;;
                *) echo "Error: Invalid floppy size: $FLOPPY_SIZE (use 360, 720, 1200, 1440)" >&2; exit 1 ;;
            esac
            shift
            ;;
        --floppy-full)
            FLOPPY_FULL=true
            shift
            ;;
        -o)
            OUTPUT="$2"
            shift 2
            ;;
        --size)
            SIZE_KB=$(( $2 * 1024 ))
            shift 2
            ;;
        -h|--help)
            usage 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage 1
            ;;
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
    REQUIRED_CMDS="dosemu mformat mcopy"
else
    REQUIRED_CMDS="dosemu mkfatimage16"
fi
for cmd in $REQUIRED_CMDS; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Error: $cmd not found. Install dosemu2 and mtools." >&2
        exit 1
    fi
done

# Calculate floppy capacity and format parameters
if $FLOPPY; then
    case "$FLOPPY_SIZE" in
        360)
            FLOPPY_SECTORS=720      # 360KB / 512 bytes
            FLOPPY_DESC="360KB (5.25\" DD)"
            FLOPPY_CAPACITY=368640  # Usable bytes (approx)
            MFORMAT_OPTS="-f 360"
            ;;
        720)
            FLOPPY_SECTORS=1440     # 720KB / 512 bytes
            FLOPPY_DESC="720KB (3.5\" DD)"
            FLOPPY_CAPACITY=737280
            MFORMAT_OPTS="-f 720"
            ;;
        1200)
            FLOPPY_SECTORS=2400     # 1.2MB / 512 bytes
            FLOPPY_DESC="1.2MB (5.25\" HD)"
            FLOPPY_CAPACITY=1228800
            MFORMAT_OPTS="-f 1200"
            ;;
        1440)
            FLOPPY_SECTORS=2880     # 1.44MB / 512 bytes
            FLOPPY_DESC="1.44MB (3.5\" HD)"
            FLOPPY_CAPACITY=1474560
            MFORMAT_OPTS="-f 1440"
            ;;
    esac
fi

if $FLOPPY; then
    echo "Creating MS-DOS 4 boot floppy image..."
    echo "  Output: $OUTPUT"
    echo "  Size:   $FLOPPY_DESC"
    if $FLOPPY_FULL; then
        echo "  Mode:   Full (utilities included)"
    else
        echo "  Mode:   Minimal (system files only)"
    fi
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

# Define utility tiers for floppy images (in priority order)
# Tier 1: Essential - must have on any bootable disk
TIER1_COM="format sys"
TIER1_EXE="fdisk"

# Tier 2: Important utilities
TIER2_COM="debug chkdsk edlin mode"
TIER2_EXE="attrib xcopy"

# Tier 3: Additional utilities
TIER3_COM="comp diskcopy diskcomp more print recover tree label assign backup restore graphics graftabl keyb"
TIER3_EXE="fc find sort mem append fastopen replace share subst join"

# Tier 4: Drivers (less critical for boot floppy)
TIER4_SYS="ansi display driver keyboard"
TIER4_CPI="ega"

# Tier 5: Large/optional files
# Note: SELECT installer not available (depends on unreleased DOS Shell source)
TIER5_EXE="filesys nlsfunc exe2bin"
TIER5_SYS="country printer smartdrv ramdrive xma2ems xmaem emm386"
TIER5_CPI="lcd 4201 4208 5202"

# Function to calculate size of files to copy
calculate_staged_size() {
    local total=0
    local f
    for f in "$STAGING"/* "$STAGING/DOS"/*; do
        [ -f "$f" ] && total=$((total + $(stat -c%s "$f")))
    done
    echo "$total"
}

# Function to try copying a file if it exists and fits
try_copy_file() {
    local src="$1"
    local dst="$2"
    local capacity="$3"

    if [ ! -f "$src" ]; then
        return 1
    fi

    local filesize=$(stat -c%s "$src")
    local current_size=$(calculate_staged_size)
    local projected=$((current_size + filesize))

    # Leave 10KB buffer for filesystem overhead
    if [ $projected -lt $((capacity - 10240)) ]; then
        cp "$src" "$dst"
        return 0
    fi
    return 1
}

if $FLOPPY; then
    # Always copy SYS.COM for the dosemu staging boot
    cp "$SCRIPT_DIR/sys.com" "$STAGING/DOS/SYS.COM"

    if $FLOPPY_FULL; then
        echo "Selecting utilities for ${FLOPPY_SIZE}KB floppy..."

        # Tier 1: Essential (always try to include)
        for f in $TIER1_COM; do
            try_copy_file "$SCRIPT_DIR/$f.com" "$STAGING/DOS/$(echo $f | tr 'a-z' 'A-Z').COM" "$FLOPPY_CAPACITY" || true
        done
        for f in $TIER1_EXE; do
            try_copy_file "$SCRIPT_DIR/$f.exe" "$STAGING/DOS/$(echo $f | tr 'a-z' 'A-Z').EXE" "$FLOPPY_CAPACITY" || true
        done

        # Tier 2: Important
        for f in $TIER2_COM; do
            try_copy_file "$SCRIPT_DIR/$f.com" "$STAGING/DOS/$(echo $f | tr 'a-z' 'A-Z').COM" "$FLOPPY_CAPACITY" || true
        done
        for f in $TIER2_EXE; do
            try_copy_file "$SCRIPT_DIR/$f.exe" "$STAGING/DOS/$(echo $f | tr 'a-z' 'A-Z').EXE" "$FLOPPY_CAPACITY" || true
        done

        # Tier 3: Additional (skip on 360KB to leave room)
        if [ "$FLOPPY_SIZE" -ge 720 ]; then
            for f in $TIER3_COM; do
                try_copy_file "$SCRIPT_DIR/$f.com" "$STAGING/DOS/$(echo $f | tr 'a-z' 'A-Z').COM" "$FLOPPY_CAPACITY" || true
            done
            for f in $TIER3_EXE; do
                try_copy_file "$SCRIPT_DIR/$f.exe" "$STAGING/DOS/$(echo $f | tr 'a-z' 'A-Z').EXE" "$FLOPPY_CAPACITY" || true
            done
        fi

        # Tier 4: Drivers (720KB+)
        if [ "$FLOPPY_SIZE" -ge 720 ]; then
            for f in $TIER4_SYS; do
                try_copy_file "$SCRIPT_DIR/$f.sys" "$STAGING/DOS/$(echo $f | tr 'a-z' 'A-Z').SYS" "$FLOPPY_CAPACITY" || true
            done
            for f in $TIER4_CPI; do
                try_copy_file "$SCRIPT_DIR/$f.cpi" "$STAGING/DOS/$(echo $f | tr 'a-z' 'A-Z').CPI" "$FLOPPY_CAPACITY" || true
            done
        fi

        # Tier 5: Large/optional (1.2MB+)
        if [ "$FLOPPY_SIZE" -ge 1200 ]; then
            for f in $TIER5_EXE; do
                try_copy_file "$SCRIPT_DIR/$f.exe" "$STAGING/DOS/$(echo $f | tr 'a-z' 'A-Z').EXE" "$FLOPPY_CAPACITY" || true
            done
            for f in $TIER5_SYS; do
                try_copy_file "$SCRIPT_DIR/$f.sys" "$STAGING/DOS/$(echo $f | tr 'a-z' 'A-Z').SYS" "$FLOPPY_CAPACITY" || true
            done
            for f in $TIER5_CPI; do
                try_copy_file "$SCRIPT_DIR/$f.cpi" "$STAGING/DOS/$(echo $f | tr 'a-z' 'A-Z').CPI" "$FLOPPY_CAPACITY" || true
            done
        fi

        # Add helper files if there's room
        try_copy_file "$SCRIPT_DIR/graphics.pro" "$STAGING/DOS/GRAPHICS.PRO" "$FLOPPY_CAPACITY" || true

        UTIL_COUNT=$(($(ls "$STAGING/DOS/" 2>/dev/null | wc -l) - 1))  # -1 for SYS.COM which is always there
        STAGED_SIZE=$(calculate_staged_size)
        echo "  Selected $UTIL_COUNT utilities ($(( STAGED_SIZE / 1024 ))KB staged)"
    fi
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
    # Create a blank floppy image and format as FAT12
    dd if=/dev/zero of="$TMPDIR/floppy.img" bs=512 count="$FLOPPY_SECTORS" 2>/dev/null
    mformat $MFORMAT_OPTS -v MSDOS4 -i "$TMPDIR/floppy.img" ::
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
    # Floppy: SYS + copy COMMAND.COM + utilities to A:
    printf 'ECHO Transferring system to A: ...\r\n' >> "$STAGING/AUTOEXEC.BAT"
    printf 'SYS C: A:\r\n' >> "$STAGING/AUTOEXEC.BAT"
    printf 'COPY C:\\COMMAND.COM A:\\ > NUL\r\n' >> "$STAGING/AUTOEXEC.BAT"

    if $FLOPPY_FULL; then
        # Copy utilities to floppy (they're in STAGING/DOS)
        # Count how many we have (excluding SYS.COM which stays on staging drive)
        UTIL_COUNT=$(($(ls "$STAGING/DOS/" 2>/dev/null | wc -l) - 1))
        if [ "$UTIL_COUNT" -gt 0 ]; then
            printf 'ECHO Copying utilities...\r\n' >> "$STAGING/AUTOEXEC.BAT"
            printf 'MD A:\\DOS\r\n' >> "$STAGING/AUTOEXEC.BAT"
            # Copy everything except SYS.COM (needed by staging, not target)
            for f in "$STAGING/DOS/"*; do
                fname=$(basename "$f")
                if [ "$fname" != "SYS.COM" ]; then
                    printf 'COPY C:\\DOS\\%s A:\\DOS > NUL\r\n' "$fname" >> "$STAGING/AUTOEXEC.BAT"
                fi
            done
        fi
    fi

    printf 'ECHO Done! Floppy image is ready.\r\n' >> "$STAGING/AUTOEXEC.BAT"
else
    # Hard disk: SYS + copy all files to D:
    printf 'ECHO Transferring system to D: ...\r\n' >> "$STAGING/AUTOEXEC.BAT"
    printf 'SYS C: D:\r\n' >> "$STAGING/AUTOEXEC.BAT"
    printf 'COPY C:\\COMMAND.COM D:\\ > NUL\r\n' >> "$STAGING/AUTOEXEC.BAT"
    printf 'MD D:\\DOS\r\n' >> "$STAGING/AUTOEXEC.BAT"
    printf 'ECHO Copying DOS utilities...\r\n' >> "$STAGING/AUTOEXEC.BAT"
    printf 'COPY C:\\DOS\\*.* D:\\DOS > NUL\r\n' >> "$STAGING/AUTOEXEC.BAT"
    printf 'ECHO Copying root files...\r\n' >> "$STAGING/AUTOEXEC.BAT"
    printf 'COPY C:\\REAL_CF.SYS D:\\CONFIG.SYS > NUL\r\n' >> "$STAGING/AUTOEXEC.BAT"
    printf 'COPY C:\\REAL_AE.BAT D:\\AUTOEXEC.BAT > NUL\r\n' >> "$STAGING/AUTOEXEC.BAT"
    # DOS 4 ATTRIB only supports +R/-R and +A/-A (no +H/+S)
    # System/hidden attributes are set by SYS command anyway
    printf 'ECHO Setting file attributes...\r\n' >> "$STAGING/AUTOEXEC.BAT"
    printf 'ATTRIB +R D:\\IO.SYS\r\n' >> "$STAGING/AUTOEXEC.BAT"
    printf 'ATTRIB +R D:\\MSDOS.SYS\r\n' >> "$STAGING/AUTOEXEC.BAT"
    printf 'ATTRIB +R D:\\COMMAND.COM\r\n' >> "$STAGING/AUTOEXEC.BAT"
    printf 'ECHO Done! Image is ready.\r\n' >> "$STAGING/AUTOEXEC.BAT"
fi
printf 'exitemu\r\n' >> "$STAGING/AUTOEXEC.BAT"

# Create dosemu config
if $FLOPPY; then
    # Staging dir is C: (boot drive), floppy image is A:
    # Determine floppy type for dosemu
    case "$FLOPPY_SIZE" in
        360)  FLOPPY_TYPE="fiveinch" ;;
        720)  FLOPPY_TYPE="threeinch" ;;
        1200) FLOPPY_TYPE="fiveinch" ;;
        1440) FLOPPY_TYPE="threeinch" ;;
    esac
    cat > "$TMPDIR/dosemurc" << EOF
\$_hdimage = "$STAGING"
\$_floppy_a = "$TMPDIR/floppy.img:$FLOPPY_TYPE"
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
    echo "  Type:     $FLOPPY_DESC boot floppy"
    if $FLOPPY_FULL; then
        FINAL_UTIL_COUNT=$(($(ls "$STAGING/DOS/" 2>/dev/null | wc -l) - 1))
        echo "  Files:    IO.SYS, MSDOS.SYS, COMMAND.COM + $FINAL_UTIL_COUNT utilities"
    else
        echo "  Files:    IO.SYS, MSDOS.SYS, COMMAND.COM"
    fi
    echo ""
    echo "  $OUTPUT"
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
