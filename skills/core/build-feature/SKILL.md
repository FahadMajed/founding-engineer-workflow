---
name: build-feature
description: Implement features from design docs. Use when (1) user references a design doc, (2) user says "build feature" or "implement feature", (3) user references an existing implementation plan. Creates implementation plan from design doc if none exists, then builds.
---

# Build Feature

Implement features following established patterns. Read [references/coding-patterns.template.md](references/coding-patterns.template.md) for codebase-specific patterns.

## Workflow

### 1. Understand Scope

1. Read the design doc (primary input)
2. Check if implementation plan exists
3. Identify files to create/modify

### 2. Plan (if no impl plan exists)

1. Analyze similar features in codebase
2. Deeply think & plan feature
3. Write approved plan to designated location
4. If no plan file exists and you are not in plan mode, notify user to switch to plan mode
5. Implement your plan
6. Verify with build & lint commands

### 3. When you finish, Review & Re-iterate

Launch 2 agents in parallel using the Task tool with different focuses:

- **code-simplifier agent:** Code quality and maintainability, focus on re-use without compromising human readability (simplicity/DRY/elegance)
- **code-reviewer agent:** Functional correctness and logic errors (bugs/correctness)

## Rules

- Never introduce new patterns without discussion
- Never use `any` types - define interfaces
- Add comments only when code cannot express intent
- Follow existing patterns in the codebase
