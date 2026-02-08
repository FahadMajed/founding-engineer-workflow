#!/bin/bash

# Merge implementation into tests worktree
# Usage: ./scripts/merge-worktrees.sh <feature-name>

set -e

RAW_FEATURE_NAME="$*"

if [ -z "$RAW_FEATURE_NAME" ]; then
  echo "Usage: ./scripts/merge-worktrees.sh <feature-name>"
  exit 1
fi

# Normalize feature name
FEATURE_NAME=$(echo "$RAW_FEATURE_NAME" | tr '[:upper:]' '[:lower:]' | tr ' _' '-' | tr -s '-')

REPO_ROOT=$(git rev-parse --show-toplevel)
REPO_NAME=$(basename "$REPO_ROOT")
PARENT_DIR=$(dirname "$REPO_ROOT")

TESTS_DIR="$PARENT_DIR/${REPO_NAME}-${FEATURE_NAME}-tests"
IMPL_DIR="$PARENT_DIR/${REPO_NAME}-${FEATURE_NAME}-impl"
IMPL_BRANCH="feature/${FEATURE_NAME}-impl"

echo ""
echo "Merging implementation into tests: $FEATURE_NAME"
echo ""

# Verify worktrees exist
if [ ! -d "$TESTS_DIR" ]; then
  echo "Tests worktree not found: $TESTS_DIR"
  exit 1
fi

if [ ! -d "$IMPL_DIR" ]; then
  echo "Impl worktree not found: $IMPL_DIR"
  exit 1
fi

# Check for uncommitted changes in impl
cd "$IMPL_DIR"
if [ -n "$(git status --porcelain)" ]; then
  echo "Uncommitted changes in impl worktree"
  echo "   Commit or stash before merging."
  git status --short
  exit 1
fi

# Get impl commit info for summary
IMPL_COMMITS=$(git log origin/master..HEAD --oneline | wc -l | tr -d ' ')
IMPL_HEAD=$(git rev-parse --short HEAD)

# Switch to tests and merge
cd "$TESTS_DIR"

# Check for uncommitted changes in tests
if [ -n "$(git status --porcelain)" ]; then
  echo "Uncommitted changes in tests worktree"
  echo "   Commit or stash before merging."
  git status --short
  exit 1
fi

echo "Impl branch has $IMPL_COMMITS commit(s) to merge"
echo ""

# Perform merge
echo "Merging $IMPL_BRANCH into tests..."
if git merge "$IMPL_BRANCH" -m "Merge implementation into tests for $FEATURE_NAME"; then
  echo ""
  echo "Merge successful"
  echo ""
  echo "Next steps:"
  echo "   1. cd $TESTS_DIR"
  echo "   2. claude → /write-tests"
  echo "   3. Create PR when tests pass"
else
  echo ""
  echo "Merge conflicts detected"
  echo "   Resolve conflicts in: $TESTS_DIR"
  echo "   Then run: git add . && git commit"
fi
echo ""
