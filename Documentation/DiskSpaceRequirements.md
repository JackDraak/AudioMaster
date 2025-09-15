# Disk Space Requirements

This document outlines the disk space requirements for building the AudioMaster project.

## Build Environment Requirements

### Remote Build Server
- Minimum free space: 20GB
  - Project files: ~2GB
  - Build artifacts: ~5GB
  - Xcode DerivedData: ~10GB
  - Buffer space: ~3GB

### Local Development Machine
- Minimum free space: 20GB
  - Project files: ~2GB
  - Retrieved artifacts: ~5GB
  - Test resources: ~3GB
  - Buffer space: ~10GB

## Cleanup Policies

### Automatic Cleanup
The build script automatically cleans:
- DerivedData directory after builds
- Temporary build artifacts
- Old build logs

### Manual Cleanup
Periodically run:
```bash
# On remote server
rm -rf ~/Projects/AudioMaster/DerivedData/*
xcodebuild clean -project AudioMaster.xcodeproj -scheme AudioMaster

# On local machine
rm -rf ./build/*
```

## Monitoring

The build script monitors:
- Available disk space before builds
- Space used during build process
- Cleanup success

## Error Handling

If disk space is insufficient:
1. Build will not start
2. Detailed error message provided
3. Cleanup recommendations displayed
