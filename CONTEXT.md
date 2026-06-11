# APIM Foundry Cost Governance Context

This context defines the durable language for Azure API Management + AI Foundry 프로젝트별 비용 거버넌스 및 사용량 모니터링.

## Language

**APIM Instance**:
Azure API Management 인스턴스. Foundry 엔드포인트의 게이트웨이 역할을 하며, 사용자 인증, 라우팅, 사용량 제한을 담당한다.
_Avoid_: gateway (단독 사용 시 모호), proxy

**Foundry Project**:
Azure AI Foundry 내에서 생성된 프로젝트 단위. 모델 배포, API 키, 리소스 할당의 경계가 된다.
_Avoid_: workspace (Azure ML Workspace와 혼동)

**Project API Key**:
Foundry Project에 할당된 API 키. APIM Subscription을 통해 end-user에게 배포되며, 프로젝트별 사용량 추적의 기본 단위이다.
_Avoid_: token (인증 토큰과 모델 토큰을 혼동)

**APIM Subscription**:
APIM에서 발급되는 구독 키. 하나의 Foundry Project와 매핑되어 end-user가 API에 접근하는 수단이다.
_Avoid_: API key (Foundry API Key와 혼동)

**User Group**:
APIM 내에서 정의된 사용자 그룹. 하나의 Foundry Project에 매핑되어, 해당 프로젝트의 리소스에 접근할 수 있는 사용자 집합이다.
_Avoid_: team, organization

**Token Usage**:
모델 호출 시 소비되는 입력/출력 토큰의 양. App Insights를 통해 프로젝트별, 모델별, 사용자별로 추적된다.
_Avoid_: cost (토큰 사용량과 비용은 별개 개념)

**App Insights Telemetry**:
Application Insights에 수집되는 APIM 요청 로그. 토큰 사용량, 응답 시간, 오류율 등을 포함하며, KQL 쿼리로 분석한다.
_Avoid_: logs (너무 포괄적)

**Cost Dashboard**:
프로젝트별/모델별/사용자별 토큰 사용량과 예상 비용을 시각화하는 대시보드. App Insights Workbook 또는 별도 UI로 구현한다.
_Avoid_: report (일회성 느낌)

## Relationships

- 하나의 **APIM Instance**는 여러 **Foundry Project**를 프록시할 수 있다
- 하나의 **Foundry Project**는 하나의 **User Group**에 매핑된다
- 하나의 **User Group**의 사용자들은 해당 **APIM Subscription**으로 API에 접근한다
- **APIM Instance**는 모든 요청을 **App Insights Telemetry**로 기록한다
- **Token Usage**는 **App Insights Telemetry**에서 추출하여 **Cost Dashboard**에 시각화된다
- **Project API Key**는 APIM 백엔드 설정에서 Foundry 엔드포인트 인증에 사용된다

## Example dialogue

> **Dev:** "사용자가 API를 호출하면 어떤 키를 쓰는 거야?"
> **Domain expert:** "End-user는 **APIM Subscription** 키를 사용합니다. APIM이 내부적으로 해당 **Foundry Project**의 **Project API Key**로 변환하여 Foundry에 전달합니다."

> **Dev:** "프로젝트별 비용을 어떻게 나누지?"
> **Domain expert:** "각 **APIM Subscription**이 하나의 **Foundry Project**에 매핑되므로, **App Insights Telemetry**에서 subscription-id 기준으로 **Token Usage**를 집계하면 프로젝트별 비용이 나옵니다."

## Flagged ambiguities

- "API key"가 APIM Subscription 키와 Foundry Project API Key 두 가지를 의미할 수 있음 — 항상 구분하여 사용
- "토큰"이 인증 토큰(OAuth)과 모델 토큰(prompt/completion tokens)을 모두 의미할 수 있음 — "Token Usage"는 모델 토큰만 지칭
