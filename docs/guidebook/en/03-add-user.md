# Add User Guide

> 🇰🇷 [한국어 버전](../03-add-user.md)

This guide explains how to add a new user to an existing Foundry Project. The workflow is: the user registers on the Developer Portal, an administrator assigns them to a User Group, and then the user self-issues a Personal Key.

## Prerequisites

- APIM Instance + Developer Portal deployed (see [Initial Setup Guide](01-initial-setup.md))
- Email address of the user to add
- Name of the Foundry Project (= User Group) the user should belong to

## 1. User Registration

### Method A: User Self-Registration (Recommended)

Share the Developer Portal URL with the user:

```bash
cd infra && terraform output apim_developer_portal_url
```

1. Navigate to the Developer Portal URL
2. Click **Sign up**
3. Enter email, name, and password, then submit
4. Complete email verification

<!-- screenshot: Developer Portal sign-up screen -->

### Method B: Admin-Initiated Registration

If the user cannot sign up on their own, an administrator can register them:

1. Go to the [Azure Portal](https://portal.azure.com) and navigate to the APIM Instance
2. Click **Users** in the left menu
3. Click **+ Add**
4. Enter the user's information (email, name, initial password)
5. Click **Create**

<!-- screenshot: APIM add user screen -->

## 2. Assign to a User Group (Administrator)

Assign the registered user to the User Group for their Foundry Project:

1. Azure Portal → APIM Instance → **Groups**
2. Select the project group (e.g., `catalog-project-users`)
3. Click **+ Add member** → search for the user → add

<!-- screenshot: APIM User Group member addition screen -->

> **This assignment is the approval action.** There is no separate approval process — only users assigned to a group can subscribe to the corresponding Product.

## 3. Instruct the User

Guide the user through the following steps:

1. Log in to the Developer Portal
2. Go to the **Products** menu and select their project's Product
3. Click **"Subscribe"** → a Personal Key is issued immediately
4. Check the Personal Key on the **Profile** page

<!-- screenshot: Developer Portal Products subscription screen -->

> Each user can issue only one Personal Key per Product (`subscriptions_limit = 1`).

Once the user has their Personal Key, share the [User Quickstart Guide](04-user-quickstart.md) so they can start making API calls.

## 4. Service Key (for CI/CD)

For automation scripts, CI/CD pipelines, and other system purposes, use the Service Key created by Terraform:

```bash
terraform output -json apim_subscription_keys
```

Each project's Service Key is displayed in the format `{project}-service-key`.

> **Service Keys are not intended for individual use.** Developers must use their Personal Key.

## 5. Personal Key Regeneration

If a key is compromised, the user can regenerate it themselves:

1. Developer Portal → **Profile** → select the Subscription
2. Click **Regenerate primary key** or **Regenerate secondary key**
3. The old key is invalidated immediately

> Personal Keys are independent per user, so regeneration only affects the individual's key. Other team members are not impacted.
