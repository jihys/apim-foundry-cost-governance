# apim-foundry-cost-governance

Azure API Management + AI Foundry 프로젝트별 비용 거버넌스 및 사용량 모니터링

## Overview

APIM을 통해 AI Foundry 프로젝트를 User Group별로 분리하고, 프로젝트별 API Key를 할당하여 end-user가 사용할 수 있도록 합니다. Application Insights를 통해 프로젝트별/모델별/사용자별 토큰 사용량을 모니터링합니다.

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
| **APIM Instance** | API 게이트웨이, 인증, 라우팅, 사용량 제한 |
| **Foundry Project** | 프로젝트별 모델 배포 및 API 키 관리 |
| **User Group** | APIM 사용자 그룹 → Foundry Project 매핑 |
| **App Insights** | 요청 로그, 토큰 사용량 수집 |
| **Cost Dashboard** | 프로젝트별/모델별/사용자별 사용량 시각화 |

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
│   ├── setup-apim.py         # APIM 구성 자동화
│   ├── create-foundry-project.py
│   ├── assign-keys.py        # Key 생성 및 할당
│   └── query-usage.py        # 사용량 조회
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
# Python 환경
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# Terraform 초기화
cd infra
terraform init
```

## Development Workflow

이 프로젝트는 skills-first 에이전트 워크플로우를 사용합니다.

- **Orchestrator**: `@orchestrator` — 멀티 에이전트 오케스트레이션
- **Planner**: `@planner` — PRD 생성, 이슈 분해
- **Senior Developer**: `@senior-developer` — TDD 구현, 디버깅
- **Researcher**: `@researcher` — 코드베이스 탐색, 패턴 분석
- **Reviewer**: `@reviewer` — 코드 리뷰, 보안 검토
- **Documentation Writer**: `@documentation-writer` — 문서화

## Guidebook Sections (Planned)

1. **APIM 설치 및 구성** — Terraform으로 APIM 인스턴스 프로비저닝
2. **Foundry Project 생성** — 프로젝트별 모델 배포 및 키 생성
3. **User Group 매핑** — APIM Subscription ↔ Foundry Project 연결
4. **App Insights 모니터링** — KQL 쿼리로 토큰 사용량 분석
5. **Cost Dashboard** — 프로젝트별/모델별/사용자별 비용 시각화
