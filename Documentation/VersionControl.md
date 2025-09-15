# Version Control Guidelines

## Version Format
- Format: MAJOR.MINOR.PATCH
- Example: 1.0.0

## Build Identifier Format
${VERSION}+${BUILD_NUMBER}.${BRANCH}.${GIT_HASH}.${TIMESTAMP}
Example: 1.0.0+123.main.a1b2c3d.20250915_123456

## Components
1. VERSION: Semantic version from VERSION file
2. BUILD_NUMBER: Git commit count
3. BRANCH: Current git branch
4. GIT_HASH: Short commit hash
5. TIMESTAMP: Build timestamp

## Files
- VERSION: Contains current semantic version
- .build-metadata: Contains complete build information
- .gitignore: Excludes build artifacts

## Build Metadata
Each build generates metadata including:
- Build ID
- Version
- Build number
- Git hash
- Branch
- Timestamp
- Build user
- Build host

## Version Update Process
1. Update VERSION file
2. Tag release in git
3. Push changes and tags

## Commands
```bash
# Get current version
cat VERSION

# Update version
echo "1.0.1" > VERSION

# Tag release
git tag -a "v$(cat VERSION)" -m "Release $(cat VERSION)"

# Push tags
git push --tags
```

## Automatic Version Components
- Build number: Increments with each commit
- Git hash: Current commit identifier
- Timestamp: Build time
- Branch: Current branch name

## Build Artifacts
Build artifacts are tagged with the build identifier for traceability.

## Version History
Version history is maintained in CHANGELOG.md following Keep a Changelog format.
