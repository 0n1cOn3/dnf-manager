#!/bin/bash

set -euo pipefail

get_help() {
    cat <<EOF
Usage: sudo $0 [-o <export|import>] [-p <arg...>]

-o  Operation to perform, can either be export or import:
        export - Exports names of installed packages (without version and architecture) to a plain text file.
        import - Imports package names from plain text file and installs the same set of packages removing the ones not in the list.
-p  Relative filepath, file shouldn't exist for export operation and should exist, be readable and not empty for import operation.
EOF
}

export_pkgs() {
    if [ -f "$1" ]; then
        echo "$1 already exists." && exit 1
    fi

    dnf repoquery --installed | sort | grep -oP "(^.+)(?=-[\d]+:.+)" | uniq -i >"$1" && echo "Package list successfully exported to $1."
}

import_pkgs() {
    if ! [ -f "$1" ] || ! [ -r "$1" ] || ! [ -s "$1" ]; then
        echo "File does not exist, is not readable, or is empty." && exit 1
    fi

    local actual
    actual=$(uuidgen)

    export_pkgs "$actual"

    local to_delete
    to_delete=$(comm -23 <(sort "$actual") <(sort "$1"))

    for pkg in $to_delete; do
        dnf remove -y "$pkg"
    done

    rm "$actual"

    local to_install
    to_install=$(comm -13 <(sort "$actual") <(sort "$1"))

    for pkg in $to_install; do
        dnf --setopt=install_weak_deps=False install -y "$pkg"
    done
}

if [ $EUID -ne 0 ]; then
    echo "Root privileges required." && exit 1
fi

while getopts "o:p:" opt; do
    case "$opt" in
    o) operation="$OPTARG" ;;
    p) path="$OPTARG" ;;
    ?) get_help ;;
    esac
done

if [ -z "${operation:-}" ]; then
    get_help
elif [ "$operation" = "export" ]; then
    if [ -e "$path" ]; then
        echo "$path already exists." && exit 1
    fi
    export_pkgs "$path"
elif [ "$operation" = "import" ]; then
    import_pkgs "$path"
else
    echo "Invalid operation." && get_help && exit 1
fi
