# Posting Review Findings as Inline PR Comments

Every review agent posts its own findings on the PR. Prefix every comment body with your agent tag: `**[security]**`, `**[design]**`, `**[conventions]**`, `**[bug-hunter]**`, `**[sql-and-migration]**`, `**[perf]**`, `**[simplicity]**`.

## One review per agent, all comments in one call

Write the payload to a file, then post it:

```bash
cat > /tmp/{agent}-review.json <<'EOF'
{
  "commit_id": "{HEAD_SHA}",
  "event": "COMMENT",
  "body": "**[design]** 3 findings. Worst: OrderSyncService's interface is as wide as its implementation.",
  "comments": [
    {
      "path": "src/orders/order-sync.service.ts",
      "line": 42,
      "side": "RIGHT",
      "body": "**[design]** Shallow module: this method exposes ... The deeper cut: ..."
    }
  ]
}
EOF
gh api repos/{{YOUR_ORG}}/{repo}/pulls/{PR}/reviews --input /tmp/{agent}-review.json
```

## Rules

- `line` must be a line that appears in the diff (`side: "RIGHT"` = the new code). A file-level or architectural finding that doesn't map to a changed line goes in the review `body`, not a comment — the API rejects comments on unchanged lines.
- Multi-line finding: add `start_line` (+ `start_side`) with `line` as the end.
- One finding per comment. Shape: what's wrong → why it matters → the concrete fix (code when short).
- Comments are for the user first, the main agent second: full sentences, no shorthand, no internal codenames.

## Zero findings

Don't post an empty review. Post proof you ran:

```bash
gh pr comment {PR} --body "**[security]** No findings — reviewed {N} changed files against {base}."
```

## Verify, then report back

A 200 with a review `id` means it posted. Return to the main agent: finding count + the review URL. If the API call fails after a retry, return the full findings text to the main agent so it can post them — never drop findings silently.
