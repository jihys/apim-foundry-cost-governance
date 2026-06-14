# 프로젝트 추가 가이드

> 🇺🇸 [English Version](../en/02-add-project.md)

새로운 Foundry Project(팀)를 추가하는 방법을 안내합니다. 두 가지 방법이 있으며, **방법 A (Terraform 재실행)**를 권장합니다.

---

## 방법 A: Terraform 재실행 (권장)

Terraform은 기존 리소스를 유지하면서 새 Foundry Project만 추가합니다.

### 1단계: `terraform.tfvars`에 새 프로젝트 추가

`infra/terraform.tfvars`의 `foundry_projects` 리스트에 새 프로젝트 이름을 추가합니다:

```hcl
foundry_projects = ["catalog-project", "image-project", "search-project"]  # 새 프로젝트 추가
```

### 2단계: 변경 사항 확인

```bash
cd infra
terraform plan
```

아래와 같은 리소스가 새로 생성될 것입니다:

- `azapi_resource.project["search-project"]` — 새 Foundry Project (Foundry 계정의 하위 리소스)
- `azurerm_api_management_product.project["search-project"]` — APIM Product
- `azurerm_api_management_subscription.project["search-project"]` — Service Key
- `azurerm_api_management_group.project["search-project"]` — User Group

기존 `catalog-project`, `image-project`에는 변경이 없음을 확인합니다.

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

> **참고:** Terraform은 새 Foundry Project에 대한 APIM Product, API, User Group, 그리고 **Service Key**(`{project}-service-key`)를 함께 생성합니다. Service Key는 CI/CD 파이프라인 등 시스템 자동화 용도이며, 사람이 직접 사용하지 않습니다.
>
> 개발자는 Developer Portal에서 셀프서비스로 **Personal Key**를 발급받습니다. 자세한 내용은 [사용자 추가 가이드](03-add-user.md)를 참고하세요.
>
> Service Key 확인:
> ```bash
> terraform output -json apim_subscription_keys
> ```

---

## 방법 B: Azure Portal 수동 추가

> ⚠️ **주의:** Portal에서 수동으로 리소스를 추가하면 Terraform state와 drift가 발생합니다. 반드시 `terraform import`로 state를 동기화하거나, 이후 `terraform apply` 시 충돌이 발생할 수 있습니다. **방법 A를 권장합니다.**

수동 추가가 필요한 경우에도 `terraform.tfvars`에 프로젝트 이름을 추가하고 `terraform apply`를 실행하는 것이 가장 안전합니다. Portal에서 직접 리소스를 생성하는 경우 아래 항목을 모두 수동으로 구성해야 합니다:

1. **Foundry Project 생성:** Azure AI Foundry에서 프로젝트를 추가합니다.
2. **APIM Product 생성:** APIM Instance > Products > + 추가. Product 이름은 Foundry Project 이름과 동일하게 설정합니다.
3. **APIM Backend 설정:** APIs > + API 추가 > HTTP 선택. 백엔드 URL에 새 Foundry Endpoint URL을 입력합니다.
4. **User Group 생성:** APIM Instance > 그룹 > + 추가. 이름: `{project}-users`
5. **Product-Group 연결:** Product 설정에서 Access control > 생성한 User Group을 추가합니다.
6. **Service Key 생성 (CI/CD용):** APIM Instance > Subscriptions > + 구독 추가. 이름: `{project}-service-key`, 범위: 생성한 Product.

> **참고:** 수동 추가 시 Developer Portal에 Personal Key 발급을 위한 Product가 정확히 설정되어야 합니다 (`subscription_required = true`, `subscriptions_limit = 1`, `approval_required = false`).

### Terraform State 동기화

수동으로 추가한 리소스를 Terraform state에 import합니다:

```bash
terraform import 'module.foundry.azapi_resource.project["search-project"]' \
  /subscriptions/<sub-id>/resourceGroups/<rg>/providers/Microsoft.CognitiveServices/accounts/<foundry-name>/projects/search-project
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
