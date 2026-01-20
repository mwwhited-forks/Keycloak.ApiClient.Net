# Client Authorization Permissions

> **Document Metadata**
> Last Updated: 2026-01-20 19:30:00 UTC
> Git Commit: `9bc2d34` (9bc2d34a37e88fae053f63977e0bfbd02a61441d)
> Library Version: 2.0.2

This document covers the management of authorization permissions for Keycloak clients.

## Table of Contents

- [Get Client Authorization Permissions](#get-client-authorization-permissions)
- [Set Client Authorization Permissions](#set-client-authorization-permissions)

## Get Client Authorization Permissions

Retrieves authorization permissions for a client.

```csharp
ManagementPermission permissions =
    await keycloakClient.GetClientAuthorizationPermissionsInitializedAsync(
        "master",
        clientUUID
    );
```

**Note:** This method is marked as `[Obsolete("Not working yet")]`

**Location:** `/src/Keycloak.ApiClient.Net/Clients/KeycloakClient.cs:180`

## Set Client Authorization Permissions

Initializes or updates authorization permissions for a client.

```csharp
var permissions = new ManagementPermission
{
    Enabled = true
};

ManagementPermission result =
    await keycloakClient.SetClientAuthorizationPermissionsInitializedAsync(
        "master",
        clientUUID,
        permissions
    );
```

**Returns:** `ManagementPermission`

**Location:** `/src/Keycloak.ApiClient.Net/Clients/KeycloakClient.cs:185`
