# 초기 설정 가이드

이 가이드는 APIM Foundry Cost Governance 인프라를 처음부터 배포하는 과정을 안내합니다.

## 사전 요구사항

| 도구 | 최소 버전 | 설치 확인 |
|------|-----------|-----------|
| [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) | 2.50+ | `az --version` |
| [Terraform](https://developer.hashicorp.com/terraform/install) | 1.5+ | `terraform --version` |
| [Python](https://www.python.org/downloads/) | 3.10+ | `python --version` |

Azure CLI 로그인이 필요합니다:

```bash
az login
az account set --subscription "<Azure Subscription ID>"
```

<!-- screenshot: Azure CLI 로그인 성공 화면 -->

### Azure Resource Provider 사전 등록

아래 Resource Provider가 구독에 등록되어 있어야 합니다. 등록 권한이 있다면 다음 명령을 실행합니다:

```bash
az provider register --namespace Microsoft.ApiManagement
az provider register --namespace Microsoft.CognitiveServices
az provider register --namespace Microsoft.Insights
az provider register --namespace Microsoft.OperationalInsights
```

등록 상태 확인:

```bash
az provider show -n Microsoft.ApiManagement --query registrationState -o tsv
```

> **참고:** 엔터프라이즈 구독에서는 Resource Provider 등록 권한이 제한될 수 있습니다. 이 경우 구독 관리자에게 사전 등록을 요청하세요.

## 1. 저장소 클론 및 설정

```bash
git clone https://github.com/jihys/apim-foundry-cost-governance.git
cd apim-foundry-cost-governance
```

## 2. Deployment Config 구성

`terraform.tfvars.example`을 복사하여 실제 값을 입력합니다:

```bash
cd infra
cp terraform.tfvars.example terraform.tfvars
```

`terraform.tfvars`를 편집하여 환경에 맞는 값을 설정합니다:

```hcl
# Azure Subscription ID (Azure Portal > Subscriptions에서 확인)
subscription_id     = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
resource_group_name = "rg-apim-foundry"
location            = "koreacentral"

# APIM Instance 설정
apim_name = "apim-foundry-gw"
apim_sku  = "Developer"  # 프로덕션 환경에서는 Standard_v2 권장

# Foundry Projects — 팀별로 하나씩 정의
foundry_projects = [
  {
    name           = "catalog"
    models         = ["gpt-4o"]
    rate_limit_tpm = null  # null = 기본값 10000 TPM
  },
  {
    name           = "image"
    models         = ["gpt-4o", "dall-e-3"]
    rate_limit_tpm = null
  }
]
```

> **참고:** `apim_sku`는 초기 개발 시 `Developer`를 사용하고, 프로덕션 배포 시 `Standard_v2`로 변경합니다. Developer SKU는 SLA가 제공되지 않습니다.

## 3. Terraform 배포

### 초기화

```bash
terraform init
```

<!-- screenshot: terraform init 성공 출력 -->

### 배포 계획 확인

```bash
terraform plan
```

> **트러블슈팅:** `Resource Provider registration` 관련 409 에러가 발생하면, 위 사전 요구사항의 Resource Provider 등록 단계를 확인하세요.

생성될 리소스 목록을 확인합니다:

- `azurerm_resource_group` — 리소스 그룹
- `azapi_resource.foundry_account` — Foundry 리소스 (AIServices)
- `azapi_resource.project` — 팀별 Foundry Project
- `azapi_resource.model_deployment` — 공유 모델 배포

<!-- screenshot: terraform plan 출력 (리소스 목록) -->

### 배포 실행

> **팁:** 배포 전에 대상 리전에서 모델 가용성을 확인하세요:
> ```bash
> az cognitiveservices model list --location koreacentral -o table
> ```

```bash
terraform apply
```

`yes`를 입력하여 배포를 진행합니다.

<!-- screenshot: terraform apply 완료 화면 -->

## 4. 배포 확인

### Terraform 출력 확인

```bash
terraform output foundry_project_endpoints
```

각 Foundry Project의 Foundry Endpoint URL이 출력됩니다:

```
{
  "catalog" = "https://aoai-foundry-catalog.openai.azure.com/"
  "image"   = "https://aoai-foundry-image.openai.azure.com/"
}
```

### Azure Portal에서 확인

1. [Azure Portal](https://portal.azure.com)에 접속
2. 리소스 그룹 `rg-apim-foundry`로 이동
3. 생성된 리소스 목록을 확인

<!-- screenshot: Azure Portal 리소스 그룹 내 리소스 목록 -->

## 5. APIM Subscription Key 확인

> **참고:** APIM Instance는 후속 이슈에서 배포됩니다. APIM이 배포된 후에 아래 명령으로 APIM Subscription Key를 확인할 수 있습니다:

```bash
terraform output -json apim_subscription_keys
```

각 Foundry Project당 하나의 APIM Subscription Key가 발급되며, 해당 팀원이 공유합니다.

## 다음 단계

- [프로젝트 추가 가이드](02-add-project.md) — 새 Foundry Project 추가 방법
- [사용자 추가 가이드](03-add-user.md) — 팀원을 User Group에 등록
- [사용자 퀵스타트](04-user-quickstart.md) — APIM Subscription Key를 받은 후 API 호출 시작
