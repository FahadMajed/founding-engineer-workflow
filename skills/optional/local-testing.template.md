---
name: local-testing
description: Test endpoints against any running server (local dev, staging, prod). Handles auth token acquisition and reuse. Use when testing API endpoints, debugging server responses, or verifying new features.
---

# Local Testing

Test API endpoints against running servers with automatic authentication.

## Setup

1. **Get credentials:**
   - Check `.env` files for test user credentials
   - Ask user for email/password if not found
   - Default test user: `{{YOUR_TEST_EMAIL}}` / `{{YOUR_TEST_PASSWORD}}`

## Auth Flow

```bash
# Get access token - customize for your auth endpoint
curl -s -X POST "http://localhost:{{PORT}}/{{AUTH_ENDPOINT}}" \
  -H "Content-Type: application/json" \
  -d '{"email": "{{email}}", "password": "{{password}}"}' | jq '.accessToken'
```

**Store the token** - reuse for all subsequent requests in the session.

## Test Endpoint

```bash
curl -s -X {{METHOD}} "http://{{base_url}}/{{endpoint}}" \
  -H "Authorization: Bearer {{token}}" \
  -H "Content-Type: application/json" \
  {{-d 'body' if POST/PUT/PATCH}} | jq '.'
```

## Workflow

1. Ask user what endpoint to test (method, path, body if needed)
2. Obtain token if not already stored
3. Execute request with jq formatting
4. Show response and help interpret results

## Troubleshooting

| Issue                 | Fix                                                      |
| --------------------- | -------------------------------------------------------- |
| 401 Unauthorized      | Token expired, re-authenticate                           |
| 401 Invalid token     | Use single quotes for -H 'Authorization: Bearer ...'     |
| Connection refused    | Server not running, check port                           |
| 403 Forbidden         | User lacks permission for this endpoint                  |

**Token tip**: Tokens with special chars can break when stored in variables. Prefer inlining:

```bash
# Good - single quotes, inline token
curl -s -X GET "http://localhost:{{PORT}}/endpoint" \
  -H 'Authorization: Bearer eyJhbG...' | jq '.'

# Bad - variable expansion can corrupt token
TOKEN="eyJhbG..."
curl ... -H "Authorization: Bearer $TOKEN"
```

## Examples

```bash
# GET with query params
curl -s -X GET "http://localhost:{{PORT}}/items?page=1&limit=10" \
  -H 'Authorization: Bearer {{token}}' | jq '.'

# POST with body
curl -s -X POST "http://localhost:{{PORT}}/items" \
  -H 'Authorization: Bearer {{token}}' \
  -H "Content-Type: application/json" \
  -d '{"name": "example", "quantity": 1}' | jq '.'
```

## Common Endpoints

| Endpoint         | Response structure          |
| ---------------- | --------------------------- |
| GET /{{items}}   | `{items: [{id, name, ...}]}` |
| POST /{{items}}  | `{id, name, ...}`           |
