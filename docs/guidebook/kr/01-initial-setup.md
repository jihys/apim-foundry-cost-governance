# 초기 설정 가이드

> 🇺🇸 [English Version](../en/01-initial-setup.md)

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

# 현재 활성 구독 확인
az account show --query "{name:name, id:id}" -o table
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

> **참고:** Resource Provider 등록은 15~30분 소요될 수 있습니다. 모든 Provider가 `Registered` 상태가 될 때까지 확인한 후 `terraform apply`를 진행하세요.

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
subscription_id     = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
resource_group_name = "rg-apim-foundry"
location            = "koreacentral"

apim_name            = "apim-foundry-gw-mycompany"
apim_sku             = "Developer_1"
apim_publisher_name  = "AI Platform Team"
apim_publisher_email = "admin@example.com"

foundry_resource_name = "aoai-foundry-mycompany"
foundry_projects      = ["team-a-project", "team-b-project"]

model_deployments = [
  {
    name          = "gpt-4o"
    model_name    = "gpt-4o"
    model_version = "2024-11-20"
  }
]
```

> ⚠️ `apim_name`은 Azure 전역에서 고유해야 합니다. `apim-{company}-{env}` 형식을 권장합니다.

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
> # 리전에서 사용 가능한 모델 버전 확인
> az cognitiveservices model list --location koreacentral \
>   --query "[?model.name=='gpt-4o'].{name:model.name, version:model.version, status:model.lifecycleStatus}" \
>   -o table
> ```

```bash
terraform apply
```

`yes`를 입력하여 배포를 진행합니다.

<!-- screenshot: terraform apply 완료 화면 -->

### Developer Portal 초기화 및 퍼블리시 (최초 1회, 필수)

> ⚠️ **이 단계를 건너뛰면 Developer Portal에서 사용자 Sign up이 불가능합니다.**

Terraform은 APIM 인스턴스와 CORS 정책을 자동 생성하지만, Developer Portal의 내부 인증 시스템은 관리자가 Portal 관리 UI를 최초 1회 열어야 초기화됩니다.

1. Azure Portal → API Management (`<your-apim-name>`) → 왼쪽 메뉴 **Developer portal**
2. 상단 툴바의 **"Developer portal"** 링크 클릭 → 관리 인터페이스가 새 탭에서 열림
3. 관리 인터페이스가 완전히 로드될 때까지 대기 (이 과정에서 내부 인증 시스템이 초기화됩니다)
4. Azure Portal 탭으로 돌아가서 **"Publish"** 버튼 클릭

퍼블리시 상태는 Azure CLI로도 확인할 수 있습니다:

```bash
az rest --method GET \
  --uri "https://management.azure.com/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.ApiManagement/service/<your-apim-name>/portalRevisions/initial-publish?api-version=2022-08-01" \
  --query properties.status -o tsv
```

`completed`가 출력되면 성공입니다.

> CORS는 Terraform이 자동 설정하므로 별도 설정이 필요 없습니다.

> 이 과정은 최초 배포 시 1회만 필요합니다. 이후 API/Product 변경은 Terraform이 자동 반영합니다.

5. (선택) 웰컴 메시지 및 포탈 설정:
   ```bash
   ./scripts/setup-portal.sh <apim-name> <resource-group> <subscription-id>
   ```
   이 스크립트는 신규 사용자를 위한 가이드 메시지를 설정하고 포탈을 재publish합니다.

## 트러블슈팅: 첫 배포 시 알려진 에러

첫 `terraform apply` 실행 시 다음 에러가 발생할 수 있습니다. 대부분 일시적이며 재실행으로 해결됩니다.

### APIM 401 Unauthorized

APIM 리소스 생성(약 33분 소요) 직후 azurerm provider가 APIM API를 조회할 때 401 에러가 발생할 수 있습니다. APIM 내부 초기화가 완전히 완료되지 않은 상태에서 발생하는 일시적 에러입니다.

**해결 방법:** 2~3분 대기 후 `terraform apply`를 다시 실행합니다.

### 모델 배포 409 Conflict

