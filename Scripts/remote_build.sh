#!/bin/bash
set -eo pipefail

# Color output helpers
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Version control settings
VERSION_FILE="VERSION"
DEFAULT_VERSION="1.0.0"
BUILD_METADATA_FILE=".build-metadata"
VERSION_REGEX="^([0-9]+)\.([0-9]+)\.([0-9]+)(-([0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*))?(+([0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*))?$"

validate_version() {
    local version=$1
    if ! [[ $version =~ $VERSION_REGEX ]]; then
        log_error "Invalid version format: $version"
        log_error "Version must follow semantic versioning (MAJOR.MINOR.PATCH)"
        return 1
    fi
    return 0
}

get_version() {
    local version
    if [ -f "$VERSION_FILE" ]; then
        version=$(cat "$VERSION_FILE")
        if ! validate_version "$version"; then
            log_error "Invalid version in $VERSION_FILE"
            exit 1
        fi
    else
        version="$DEFAULT_VERSION"
    fi
    echo "$version"
}

increment_version() {
    local version=$1
    local increment_type=$2  # major, minor, or patch
    
    if ! validate_version "$version"; then
        return 1
    fi
    
    local major minor patch
    IFS='.' read -r major minor patch <<< "$version"
    
    case $increment_type in
        major)
            major=$((major + 1))
            minor=0
            patch=0
            ;;
        minor)
            minor=$((minor + 1))
            patch=0
            ;;
        patch)
            patch=$((patch + 1))
            ;;
        *)
            log_error "Invalid increment type: $increment_type (use major, minor, or patch)"
            return 1
            ;;
    esac
    
    echo "${major}.${minor}.${patch}"
}

update_version() {
    local increment_type=$1
    local current_version=$(get_version)
    local new_version=$(increment_version "$current_version" "$increment_type")
    
    if [ $? -eq 0 ]; then
        echo "$new_version" > "$VERSION_FILE"
        log_info "Version updated: $current_version -> $new_version"
        
        # Update git tag
        git tag -a "v$new_version" -m "Release version $new_version"
        log_info "Git tag created: v$new_version"
        
        # Update changelog
        update_changelog "$new_version"
    else
        log_error "Failed to update version"
        return 1
    fi
}

compare_versions() {
    local version1=$1
    local version2=$2
    
    if ! validate_version "$version1" || ! validate_version "$version2"; then
        return 1
    }
    
    local IFS=.
    local i ver1=($version1) ver2=($version2)
    
    # Fill empty positions with zeros
    for ((i=${#ver1[@]}; i<3; i++)); do
        ver1[i]=0
    done
    for ((i=${#ver2[@]}; i<3; i++)); do
        ver2[i]=0
    done
    
    for ((i=0; i<3; i++)); do
        if [[ -z ${ver1[i]} ]]; then
            ver1[i]=0
        fi
        if [[ -z ${ver2[i]} ]]; then
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]})); then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]})); then
            return 2
        fi
    done
    return 0
}

update_changelog() {
    local version=$1
    local date=$(date +%Y-%m-%d)
    local changelog_file="CHANGELOG.md"
    local temp_file=$(mktemp)
    
    # Create new version entry
    cat > "$temp_file" << EOF
# Changelog

## [$version] - $date
### Added
- 

### Changed
- 

### Deprecated
- 

### Removed
- 

### Fixed
- 

### Security
- 

EOF
    
    # Append existing changelog if it exists
    if [ -f "$changelog_file" ]; then
        sed '1,2d' "$changelog_file" >> "$temp_file"
    fi
    
    mv "$temp_file" "$changelog_file"
    log_info "Changelog updated for version $version"
}

get_build_number() {
    git rev-list HEAD --count
}

get_git_hash() {
    git rev-parse --short HEAD
}

get_branch_name() {
    git rev-parse --abbrev-ref HEAD
}

generate_build_identifier() {
    local version=$(get_version)
    local build_num=$(get_build_number)
    local git_hash=$(get_git_hash)
    local branch=$(get_branch_name)
    local timestamp=$(date +%Y%m%d_%H%M%S)
    
    echo "${version}+${build_num}.${branch}.${git_hash}.${timestamp}"
}

