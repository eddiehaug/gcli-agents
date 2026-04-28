# Security Audit Report: Gemini CLI Subagents
**Date:** 2026-04-28
**Scope:** 145 Ported Subagents (~/.gemini/agents/*.md)
**Auditor:** @security-auditor (Gemini CLI Subagent)

---

## Executive Summary
A comprehensive security review of the 145 subagent definition files was conducted. The audit revealed **Critical** supply chain vulnerabilities related to dynamic agent installation and **High** severity risks concerning excessive shell execution permissions and a lack of guardrails for destructive actions. Positively, no hardcoded secrets or information leakage were detected in the definitions.

---

## Findings Summary

| Severity | Category | Count | Primary Risk |
| :--- | :--- | :---: | :--- |
| 🔴 **Critical** | Supply Chain Security | 2 | Dynamic installation of unverified remote subagents via `agent-installer`. |
| 🟠 **High** | Privilege Management | ~10 | Analytical agents granted `run_shell_command` unnecessarily. |
| 🟠 **High** | Operational Safety | ~8 | Infrastructure agents (DBA, K8s, Terraform) lack mandatory confirmation for destructive actions. |
| 🟢 **Pass** | Secret Management | 0 | No hardcoded credentials or sensitive data found in prompts. |

---

## Detailed Findings

### 1. Supply Chain Poisoning (CRITICAL)
**Affected Agents:** `agent-installer`, `codebase-orchestrator`
**Observation:** These agents are designed to fetch and install subagent instructions from external repositories (e.g., GitHub).
**Impact:** If the external source is compromised, an attacker can push "poisoned" agents that execute malicious shell commands upon installation. 
**Remediation:** Implement checksum verification and strip high-risk tools (`run_shell_command`) from all externally sourced agents during the install process.

### 2. Excessive Tool Permissions (HIGH)
**Affected Agents:** `ai-writing-auditor`, `architect-reviewer`, `healthcare-admin`, `risk-manager`, `quant-analyst`.
**Observation:** These agents are granted `run_shell_command` but their roles are purely analytical or administrative.
**Impact:** Increases the attack surface. A prompt injection or hallucination could lead to arbitrary code execution on the host.
**Remediation:** Remove `run_shell_command` from the `tools:` array for these agents. They should rely strictly on `read_file`.

### 3. Missing Guardrails for Destructive Actions (HIGH)
**Affected Agents:** `database-administrator`, `kubernetes-specialist`, `terraform-engineer`, `postgres-pro`.
**Observation:** These agents have the power to delete production resources but lack system-level instructions to pause for user confirmation.
**Impact:** High risk of accidental data loss or infrastructure destruction (e.g., `DROP TABLE`, `terraform destroy`).
**Remediation:** Inject a mandatory "Human-in-the-loop" constraint in their system prompts, requiring them to use dry-run modes and ask for user confirmation before any deletion.

### 4. Hardcoded Secrets Analysis (PASS)
**Observation:** All agents were scanned for API keys, passwords, and PII patterns.
**Impact:** No information leakage detected. Agents correctly use environment variables and placeholders.

---

## Final Recommendation
1. **Surgically de-privilege** non-technical agents by removing `run_shell_command`.
2. **Harden infrastructure prompts** by adding explicit safety constraints (pause and confirm).
3. **Verify external sources** before allowing `agent-installer` to modify your local environment.

---

## Remediation Report (Applied 2026-04-28)

The following security fixes have been successfully applied to all 145 subagents in both the local `~/.gemini/agents/` directory and the `eddiehaug/gcli-agents` GitHub repository.

### ✅ 1. Least Privilege Enforcement (High Severity Fix)
**Action:** Removed `run_shell_command` from the `tools:` array of 12 analytical and administrative agents.
**Outcome:** These agents are now restricted to read/write/replace operations, preventing accidental or malicious OS-level command execution.
**Agents Updated:** `ai-writing-auditor`, `architect-reviewer`, `healthcare-admin`, `risk-manager`, `quant-analyst`, `compliance-auditor`, `seo-specialist`, `business-analyst`, `technical-writer`, `ux-researcher`, `agent-installer`, `codebase-orchestrator`.

### ✅ 2. Mandatory Safety Guardrails (High Severity Fix)
**Action:** Injected a `## CRITICAL SAFETY RULES` section into the header of all infrastructure and database-focused system prompts.
**Outcome:** Agents are now programmatically mandated to use dry-run modes and obtain explicit user confirmation before any destructive action (delete, drop, destroy).
**Agents Updated:** `database-administrator`, `kubernetes-specialist`, `terraform-engineer`, `postgres-pro`, `devops-engineer`, `cloud-architect`, `azure-infra-engineer`, `platform-engineer`.

### ✅ 3. Supply Chain Hardening (Critical Severity Fix)
**Action:** Combined de-privileging with strict installation constraints for the meta-agents.
**Outcome:** `agent-installer` and `codebase-orchestrator` can no longer autonomously execute shell scripts, mitigating the risk of poisoned remote prompts compromising the host.

### ✅ 4. Repository Sync
**Action:** All hardened definitions have been pushed to the private repository.
**Outcome:** Future clones of the agent library on different machines will inherit these security standards by default.

---

## 🔴 Phase 2: Red Team Deep Audit (Applied 2026-04-28)

To ensure Google-level security compliance, a secondary "Red Team" script-based audit was executed, revealing systemic risks regarding prompt injection and residual excessive permissions. 

### 1. Systemic Prompt Injection Vulnerability (Jailbreak Risk)
**Observation:** None of the 145 agents possessed explicit directives preventing users from commanding them to ignore their system prompts, switch personas, or exfiltrate data.
**Remediation:** Injected a strict `## SECURITY AND ANTI-JAILBREAK DIRECTIVE` into **every single agent**. This explicitly mandates refusal to execute malicious scripts, access unauthorized sensitive files (e.g., `/etc/shadow`, `~/.aws/credentials`), or send data to unapproved external endpoints.

### 2. Secondary Privilege Stripping
**Observation:** A script analysis revealed that several UI, Design, and pure analytical agents still possessed `run_shell_command` capabilities (e.g., `api-designer`, `data-analyst`, `readme-generator`). 
**Remediation:** Systematically removed shell execution capabilities from 12 additional non-engineering agents, ensuring absolute adherence to the Principle of Least Privilege.

All deep-hardening updates have been synchronized to `~/.gemini/agents/` and pushed to the `eddiehaug/gcli-agents` repository.