여러 모델 배포가 병렬로 실행되지만, Azure ARM은 동일한 Cognitive Services 계정에 대한 쓰기 작업을 직렬화합니다. 이로 인해 동시 배포 시 409 Conflict가 발생할 수 있습니다.

**해결 방법:** `terraform apply`를 다시 실행합니다. 이미 생성된 모델은 건너뛰므로 두 번째 실행에서 성공합니다.

**대안:** `terraform apply -parallelism=1` 으로 실행하면 병렬 충돌을 방지할 수 있습니다 (속도가 느려집니다).

### 복합 에러 복구

두 에러가 동시에 발생하면 2회 재시도가 필요할 수 있습니다:

```bash
terraform apply    # 401 + 409 에러 발생 가능
# 2~3분 대기
terraform apply    # 나머지 리소스 생성 완료
```

### 재배포 시 주의사항 (Soft-Delete)

`terraform destroy` 후 동일 이름으로 재배포하면 충돌이 발생할 수 있습니다. Azure에서 삭제된 리소스가 일정 기간 soft-delete 상태로 유지되기 때문입니다.

**Foundry (Cognitive Services) 계정:**
삭제 후 48시간 동안 soft-delete 상태로 유지됩니다. 동일 이름으로 재생성하려면 먼저 purge해야 합니다:

```bash
az cognitiveservices account purge \
  --name <foundry-resource-name> \
  --resource-group <resource-group> \
  --location <location>
```

**APIM:**
APIM도 soft-delete 상태로 유지될 수 있습니다. 삭제된 APIM 인스턴스 확인 및 purge:

```bash
az apim deletedservice list -o table
az apim deletedservice purge \
  --service-name <apim-name> \
  --location <location>
```

## 4. 배포 확인

### Terraform 출력 확인

```bash
terraform output foundry_project_endpoints
```

각 Foundry Project의 Foundry Endpoint URL이 출력됩니다:

```
{
  "team-a-project" = "https://{foundry-resource-name}.cognitiveservices.azure.com/"
  "team-b-project" = "https://{foundry-resource-name}.cognitiveservices.azure.com/"
}
```

> **참고:** 모든 Foundry Project는 동일한 부모 Foundry 리소스의 엔드포인트를 공유합니다. `{foundry-resource-name}`은 `terraform.tfvars`에서 설정한 `foundry_resource_name` 값입니다.

### Azure Portal에서 확인

1. [Azure Portal](https://portal.azure.com)에 접속
2. 리소스 그룹 `rg-apim-foundry`로 이동
3. 생성된 리소스 목록을 확인

<!-- screenshot: Azure Portal 리소스 그룹 내 리소스 목록 -->

## 5. Service Key 확인 (CI/CD용)

Terraform은 각 Foundry Project에 대해 **Service Key**를 자동 생성합니다. Service Key는 CI/CD 파이프라인, 자동화 스크립트 등 시스템 용도로만 사용하며, 사람이 직접 사용하지 않습니다.

### Service Key vs Personal Key

| 구분 | Service Key | Personal Key |
|------|-------------|-------------|
| 발급 방식 | Terraform 자동 생성 | Developer Portal 셀프서비스 |
| 용도 | CI/CD, 자동화 스크립트 | 개인 사용자 API 호출 |
| 공유 | 시스템 간 공유 | 개인 전용 (공유 불가) |
| 사용량 추적 | 프로젝트 단위 | 사용자 단위 |

```bash
terraform output -json apim_subscription_keys
```

> **참고:** 개발자 개인은 Developer Portal에서 셀프서비스로 **Personal Key**를 발급받아 사용합니다. 자세한 내용은 [사용자 추가 가이드](03-add-user.md)를 참고하세요.

## 다음 단계

- [프로젝트 추가 가이드](02-add-project.md) — 새 Foundry Project 추가 방법
- [사용자 추가 가이드](03-add-user.md) — 사용자 등록 및 User Group 할당, Personal Key 발급 안내
- [사용자 퀵스타트](04-user-quickstart.md) — Personal Key로 API 호출 시작
