#!/bin/bash

# Start parallel feature development with isolated worktrees
# Usage: ./scripts/start-worktrees.sh <feature-name>
# Example: ./scripts/start-worktrees.sh vendor-management

set -e

RAW_FEATURE_NAME="$*"

if [ -z "$RAW_FEATURE_NAME" ]; then
  echo "Usage: ./scripts/start-worktrees.sh <feature-name>"
  echo "   Example: ./scripts/start-worktrees.sh vendor-management"
  exit 1
fi

# Normalize feature name: lowercase, spaces/underscores to hyphens
FEATURE_NAME=$(echo "$RAW_FEATURE_NAME" | tr '[:upper:]' '[:lower:]' | tr ' _' '-' | tr -s '-')

if [ "$RAW_FEATURE_NAME" != "$FEATURE_NAME" ]; then
  echo "Normalized: '$RAW_FEATURE_NAME' → '$FEATURE_NAME'"
fi

REPO_ROOT=$(git rev-parse --show-toplevel)
REPO_NAME=$(basename "$REPO_ROOT")
PARENT_DIR=$(dirname "$REPO_ROOT")

TESTS_DIR="$PARENT_DIR/${REPO_NAME}-${FEATURE_NAME}-tests"
IMPL_DIR="$PARENT_DIR/${REPO_NAME}-${FEATURE_NAME}-impl"
TESTS_BRANCH="feature/${FEATURE_NAME}-tests"
IMPL_BRANCH="feature/${FEATURE_NAME}-impl"

echo ""
echo "Starting parallel feature development: $FEATURE_NAME"
echo ""

# Check if worktrees already exist
if [ -d "$TESTS_DIR" ] || [ -d "$IMPL_DIR" ]; then
  echo "Worktrees already exist:"
  [ -d "$TESTS_DIR" ] && echo "   - $TESTS_DIR"
  [ -d "$IMPL_DIR" ] && echo "   - $IMPL_DIR"
  echo ""
  echo "   To remove: ./scripts/end-worktrees.sh $FEATURE_NAME"
  exit 1
fi

echo "Fetching latest..."
git fetch origin

echo "Creating worktrees..."
git worktree add -b "$TESTS_BRANCH" "$TESTS_DIR" origin/master
git worktree add -b "$IMPL_BRANCH" "$IMPL_DIR" origin/master

echo ""
echo "Worktrees created"
echo ""

# Open VS Code for editing (customize for your editor)
echo "Opening editor..."
code "$TESTS_DIR"
code "$IMPL_DIR"

# Spawn Claude sessions (macOS Terminal.app)
# Customize this for your OS/terminal
echo "Spawning Claude sessions..."

osascript <<EOF
tell application "Terminal"
    activate

    -- Tests session
    do script "cd '$TESTS_DIR' && claude '/plan-tests $FEATURE_NAME'"

    -- Impl session
    do script "cd '$IMPL_DIR' && claude '/build-feature $FEATURE_NAME'"
end tell
EOF

echo ""
echo "Two Claude sessions started"
echo ""
echo "Next steps:"
echo "   1. Work in parallel - don't cross-pollinate"
echo "   2. When done: ./scripts/merge-worktrees.sh $FEATURE_NAME"
echo "   3. Then: claude → /write-tests"
echo "   4. Create PR, then: ./scripts/end-worktrees.sh $FEATURE_NAME"
echo ""
