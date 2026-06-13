# User Quickstart

> 🇰🇷 [한국어 버전](../04-user-quickstart.md)

This guide explains how to start making API calls after obtaining your Personal Key.

## Prerequisites

- You have subscribed to a Product on the Developer Portal and received your Personal Key (see [Add User Guide](03-add-user.md))
- Python 3.10+ installed

### Python Environment Setup

```bash
# Create and activate a virtual environment
python -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate

# Install required packages
pip install openai python-dotenv
```

## 1. Configure Runtime Config (.env)

Create a `.env` file in the project root. Refer to `sample.env`:

```bash
cp sample.env .env
```

Edit the `.env` file:

```env
# APIM Instance endpoint
APIM_ENDPOINT=https://<apim-name>.azure-api.net

# Personal Key (find it in Developer Portal → Profile)
APIM_SUBSCRIPTION_KEY=<your-personal-key>
```

> **How to find your Personal Key:**
> 1. Go to the Developer Portal (`terraform output apim_developer_portal_url` to get the URL)
> 2. Log in → **Profile** menu
> 3. Find the Subscription Key for the Product you subscribed to

> **Important:** The `.env` file is included in `.gitignore` and will not be committed to Git.
> Do not hard-code your Personal Key in source code or commit it to Git.
> If your key is compromised, regenerate it immediately on the Developer Portal.

## 2. Run the Quickstart Notebook

Test the API connection using the quickstart notebook included in the project:

```bash
cd notebooks
jupyter notebook apim-quickstart.ipynb
```

<!-- screenshot: Jupyter Notebook quickstart execution screen -->

## 3. Call the API with the OpenAI SDK

To call the API through the APIM Instance, set the OpenAI SDK's `base_url` to the APIM Instance endpoint:

```python
import os
from openai import AzureOpenAI
from dotenv import load_dotenv

load_dotenv()

client = AzureOpenAI(
    # Access the Foundry Endpoint through the APIM Instance
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

> **Key points:**
> - Use the APIM Instance URL for `azure_endpoint` (not the Foundry Endpoint directly)
> - Use your Personal Key for `api_key` (not the Service Key or Project API Key)
> - APIM internally routes the request to the appropriate Foundry Project's Foundry Endpoint

## 4. Verify the Response

If you receive a successful response, your setup is complete. Example response:

```
안녕하세요! 테스트 메시지를 잘 받았습니다. 무엇을 도와드릴까요?
```

If you encounter errors:

| Error Code | Cause | Solution |
|------------|-------|----------|
| `401 Unauthorized` | Invalid Personal Key | Re-check your key in Developer Portal → Profile |
| `403 Forbidden` | Not assigned to a User Group, or not subscribed to the Product | Ask your administrator for User Group assignment, then subscribe to the Product on the Developer Portal |
| `404 Not Found` | Incorrect endpoint or model name | Verify `APIM_ENDPOINT` and the `model` parameter |
| `429 Too Many Requests` | Rate limit exceeded | Wait and retry, or ask your administrator to adjust the limit |
| `Connection refused` | APIM deployment not complete | Verify the URL with `terraform output apim_endpoint` |
| `InvalidApiKey` | Key format error | Re-copy the key from Developer Portal Profile |

## 5. Per-User Usage Tracking

When you use a Personal Key, **per-user usage tracking is automatic**.
Each Personal Key is linked to subscriber information and recorded as the `subscriber` dimension in App Insights.
No custom headers or additional configuration are required.

Administrators can view per-user and per-project token usage on the **Cost Dashboard** in the Azure Portal.

## Next Steps

- **Check Token Usage:** Ask your administrator for access to the Cost Dashboard to view per-project and per-user usage
- **Regenerate your Personal Key:** If your key is compromised, you can regenerate it on the Developer Portal (see [Add User Guide](03-add-user.md))