save_build_metadata() {
    local build_id=$1
    cat > "$BUILD_METADATA_FILE" << EOF
BUILD_ID=${build_id}
VERSION=$(get_version)
BUILD_NUMBER=$(get_build_number)
GIT_HASH=$(get_git_hash)
BRANCH=$(get_branch_name)
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
BUILD_USER=$(whoami)
BUILD_HOST=$(hostname)
EOF
}

# Retry settings
MAX_RETRIES=3
RETRY_DELAY=5

# Cleanup state tracking
SYNC_COMPLETE=false
BUILD_STARTED=false
ARTIFACTS_RETRIEVED=false

# Logging helpers
log_error() { echo -e "${RED}ERROR: $1${NC}" >&2; }
log_warning() { echo -e "${YELLOW}WARNING: $1${NC}" >&2; }
log_success() { echo -e "${GREEN}$1${NC}"; }
log_info() { echo "$1"; }

# Cleanup handler
cleanup() {
    local exit_code=$?
    log_info "Performing cleanup..."

    if [ "$BUILD_STARTED" = true ]; then
        log_info "Stopping any running builds..."
        ssh "$REMOTE_MAC" "pkill -f 'xcodebuild.*$SCHEME' || true" 2>/dev/null || true
    fi

    if [ "$SYNC_COMPLETE" = true ]; then
        log_info "Cleaning up remote directory..."
        ssh "$REMOTE_MAC" "rm -rf $REMOTE_PATH/DerivedData" 2>/dev/null || true
    fi

    # Remove local temporary files
    rm -f ./*.log 2>/dev/null || true

    if [ $exit_code -ne 0 ]; then
        log_error "Build failed with exit code $exit_code"
    fi

    exit $exit_code
}

# Error handler
handle_error() {
    local line_no=$1
    local error_code=$2
    log_error "Script failed at line $line_no with exit code $error_code"
    cleanup
}

# Retry logic for network operations
retry_command() {
    local cmd=$1
    local description=$2
    local attempts=0

    while [ $attempts -lt $MAX_RETRIES ]; do
        if eval "$cmd"; then
            return 0
        fi
        
        attempts=$((attempts + 1))
        if [ $attempts -lt $MAX_RETRIES ]; then
            log_warning "$description failed, attempt $attempts of $MAX_RETRIES. Retrying in ${RETRY_DELAY}s..."
            sleep $RETRY_DELAY
        fi
    done

    log_error "$description failed after $MAX_RETRIES attempts"
    return 1
}

trap 'handle_error ${LINENO} $?' ERR
trap cleanup EXIT INT TERM

# Validate environment and dependencies
validate_environment() {
    local missing_deps=()
    
    # Check required commands
    for cmd in rsync ssh xcodebuild git; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_deps+=("$cmd")
        fi
    done
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        log_error "Missing required dependencies: ${missing_deps[*]}"
        exit 1
    fi

    # Validate git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_error "Not in a git repository"
        exit 1
    fi
}

# Configuration with validation
validate_configuration() {
    REMOTE_MAC="${BUILD_SERVER:-user@mac-mini.local}"
    PROJECT_PATH="${PROJECT_ROOT:-$(git rev-parse --show-toplevel)}"
    REMOTE_PATH="${REMOTE_PROJECT_PATH:-~/Projects/AudioMaster}"
    BUILD_CONFIG="${BUILD_CONFIGURATION:-Debug}"
    SCHEME="${XCODE_SCHEME:-AudioMaster}"
    
    # Required disk space in GB
    REQUIRED_SPACE=20
    
    # Validate remote connection
    if ! ssh -q "$REMOTE_MAC" exit; then
        log_error "Cannot connect to build server: $REMOTE_MAC"
        exit 1
    }

    # Check remote disk space
    log_info "Checking remote disk space..."
    REMOTE_SPACE=$(ssh "$REMOTE_MAC" "df -BG \$(dirname \$(eval echo $REMOTE_PATH)) | tail -1 | awk '{print \$4}' | sed 's/G//'")
    if ! [[ "$REMOTE_SPACE" =~ ^[0-9]+$ ]]; then
        log_error "Failed to determine available disk space on remote server"
        exit 1
    fi
    
    if [ "$REMOTE_SPACE" -lt "$REQUIRED_SPACE" ]; then
        log_error "Insufficient disk space on remote server. Available: ${REMOTE_SPACE}GB, Required: ${REQUIRED_SPACE}GB"
        exit 1
    fi
    log_info "Remote disk space check passed (${REMOTE_SPACE}GB available)"

    # Check local disk space for artifacts
    log_info "Checking local disk space..."
    LOCAL_SPACE=$(df -BG "$(dirname "$PROJECT_PATH")" | tail -1 | awk '{print $4}' | sed 's/G//')
    if ! [[ "$LOCAL_SPACE" =~ ^[0-9]+$ ]]; then
        log_error "Failed to determine available local disk space"
        exit 1
    fi
    
    if [ "$LOCAL_SPACE" -lt "$REQUIRED_SPACE" ]; then
        log_error "Insufficient local disk space. Available: ${LOCAL_SPACE}GB, Required: ${REQUIRED_SPACE}GB"
        exit 1
    }
    log_info "Local disk space check passed (${LOCAL_SPACE}GB available)"

    # Validate project path
    if [ ! -d "$PROJECT_PATH" ]; then
        log_error "Project directory not found: $PROJECT_PATH"
        exit 1
    }

    # Validate Xcode project existence
    if [ ! -f "$PROJECT_PATH/AudioMaster.xcodeproj/project.pbxproj" ]; then
        log_error "Xcode project not found in $PROJECT_PATH"
        exit 1
    }

    # Estimate project size
    PROJECT_SIZE=$(du -sh "$PROJECT_PATH" | awk '{print $1}')
    log_info "Project size: $PROJECT_SIZE"

    log_info "Configuration validated successfully"
}

# Initialize
validate_environment
validate_configuration

# Generate build identifier and save metadata
BUILD_ID=$(generate_build_identifier)
save_build_metadata "$BUILD_ID"

log_info "Starting remote build process..."
log_info "Build ID: $BUILD_ID"
# Sync project files to Mac
log_info "Syncing project files to remote server..."
if ! retry_command "rsync -avz --exclude '.git' \
          --exclude 'DerivedData' \
          --exclude 'build' \
          --exclude '.DS_Store' \
          --exclude '*.log' \
          '$PROJECT_PATH/' \
          '$REMOTE_MAC:$REMOTE_PATH'" "Project sync"; then
    log_error "Failed to sync files to remote server"
    exit 1
fi
SYNC_COMPLETE=true
log_success "Project files synced successfully"

# Execute remote build
log_info "Starting remote build process..."
BUILD_STARTED=true
BUILD_CMD="cd $REMOTE_PATH && \
    xcodebuild clean build \
    -project AudioMaster.xcodeproj \
    -scheme $SCHEME \
    -configuration $BUILD_CONFIG \
    -destination 'platform=iOS Simulator,name=iPad Air (4th generation)' \
    COMPILER_INDEX_STORE_ENABLE=NO \
    CURRENT_PROJECT_VERSION=${BUILD_ID} \
    MARKETING_VERSION=$(get_version) \
    BUILD_NUMBER=$(get_build_number)"

if ! ssh "$REMOTE_MAC" "$BUILD_CMD"; then
    log_error "Remote build failed"
    # Try to fetch build logs
    ssh "$REMOTE_MAC" "cat $REMOTE_PATH/build/last_build.log" || true
    exit 1
fi
log_success "Remote build completed successfully"

# Fetch build artifacts
log_info "Retrieving build artifacts..."
if ! retry_command "rsync -avz '$REMOTE_MAC:$REMOTE_PATH/build/' '$PROJECT_PATH/build/'" "Artifact retrieval"; then
    log_warning "Failed to retrieve some build artifacts"
    exit 1
fi
ARTIFACTS_RETRIEVED=true
log_success "Build artifacts retrieved successfully"

# Verify build artifacts
if [ ! -d "$PROJECT_PATH/build" ]; then
    log_error "Build directory not found after artifact retrieval"
    exit 1
fi

log_success "Remote build process completed successfully!"
