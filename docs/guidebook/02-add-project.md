# 프로젝트 추가 가이드

새로운 Foundry Project(팀)를 추가하는 방법을 안내합니다. 두 가지 방법이 있으며, **방법 A (Terraform 재실행)**를 권장합니다.

---

## 방법 A: Terraform 재실행 (권장)

Terraform은 기존 리소스를 유지하면서 새 Foundry Project만 추가합니다.

### 1단계: `terraform.tfvars`에 새 프로젝트 추가

`infra/terraform.tfvars`의 `foundry_projects` 리스트에 새 프로젝트 블록을 추가합니다:

```hcl
foundry_projects = [
  # 기존 프로젝트 (수정하지 않음)
  {
    name           = "catalog"
    models         = ["gpt-4o"]
    rate_limit_tpm = null
  },
  {
    name           = "image"
    models         = ["gpt-4o", "dall-e-3"]
    rate_limit_tpm = null
  },
  # 새 프로젝트 추가
  {
    name           = "search"
    models         = ["gpt-4o", "text-embedding-ada-002"]
    rate_limit_tpm = 20000  # 기본값(10000) 대신 커스텀 rate limit 지정
  }
]
```

### 2단계: 변경 사항 확인

```bash
cd infra
terraform plan
```

아래와 같은 리소스가 새로 생성될 것입니다:

- `azapi_resource.foundry_account["search"]` — 새 Azure AI Services 계정
- `azapi_resource.model_deployment["search-gpt-4o"]` — gpt-4o 모델 배포
- `azapi_resource.model_deployment["search-text-embedding-ada-002"]` — embedding 모델 배포

기존 `catalog`, `image` 프로젝트에는 변경이 없음을 확인합니다.

<!-- screenshot: terraform plan에서 새 리소스만 추가되는 것을 보여주는 출력 -->

### 3단계: 배포 실행

```bash
terraform apply
```

### 4단계: 새 Foundry Endpoint 확인

```bash
terraform output foundry_project_endpoints
```

새 프로젝트의 Foundry Endpoint가 추가된 것을 확인합니다.

> **참고:** APIM Instance가 배포된 후에는 Terraform이 자동으로 새 Foundry Project에 대한 APIM Product, API, APIM Subscription, User Group도 함께 생성합니다. 새 APIM Subscription Key는 아래 명령으로 확인합니다:
>
> ```bash
> terraform output -json apim_subscription_keys
> ```

---

## 방법 B: Azure Portal 수동 추가

> ⚠️ **주의:** Portal에서 수동으로 리소스를 추가하면 Terraform state와 drift가 발생합니다. 반드시 `terraform import`로 state를 동기화하거나, 이후 `terraform apply` 시 충돌이 발생할 수 있습니다. **방법 A를 권장합니다.**

### Step 1: AI Foundry에서 프로젝트 생성

1. [Azure Portal](https://portal.azure.com)에서 리소스 그룹으로 이동
2. **+ 만들기** > **Azure OpenAI** 검색 > **만들기**
3. 이름: `aoai-foundry-<project-name>` 형식으로 입력
4. 리전: 기존 리소스와 동일한 리전 선택
5. 가격 책정 계층: `S0`
6. **검토 + 만들기** 클릭

<!-- screenshot: Azure Portal에서 Azure OpenAI 리소스 생성 화면 -->

7. 생성 완료 후 **키 및 엔드포인트**로 이동하여 Foundry Endpoint URL과 Project API Key를 확인합니다.

<!-- screenshot: Azure OpenAI 키 및 엔드포인트 화면 -->

### Step 2: 모델 배포

1. 생성한 Azure OpenAI 리소스로 이동
2. **모델 배포** > **배포 관리** 클릭
3. **+ 새 배포 만들기**
4. 모델 선택, 배포 이름 입력, 용량(TPM) 설정

<!-- screenshot: Azure OpenAI Studio 모델 배포 화면 -->

### Step 3: APIM에 API 추가 (APIM 배포 후)

> **참고:** 이 단계는 APIM Instance가 배포된 후에 수행합니다.

1. APIM Instance로 이동 > **Products** > **+ 추가**
2. Product 이름: Foundry Project 이름과 동일하게 설정
3. **APIs** > **+ API 추가** > **HTTP** 선택
4. 백엔드 URL에 새 Foundry Endpoint URL 입력

<!-- screenshot: APIM Product 추가 화면 -->

<!-- screenshot: APIM API 설정 화면 (백엔드 URL 입력) -->

### Step 4: APIM Subscription 생성

1. APIM Instance > **Subscriptions** > **+ 구독 추가**
2. 이름: Foundry Project 이름
3. 범위: 위에서 생성한 Product 선택
4. APIM Subscription Key를 팀에 전달

<!-- screenshot: APIM Subscription 생성 화면 -->

### Step 5: Terraform State 동기화

수동으로 추가한 리소스를 Terraform state에 import합니다:

```bash
terraform import 'module.foundry.azapi_resource.foundry_account["search"]' \
  /subscriptions/<sub-id>/resourceGroups/<rg>/providers/Microsoft.CognitiveServices/accounts/aoai-foundry-search
```

> ⚠️ 모든 수동 리소스에 대해 import를 수행하지 않으면 다음 `terraform apply` 시 충돌이 발생합니다.

---

## 비교

| 항목 | 방법 A (Terraform) | 방법 B (Portal 수동) |
|------|-------------------|---------------------|
| 소요 시간 | ~5분 | ~20분 |
| Drift 위험 | 없음 | 높음 |
| 재현성 | 완전 재현 가능 | 수동 기록 필요 |
| APIM 연동 | 자동 | 수동 설정 필요 |
| 권장 여부 | ✅ 권장 | ⚠️ 비상시만 |
