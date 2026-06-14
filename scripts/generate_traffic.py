"""Generate diverse traffic across multiple models and users for dashboard testing."""

import time
import random
import asyncio
from openai import AzureOpenAI

# APIM endpoint (test2)
APIM_ENDPOINT = "https://apim-foundry-gw-test2.azure-api.net"
API_VERSION = "2024-12-01-preview"

# Personal keys (Developer Portal subscriptions)
USERS = {
    "user-A-personal": "19a66a8b02404e22b589b9e4e6be49f8",    # bonayaing81@naver.com
    "user-B-personal": "dc206f61e4c342c6a256affae0f89226",    # bonayaing81@hotmail.com
}

# Chat models
CHAT_MODELS = ["gpt-4o", "gpt-5.2", "gpt-5.4"]

# Embedding model
EMBEDDING_MODEL = "text-embedding-3-large"

# Diverse prompts for chat (varying lengths for different token counts)
CHAT_PROMPTS = [
    "What is Azure API Management?",
    "Explain the difference between OAuth 2.0 and API keys in 3 sentences.",
    "Write a Python function that calculates the Fibonacci sequence up to n terms. Include docstring and type hints.",
    "Summarize the benefits of using a gateway pattern for AI model access control in enterprise environments.",
    "What are the top 5 best practices for securing REST APIs? Explain each briefly.",
    "Translate this to Korean: The cost governance dashboard helps teams track their AI spending in real time.",
    "Create a haiku about cloud computing.",
    "Explain how token-based pricing works for large language models. Include examples of prompt tokens vs completion tokens.",
    "What is the difference between embedding models and generative models? When should you use each?",
    "List 10 creative use cases for text embeddings in enterprise applications.",
    "Write a SQL query that joins users with their API usage and calculates monthly cost per team.",
    "Explain rate limiting strategies for AI API gateways. Compare token bucket vs sliding window.",
]

# Texts for embedding (varying lengths)
EMBEDDING_TEXTS = [
    "Azure API Management provides a hybrid, multicloud management platform for APIs.",
    "Token usage monitoring helps organizations control AI spending across teams.",
    "The catalog team uses GPT-4o for product description generation and classification.",
    "Image processing pipeline leverages multimodal models for visual content analysis.",
    "Cost governance requires per-user tracking with subscription key identification.",
    "Embedding models convert text into high-dimensional vectors for semantic search.",
    "Rate limiting prevents individual users from consuming disproportionate resources.",
    "Developer Portal enables self-service API key management for end users.",
    "Application Insights traces store custom dimensions for per-request telemetry.",
    "Workbook dashboards aggregate token usage across projects, models, and users.",
    "The infrastructure is defined as code using Terraform modules for reproducibility.",
    "Fine-grained access control maps user groups to specific Foundry project endpoints.",
    "Real-time cost estimation multiplies token counts by per-model pricing rates.",
    "CI/CD pipelines use service keys while humans use personal subscription keys.",
    "Korea Central region provides low-latency access for APAC-based development teams.",
]


def create_client(api_key: str) -> AzureOpenAI:
    return AzureOpenAI(
        azure_endpoint=APIM_ENDPOINT,
        api_key=api_key,
        api_version=API_VERSION,
    )


def call_chat(client: AzureOpenAI, model: str, prompt: str, user_name: str) -> dict:
    """Make a chat completion call and return usage info."""
    try:
        # gpt-5.x models require max_completion_tokens instead of max_tokens
        token_param = {}
        if model.startswith("gpt-5"):
            token_param["max_completion_tokens"] = random.randint(50, 300)
        else:
            token_param["max_tokens"] = random.randint(50, 300)

        response = client.chat.completions.create(
            model=model,
            messages=[
                {"role": "system", "content": "You are a helpful assistant. Be concise."},
                {"role": "user", "content": prompt},
            ],
            **token_param,
        )
        usage = response.usage
        print(f"  ✓ [{user_name}] {model} | prompt={usage.prompt_tokens} completion={usage.completion_tokens} total={usage.total_tokens}")
        return {"model": model, "user": user_name, "tokens": usage.total_tokens}
    except Exception as e:
        print(f"  ✗ [{user_name}] {model} | Error: {e}")
        return None


