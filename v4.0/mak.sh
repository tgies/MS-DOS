#! /bin/bash

# Public Domain

# Build MS-DOS 4.0
#
# Usage: ./mak.sh [--flavor=msdos|pcdos] [--clean]
#
# Build flavors:
#   msdos  - OEM MS-DOS with IO.SYS/MSDOS.SYS (default)
#   pcdos  - IBM PC-DOS with IBMBIO.COM/IBMDOS.COM

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Default values
FLAVOR="msdos"
DO_CLEAN=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --flavor=*)
            FLAVOR="${1#--flavor=}"
            ;;
        --clean)
            DO_CLEAN=true
            ;;
        -h|--help)
            echo "Usage: $0 [--flavor=msdos|pcdos] [--clean]"
            echo ""
            echo "Build flavors:"
            echo "  msdos  - OEM MS-DOS with IO.SYS/MSDOS.SYS (default)"
            echo "  pcdos  - IBM PC-DOS with IBMBIO.COM/IBMDOS.COM"
            echo ""
            echo "Options:"
            echo "  --clean  Clean build artifacts before building"
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
    esac
    shift
done

# Validate flavor
case "$FLAVOR" in
    msdos|pcdos)
        ;;
    *)
        echo "Error: Invalid flavor '$FLAVOR'. Must be 'msdos' or 'pcdos'." >&2
        exit 1
        ;;
esac

echo "Building DOS 4 ($FLAVOR flavor)..."

# Path to VERSION.INC
VERSION_INC="$SCRIPT_DIR/src/INC/VERSION.INC"

# Backup VERSION.INC
cp "$VERSION_INC" "$VERSION_INC.bak"

# Set IBMCOPYRIGHT based on flavor
# MS-DOS: IBMCOPYRIGHT = FALSE (default in source)
# PC-DOS: IBMCOPYRIGHT = TRUE
if [[ "$FLAVOR" == "pcdos" ]]; then
    echo "Patching VERSION.INC for PC-DOS build..."
    sed -i 's/^IBMCOPYRIGHT EQU[[:space:]]*FALSE/IBMCOPYRIGHT EQU   TRUE/' "$VERSION_INC"
else
    echo "Using default VERSION.INC for MS-DOS build..."
    # Ensure it's set to FALSE (in case it was left in PC-DOS state)
    sed -i 's/^IBMCOPYRIGHT EQU[[:space:]]*TRUE/IBMCOPYRIGHT EQU   FALSE/' "$VERSION_INC"
fi

# Cleanup function to restore VERSION.INC
cleanup() {
    if [[ -f "$VERSION_INC.bak" ]]; then
        mv "$VERSION_INC.bak" "$VERSION_INC"
    fi
}
trap cleanup EXIT

# Run the build
[[ -z "$DOSEMU" ]] && DOSEMU=dosemu

if [[ "$DO_CLEAN" == "true" ]]; then
    echo "Cleaning build artifacts..."
    # Clean .obj files except in TOOLS (contains checked-in build tools)
    # and SELECT/bootrec.obj (copied from FDISK; DOS copy command unreliable via LREDIR)
    find "$SCRIPT_DIR/src" -type f -name "*.obj" \
        -not -path "*/TOOLS/*" \
        -not -path "*/SELECT/bootrec.obj" -delete
    # Clean generated binaries, but exclude TOOLS and LIB directories
    # (they contain checked-in build tools like NMAKE.EXE, LIB.EXE)
    find "$SCRIPT_DIR/src" -type f \( \
        -name "*.exe" -o -name "*.com" -o -name "*.sys" -o -name "*.bin" \
    \) -not -path "*/TOOLS/*" -not -path "*/LIB/*" -not -path "*/DEV/*" -delete
    # Clean output files in script directory
    rm -f "$SCRIPT_DIR"/*.sys "$SCRIPT_DIR"/*.com "$SCRIPT_DIR"/*.exe \
          "$SCRIPT_DIR"/*.cpi "$SCRIPT_DIR"/*.pro 2>/dev/null || true
    echo "  Cleaned."
fi

# TERM=dumb prevents dosemu from enabling xterm mouse tracking
# (it checks terminfo for "Km" capability which dumb lacks)
TERM=dumb "$DOSEMU" -dumb -td -kt < /dev/null -K "$PWD" -E "mak.bat"

# Post-build: rename system files for PC-DOS flavor
# (CPY.BAT always outputs io.sys/msdos.sys - we rename here to avoid modifying source)
if [[ "$FLAVOR" == "pcdos" ]]; then
    echo "Renaming system files for PC-DOS..."
    if [[ -f "$SCRIPT_DIR/io.sys" ]]; then
        mv "$SCRIPT_DIR/io.sys" "$SCRIPT_DIR/ibmbio.com"
    fi
    if [[ -f "$SCRIPT_DIR/msdos.sys" ]]; then
        mv "$SCRIPT_DIR/msdos.sys" "$SCRIPT_DIR/ibmdos.com"
    fi
fi

echo ""
echo "Build complete ($FLAVOR flavor)."
