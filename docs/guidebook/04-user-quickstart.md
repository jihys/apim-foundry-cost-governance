# 사용자 퀵스타트

Personal Key를 발급받은 후, API 호출을 시작하는 방법을 안내합니다.

## 사전 요구사항

- Developer Portal에서 Product에 구독하여 Personal Key를 발급받은 상태 ([사용자 추가 가이드](03-add-user.md) 참고)
- Python 3.10+ 설치
- `openai` Python 패키지 설치: `pip install openai`

## 1. Runtime Config (.env) 설정

프로젝트 루트에 `.env` 파일을 생성합니다. `sample.env`를 참고하세요:

```bash
cp sample.env .env
```

`.env` 파일을 편집합니다:

```env
# APIM Instance 엔드포인트
APIM_ENDPOINT=https://<apim-name>.azure-api.net

# Personal Key (Developer Portal → Profile에서 확인)
APIM_SUBSCRIPTION_KEY=<your-personal-key>
```

> **Personal Key 확인 방법:**
> 1. Developer Portal 접속 (`terraform output apim_developer_portal_url`로 URL 확인)
> 2. 로그인 → **Profile** 메뉴
> 3. 구독한 Product의 Subscription Key 확인

> **주의:** `.env` 파일은 `.gitignore`에 포함되어 있어 Git에 커밋되지 않습니다. APIM Subscription Key를 코드에 하드코딩하지 마세요.

## 2. 퀵스타트 노트북 실행

프로젝트에 포함된 퀵스타트 노트북으로 API 연결을 테스트합니다:

```bash
cd notebooks
jupyter notebook apim-quickstart.ipynb
```

<!-- screenshot: Jupyter Notebook 퀵스타트 실행 화면 -->

## 3. OpenAI SDK로 API 호출

APIM Instance를 통해 API를 호출하려면, OpenAI SDK의 `base_url`을 APIM Instance 엔드포인트로 변경합니다:

```python
import os
from openai import AzureOpenAI
from dotenv import load_dotenv

load_dotenv()

client = AzureOpenAI(
    # APIM Instance를 통해 Foundry Endpoint에 접근
    azure_endpoint=os.getenv("APIM_ENDPOINT"),
    api_key=os.getenv("APIM_SUBSCRIPTION_KEY"),
    api_version="2024-10-21",
)

response = client.chat.completions.create(
    model="gpt-4o",
    messages=[
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": "안녕하세요! 테스트 메시지입니다."},
    ],
)

print(response.choices[0].message.content)
```

> **핵심 포인트:**
> - `azure_endpoint`에 APIM Instance URL을 사용합니다 (Foundry Endpoint 직접 접근 아님)
> - `api_key`에 Personal Key를 사용합니다 (Service Key나 Project API Key 아님)
> - APIM이 내부적으로 해당 Foundry Project의 Foundry Endpoint로 라우팅합니다

## 4. 호출 확인

정상적으로 응답을 받으면 설정이 완료된 것입니다. 응답 예시:

```
안녕하세요! 테스트 메시지를 잘 받았습니다. 무엇을 도와드릴까요?
```

오류가 발생하는 경우:

| 오류 코드 | 원인 | 해결 방법 |
|-----------|------|-----------|
| `401 Unauthorized` | 잘못된 Personal Key | Developer Portal → Profile에서 키를 다시 확인하세요 |
| `403 Forbidden` | User Group에 할당되지 않았거나 Product에 구독하지 않음 | 관리자에게 User Group 할당 요청 후, Developer Portal에서 Product 구독 |
| `404 Not Found` | 잘못된 엔드포인트 또는 모델명 | `APIM_ENDPOINT`와 `model` 파라미터 확인 |
| `429 Too Many Requests` | Rate limit 초과 | 잠시 후 재시도하거나 관리자에게 한도 조정 요청 |

## 5. 사용자별 Token Usage 추적

Personal Key를 사용하면 사용자별 Token Usage가 자동으로 추적됩니다. APIM Policy가 각 요청의 `subscriber` 정보(사용자 이메일)를 App Insights Telemetry에 기록하므로, 별도의 커스텀 헤더 없이 Cost Dashboard에서 사용자별 사용량을 확인할 수 있습니다.

> **참고:** 기존 `x-user-id` 커스텀 헤더는 더 이상 필요하지 않습니다. Personal Key 방식으로 전환하면서 사용자 식별이 Subscription 단위로 자동 처리됩니다.

## 다음 단계

- **Token Usage 확인:** 관리자에게 Cost Dashboard 접근 권한을 요청하여 프로젝트별/사용자별 사용량을 확인합니다
- **Personal Key 재발급:** 키가 유출된 경우 Developer Portal에서 재발급할 수 있습니다 ([사용자 추가 가이드](03-add-user.md) 참고)