def call_embedding(client: AzureOpenAI, texts: list[str], user_name: str) -> dict:
    """Make an embedding call and return usage info."""
    try:
        response = client.embeddings.create(
            model=EMBEDDING_MODEL,
            input=texts,
        )
        usage = response.usage
        print(f"  ✓ [{user_name}] {EMBEDDING_MODEL} | tokens={usage.total_tokens} ({len(texts)} texts)")
        return {"model": EMBEDDING_MODEL, "user": user_name, "tokens": usage.total_tokens}
    except Exception as e:
        print(f"  ✗ [{user_name}] {EMBEDDING_MODEL} | Error: {e}")
        return None


def main():
    print("=" * 60)
    print("🚀 Generating diverse traffic for Cost Dashboard")
    print("=" * 60)

    total_calls = 0
    total_tokens = 0

    # Phase 1: Chat completions across all models and users
    print("\n📝 Phase 1: Chat Completions (3 models × 4 users × varied prompts)")
    print("-" * 60)

    for user_name, api_key in USERS.items():
        client = create_client(api_key)
        # Each user calls each model 3-4 times with different prompts
        for model in CHAT_MODELS:
            num_calls = random.randint(3, 5)
            prompts = random.sample(CHAT_PROMPTS, min(num_calls, len(CHAT_PROMPTS)))
            for prompt in prompts:
                result = call_chat(client, model, prompt, user_name)
                if result:
                    total_calls += 1
                    total_tokens += result["tokens"]
                time.sleep(1.5)  # Rate limit friendly

    # Phase 2: Embedding calls
    print(f"\n🔢 Phase 2: Embeddings ({EMBEDDING_MODEL})")
    print("-" * 60)

    for user_name, api_key in USERS.items():
        client = create_client(api_key)
        # Each user makes 3-4 embedding calls with batches of 2-5 texts
        for i in range(random.randint(3, 4)):
            batch_size = random.randint(2, 5)
            texts = random.sample(EMBEDDING_TEXTS, batch_size)
            result = call_embedding(client, texts, user_name)
            if result:
                total_calls += 1
                total_tokens += result["tokens"]
            time.sleep(1.5)

    # Phase 3: Burst traffic (simulate peak usage)
    print("\n⚡ Phase 3: Burst traffic (simulating peak usage)")
    print("-" * 60)

    burst_prompts = [
        "Generate a product description for a wireless bluetooth speaker.",
        "Classify this text as positive/negative/neutral: 'The service was okay but could be faster.'",
        "Extract keywords from: 'Machine learning models deployed on Azure can be accessed through API Management for governance.'",
        "Rewrite this formally: 'Hey, can you check the dashboard for last week's token usage?'",
        "What are three ways to reduce token consumption in AI applications?",
    ]

    for _ in range(3):  # 3 rounds of burst
        user_name = random.choice(list(USERS.keys()))
        api_key = USERS[user_name]
        client = create_client(api_key)
        model = random.choice(CHAT_MODELS)
        prompt = random.choice(burst_prompts)
        result = call_chat(client, model, prompt, user_name)
        if result:
            total_calls += 1
            total_tokens += result["tokens"]
        time.sleep(1)

    # Summary
    print("\n" + "=" * 60)
    print(f"📊 Traffic Generation Complete!")
    print(f"   Total API calls: {total_calls}")
    print(f"   Total tokens: {total_tokens:,}")
    print(f"   Models used: {', '.join(CHAT_MODELS + [EMBEDDING_MODEL])}")
    print(f"   Users: {', '.join(USERS.keys())}")
    print("=" * 60)
    print("\n💡 Wait 2-3 minutes, then check the Cost Dashboard Workbook in Azure Portal.")


if __name__ == "__main__":
    main()
