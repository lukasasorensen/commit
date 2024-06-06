#!/bin/bash

# Check if COMMIT_PREFIX is set
if [ -z "$COMMIT_PREFIX" ]; then
  echo "Error: COMMIT_PREFIX is not set. Please set it using 'export COMMIT_PREFIX=\"MyPrefix-\"'."
  exit 1
fi

# Get the current git branch name
branch_name=$(git rev-parse --abbrev-ref HEAD)

# Extract the JIRA card number from the branch name
jira_card_number=$(echo $branch_name | grep -o "${COMMIT_PREFIX}[0-9]\+")

# Check if the JIRA card number was found
if [ -z "$jira_card_number" ]; then
  echo "Error: JIRA card number not found in the branch name."
  read -p "Would you like to continue making a commit without a prefix? (y/n): " choice
  if [ "$choice" != "y" ]; then
    echo "Commit aborted."
    exit 1
  fi
  # Commit without prefix
  commit_message="$1"
else
  # Construct the commit message with the JIRA card number
  commit_message="$jira_card_number: $1"
fi


# add all files
git add .

# Run the git commit command with the constructed message
git commit -m "$commit_message"
