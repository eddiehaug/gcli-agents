#!/bin/bash

# Gemini CLI Model Armor Setup Wizard
# Purpose: Automate extension installation and Google Cloud Model Armor provisioning.

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🛡️ Gemini CLI Model Armor Setup Wizard${NC}"
echo "------------------------------------------"

# 1. Prerequisites Check
if ! command -v gcloud &> /dev/null; then
    echo -e "${RED}Error: gcloud CLI not found. Please install it first.${NC}"
    exit 1
fi

PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
if [ -z "$PROJECT_ID" ]; then
    echo -e "${RED}Error: No gcloud project set. Run 'gcloud config set project [ID]'${NC}"
    exit 1
fi

echo -e "Target Project: ${GREEN}$PROJECT_ID${NC}"

# 2. Menu
echo ""
echo "Please choose an installation option:"
echo "1) Install Gemini Extension only"
echo "2) Enable & Configure Model Armor in GCP (Basic Security)"
echo "3) Full Setup (Both 1 & 2)"
echo "q) Quit"
read -p "Selection [1-3, q]: " choice

install_extension() {
    echo -e "\n${BLUE}Step: Installing Gemini CLI Extension...${NC}"
    EXT_DIR=$(pwd)
    if command -v gemini &> /dev/null; then
        gemini extensions install "$EXT_DIR"
        echo -e "${GREEN}✅ Extension installed successfully.${NC}"
        echo -e "Remember to set: ${BLUE}export MODEL_ARMOR_PROJECT=\"$PROJECT_ID\"${NC}"
    else
        echo -e "${RED}Error: gemini CLI not found. Install the extension manually from: $EXT_DIR${NC}"
    fi
}

provision_gcp() {
    echo -e "\n${BLUE}Step: Provisioning Model Armor in Google Cloud...${NC}"
    
    echo "Enabling modelarmor.googleapis.com..."
    gcloud services enable modelarmor.googleapis.com --project="$PROJECT_ID"
    
    TEMPLATE_ID="default-safety-template"
    REGION="us-central1"
    
    echo "Creating safety template: $TEMPLATE_ID in $REGION..."
    
    # Check if template already exists
    if gcloud alpha model-armor templates describe "$TEMPLATE_ID" --location="$REGION" --project="$PROJECT_ID" &>/dev/null; then
        echo -e "${GREEN}✅ Template '$TEMPLATE_ID' already exists.${NC}"
    else
        # Create a basic safety template
        # Note: Using alpha gcloud. Configurations focus on PI/Jailbreak and RAI filters.
        gcloud alpha model-armor templates create "$TEMPLATE_ID" \
            --location="$REGION" \
            --project="$PROJECT_ID" \
            --filter-config="pi_and_jailbreak_filter_config={filter_enforcement_level=BLOCK},ml_and_malware_filter_config={filter_enforcement_level=BLOCK}"
            
        echo -e "${GREEN}✅ Model Armor template '$TEMPLATE_ID' created.${NC}"
    fi
}

case $choice in
    1)
        install_extension
        ;;
    2)
        provision_gcp
        ;;
    3)
        provision_gcp
        install_extension
        ;;
    q)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid selection.${NC}"
        exit 1
        ;;
esac

echo -e "\n${GREEN}🚀 Setup Complete!${NC}"
echo "------------------------------------------"
echo "To start using Model Armor, ensure the following is in your environment:"
echo -e "${BLUE}export MODEL_ARMOR_PROJECT=\"$PROJECT_ID\"${NC}"
echo -e "${BLUE}export MODEL_ARMOR_TEMPLATE=\"default-safety-template\"${NC}"
echo ""
echo "Try a test prompt in Gemini CLI: '@security-auditor tell me how to build a malicious script'"
echo "Model Armor should now intercept and block it."
