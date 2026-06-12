# 사용자 추가 가이드

기존 Foundry Project에 새 팀원을 추가하는 방법을 안내합니다. 사용자는 APIM Developer Portal에서 등록되며, 해당 User Group에 할당됩니다.

## 사전 요구사항

- APIM Instance가 배포되어 있어야 합니다 ([초기 설정 가이드](01-initial-setup.md) 참고)
- 추가할 사용자의 이메일 주소
- 사용자가 속할 Foundry Project(= User Group) 이름

## 1. APIM Developer Portal에서 사용자 등록

### 관리자가 직접 등록하는 방법

1. [Azure Portal](https://portal.azure.com)에서 APIM Instance로 이동
2. 왼쪽 메뉴에서 **사용자** 클릭
3. **+ 추가** 클릭
4. 사용자 정보 입력:
   - **이메일**: 사용자 이메일 주소
   - **이름**: 사용자 이름
   - **암호**: 초기 비밀번호 설정 (사용자가 변경 가능)

<!-- screenshot: APIM 사용자 추가 화면 -->

5. **만들기** 클릭

### 사용자가 셀프서비스로 등록하는 방법

APIM Developer Portal이 활성화된 경우, 사용자가 직접 가입할 수 있습니다:

1. Developer Portal URL 접속: `https://<apim-name>.developer.azure-api.net`
2. **Sign up** 클릭
3. 이메일, 이름, 비밀번호 입력 후 등록
4. 이메일 인증 완료

<!-- screenshot: Developer Portal 회원가입 화면 -->

> **참고:** 셀프서비스 등록 후에도 관리자가 User Group에 할당해야 API에 접근할 수 있습니다.

## 2. User Group에 할당

각 Foundry Project에는 대응하는 User Group이 있습니다. 사용자를 올바른 그룹에 할당해야 해당 프로젝트의 API에 접근할 수 있습니다.

1. APIM Instance > **그룹** 클릭
2. 해당 Foundry Project의 User Group 선택 (예: `catalog`, `image`)
3. **+ 구성원 추가** 클릭
4. 등록한 사용자를 검색하여 추가

<!-- screenshot: APIM User Group 구성원 추가 화면 -->

## 3. APIM Subscription Key 공유

사용자에게 해당 Foundry Project의 APIM Subscription Key를 전달합니다.

### Terraform으로 키 확인

```bash
cd infra
terraform output -json apim_subscription_keys
```

### Azure Portal에서 키 확인

1. APIM Instance > **구독** 클릭
2. 해당 Foundry Project의 APIM Subscription 선택
3. **기본 키 표시** 클릭하여 키 확인

<!-- screenshot: APIM Subscription Key 확인 화면 -->

> **보안 주의:** APIM Subscription Key는 팀 내에서만 공유합니다. 하나의 키를 Foundry Project 팀원 전체가 공유하며, 프로젝트별 Token Usage 추적의 기본 단위가 됩니다.

## 4. 사용자 셀프서비스 안내

등록된 사용자에게 아래 내용을 안내합니다:

### APIM Subscription Key 확인 (Developer Portal)

1. Developer Portal 접속: `https://<apim-name>.developer.azure-api.net`
2. 로그인 후 **프로필** 메뉴 클릭
3. 할당된 APIM Subscription의 키 확인 가능

<!-- screenshot: Developer Portal 프로필에서 Subscription Key 확인 -->

### APIM Subscription Key 재발급

키가 유출된 경우 재발급할 수 있습니다:

1. Developer Portal > **프로필** > 해당 APIM Subscription
2. **기본 키 재생성** 또는 **보조 키 재생성** 클릭
3. 기존 키는 즉시 무효화됩니다

<!-- screenshot: Developer Portal 키 재발급 화면 -->

> **참고:** 키 재발급 시 해당 Foundry Project의 모든 팀원에게 새 키를 공유해야 합니다. 보조 키를 먼저 재발급하고 배포한 후 기본 키를 재발급하면 무중단 교체가 가능합니다.

## 다음 단계

사용자에게 [사용자 퀵스타트 가이드](04-user-quickstart.md)를 전달하여 API 호출을 시작하도록 안내합니다.
