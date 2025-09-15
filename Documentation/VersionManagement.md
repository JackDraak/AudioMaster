# Version Management

## Overview
The AudioMaster project uses semantic versioning (MAJOR.MINOR.PATCH) with automated version management tools.

## Version Format
- MAJOR: Breaking changes
- MINOR: New features, backward compatible
- PATCH: Bug fixes, backward compatible

## Tools

### Version Management Script
Located at `Scripts/version.sh`, provides:
- Version validation
- Automated increments
- Version comparison
- Changelog management

### Commands
```bash
# Get current version
./Scripts/version.sh get

# Increment version
./Scripts/version.sh increment [major|minor|patch]

# Validate version
./Scripts/version.sh validate

# Set specific version
./Scripts/version.sh set X.Y.Z

# Compare versions
./Scripts/version.sh compare 1.0.0 1.1.0
```

## Validation Rules
- Must follow semantic versioning
- Format: X.Y.Z (e.g., 1.0.0)
- Each component must be numeric
- No leading zeros allowed

## Automated Processes
1. Version Increment
   - Updates VERSION file
   - Creates git tag
   - Updates CHANGELOG.md
   - Validates new version

2. Build Integration
   - Version included in build identifier
   - Embedded in app bundle
   - Included in build metadata

3. Changelog Management
   - Automatic entry creation
   - Date stamping
   - Structured sections
   - Git integration

## Best Practices
1. Version Updates
   - MAJOR: API changes, breaking updates
   - MINOR: New features, additions
   - PATCH: Bug fixes, minor updates

2. Git Tags
   - Always tag releases
   - Use annotated tags
   - Include release notes

3. Changelog
   - Keep entries clear and concise
   - Document all significant changes
   - Include migration notes
   - Reference relevant issues/PRs

4. Build Process
   - Verify version before build
   - Include version in artifacts
   - Log version in build metadata

## Error Handling
- Invalid version format
- Missing VERSION file
- Git tag conflicts
- Changelog conflicts

## Examples

### Increment Version
```bash
# Patch update for bug fix
./Scripts/version.sh increment patch

# Minor update for new feature
./Scripts/version.sh increment minor

# Major update for breaking change
./Scripts/version.sh increment major
```

### Version Validation
```bash
# Validate current version
./Scripts/version.sh validate

# Validate specific version
./Scripts/version.sh set 1.2.3
```

### Version Comparison
```bash
# Compare two versions
./Scripts/version.sh compare 1.0.0 1.1.0
```
