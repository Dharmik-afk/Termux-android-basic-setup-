#!/data/data/com.termux/files/usr/bin/sh
set -e

# bootstrap.sh
# Moves the current repository to TARGET_DIR inside Termux internal storage
# and then execs the relocated setup.sh so $SCRIPT_DIR is correct.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TERMUX_DATA="/data/data/com.termux/files"
TARGET_DIR="$TERMUX_DATA/termux_setup_repo"   # change this if you want a different target

echo "Repository (bootstrap) located at: $SCRIPT_DIR"
echo "Target location: $TARGET_DIR"

# Confirm with user before moving (safety)
printf "Move repository to Termux internal storage and run installer there? (y/N): "
read REPLY
if [ "$REPLY" != "y" ] && [ "$REPLY" != "Y" ]; then
    echo "Aborted by user."
    exit 0
fi

# Clean any previous target safe copy
if [ -d "$TARGET_DIR" ]; then
    echo "Removing existing target directory: $TARGET_DIR"
    rm -rf "$TARGET_DIR"
fi

# Attempt to move repository into the target location
echo "Moving repository..."
mv "$SCRIPT_DIR" "$TARGET_DIR"

if [ ! -d "$TARGET_DIR" ]; then
    echo "❌ Move failed. Aborting."
    exit 1
fi

# Exec the relocated setup script (replaces current process)
if [ -x "$TARGET_DIR/setup.sh" ]; then
    echo "Launching setup from relocated repository..."
    exec "$TARGET_DIR/setup.sh"
else
    echo "❌ setup.sh not found or not executable in $TARGET_DIR"
    exit 1
fi
