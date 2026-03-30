#!/data/data/com.termux/files/usr/bin/bash
# Quick-Install Menu for Stacks

INSTALL_DIR="$HOME/TermuxServerX"
STACKSCRIPT="$INSTALL_DIR/scripts/stacks/install-stack.sh"

if [ ! -f "$STACKSCRIPT" ]; then
    echo "Stack script not found. Please run full installer first."
    exit 1
fi

bash "$STACKSCRIPT"
