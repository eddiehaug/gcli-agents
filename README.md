# Gemini CLI Subagents

A curated collection of **145+ specialized subagents** and skills for the Gemini CLI, designed to handle everything from core development and infrastructure to business strategy and research.

Each agent in this library has been **hardened for security**, following the principle of least privilege and including anti-jailbreak directives.

## 🚀 Installation

### Option 1: Global Installation (Recommended)
Clone this repository and copy the agents and skills to your global Gemini directory:

```bash
git clone https://github.com/eddiehaug/gcli-agents.git
cd gcli-agents

# Install agents
cp -r agents/* ~/.gemini/agents/

# Install skills
mkdir -p ~/.gemini/skills
cp -r skills/* ~/.gemini/skills/
```

### Option 2: Use the Subagent Catalog
You can search and fetch agents directly from within Gemini CLI using the `subagent-catalog` skill included in this repo.

1. Install the skill: `cp -r skills/subagent-catalog ~/.gemini/skills/`
2. In Gemini CLI, ask: *"Search the catalog for security agents"* or *"Fetch the definition for python-pro"*

---

## 📚 Categories

The library is organized into 10 logical categories:

1.  [**Core Development**](agents/01-core-development/) - Backend, frontend, fullstack, and mobile experts.
2.  [**Language Specialists**](agents/02-language-specialists/) - Deep expertise in Python, TypeScript, Rust, Go, .NET, and more.
3.  [**Infrastructure**](agents/03-infrastructure/) - DevOps, Kubernetes, Terraform, and Cloud (AWS/GCP/Azure).
4.  [**Quality & Security**](agents/04-quality-security/) - Security auditors, penetration testers, and QA automation.
5.  [**Data & AI**](agents/05-data-ai/) - Data scientists, ML engineers, and LLM architects.
6.  [**Developer Experience**](agents/06-developer-experience/) - Tooling, documentation, and workflow optimization.
7.  [**Specialized Domains**](agents/07-specialized-domains/) - Fintech, Blockchain, Healthcare, and IoT.
8.  [**Business & Product**](agents/08-business-product/) - Product managers, technical writers, and scrum masters.
9.  [**Meta-Orchestration**](agents/09-meta-orchestration/) - Multi-agent coordination and state management.
10. [**Research & Analysis**](agents/10-research-analysis/) - Market researchers, trend analysts, and literature searchers.

---

## 🛡️ Security Hardening

All agents in this repository have been audited and hardened:
- **Principle of Least Privilege:** Purely analytical agents do not have shell access.
- **Anti-Jailbreak Directives:** Every agent contains strict instructions to refuse malicious requests or persona switching.
- **Human-in-the-loop:** Critical infrastructure agents (DBA, Terraform, K8s) are mandated to pause and request confirmation before destructive actions.

---

## 📖 Subagent Structure

Each subagent uses the Gemini CLI Markdown format:

```yaml
---
name: agent-name
description: "Brief description for auto-discovery"
tools: [read_file, grep_search, ...]
model: gemini-3.1-pro-preview  # Optimized for the task
skills:
  - relevant-skill-name
---

You are an expert...
```

### Model Selection
Agents are pre-configured to use the most efficient model for their role:
*   **Gemini 3.1 Pro:** Used for complex reasoning, security audits, and architectural planning.
*   **Gemini 3.1 Flash:** Used for fast execution, coding assistance, and documentation.
*   **Gemini Deep Research:** Used for multi-step information retrieval, trend analysis, and evidence synthesis across scientific and market domains.

---

## 📄 License
MIT License. See [LICENSE](LICENSE) for details.
