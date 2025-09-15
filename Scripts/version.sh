#!/bin/bash

# Source the main build script for functions
source "$(dirname "$0")/remote_build.sh"

# Help message
show_help() {
    cat << EOF
Version Management Tool

Usage: $(basename "$0") <command> [options]

Commands:
    get                     Display current version
    increment <type>        Increment version number
    validate               Validate current version
    set <version>          Set specific version
    compare <v1> <v2>      Compare two versions

Options for increment:
    major                  Increment major version (x.0.0)
    minor                  Increment minor version (0.x.0)
    patch                  Increment patch version (0.0.x)

Examples:
    $(basename "$0") get
    $(basename "$0") increment patch
    $(basename "$0") validate
    $(basename "$0") set 1.2.3
    $(basename "$0") compare 1.0.0 1.1.0
EOF
}

case "$1" in
    get)
        get_version
        ;;
    increment)
        if [ -z "$2" ]; then
            log_error "Please specify increment type (major, minor, or patch)"
            show_help
            exit 1
        fi
        update_version "$2"
        ;;
    validate)
        version=$(get_version)
        if validate_version "$version"; then
            log_success "Version $version is valid"
        else
            exit 1
        fi
        ;;
    set)
        if [ -z "$2" ]; then
            log_error "Please specify version number"
            show_help
            exit 1
        fi
        if validate_version "$2"; then
            echo "$2" > "$VERSION_FILE"
            log_success "Version set to $2"
            update_changelog "$2"
        else
            exit 1
        fi
        ;;
    compare)
        if [ -z "$2" ] || [ -z "$3" ]; then
            log_error "Please specify two versions to compare"
            show_help
            exit 1
        fi
        compare_versions "$2" "$3"
        case $? in
            0) echo "Versions are equal" ;;
            1) echo "$2 is greater than $3" ;;
            2) echo "$2 is less than $3" ;;
        esac
        ;;
    *)
        show_help
        exit 1
        ;;
esac
