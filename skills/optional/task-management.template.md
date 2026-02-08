---
name: task-management
description: Create and manage tasks for project tracking. Use when (1) logging completed work to tasks, (2) planning new features or milestones, (3) creating bug reports or tech debt tasks, (4) updating task status after code changes.
---

# Task Management

Create and update tasks in your project management tool.

## Setup

Configure for your tool:

```
Tool: {{YOUR_TOOL}} (ClickUp, Linear, Jira, GitHub Issues, etc.)

API: {{YOUR_API_ENDPOINT}}
Auth: {{YOUR_AUTH_METHOD}}

Workspace/Project: {{YOUR_WORKSPACE_ID}}
Default List/Board: {{YOUR_DEFAULT_LIST_ID}}
```

## Workflows

### 1. Update Existing Task

When user references a task by ID or name:

```bash
# Get task details
{{YOUR_GET_TASK_COMMAND}}

# Update task status
{{YOUR_UPDATE_TASK_COMMAND}}

# Add comment
{{YOUR_ADD_COMMENT_COMMAND}}
```

### 2. Log Work Retroactively

When user says "log what I just did":

1. Check recent git commits for context
2. Find related task (ask if not obvious)
3. Add completion comment with details

### 3. Plan New Work

When user wants to create a feature/milestone:

1. Ask for: name, description, priority, timeline
2. Create parent task
3. Break down into subtasks if complex
4. Return task link

### 4. Report Bug/Tech Debt

When user finds an issue to fix later:

1. Capture: what, where, severity, reproduction steps
2. Create task with appropriate labels/tags
3. Return task link

## Task Templates

### Feature/Milestone

```
Name: [Feature Name]
Description:
  Problem: [What pain point this solves]
  Solution: [High-level approach]
  Done When: [Acceptance criteria]

Subtasks:
  - [ ] Design doc
  - [ ] Implementation
  - [ ] Tests
  - [ ] Review
  - [ ] Deploy
```

### Bug

```
Name: [Bug] [Brief description]
Description:
  Expected: [What should happen]
  Actual: [What happens instead]
  Steps to Reproduce: [How to trigger]
  Severity: [Critical/High/Medium/Low]
```

### Tech Debt

```
Name: [Tech Debt] [Brief description]
Description:
  Current State: [What's wrong]
  Desired State: [What it should be]
  Impact: [Why this matters]
  Effort: [Rough estimate]
```

## Status Mapping

Map your tool's statuses:

| Workflow State | {{YOUR_TOOL}} Status |
| -------------- | -------------------- |
| Not Started    | {{STATUS_1}}         |
| In Progress    | {{STATUS_2}}         |
| Review         | {{STATUS_3}}         |
| Done           | {{STATUS_4}}         |

## Rules

- Require specific task names (not "Fix bug")
- Require problem statements (not just solutions)
- Require done criteria (how we know it's complete)
- Reject vague tasks — ask for details
