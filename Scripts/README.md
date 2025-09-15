# Remote Build Configuration

## Environment Variables

The following environment variables can be set to configure the remote build process:

- `BUILD_SERVER`: The SSH address of your Mac build server (e.g., "user@mac-mini.local")
- `PROJECT_ROOT`: The local path to your project root (defaults to git repository root)
- `REMOTE_PROJECT_PATH`: The path on the remote Mac where the project should be built (defaults to ~/Projects/AudioMaster)
- `XCODE_SCHEME`: The Xcode scheme to build (defaults to AudioMaster)
- `BUILD_CONFIGURATION`: The build configuration to use (Debug/Release, defaults to Debug)

## Example Usage

```bash
# Configure build environment
export BUILD_SERVER="builder@mac-build.local"
export REMOTE_PROJECT_PATH="/Volumes/BuildDrive/AudioMaster"

# Run build
./Scripts/remote_build.sh
```

## CI/CD Integration

When using in CI/CD pipelines, ensure these variables are properly set in your pipeline configuration:

```yaml
jobs:
  build:
    environment:
      BUILD_SERVER: ${{ secrets.BUILD_SERVER }}
      REMOTE_PROJECT_PATH: /Volumes/CI/AudioMaster
```
