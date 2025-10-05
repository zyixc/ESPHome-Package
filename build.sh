#!/bin/sh

# Configuration
ENV_NAME=".venv"
REQUIREMENTS_FILE="requirements.txt"

# --- Check for Python ---
if ! command -v python3 --version > /dev/null 2>&1; then
    echo "Error: python3 could not be found."
    echo "Please install Python 3 and try again."
    exit 1
fi

# Check if the virtual environment directory exists
if [ ! -d "$ENV_NAME" ]; then
    echo "Creating virtual environment '$ENV_NAME'..."
    # Use python3 to create the virtual environment
    python3 -m venv "$ENV_NAME"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to create virtual environment."
        exit 1
    fi
fi

# Check for and use the correct activation script
if [ -f "$ENV_NAME/bin/activate" ]; then
    ACTIVATE_SCRIPT="$ENV_NAME/bin/activate"
else
    echo "Error: Could not find environment activation script."
    exit 1
fi

. "$ACTIVATE_SCRIPT"
echo "Activated virtual environment."

# Check if requirements file exists
if [ ! -f "$REQUIREMENTS_FILE" ]; then
    echo "Warning: '$REQUIREMENTS_FILE' not found."
    echo "Creating an empty requirements file and skipping pip install."
    touch "$REQUIREMENTS_FILE"
else
    pip install -r "$REQUIREMENTS_FILE"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to install dependencies."
        deactivate
        exit 1
    fi
fi

# Build using esphome
esphome run $1

# Deactive local python env
deactivate
