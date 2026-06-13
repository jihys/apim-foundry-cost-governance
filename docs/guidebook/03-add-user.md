# 사용자 추가 가이드

기존 Foundry Project에 새 사용자를 추가하는 방법을 안내합니다. 사용자는 Developer Portal에서 등록하고, 관리자가 User Group에 할당한 뒤, 사용자가 직접 Personal Key를 발급받는 흐름입니다.

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

1. Azure Portal → APIM Instance → **그룹**
2. 해당 프로젝트 그룹 선택 (예: `catalog-project-users`)
3. **+ 구성원 추가** → 사용자 검색 → 추가

<!-- screenshot: APIM User Group 구성원 추가 화면 -->

> **이 할당이 곧 승인 행위입니다.** 별도의 승인 절차 없이, 그룹에 할당된 사용자만 해당 Product에 구독할 수 있습니다.

## 3. 사용자에게 안내

사용자에게 다음 절차를 안내합니다:

1. Developer Portal 로그인
2. **Products** 메뉴에서 자신의 프로젝트 Product 선택
3. **"Subscribe"** 클릭 → Personal Key 즉시 발급
4. **Profile** 페이지에서 Personal Key 확인

<!-- screenshot: Developer Portal Products 구독 화면 -->

> 사용자당 Product별 1개의 Personal Key만 발급 가능합니다 (`subscriptions_limit = 1`).

사용자가 Personal Key를 확인한 후 [사용자 퀵스타트 가이드](04-user-quickstart.md)를 전달하여 API 호출을 시작하도록 안내합니다.

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
