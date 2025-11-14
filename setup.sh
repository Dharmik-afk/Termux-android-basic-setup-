#!/data/data/com.termux/files/usr/bin/sh
set -euo pipefail

# setup.sh
# - Runs from the relocated repository (outside Termux $HOME)
# - Offers two modes: replace HOME or merge contents into HOME
# - Optionally backs up existing HOME before destructive actions
# - Installs required packages if missing

# ---- Configuration: edit package list as needed ----
REQUIRED_PACKAGES=(
  "clang"
  "python3"
  "vim"
  "termux-api"
)

# ---- Environment checks ----
if [ -z "${PREFIX:-}" ] || [ ! -d "${PREFIX:-}" ]; then
    echo "❌ This script must be run inside Termux."
    exit 1
fi

TERMUX_HOME="/data/data/com.termux/files/home"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Setup running from: $SCRIPT_DIR"
echo "Termux home:      $TERMUX_HOME"

# ---- Prompts ----
echo "⚠️  This script can DELETE or OVERWRITE files in your Termux HOME."
printf "Delete & replace HOME entirely? (y/N): "
read REPLACE_ANSWER

# Ask about backup (for destructive mode)
CREATE_BACKUP="n"
if [ "$REPLACE_ANSWER" = "y" ] || [ "$REPLACE_ANSWER" = "Y" ]; then
    printf "Create a backup of current HOME before deleting? (Y/n): "
    read bkp
    if [ -z "$bkp" ] || [ "$bkp" = "Y" ] || [ "$bkp" = "y" ]; then
        CREATE_BACKUP="y"
    fi
fi

# ---- Helper functions ----

# Check whether a file/entry is git-related and should be skipped
is_git_related() {
    case "$1" in
        .git|.git/*|.gitignore|.gitattributes|.gitmodules|.github|.github/*)
            return 0 ;;
        *)
            return 1 ;;
    esac
}

# Install a package if it's not already installed
install_if_missing() {
    PKG="$1"
    # pkg list-installed prints lines like "pkg/version". Match start of line.
    if pkg list-installed 2>/dev/null | grep -qE "^${PKG}/"; then
        echo "Package '$PKG' already installed. Skipping."
    else
        echo "Installing package: $PKG"
        pkg install -y "$PKG"
    fi
}

# Copy with optional overwrite prompt
copy_with_prompt() {
    SRC="$1"
    DEST="$2"

    # Skip if git-related
    if is_git_related "$(basename "$SRC")"; then
        echo "⏩ Skipping Git-related item: $SRC"
        return
    fi

    # Skip copying the bootstrap script (optional) - do not copy installer scripts unless user wants
    case "$(basename "$SRC")" in
        bootstrap.sh|setup.sh)
            echo "⏩ Skipping installer script: $SRC"
            return
            ;;
    esac

    if [ -e "$DEST" ]; then
        printf "File exists: %s — overwrite? (y/N): " "$DEST"
        read OW
        if [ "$OW" != "y" ] && [ "$OW" != "Y" ]; then
            echo "⏩ Skipped: $DEST"
            return
        fi
    fi

    mkdir -p "$(dirname "$DEST")"
    cp -a "$SRC" "$DEST"
    echo "✔️ Copied: $SRC → $DEST"
}

timestamp() {
    # fallback to `date` available in Termux
    date +"%Y%m%d_%H%M%S"
}

# ---- MAIN: Replace or Merge ----

if [ "$REPLACE_ANSWER" = "y" ] || [ "$REPLACE_ANSWER" = "Y" ]; then
    # Backup if requested
    if [ "$CREATE_BACKUP" = "y" ]; then
        BACKUP_DIR="${TERMUX_HOME}-backup-$(timestamp)"
        echo "Creating backup at: $BACKUP_DIR"
        # Use rsync-like copy via cp -a to preserve structure; ensure parent exists
        mkdir -p "$(dirname "$BACKUP_DIR")"
        cp -a "$TERMUX_HOME" "$BACKUP_DIR" || {
            echo "⚠️ Backup failed. Aborting to prevent data loss."
            exit 1
        }
        echo "Backup complete."
    fi

    # Remove home (destructive)
    echo "🗑️ Deleting $TERMUX_HOME ..."
    rm -rf "$TERMUX_HOME"

    # Recreate home and copy contents
    echo "📁 Creating fresh HOME at $TERMUX_HOME ..."
    mkdir -p "$TERMUX_HOME"
    echo "📄 Copying repository contents into fresh HOME ..."
    for ITEM in "$SCRIPT_DIR"/.* "$SCRIPT_DIR"/*; do
        NAME="$(basename "$ITEM")"
        [ "$NAME" = "." ] && continue
        [ "$NAME" = ".." ] && continue
        is_git_related "$NAME" && continue

        copy_with_prompt "$ITEM" "$TERMUX_HOME/$NAME"
    done

    echo "✔️ HOME replaced successfully."

else
    echo "📄 Merge mode: copying repository contents into existing HOME ..."
    for ITEM in "$SCRIPT_DIR"/.* "$SCRIPT_DIR"/*; do
        NAME="$(basename "$ITEM")"
        [ "$NAME" = "." ] && continue
        [ "$NAME" = ".." ] && continue
        is_git_related "$NAME" && continue

        copy_with_prompt "$ITEM" "$TERMUX_HOME/$NAME"
    done
    echo "✔️ Merge complete."
fi

# ---- Install packages ----
echo "🔄 Updating package lists..."
pkg update -y || true

echo "📦 Ensuring required packages are installed..."
for PKG in "${REQUIRED_PACKAGES[@]}"; do
    install_if_missing "$PKG"
done

# ---- Optional cleanup of installer files ----
printf "Remove installer scripts (bootstrap.sh and setup.sh) from the repository directory? (y/N): "
read CLEANUP_ANSWER
if [ "$CLEANUP_ANSWER" = "y" ] || [ "$CLEANUP_ANSWER" = "Y" ]; then
    # remove in background after short delay to avoid interfering with running process
    (
        sleep 2
        rm -f "$SCRIPT_DIR/bootstrap.sh" "$SCRIPT_DIR/setup.sh"
    ) &
    echo "Installer scripts scheduled for removal."
fi

echo "🎉 Setup complete!"
echo "➡️ It is recommended to restart Termux for all changes to settle."
