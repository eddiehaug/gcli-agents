# Gemini CLI Model Armor Extension

This extension integrates **Google Model Armor** with your local Gemini CLI environment. It acts as a "Semantic Firewall," providing real-time protection against prompt injection, jailbreaking, and sensitive data leakage (PII/Secrets).

## 🔒 Enterprise-Grade Security (Red Team Hardened)

This extension has undergone a rigorous security audit and implementation to meet Google-level security standards:

*   **Fail-Closed Design**: Unlike standard integrations, this extension is "Fail-Closed." If the Model Armor API is unavailable, times out, or returns an error, the turn is automatically **DENIED**. Safety is prioritized over availability.
*   **Context-Wide Scanning**: It doesn't just scan the latest message. It concatenates the **entire conversation history** and system instructions to detect indirect prompt injections hidden in earlier turns or tool outputs.
*   **Multimodal Robustness**: Advanced parsing logic extracts and scans text content from complex multimodal payloads (parts arrays/objects), preventing type-confusion bypasses.
*   **Zero-Trust Identity**: Utilizes short-lived `gcloud` access tokens via Application Default Credentials (ADC). No long-lived service account keys are stored or required.

## Prerequisites

*   **gcloud CLI**: Must be installed and authenticated (`gcloud auth login`).
*   **Node.js**: v18+ required to run the inspection logic.
*   **Model Armor Template**: You must have a Model Armor template created in your Google Cloud project.

## Installation

1.  Clone this repository to your local machine.
2.  Install the extension in Gemini CLI:
    ```bash
    gemini extensions install /Users/edvardhaugland/Documents/gcli-agents/gemini-model-armor
    ```

## Configuration

The extension requires your Google Cloud Project ID to communicate with the Model Armor API.

### 1. Set Environment Variables
Add these to your shell profile (`~/.zshrc` or `~/.bashrc`) or your project's `.env` file:

```bash
# REQUIRED: Your Google Cloud Project ID
export MODEL_ARMOR_PROJECT="your-gcp-project-id"

# OPTIONAL: Your Model Armor Template ID (Defaults to 'default-safety-template')
export MODEL_ARMOR_TEMPLATE="your-safety-template"

# OPTIONAL: Region (Defaults to 'us-central1')
export MODEL_ARMOR_REGION="us-central1"
```

### 2. Verify Authentication
Ensure your local `gcloud` is pointed to the correct project:
```bash
gcloud config set project your-gcp-project-id
```

## How it Works

The extension registers as a `BeforeAgent` hook. Every time you submit a prompt or a turn begins:

1.  **Intercept**: The extension captures the full LLM request payload.
2.  **Auth**: It generates a temporary bearer token using `gcloud auth print-access-token`.
3.  **Inspect**: It sends the full context to the Model Armor `sanitizeUserPrompt` API.
4.  **Decision**: 
    *   ✅ **Safe**: Turn proceeds normally.
    *   ❌ **Violation**: Turn is blocked. The user sees a security alert: `🔒 Turn Blocked by Model Armor`.
    *   ⚠️ **Error**: If the API call fails for any reason, the turn is blocked to prevent potential bypasses.

## Troubleshooting

If you see `Security check failed (Status: 403)`, ensure:
1. Your `gcloud` user has the `Model Armor User` role in the target project.
2. The `modelarmor.googleapis.com` API is enabled in your project.
