# 초기 설정 가이드

> 🇺🇸 [English Version](en/01-initial-setup.md)

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
apim_sku  = "Developer_1"  # 프로덕션 환경에서는 StandardV2_1 권장

# Foundry Projects — 팀별로 하나씩 정의 (단순 문자열 리스트)
foundry_projects = ["catalog-project", "image-project"]

# 공유 모델 배포
model_deployments = [
  {
    name          = "gpt-4o"
    model_name    = "gpt-4o"
    model_version = "2024-11-20"
  }
]
```

> **참고:** `apim_sku`는 초기 개발 시 `Developer_1`을 사용하고, 프로덕션 배포 시 `StandardV2_1`로 변경합니다. Developer SKU는 SLA가 제공되지 않습니다.

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

### Developer Portal 초기 설정 (최초 1회)

Terraform 배포 후 Developer Portal을 활성화하려면:

1. Azure Portal → API Management (`apim-foundry-gw-jihys`) → 왼쪽 메뉴 **Developer portal**
2. 상단 툴바의 **"Developer portal"** 링크 클릭 → 관리 인터페이스가 새 탭에서 열림
3. 관리 인터페이스 로드 완료 후, Azure Portal 탭으로 돌아가서 페이지 새로고침
4. **"Publish"** 버튼 클릭

> 이 과정은 최초 배포 시 1회만 필요합니다. 이후 API/Product 변경은 Terraform이 자동 반영합니다.

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

## 5. Service Key 확인 (CI/CD용)

Terraform은 각 Foundry Project에 대해 **Service Key**를 자동 생성합니다. Service Key는 CI/CD 파이프라인, 자동화 스크립트 등 시스템 용도로만 사용하며, 사람이 직접 사용하지 않습니다.

```bash
terraform output -json apim_subscription_keys
```

> **참고:** 개발자 개인은 Developer Portal에서 셀프서비스로 **Personal Key**를 발급받아 사용합니다. 자세한 내용은 [사용자 추가 가이드](03-add-user.md)를 참고하세요.

## 다음 단계

- [프로젝트 추가 가이드](02-add-project.md) — 새 Foundry Project 추가 방법
- [사용자 추가 가이드](03-add-user.md) — 사용자 등록 및 User Group 할당, Personal Key 발급 안내
- [사용자 퀵스타트](04-user-quickstart.md) — Personal Key로 API 호출 시작
