# Add User Guide

> 🇰🇷 [한국어 버전](../03-add-user.md)

This guide explains how to add a new user to an existing Foundry Project. The workflow is: the user registers on the Developer Portal, an administrator assigns them to a User Group, and then the user self-issues a Personal Key.

## Key Type Guide

| Scenario | Key to Use | How to Obtain |
|----------|-----------|---------------|
| Developer testing APIs locally | Personal Key | Developer Portal subscription |
| Jupyter Notebook exercises | Personal Key | Developer Portal subscription |
| CI/CD pipelines | Service Key | `terraform output` |
| Batch processing scripts | Service Key | `terraform output` |

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

![APIM Groups](../images/03-groups.png)

1. Azure Portal → APIM Instance → left menu **Groups**
2. Select the project group (e.g., `catalog-project Users`)

![Group Add Member](../images/03-group-member.png)

3. Click **+ Add member** → search for the user → add
4. The user appears in the Members list when complete

> **This assignment is the approval action.** There is no separate approval process — only users assigned to a group can subscribe to the corresponding Product.

## 3. Instruct the User

After the administrator completes the User Group assignment, share the following steps with the user.

### 3-1. Sign In to the Developer Portal

> **Developer Portal URL:** `https://<your-apim-name>.developer.azure-api.net`
>
> Use a private/incognito browser window. In a regular browser signed into Azure Portal, you will be redirected to the admin editing interface.

![Developer Portal Sign in](../images/03-signin.png)

1. Navigate to the Developer Portal URL
2. Click **Sign in**
3. Enter the email and password used during registration
4. Click the **Sign in** button

### 3-2. Subscribe to a Product (Issue Personal Key)

![Product Subscribe](../images/03-subscribe.png)

1. Click **Products** in the top menu
2. Select the project assigned by the administrator (e.g., `catalog-project`)
3. Enter a Subscription Name (e.g., `catalog-subscription-key`)
4. Click the **Subscribe** button → a Personal Key is issued immediately

> Each user can issue only one Personal Key per Product (`subscriptions_limit = 1`).

### 3-3. View Your Personal Key

![User Profile](../images/03-profile.png)

1. Click your username in the top-right corner → select **Profile**
2. Find your subscription in the **Subscriptions** section
3. Click **Show** next to the **Primary key** → the key is displayed
4. Copy the key to use in API calls

| Field | Description |
|-------|-------------|
| Name | Subscription name (entered during subscribe) |
| Product | Assigned project |
| State | `Active` — ready to use |
| Primary key | Used in the `api-key` header for API calls |
| Secondary key | Used for key rotation when regenerating the Primary key |

Once the user has their Personal Key, refer to the [User Quickstart Guide](04-user-quickstart.md) to start making API calls.

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
