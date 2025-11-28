---
name: log-triage-testing
description: Testing conventions and workflows for the log-triage-service Node.js project.
version: 1.0.0
category: testing
---

# Purpose

This Skill describes how to test the log-triage-service project.

Use it when:
- Adding or updating Jest tests
- Designing tests for new HTTP endpoints
- Checking coverage for bug fixes

# Stack

- Runtime: Node.js (LTS)
- Test runner: Jest
- HTTP tests: supertest (optional)
- Entry point: src/server.js
- Tests live in: tests/*.test.js

# Conventions

- One main `describe()` block per module or endpoint.
- File naming examples:
  - tests/parser.test.js
  - tests/store.test.js
  - tests/ingest.test.js
- Test names: "should <do something> when <condition>".

# Commands

- Run all tests:

  ```bash
  npm test