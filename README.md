# Gemini CLI Agents

This repository contains a collection of specialized subagents for the Gemini CLI, ported from the [awesome-claude-code-subagents](https://github.com/VoltAgent/awesome-claude-code-subagents) project.

## Installation

To use these agents, copy the `.md` files to your project's `.gemini/agents/` directory or your global `~/.gemini/agents/` directory.

## Usage

You can invoke these agents using the `@` syntax in the Gemini CLI:

```bash
@typescript-pro Refactor this file to use advanced generics.
```

Or the main agent will automatically delegate tasks to them based on their descriptions.
