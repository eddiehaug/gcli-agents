---
name: subagent-catalog
description: "Browse and fetch subagents from the awesome-claude-code-subagents catalog. Use when you need to find specialized agents for specific tasks."
---

# Subagent Catalog Skill

This skill allows you to discover and retrieve specialized agent definitions from the official `awesome-claude-code-subagents` repository.

## Capabilities

### 1. List All Categories
Use this to see the available categories of agents.
```bash
bash scripts/catalog.sh list
```

### 2. Search Agents
Find agents by name, description, or capability.
```bash
bash scripts/catalog.sh search <query>
```

### 3. Fetch Agent Definition
Retrieve the full Markdown definition of a specific agent.
```bash
bash scripts/catalog.sh fetch <agent-name>
```

### 4. Invalidate Cache
Clear the local catalog cache and optionally refresh it.
```bash
bash scripts/catalog.sh invalidate [--fetch]
```

## Usage Guidelines
- Always search first if you are unsure of the exact agent name.
- When an agent is fetched, you can suggest it to the user or use its instructions to inform your own behavior.
- The catalog is cached for 12 hours. Use `invalidate` if you need the absolute latest data.
