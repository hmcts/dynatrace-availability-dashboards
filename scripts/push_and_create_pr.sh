if [ -z "$SYSTEM_DEFINITIONID" ]; then
    echo "This script is only to be run from ADO agents."
    exit 0
fi

environment=$1
gh_token=$2
git fetch --all
branch=yaml_autogenerate_$environment
echo $gh_token | gh auth login --with-token

git config --global user.email 104018155+hmcts-dependency-updater[bot]@users.noreply.github.com
git config --global user.name hmcts-dependency-updater

# Temporary store file changes to checkout to local main branch

# to do mpdir=$(mktemp -d) - move files into this dir instead of /tmp, then removing dir after job completion
tmpdir=$(mktemp -d)
cp dynatrace/management_zones/management_zones_$environment.yaml $tmpdir/
cp dynatrace/synthetic_monitors/synthetic_monitors_$environment.yaml $tmpdir/

git fetch --all
git add .
git stash
git checkout main

# Add changes back to working dir
mv $tmpdir/management_zones_$environment.yaml dynatrace/management_zones/
mv $tmpdir/synthetic_monitors_$environment.yaml dynatrace/synthetic_monitors/

# Determine if there are changes against main branch
if [ -z "$(git diff origin/main -- \
            dynatrace/management_zones/management_zones_$environment.yaml \
            dynatrace/synthetic_monitors/synthetic_monitors_$environment.yaml)" ]; then
    echo "No code changes against main detected."
else
    # Determine if there are changes against PR branch if it exists
    [[ $(git ls-remote --exit-code --heads origin $branch) ]] && remote_branch_exists=true || remote_branch_exists=false
    if [ "$remote_branch_exists" = true ] && [ -z "$(git diff origin/$branch -- \
                dynatrace/management_zones/management_zones_$environment.yaml \
                dynatrace/synthetic_monitors/synthetic_monitors_$environment.yaml)" ]; then
        echo "No changes against $branch branch."
    else
        echo "Changes detected against $branch branch:"
        echo "##vso[task.logissue type=warning]$environment - changes detected against main branch, creating a PR."
        echo "Deleting the remote branch $branch to close any existing PRs if it exists."
        [[ $(git ls-remote --exit-code --heads origin $branch) ]] && git push origin --delete $branch || echo "Remote branch doesn't exist"
        git checkout -b $branch
        git add dynatrace/management_zones/management_zones_$environment.yaml \
            dynatrace/synthetic_monitors/synthetic_monitors_$environment.yaml
        git commit -m "$environment - Add autogenerated YAML objects"
        git push --set-upstream origin $branch
        gh pr create \
            --title "$environment - Update YAML definitions" \
            --body "Automated updates from daily job running on $environment cluster." \
            --base main \
            --head $branch
    fi
fi

# Clean up temp files
rm -rf $tmpdir
