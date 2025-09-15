# iOS Code Signing Guide

## Prerequisites
1. Apple Developer Account
2. Xcode installed on a Mac
3. Valid provisioning profile
4. Development and distribution certificates

## Steps for Code Signing Setup

### 1. Certificate Creation
```bash
# On your Mac, run:
security create-keychain -p "your-password" build.keychain
security default-keychain -s build.keychain
security unlock-keychain -p "your-password" build.keychain
security set-keychain-settings build.keychain
```

### 2. Provisioning Profile Setup
1. Visit https://developer.apple.com/account/resources/profiles/list
2. Create new provisioning profile:
   - Select "iOS App Development"
   - Choose your App ID
   - Select development certificates
   - Select test devices
   - Download profile

### 3. Local Development Setup
1. Open Xcode
2. In project settings:
   - Select your team
   - Set bundle identifier
   - Choose signing certificate
   - Import provisioning profile

### 4. CI/CD Setup
1. Export certificates:
```bash
security export -k build.keychain -t identities -f pkcs12 -o certificates.p12
```

2. Configure GitHub Actions secrets:
   - APPLE_DEVELOPER_CERTIFICATE (Base64 encoded .p12)
   - PROVISIONING_PROFILE (Base64 encoded .mobileprovision)
   - APPLE_DEVELOPER_CERTIFICATE_PASSWORD

3. Update CI workflow:
```yaml
- name: Import Certificate
  run: |
    echo ${{ secrets.APPLE_DEVELOPER_CERTIFICATE }} | base64 --decode > certificate.p12
    security import certificate.p12 -k build.keychain -P ${{ secrets.APPLE_DEVELOPER_CERTIFICATE_PASSWORD }}

- name: Import Provisioning Profile
  run: |
    echo ${{ secrets.PROVISIONING_PROFILE }} | base64 --decode > profile.mobileprovision
    mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
    cp profile.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles/
```

## Troubleshooting

### Common Issues
1. Certificate not found:
   - Check keychain access
   - Verify certificate validity
   - Ensure proper team permissions

2. Provisioning profile errors:
   - Verify device UDID inclusion
   - Check profile expiration
   - Confirm bundle ID match

3. Code signing errors:
   - Verify team ID in project
   - Check signing identity matches
   - Validate provisioning profile capabilities
