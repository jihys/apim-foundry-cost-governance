# APIM Foundry Cost Governance Context

This context defines the durable language for Azure API Management + AI Foundry 프로젝트별 비용 거버넌스 및 사용량 모니터링.

## Language

**APIM Instance**:
Azure API Management 인스턴스. Foundry 엔드포인트의 게이트웨이 역할을 하며, 사용자 인증, 라우팅, 사용량 제한을 담당한다.
_Avoid_: gateway (단독 사용 시 모호), proxy

**Foundry Resource**:
공유 `Microsoft.CognitiveServices/accounts` 리소스 (`kind=AIServices`). 환경당 1개 존재하며, 모든 **Foundry Project**와 모델 배포를 포함한다. 리소스 수준의 API 키를 발급하고, AI Foundry Portal 접근의 진입점 역할을 한다. (→ ADR-001)
_Avoid_: OpenAI account (legacy `kind=OpenAI` 구조와 혼동), hub (legacy 개념)

**Foundry Project**:
**Foundry Resource** 하위의 자식 리소스 (`Microsoft.CognitiveServices/accounts/projects`). 팀(catalog팀, image팀 등)과 1:1로 매핑된다. 각 프로젝트는 자체 **Foundry Endpoint**와 독립된 RBAC 경계를 가지며, AI Foundry Portal에서 팀별 격리된 작업 공간을 제공한다. 모델 배포는 프로젝트가 아닌 상위 **Foundry Resource** 수준에서 공유된다.
_Avoid_: workspace (Azure ML Workspace와 혼동), hub (legacy 개념), standalone account (독립 계정이 아님)

**Foundry Endpoint**:
**Foundry Project** 자식 리소스에서 제공하는 모델 호출 엔드포인트. APIM이 백엔드로 프록시하는 대상이다. 각 Foundry Project마다 독립된 엔드포인트를 가지며, 공유 모델 배포에 접근할 수 있다.
_Avoid_: deployment endpoint (너무 포괄적), hub endpoint (legacy)

**Project API Key**:
**Foundry Resource** 수준에서 발급되는 API 키. 모든 프로젝트가 동일한 키를 공유한다. APIM 백엔드 설정에서 **Foundry Endpoint** 인증에 사용되며, end-user에게 직접 노출되지 않는다. 프로젝트별 접근 격리는 **APIM Subscription** 키와 라우팅 정책으로 달성한다.
_Avoid_: token (인증 토큰과 모델 토큰을 혼동)

**APIM Product** (implementation detail):
APIM 내부에서 Foundry Project와 1:1로 매핑되는 리소스. API 묶음, 접근 정책, Subscription 발급의 단위이다. 도메인 대화에서는 "Product"를 쓰지 않고 항상 **Foundry Project**로 지칭한다.
_Avoid_: product (도메인 용어가 아님, 구현 상세)

**Service Key**:
Terraform이 Foundry Project(= APIM Product)당 1개 생성하는 APIM Subscription 키. CI/CD 파이프라인, 자동화 스크립트, 서비스 계정 등 시스템 용도로 사용한다. 사람이 직접 사용하지 않는다.
_Avoid_: team key (사람이 공유하는 것과 혼동), shared key

**Personal Key**:
사용자가 Developer Portal에서 Product에 직접 구독하여 발급받는 개인별 APIM Subscription 키. 사용자별 사용량 추적의 단위이다. 사용자는 자신의 **User Group**에 연결된 Product에만 구독할 수 있다.
_Avoid_: API key (Foundry API Key와 혼동), Azure Subscription (과금 단위와 혼동)

**Custom User Header** (확장 옵션):
사용자별 토큰 추적이 필요할 때, end-user가 요청 시 `x-user-id` 헤더를 포함하도록 안내한다. APIM Policy에서 이 값을 App Insights에 기록하여 프로젝트 내 개별 사용자 추적을 가능하게 한다. 초기 배포에는 포함하지 않으며, 필요 시 확장한다.
_Avoid_: 인증 토큰과 혼동하지 않도록 주의

**Azure Subscription**:
Azure 과금 및 리소스 관리의 최상위 단위. 하나의 Azure Subscription 안에 APIM Instance, Foundry Resource, 여러 Foundry Project가 생성된다.
_Avoid_: subscription (단독 사용 시 APIM Subscription과 혼동)

**User Group**:
APIM 내에서 정의된 사용자 그룹. 하나의 Foundry Project에 매핑되어, 해당 프로젝트의 리소스에 접근할 수 있는 사용자 집합이다. APIM Developer Portal에 사용자를 등록하고 그룹으로 관리하며, 사용자별 키 자가 발급/재발급 등 셀프서비스를 제공한다.
_Avoid_: team, organization

**Token Usage**:
모델 호출 시 소비되는 입력/출력 토큰의 양. App Insights를 통해 프로젝트별, 모델별, 사용자별로 추적된다.
_Avoid_: cost (토큰 사용량과 비용은 별개 개념)

**App Insights Telemetry**:
Application Insights에 수집되는 APIM 요청 로그. APIM outbound policy에서 Foundry 응답의 `usage` 필드(prompt_tokens, completion_tokens, total_tokens)를 추출하여 custom dimension으로 기록한다. KQL 쿼리로 프로젝트별/모델별 토큰 사용량을 분석한다.
_Avoid_: logs (너무 포괄적), body 전체 저장 (스토리지 비효율)

