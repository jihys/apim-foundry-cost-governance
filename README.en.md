# apim-foundry-cost-governance

> 🇰🇷 [한국어 버전](README.md)

Per-project cost governance and usage monitoring with Azure API Management + AI Foundry

## Overview

Use APIM to separate AI Foundry Projects by User Group, assign per-project API Keys, and enable end-users to call models through a single gateway. Monitor per-project, per-model, and per-user Token Usage via Application Insights.

## Architecture

```
End User → APIM (Subscription Key) → AI Foundry Project (Project API Key) → Model Deployment
                ↓
        App Insights (Telemetry)
                ↓
        Cost Dashboard (KQL Queries)
```

## Components

| Component | Purpose |
|---|---|
| **APIM Instance** | API gateway — authentication, routing, rate limiting |
| **Foundry Project** | Per-project model deployment and API key management |
| **User Group** | APIM user group → Foundry Project mapping |
| **App Insights** | Request logging, Token Usage collection |
| **Cost Dashboard** | Per-project / per-model / per-user usage visualization |

## Project Structure

```
apim-foundry-cost-governance/
├── infra/                    # Terraform IaC
│   ├── modules/
│   │   ├── apim/             # APIM instance, products, subscriptions
│   │   ├── foundry/          # AI Foundry hub, projects, deployments
│   │   ├── monitoring/       # App Insights, Log Analytics
│   │   └── networking/       # VNet, Private Endpoints (optional)
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars.example
├── scripts/                  # Automation scripts
│   ├── setup-apim.py         # APIM configuration automation
│   ├── create-foundry-project.py
│   ├── assign-keys.py        # Key generation and assignment
│   └── query-usage.py        # Usage queries
├── src/                      # Reusable modules
│   ├── apim/
│   ├── foundry/
│   └── monitoring/
├── docs/                     # Guidebook & architecture
│   ├── guidebook/
│   ├── adr/
│   └── agents/
├── notebooks/                # Analysis & demos
├── tests/
├── .github/
│   ├── agents/               # AI agent definitions
│   └── skills/               # Agent skills
├── AGENTS.md
├── CONTEXT.md
└── README.md
```

## Setup

```bash
# Python environment
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# Terraform initialization
cd infra
terraform init
```

## Guidebook Sections (Planned)

1. **APIM Setup and Configuration** — Provision the APIM Instance with Terraform
2. **Foundry Project Creation** — Per-project model deployment and key generation
3. **User Group Mapping** — Link APIM Subscriptions ↔ Foundry Projects
4. **App Insights Monitoring** — Analyze Token Usage with KQL queries
5. **Cost Dashboard** — Per-project / per-model / per-user cost visualization
