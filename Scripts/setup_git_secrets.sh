#!/bin/bash

# Script to set up git-secrets in the repository

# Check if git-secrets is installed
if ! command -v git-secrets &> /dev/null; then
    echo "Error: git-secrets is not installed"
    echo "Please install it using:"
    echo "  For macOS: brew install git-secrets"
    echo "  For Linux: "
    echo "    git clone https://github.com/awslabs/git-secrets.git"
    echo "    cd git-secrets"
    echo "    sudo make install"
    exit 1
fi

# Initialize git-secrets
git secrets --install
if [ $? -ne 0 ]; then
    echo "Failed to install git-secrets hooks"
    exit 1
fi

# Install into global git config
git secrets --install ~/.git-templates/git-secrets
git config --global init.templateDir ~/.git-templates/git-secrets

# Register patterns from .git-secrets file
if [ -f .git-secrets ]; then
    while IFS= read -r line; do
        if [[ $line =~ ^[[:space:]]*\'([^\']+)\',[[:space:]]*$ ]]; then
            pattern="${BASH_REMATCH[1]}"
            git secrets --add "$pattern"
        fi
    done < <(grep "^[[:space:]]*'.*',[[:space:]]*$" .git-secrets)
fi

# Add AWS patterns (common source of credential leaks)
git secrets --register-aws

# Add custom patterns for AudioMaster
git secrets --add 'APPLE_.*_PASSWORD'
git secrets --add 'PROVISIONING_PROFILE_UUID'
git secrets --add 'security@audiomaster\.example\.com'

echo "Setting up git-secrets pre-commit hook..."
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash

# Run git-secrets scan
if ! git secrets --pre_commit_hook; then
    echo "Error: Potential secrets found in commit."
    echo "Please remove secrets and try again."
    exit 1
fi

# Scan for large audio files
if git diff --cached --name-only | grep -E '\.(wav|aif|mp3)$'; then
    echo "Warning: Audio files detected in commit."
    echo "Please ensure these are test files and contain no sensitive audio data."
    read -p "Continue with commit? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi
EOF

chmod +x .git/hooks/pre-commit

# Add scan script for existing repository
cat > scan_history.sh << 'EOF'
#!/bin/bash

echo "Scanning entire git history for secrets..."
git secrets --scan-history

if [ $? -eq 0 ]; then
    echo "No secrets found in git history!"
else
    echo "Warning: Potential secrets found in git history!"
    echo "Please review and clean the repository history."
    echo "Consider using: git filter-branch or git filter-repo"
fi
EOF

chmod +x scan_history.sh

echo "Git secrets setup complete!"
echo "To scan existing history, run: ./scan_history.sh"