**Cost Dashboard**:
프로젝트별/모델별 토큰 사용량과 예상 비용을 시각화하는 **App Insights Workbook** 대시보드. Terraform으로 자동 배포되며, end-user는 Azure Portal에서 바로 확인할 수 있다. Azure Retail Prices API(`prices.azure.com`)를 Workbook 내에서 직접 호출하여 모델별 최신 단가를 동적으로 반영한다. 한번 배포하면 추가 관리 없이 최신 단가 기반 비용 계산이 유지된다.
_Avoid_: report (일회성 느낌), 수동 단가 관리 (IT 비전문 고객 대상)

## Relationships

- 하나의 **Azure Subscription** 안에 하나의 **APIM Instance**와 하나의 **Foundry Resource**가 존재한다
- 하나의 **Foundry Resource** 아래에 여러 **Foundry Project**와 공유 모델 배포가 존재한다
- 하나의 **Foundry Project**는 자체 **Foundry Endpoint**를 가진다
- 하나의 **APIM Instance**는 여러 **Foundry Endpoint**를 백엔드로 프록시한다
- 하나의 **Foundry Project**는 하나의 **APIM Product**와 1:1 매핑된다
- 하나의 **Foundry Project**는 하나의 **User Group**에 매핑된다
- 하나의 **Foundry Project**는 1개의 **Service Key**(Terraform 관리)와 N개의 **Personal Key**(Developer Portal 셀프서비스)를 가진다
- 사용자는 **User Group**에 할당된 후, 해당 그룹의 Product에 **1개의 Personal Key**만 발급받을 수 있다 (`subscriptions_limit = 1`)
- **Service Key**는 CI/CD, 자동화 스크립트 등 시스템 용도로 사용한다. 사람이 직접 사용하지 않는다
- **Personal Key**는 사용자별 사용량 추적의 단위이다. Developer Portal에서 셀프서비스로 발급받는다
- end-user는 **APIM Instance** 엔드포인트 하나에 **Personal Key**를 보내면, APIM이 해당 키의 Product에 연결된 **Foundry Endpoint**로 자동 라우팅한다
- **APIM Instance**는 모든 요청을 **App Insights Telemetry**로 기록한다
- **Token Usage**는 **App Insights Telemetry**에서 추출하여 **Cost Dashboard**에 사용자별/그룹별/모델별로 시각화된다
- **Project API Key**는 **Foundry Resource** 수준에서 발급되며, APIM 백엔드 설정에서 **Foundry Endpoint** 인증에 사용된다

## Example dialogue

> **Dev:** "사용자가 API를 호출하면 어떤 키를 쓰는 거야?"
> **Domain expert:** "End-user는 **APIM Subscription** 키를 사용합니다. APIM이 내부적으로 해당 **Foundry Project**의 **Project API Key**로 변환하여 Foundry에 전달합니다."

> **Dev:** "프로젝트별 비용을 어떻게 나누지?"
> **Domain expert:** "각 **APIM Subscription**이 하나의 **Foundry Project**에 매핑되므로, **App Insights Telemetry**에서 subscription-id 기준으로 **Token Usage**를 집계하면 프로젝트별 비용이 나옵니다."

**Deployment Config (terraform.tfvars)**:
Terraform 인프라 배포에 필요한 설정 파일. Azure subscription, 리소스 이름, Foundry Project 리스트(이름 + 모델 배포 목록)를 담는다. 프로젝트별 rate limit은 기본값이 적용되며, 필요 시 프로젝트 단위로 override할 수 있다.
_Avoid_: .env (런타임 설정과 혼동)

**Runtime Config (.env)**:
배포 완료 후 end-user가 API를 테스트/호출할 때 필요한 런타임 설정 파일. APIM 엔드포인트, APIM Subscription Key 등을 담는다.
_Avoid_: terraform.tfvars (인프라 설정과 혼동)

**Operations Guide**:
Foundry Project 추가, 사용자 추가 등 운영 작업을 안내하는 step-by-step 텍스트 가이드. `docs/guidebook/`에 위치한다. 프로젝트 추가는 A) Terraform 재실행(권장)과 B) Azure Portal 수동 방식 모두 안내하되, Terraform을 기본 권장으로 명시한다. 스크린샷 위치는 `<!-- screenshot: 설명 -->` 플레이스홀더로 남기고, 실제 환경에서 수동으로 캡처하여 채운다.
_Avoid_: Playwright 자동 캡처 (MFA 이슈, Portal UI 변경에 취약)

## Flagged ambiguities

- "API key"가 APIM Subscription 키와 Foundry Project API Key 두 가지를 의미할 수 있음 — 항상 구분하여 사용
- "토큰"이 인증 토큰(OAuth)과 모델 토큰(prompt/completion tokens)을 모두 의미할 수 있음 — "Token Usage"는 모델 토큰만 지칭
- "subscription"이 Azure Subscription(과금 단위)과 APIM Subscription(API 키)을 모두 의미할 수 있음 — 항상 "Azure Subscription" 또는 "APIM Subscription"으로 구분
- "프로젝트"는 항상 **Foundry Project**(팀 단위)를 지칭. APIM Product는 구현 상세이므로 도메인 대화에서 사용하지 않음
