# Default Groups

> **Document Metadata**
> Last Updated: 2026-01-20 19:30:00 UTC
> Git Commit: `9bc2d34` (9bc2d34a37e88fae053f63977e0bfbd02a61441d)
> Library Version: 2.0.2

## Overview

Default Groups management allows you to configure which groups new users are automatically assigned to when they register or are created. This simplifies user onboarding by automatically granting group memberships and associated roles.

## Get Realm Default Groups

Retrieves the default groups hierarchy for the realm.

```csharp
IEnumerable<Group> groups = await client.GetRealmGroupHierarchyAsync("my-company");

foreach (var group in groups)
{
    Console.WriteLine($"Group: {group.Name}");
}
```

**Returns:** `IEnumerable<Group>`

**Location:** `/src/Keycloak.ApiClient.Net/RealmsAdmin/KeycloakClient.cs:149`

## Add Default Group

Adds a group as a default group (new users automatically join).

```csharp
bool success = await client.UpdateRealmGroupAsync("my-company", groupId);
```

**Returns:** `bool` - `true` if group was added as default

**Location:** `/src/Keycloak.ApiClient.Net/RealmsAdmin/KeycloakClient.cs:154`

## Remove Default Group

Removes a group from default groups.

```csharp
bool success = await client.DeleteRealmGroupAsync("my-company", groupId);
```

**Returns:** `bool` - `true` if group was removed from defaults

**Location:** `/src/Keycloak.ApiClient.Net/RealmsAdmin/KeycloakClient.cs:163`

## Get Group By Path

Retrieves a group by its path.

```csharp
Group group = await client.GetRealmGroupByPathAsync("my-company", "/top-level/sub-group");
```

**Returns:** `Group`

**Location:** `/src/Keycloak.ApiClient.Net/RealmsAdmin/KeycloakClient.cs:240`
