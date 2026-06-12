# 06: Quickstart Notebook

**Labels:** ready-for-agent, AFK

## Parent

[PRD: APIM Foundry Cost Governance](../../prds/apim-foundry-cost-governance.md)

## What to build

Create a minimal Jupyter notebook (`notebooks/apim-quickstart.ipynb`) that demonstrates the difference between calling an AI model directly via the OpenAI SDK and calling it through the APIM gateway. This serves as both a setup verification tool and a learning resource.

The notebook should:
1. Load configuration from `.env` (APIM endpoint, APIM Subscription Key, direct Foundry endpoint, Foundry API Key)
2. **Section 1: Direct call** — Call a Foundry endpoint directly using the OpenAI SDK with the Foundry API Key
3. **Section 2: APIM-proxied call** — Call the same model via the APIM endpoint using the APIM Subscription Key
4. **Section 3: Comparison** — Show that both return equivalent responses, highlight that the APIM call is now tracked in App Insights

Keep it minimal — no analysis, no visualization. Just the two calls side-by-side with clear markdown explanations.

Also create/update `sample.env` with the required variables and placeholder values.

## Acceptance criteria

- [ ] `notebooks/apim-quickstart.ipynb` exists with markdown cells explaining direct vs APIM flow
- [ ] Notebook loads config from `.env` using `python-dotenv`
- [ ] Notebook demonstrates a direct Foundry API call using OpenAI SDK
- [ ] Notebook demonstrates an APIM-proxied call using OpenAI SDK (base_url pointed at APIM)
- [ ] Notebook compares both responses in a final cell
- [ ] `sample.env` contains all required variables with placeholder values and comments
- [ ] Required Python packages are listed in `requirements.txt` (openai, python-dotenv)

## Blocked by

- [02: APIM Module with Subscription Key Routing](02-apim-module-subscription-routing.md)
