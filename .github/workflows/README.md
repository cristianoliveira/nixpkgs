# GitHub Actions Workflows

This directory contains GitHub Actions workflows for the nixpkgs repository.

## Workflows

### `on-pr-validate.yml`
Validates pull requests by building packages to ensure they work correctly.

### `on-push-nixbuild.yml`
Builds all packages on push to validate changes don't break anything.

### `on-schedule-nixbuild.yml`
Periodic Nix package validation that runs every 3 hours to catch issues with external packages.

### `daily-package-updates.yml` (New!)
Daily package update checker that:
- Runs automatically every day at 2:00 AM UTC
- Checks for updates in packages that have update scripts
- Checks for new releases of Rust packages on GitHub
- Generates detailed update reports with instructions
- Creates PRs for packages that have update scripts
- Validates that updated packages build correctly

## Package Update Script

The `scripts/check-package-updates.sh` script is the heart of the daily update workflow.

### Supported Update Methods

1. **Update Scripts**: Packages with dedicated update scripts in `pkgs/<package>/`
   - `pi`: Uses `pkgs/pi/update.sh`
   - `opencode`: Uses `pkgs/opencode/upgrade-opencode`

2. **GitHub Releases**: Rust packages tracked in the script
   - Automatically checks GitHub API for latest releases
   - Generates update instructions with version, commit SHA, and hash information

### Adding a Package to Update Checks

To add a package to the automatic update checks:

#### Option 1: Add an Update Script (Recommended for Complex Packages)

Create an update script in the package directory (e.g., `pkgs/mypackage/update.sh`):

```bash
#!/usr/bin/env bash
set -euo pipefail

# Fetch latest version from your source
latest_version=$(curl -s https://api.github.com/owner/repo/releases/latest | jq -r '.tag_name')

# Update the package file with new version and hashes
# ... implementation details ...
```

Then add it to `scripts/check-package-updates.sh`:

```bash
declare -A PACKAGE_UPDATE_METHODS=(
  ["pi"]="script:pkgs/pi/update.sh"
  ["opencode"]="script:pkgs/opencode/upgrade-opencode"
  ["mypackage"]="script:pkgs/mypackage/update.sh"  # Add this line
)
```

#### Option 2: Add to Rust Packages List (For Simple Rust Packages)

For Rust packages that follow a standard pattern (using `fetchFromGitHub` and `buildRustPackage`), add them to the `RUST_PACKAGES` array:

```bash
declare -A RUST_PACKAGES=(
  ["zeroclaw"]="https://github.com/zeroclaw-labs/zeroclaw"
  ["zclaw"]="https://github.com/cristianoliveira/zclaw"
  ["mypackage"]="https://github.com/owner/mypackage"  # Add this line
)
```

### How It Works

1. **Discovery**: The script automatically discovers all local packages via `scripts/list-packages.sh --local`

2. **Checking**: For each package:
   - Checks if it has an update script and runs it
   - Checks if it's a Rust package and queries GitHub for new releases

3. **Reporting**: Generates a `package-updates.md` file with:
   - Summary of available updates
   - Detailed instructions for each package
   - Links to releases and repositories

4. **PR Creation**: If updates are found, the GitHub Action:
   - Creates a PR with the update report
   - Validates that updated packages build correctly
   - Posts the validation report as an artifact

### Manual Testing

To test the update script locally:

```bash
./scripts/check-package-updates.sh
```

This will:
- Check all packages for updates
- Generate `package-updates.md` report
- Output JSON with packages that have updates

### Disabling the Workflow

To disable the daily update workflow, edit `.github/workflows/daily-package-updates.yml` and comment out or remove the `schedule:` trigger:

```yaml
on:
  workflow_dispatch:  # Only allow manual triggering
  # schedule:
  #   - cron: '0 2 * * *'
```

### Customizing Schedule

To change when the workflow runs, modify the cron expression:

```yaml
schedule:
  - cron: '0 2 * * *'  # Daily at 2:00 AM UTC
  # Other examples:
  # - cron: '0 */6 * * *'  # Every 6 hours
  # - cron: '0 0 * * 0'    # Weekly on Sunday at midnight
```

Cron format: `minute hour day month day-of-week`
- `*` = any value
- `*/n` = every n minutes/hours
- `0-23` = range (for hours)
- `0-6` = day of week (0 = Sunday, 6 = Saturday)

### Secrets

The workflow uses optional secrets:

- `CACHIX_CACHE_NAME`: Name of your Cachix cache for faster builds
- `CACHIX_AUTH_TOKEN`: Authentication token for Cachix

These are optional - the workflow will work without them, just slower.

## Troubleshooting

### Update Script Fails

If an update script fails:
1. Check the workflow logs for detailed error messages
2. Try running the script locally to debug
3. Verify that package URLs or release formats haven't changed

### PR Not Created

If no PR is created but updates were found:
1. Check that the workflow has permissions to create PRs
2. Verify the `if` condition in the workflow job
3. Look at the "check-updates" job output for the actual status

### Package Build Fails in Validation

If a package update fails to build:
1. Check the validation job logs for specific errors
2. The hash might be wrong - rebuild to get the correct one
3. The package might have new dependencies - update the Nix expression
4. The upstream package might have breaking changes

### API Rate Limiting

GitHub API has rate limits. If you encounter rate limiting:
1. The workflow will retry automatically
2. Consider using `GITHUB_TOKEN` which has higher limits
3. For very large repos, space out the checks

## Best Practices

1. **Keep Update Scripts Simple**: Update scripts should be idempotent and handle errors gracefully
2. **Test Locally First**: Always test update scripts locally before relying on CI
3. **Use Semantic Versioning**: Package versions should follow semver for easy comparison
4. **Document Changes**: Keep changelogs or commit messages informative
5. **Validate Thoroughly**: Ensure updated packages build and run correctly
6. **Monitor PRs**: Review and merge update PRs promptly to avoid conflicts
