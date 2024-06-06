#!/bin/bash

confirm() {
    local message="$1"
    local response

    # Append "[y/n]" to the message
    message="$message [y/n]: "

    # Check if the shell is zsh or bash
    read -n 1 -p "$message" response 
    echo

    # Check the response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        return 0
    else
        return 1
    fi
}

skipPrefix=0
# Check if COMMIT_PREFIX is set
if [ -z "$COMMIT_PREFIX" ]; then
  if ! confirm "Missing COMMIT_PREFIX, no JIRA card will be added. Would you like to continue?"; then
    echo "Commit Aborted"
    echo "To set your Commit Prefix add export COMMIT_PREFIX=\"MYPREFIX-\" to your .zshrc or .bashrc"
    exit 1
  fi
  skipPrefix=1
fi

if [ "$skipPrefix" = 0 ]; then
  # Get the current git branch name
  branch_name=$(git rev-parse --abbrev-ref HEAD)
  
  # Extract the JIRA card number from the branch name
  jira_card_number=$(echo $branch_name | grep -o "${COMMIT_PREFIX}[0-9]\+")
  
  # Check if the JIRA card number was found
  if [ -z "$jira_card_number" ]; then
    echo "Error: JIRA card number not found in the branch name."
  
    if ! confirm "Would you like to continue making a commit without a prefix?"; then
      echo "Commit aborted."
      exit 1
    fi
  
    # Commit without prefix
    commit_message="$1"
  else
    # Construct the commit message with the JIRA card number
    commit_message="$jira_card_number: $1"
  fi
fi


# add all files
git add .

# Run the git commit command with the constructed message
git commit -m "$commit_message"
