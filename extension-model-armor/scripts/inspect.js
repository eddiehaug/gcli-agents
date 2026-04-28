const fs = require('fs');
const { execSync } = require('child_process');

/**
 * 🔒 SECURITY NOTICE: 
 * This script is a Fail-Closed security control. 
 * Any failure in the inspection pipeline MUST result in a 'deny' decision.
 */

function getAccessToken() {
  try {
    return execSync('gcloud auth print-access-token', { encoding: 'utf-8' }).trim();
  } catch (err) {
    throw new Error('Could not retrieve gcloud access token. Ensure gcloud is authenticated.');
  }
}

function getGcloudProject() {
  try {
    return execSync('gcloud config get-value project', { encoding: 'utf-8' }).trim();
  } catch (err) {
    return null;
  }
}

function extractAllTextContent(messages) {
  let combinedText = '';
  for (const message of messages) {
    const content = message.content;
    if (typeof content === 'string') {
      combinedText += `\n${content}`;
    } else if (Array.isArray(content)) {
      // Handle multimodal/parts array
      for (const part of content) {
        if (part.text) {
          combinedText += `\n${part.text}`;
        }
      }
    } else if (typeof content === 'object' && content !== null) {
        // Fallback for single-object content
        if (content.text) combinedText += `\n${content.text}`;
    }
  }
  return combinedText.trim();
}

function deny(reason, systemMessage) {
  process.stdout.write(JSON.stringify({
    decision: 'deny',
    reason: `Model Armor: ${reason}`,
    systemMessage: `🔒 **Turn Blocked by Model Armor**\n${systemMessage || reason}`
  }));
  process.exit(0);
}

async function main() {
  let inputData = '';
  try {
    inputData = fs.readFileSync(0, 'utf-8');
  } catch (err) {
    // Stdin failure is a critical error in a security hook
    deny('Internal Error', 'Unable to read prompt from stdin.');
    return;
  }

  if (!inputData) {
    // If no input data, we cannot verify safety
    deny('Empty Prompt', 'No content submitted for safety verification.');
    return;
  }

  let payload;
  try {
    payload = JSON.parse(inputData);
  } catch (err) {
    deny('Parse Error', 'Failed to parse prompt metadata.');
    return;
  }

  const messages = payload.llm_request?.messages || [];
  const textToAnalyze = extractAllTextContent(messages);

  if (!textToAnalyze) {
    // Proceed if there is truly no text to analyze (e.g. only images, though usually there's a prompt)
    // In a strict environment, we might even deny this, but let's allow if no text parts exist.
    process.stdout.write(JSON.stringify({ decision: 'allow' }));
    return;
  }

  // Configuration
  const PROJECT_ID = process.env.MODEL_ARMOR_PROJECT || getGcloudProject();
  const TEMPLATE_ID = process.env.MODEL_ARMOR_TEMPLATE || 'default-safety-template';
  const REGION = process.env.MODEL_ARMOR_REGION || 'us-central1';

  if (!PROJECT_ID) {
    deny('Config Error', 'GCP Project ID not found. Set MODEL_ARMOR_PROJECT.');
    return;
  }

  try {
    const accessToken = getAccessToken();
    const url = `https://modelarmor.${REGION}.rep.googleapis.com/v1/projects/${PROJECT_ID}/locations/${REGION}/templates/${TEMPLATE_ID}:sanitizeUserPrompt`;

    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${accessToken}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        user_prompt_data: {
          text: textToAnalyze
        }
      })
    });

    if (!response.ok) {
        const errorText = await response.text();
        console.error(`Model Armor API Error (${response.status}): ${errorText}`);
        deny('API Error', `Security check failed (Status: ${response.status}).`);
        return;
    }

    const result = await response.json();

    if (result.filterMatchState === 'MATCH_FOUND') {
      let violationDetails = 'Safety policy violation detected.';
      if (result.filterResults) {
          const findings = Object.entries(result.filterResults)
            .filter(([_, value]) => value.matchState === 'MATCH_FOUND')
            .map(([key, _]) => key)
            .join(', ');
          if (findings) violationDetails = `Violation(s): ${findings}`;
      }
      deny('Security Violation', violationDetails);
    } else {
      // ✅ Prompt is safe
      process.stdout.write(JSON.stringify({ decision: 'allow' }));
    }

  } catch (err) {
    console.error('Error:', err.message);
    deny('Service Error', 'The security inspection service is currently unavailable.');
  }
}

main();
