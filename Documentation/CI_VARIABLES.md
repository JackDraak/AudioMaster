# CI/CD Environment Variables

## Required Variables for Build and Deployment

### Code Signing
TEAM_ID=                     # Your Apple Developer Team ID
PROVISIONING_PROFILE_UUID=   # UUID of your provisioning profile
APPLE_ID=                    # Apple ID for certificate management
APP_SPECIFIC_PASSWORD=       # App-specific password for CI

### Build Configuration
DEVELOPMENT_TEAM=           # Your development team identifier
BUNDLE_IDENTIFIER=          # com.yourcompany.audiomaster
XCODE_SCHEME=              # AudioMaster
XCODE_CONFIGURATION=       # Release/Debug

### Remote Build (if not developing on a Mac)
REMOTE_MAC_HOST=           # IP/hostname of Mac build machine
REMOTE_MAC_USER=           # Username on Mac build machine
SSH_PRIVATE_KEY=           # SSH key for Mac build machine access

### Testing
TEST_DEVICE_UDID=         # UDID of test device
TESTFLIGHT_USERNAME=      # Apple ID for TestFlight distribution
TESTFLIGHT_APP_ID=       # Your app's Apple ID

### GitHub Actions Secrets
# Add these secrets in your GitHub repository settings:
# - APPLE_DEVELOPER_CERTIFICATE
# - APPLE_DEVELOPER_CERTIFICATE_PASSWORD
# - PROVISIONING_PROFILE
# - SSH_PRIVATE_KEY (if using remote build)
# - APPLE_ID
# - APPLE_APP_SPECIFIC_PASSWORD
