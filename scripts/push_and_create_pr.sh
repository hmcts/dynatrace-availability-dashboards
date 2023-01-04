#! /usr/bin/env bash
set -x

if [ $BUILD_REASON == "Schedule" ]; then
    APPROVE_LABEL="auto-approve"
fi

create_pr(){
    branch=$1
    environment=$2
    git push origin --delete $branch || true
    git checkout -b $branch
    git add dynatrace/management_zones/management_zones_$environment.yaml \
        dynatrace/synthetic_monitors/synthetic_monitors_$environment.yaml
    git commit -m "$environment - Add autogenerated YAML objects"
    git push --set-upstream origin $branch

    # Prepare Github CLI PR Args
    pr_args=(
        --title "$environment - Update YAML definitions"
        --body "Automated updates from daily job running on $environment cluster."
        --base main
        --head $branch
    )
    if [[ $APPROVE_LABEL == "auto-approve" ]]; then
        pr_args+=(--label $APPROVE_LABEL)
    fi

    if !([[ "$environment" == "ptl" || "$environment" == "prod" ]]); then
        pr_number=$(gh pr create "${pr_args[@]}" | cut -d "/"  -f 7)

        if [[ $APPROVE_LABEL == "auto-approve" ]]; then
            gh pr merge --auto --delete-branch --squash $branch
            # Fail if command from job returns non-zero exit code
            set -e
            gh workflow --repo \
                hmcts/dynatrace-availability-dashboards \
                run auto-approve.yaml \
                -f environment="$environment" \
                -f pr_number="$pr_number"
            set +e
        fi
    else
        gh pr create \
            --title "$environment - Update YAML definitions" \
            --body "Automated updates from daily job running on $environment cluster." \
            --base main \
            --head $branch
    fi
}

if [ -z "$SYSTEM_DEFINITIONID" ]; then
    echo "This script is only to be run from ADO agents."
    exit 0
fi

environment=$1
gh_token=$2
git fetch --all
branch=yaml_autogenerate_$environment
echo $gh_token | gh auth login --with-token

git config --global user.email 77396727+hmcts-platform-operations@users.noreply.github.com
git config --global user.name hmcts-platform-operations

# Temporary store file changes to checkout to local main branch
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

git add dynatrace/management_zones/management_zones_$environment.yaml \
    dynatrace/synthetic_monitors/synthetic_monitors_$environment.yaml

# Determine if there are changes against main branch
if [ -z "$(git diff origin/main -- \
            dynatrace/management_zones/management_zones_$environment.yaml \
            dynatrace/synthetic_monitors/synthetic_monitors_$environment.yaml)" ]; then
    echo "No code changes against main detected."
    # If remote branch exists, close it as changes are now outdated compared to master
    [[ $(git ls-remote --exit-code --heads origin $branch) ]] && git push origin --delete $branch || echo "There is no longer changes in $environment."
else
    # Determine if remote branch already exists
    [[ $(git ls-remote --exit-code --heads origin $branch) ]] && remote_branch_exists=true || remote_branch_exists=false
    # Determine if there are changes against PR branch
    if [ "$remote_branch_exists" = true ] && [ -z "$(git diff origin/$branch -- \
                dynatrace/management_zones/management_zones_$environment.yaml \
                dynatrace/synthetic_monitors/synthetic_monitors_$environment.yaml)" ]; then
        echo "No changes against $branch branch."
        # Check if PR is closed
        if [ "$(gh pr view $branch --json closed | yq .closed)" = "true" ]; then
            # create_pr $branch $environment
        fi
    else
        echo "Changes detected against $branch branch:"
        echo "Deleting the remote branch $branch to close any existing PRs."
        # create_pr $branch $environment
    fi
fi

# Clean up temp files
rm -rf $tmpdir
