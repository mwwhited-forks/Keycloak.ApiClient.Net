# Service Account Management

> **Document Metadata**
> Last Updated: 2026-01-20 19:30:00 UTC
> Git Commit: `9bc2d34` (9bc2d34a37e88fae053f63977e0bfbd02a61441d)
> Library Version: 2.0.2

This document covers the management of service accounts associated with Keycloak clients.

## Table of Contents

- [Get Service Account User](#get-service-account-user)

## Get Service Account User

Retrieves the user associated with a client's service account.

```csharp
User serviceAccountUser = await keycloakClient.GetUserForServiceAccountAsync(
    "master",
    clientUUID
);

Console.WriteLine($"Service Account: {serviceAccountUser.Username}");
```

**Note:** This method is marked as `[Obsolete("Not working yet")]`

**Use Case:** Service accounts allow clients to authenticate as themselves (not on behalf of a user).

**Location:** `/src/Keycloak.ApiClient.Net/Clients/KeycloakClient.cs:271`
