#!/bin/bash

# Clean up feature worktrees after PR merged
# Usage: ./scripts/end-worktrees.sh <feature-name>

set -e

RAW_FEATURE_NAME="$*"

if [ -z "$RAW_FEATURE_NAME" ]; then
  echo "Usage: ./scripts/end-worktrees.sh <feature-name>"
  exit 1
fi

# Normalize feature name
FEATURE_NAME=$(echo "$RAW_FEATURE_NAME" | tr '[:upper:]' '[:lower:]' | tr ' _' '-' | tr -s '-')

REPO_ROOT=$(git rev-parse --show-toplevel)
REPO_NAME=$(basename "$REPO_ROOT")
PARENT_DIR=$(dirname "$REPO_ROOT")

TESTS_DIR="$PARENT_DIR/${REPO_NAME}-${FEATURE_NAME}-tests"
IMPL_DIR="$PARENT_DIR/${REPO_NAME}-${FEATURE_NAME}-impl"

TESTS_BRANCH="feature/${FEATURE_NAME}-tests"
IMPL_BRANCH="feature/${FEATURE_NAME}-impl"

echo ""
echo "Cleaning up worktrees: $FEATURE_NAME"
echo ""

# Check for uncommitted changes
check_uncommitted() {
  local dir=$1
  local name=$2
  if [ -d "$dir" ]; then
    cd "$dir"
    if [ -n "$(git status --porcelain)" ]; then
      echo "Uncommitted changes in $name worktree"
      echo "   Commit, stash, or discard before cleanup."
      git status --short
      exit 1
    fi
    cd - > /dev/null
  fi
}

check_uncommitted "$TESTS_DIR" "tests"
check_uncommitted "$IMPL_DIR" "impl"

# Remove worktrees
if [ -d "$TESTS_DIR" ]; then
  echo "Removing tests worktree..."
  git worktree remove "$TESTS_DIR"
else
  echo "   Tests worktree already removed"
fi

if [ -d "$IMPL_DIR" ]; then
  echo "Removing impl worktree..."
  git worktree remove "$IMPL_DIR"
else
  echo "   Impl worktree already removed"
fi

# Delete local branches
echo ""
read -p "Delete local branches? ($TESTS_BRANCH, $IMPL_BRANCH) [y/N]: " DELETE_BRANCHES

if [[ "$DELETE_BRANCHES" =~ ^[Yy]$ ]]; then
  git branch -d "$TESTS_BRANCH" 2>/dev/null && echo "   Deleted $TESTS_BRANCH" || echo "   $TESTS_BRANCH: not found or not merged"
  git branch -d "$IMPL_BRANCH" 2>/dev/null && echo "   Deleted $IMPL_BRANCH" || echo "   $IMPL_BRANCH: not found or not merged"
fi

echo ""
echo "Cleanup complete"
echo ""
