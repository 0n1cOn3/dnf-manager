#!/bin/bash

# Exit immediately if any command fails, an unset variable is used, or a command in a pipeline fails.
set -euo pipefail

# Check if the script is running with root privileges.
if [ $EUID -ne 0 ]; then
    echo "Root privileges required." && exit 1
fi

# Function to display the script's usage information.
get_help() {
    cat <<EOF
Usage: sudo $0 [-o <export|import>] [-p <file_path>]

-o  Operation to perform, can be either export or import:
        export - Exports names of installed packages to a plain text file.
        import - Imports package names from a file and installs/removes packages accordingly.
-p  Relative file path. For export, the file shouldn't exist. For import, it should exist, be readable, and not empty.
EOF
}

# Function to export a list of installed package names to a file.
export_pkgs() {
    if [ -f "$1" ]; then
        echo "$1 already exists." && exit 1
    fi

    dnf repoquery --installed | sort | grep -oP "(^.+)(?=-[\d]+:.+)" | uniq -i > "$1" && echo "Package list successfully exported to $1."
}

# Function to import and check packages from a file, installing/removing as needed.
import_and_check_pkgs() {
    if [ -f "$1" ] && [ -r "$1" ] && [ -s "$1" ]; then
        local actual
        actual=$(uuidgen)

        dnf repoquery --installed | sort | grep -oP "(^.+)(?=-[\d]+:.+)" | uniq -i > "$actual"

        local to_install=()
        local to_remove=()
        while read -r pkg; do
            if ! grep -q "^$pkg$" "$actual"; then
                echo "Package $pkg is not installed."
                read -r -p "Do you want to install it? [Y/n] " answer
                case "$answer" in
                    [yY]|[yY][eE][sS]) to_install+=("$pkg") ;;
                    [nN]|[nN][oO]) to_remove+=("$pkg") ;;
                    *) to_install+=("$pkg") ;;
                esac
            fi
        done < "$1"

        if [ "${#to_remove[@]}" -gt 0 ]; then
            echo "The following packages are installed on the system but not present in the list:"
            printf '%s\n' "${to_remove[@]}"
            read -r -p "Do you want to remove them? [Y/n] " answer
            if [[ "$answer" =~ ^[yY]|[yY][eE][sS]$ ]]; then
                for pkg in "${to_remove[@]}"; do
                    dnf remove -y "$pkg"
                done
            fi
        fi

        if [ "${#to_install[@]}" -gt 0 ]; then
            echo "The following packages are not installed on the system:"
            printf '%s\n' "${to_install[@]}"
            read -r -p "Do you want to install them? [Y/n] " answer
            if [[ "$answer" =~ ^[yY]|[yY][eE][sS]$ ]]; then
                for pkg in "${to_install[@]}"; do
                    dnf --setopt=install_weak_deps=False install -y "$pkg"
                done
            fi
        else
            echo "The system is already in sync with the list."
        fi

        rm "$actual"
    else
        echo "File does not exist, is not readable, or is empty." && exit 1
    fi
}

# Check if the script is running with root privileges.
if [ $EUID -ne 0 ]; then
    echo "Root privileges required." && exit 1
fi

# Parse command-line options
while getopts "o:p:" opt; do
    case "$opt" in
    o) operation="$OPTARG" ;;
    p) path="$OPTARG" ;;
    ?) get_help ;;
    esac
done

# Perform the requested operation based on the provided arguments.
if [ -z "${operation:-}" ]; then
    get_help
elif [ "$operation" = "export" ]; then
    if [ -e "$path" ]; then
        echo "$path already exists." && exit 1
    fi
    export_pkgs "$path"
elif [ "$operation" = "import" ]; then
    import_and_check_pkgs "$path"
else
    echo "Invalid operation." && get_help && exit 1
fi

# Parse command-line options
while getopts "o:p:" opt; do
    case "$opt" in
    o) operation="$OPTARG" ;;
    p) path="$OPTARG" ;;
    ?) get_help ;;
    esac
done

# Perform the requested operation based on the provided arguments.
if [ -z "${operation:-}" ]; then
    get_help
elif [ "$operation" = "export" ]; then
    if [ -e "$path" ]; then
        echo "$path already exists." && exit 1
    fi
    export_pkgs "$path"
elif [ "$operation" = "import" ]; then
    import_and_check_pkgs "$path"
else
    echo "Invalid operation." && get_help && exit 1
fi
