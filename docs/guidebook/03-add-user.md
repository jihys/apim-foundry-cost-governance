# 사용자 추가 가이드

> 🇺🇸 [English Version](en/03-add-user.md)

기존 Foundry Project에 새 사용자를 추가하는 방법을 안내합니다. 사용자는 Developer Portal에서 등록하고, 관리자가 User Group에 할당한 뒤, 사용자가 직접 Personal Key를 발급받는 흐름입니다.

## 키 유형 안내

| 시나리오 | 사용할 키 | 발급 방법 |
|---------|----------|----------|
| 개발자가 로컬에서 API 테스트 | Personal Key | Developer Portal 구독 |
| Jupyter Notebook 실습 | Personal Key | Developer Portal 구독 |
| CI/CD 파이프라인 | Service Key | `terraform output` |
| 배치 처리 스크립트 | Service Key | `terraform output` |

## 사전 요구사항

- APIM Instance + Developer Portal 배포 완료 ([초기 설정 가이드](01-initial-setup.md) 참고)
- 추가할 사용자의 이메일 주소
- 사용자가 속할 Foundry Project(= User Group) 이름

## 1. 사용자 등록

### 방법 A: 사용자 셀프서비스 등록 (권장)

사용자에게 Developer Portal URL을 안내합니다:

```bash
cd infra && terraform output apim_developer_portal_url
```

1. Developer Portal URL 접속
2. **Sign up** 클릭
3. 이메일, 이름, 비밀번호 입력 후 등록
4. 이메일 인증 완료

<!-- screenshot: Developer Portal 회원가입 화면 -->

### 방법 B: 관리자 직접 등록

사용자가 직접 가입하기 어려운 경우 관리자가 등록할 수 있습니다:

1. [Azure Portal](https://portal.azure.com)에서 APIM Instance로 이동
2. 왼쪽 메뉴에서 **사용자** 클릭
3. **+ 추가** 클릭
4. 사용자 정보 입력 (이메일, 이름, 초기 비밀번호)
5. **만들기** 클릭

<!-- screenshot: APIM 사용자 추가 화면 -->

## 2. User Group에 할당 (관리자)

등록된 사용자를 해당 Foundry Project의 User Group에 할당합니다:

![APIM Groups](images/03-groups.png)

1. Azure Portal → APIM Instance → 왼쪽 메뉴 **그룹 (Groups)**
2. 해당 프로젝트 그룹 선택 (예: `catalog-project Users`)

![Group Add Member](images/03-group-member.png)

3. **+ Add member (구성원 추가)** 클릭 → 사용자 검색 → 추가
4. Members 목록에 사용자가 표시되면 완료

> **이 할당이 곧 승인 행위입니다.** 별도의 승인 절차 없이, 그룹에 할당된 사용자만 해당 Product에 구독할 수 있습니다.

## 3. 사용자에게 안내

관리자가 User Group 할당을 완료한 후, 사용자에게 아래 절차를 안내합니다.

### 3-1. Developer Portal 로그인

> **Developer Portal URL:** `https://<your-apim-name>.developer.azure-api.net`
>
> 시크릿/InPrivate 브라우저 창에서 접속하세요 (Azure Portal에 로그인된 일반 브라우저에서는 관리자 편집 화면으로 이동됩니다).

![Developer Portal Sign in](images/03-signin.png)

1. Developer Portal URL 접속
2. **Sign in** 클릭
3. 가입 시 등록한 이메일과 비밀번호 입력
4. **Sign in** 버튼 클릭

### 3-2. Product 구독 (Personal Key 발급)

![Product Subscribe](images/03-subscribe.png)

1. 상단 메뉴에서 **Products** 클릭
2. 관리자가 할당한 프로젝트 선택 (예: `catalog-project`)
3. Subscription Name 입력 (예: `catalog-subscription-key`)
4. **Subscribe** 버튼 클릭 → Personal Key 즉시 발급

> 사용자당 Product별 1개의 Personal Key만 발급 가능합니다 (`subscriptions_limit = 1`).

### 3-3. Personal Key 확인

![User Profile](images/03-profile.png)

1. 상단 오른쪽의 사용자 이름 클릭 → **Profile** 선택
2. **Subscriptions** 섹션에서 구독 정보 확인
3. **Primary key** 옆의 **Show** 클릭 → 키가 표시됨
4. 키를 복사하여 API 호출에 사용

| 항목 | 설명 |
|------|------|
| Name | 구독 이름 (구독 시 입력한 값) |
| Product | 할당된 프로젝트 |
| State | `Active` — 즉시 사용 가능 |
| Primary key | API 호출 시 `Ocp-Apim-Subscription-Key` 헤더에 사용 |
| Secondary key | Primary key 로테이션 시 사용 |

Personal Key를 확인한 후 [사용자 퀵스타트 가이드](04-user-quickstart.md)를 참고하여 API 호출을 시작합니다.

## 4. Service Key (CI/CD용)

자동화 스크립트, CI/CD 파이프라인 등 시스템 용도로는 Terraform이 생성한 Service Key를 사용합니다:

```bash
terraform output -json apim_subscription_keys
```

각 프로젝트의 Service Key는 `{project}-service-key` 형식으로 표시됩니다.

> **Service Key는 사람이 직접 사용하지 않습니다.** 개발자는 반드시 Personal Key를 사용하세요.

## 5. Personal Key 재발급

키가 유출된 경우 사용자가 직접 재발급할 수 있습니다:

1. Developer Portal → **Profile** → 해당 Subscription
2. **기본 키 재생성** 또는 **보조 키 재생성** 클릭
3. 기존 키는 즉시 무효화됩니다

> Personal Key는 개인별로 독립되어 있어, 재발급 시 본인의 키만 영향을 받습니다. 다른 팀원에게 영향이 없습니다.
