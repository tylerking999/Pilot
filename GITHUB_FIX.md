# Fix GitHub Authentication

## Quick Solution (2 minutes)

### Option 1: Use Personal Access Token

1. **Create Token:**
   - Go to: https://github.com/settings/tokens/new
   - Note: "Pilot App Push"
   - Expiration: 90 days
   - Select scopes: ✅ **repo** (all checkboxes)
   - Click **Generate token**
   - **COPY THE TOKEN** (you can't see it again!)

2. **Push with Token:**
   ```bash
   cd /Users/tylerking/Desktop/Pilot
   git push -u origin main
   ```
   - Username: `tylerking999`
   - Password: **[paste the token]**

### Option 2: Use GitHub CLI (Easier)

```bash
# Install GitHub CLI
brew install gh

# Login
gh auth login

# Push
cd /Users/tylerking/Desktop/Pilot
git push -u origin main
```

### Option 3: Switch to SSH (Best Long-term)

```bash
# Check if you have SSH key
ls ~/.ssh/id_ed25519.pub

# If not, create one
ssh-keygen -t ed25519 -C "your_email@example.com"
# Press Enter 3 times (accept defaults)

# Copy public key
cat ~/.ssh/id_ed25519.pub | pbcopy

# Add to GitHub:
# Go to: https://github.com/settings/ssh/new
# Paste key, give it a name, click Add

# Change remote to SSH
cd /Users/tylerking/Desktop/Pilot
git remote set-url origin git@github.com:tylerking999/Pilot.git

# Push
git push -u origin main
```

## Fastest: Use Option 1
Just create the token and paste it when it asks for password!
