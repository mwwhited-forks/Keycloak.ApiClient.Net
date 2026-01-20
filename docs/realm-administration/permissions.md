# User Management Permissions

> **Document Metadata**
> Last Updated: 2026-01-20 19:30:00 UTC
> Git Commit: `9bc2d34` (9bc2d34a37e88fae053f63977e0bfbd02a61441d)
> Library Version: 2.0.2

## Overview

User Management Permissions control the fine-grained authorization for managing users within a realm. This allows you to delegate user management responsibilities to specific administrators or groups.

## Get Users Management Permissions

Retrieves user management permissions for the realm.

```csharp
ManagementPermission permissions =
    await client.GetRealmUsersManagementPermissionsAsync("my-company");

Console.WriteLine($"Permissions Enabled: {permissions.Enabled}");
```

**Note:** This method is marked as `[Obsolete]`

**Location:** `/src/Keycloak.ApiClient.Net/RealmsAdmin/KeycloakClient.cs:318`

## Update Users Management Permissions

Updates user management permissions for the realm.

```csharp
var permissions = new ManagementPermission
{
    Enabled = true
};

ManagementPermission result =
    await client.UpdateRealmUsersManagementPermissionsAsync("my-company", permissions);
```

**Returns:** `ManagementPermission`

**Location:** `/src/Keycloak.ApiClient.Net/RealmsAdmin/KeycloakClient.cs:323`
