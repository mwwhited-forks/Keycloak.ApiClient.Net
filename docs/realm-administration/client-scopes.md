# Default Client Scopes

> **Document Metadata**
> Last Updated: 2026-01-20 19:30:00 UTC
> Git Commit: `9bc2d34` (9bc2d34a37e88fae053f63977e0bfbd02a61441d)
> Library Version: 2.0.2

## Overview

Default Client Scopes management allows you to configure which client scopes are automatically assigned to new clients in the realm. This includes both default scopes (always included) and optional scopes (can be requested by clients).

## Get Realm Default Client Scopes

Retrieves default client scopes for the realm.

```csharp
IEnumerable<ClientScope> scopes = await client.GetRealmDefaultClientScopesAsync("my-company");

foreach (var scope in scopes)
{
    Console.WriteLine($"Scope: {scope.Name}, Protocol: {scope.Protocol}");
}
```

**Returns:** `IEnumerable<ClientScope>`

**Location:** `/src/Keycloak.ApiClient.Net/RealmsAdmin/KeycloakClient.cs:126`

## Add Realm Default Client Scope

Adds a client scope as a default for all new clients.

```csharp
bool success = await client.UpdateRealmDefaultClientScopeAsync("my-company", clientScopeId);
```

**Returns:** `bool` - `true` if scope was added

**Location:** `/src/Keycloak.ApiClient.Net/RealmsAdmin/KeycloakClient.cs:131`

## Remove Realm Default Client Scope

Removes a default client scope from the realm.

```csharp
bool success = await client.DeleteRealmDefaultClientScopeAsync("my-company", clientScopeId);
```

**Returns:** `bool` - `true` if scope was removed

**Location:** `/src/Keycloak.ApiClient.Net/RealmsAdmin/KeycloakClient.cs:140`

## Get Realm Optional Client Scopes

Retrieves optional client scopes for the realm.

```csharp
IEnumerable<ClientScope> scopes = await client.GetRealmOptionalClientScopesAsync("my-company");
```

**Returns:** `IEnumerable<ClientScope>`

**Location:** `/src/Keycloak.ApiClient.Net/RealmsAdmin/KeycloakClient.cs:172`

## Add Realm Optional Client Scope

Adds a client scope as optional for all new clients.

```csharp
bool success = await client.UpdateRealmOptionalClientScopeAsync("my-company", clientScopeId);
```

**Returns:** `bool` - `true` if scope was added

**Location:** `/src/Keycloak.ApiClient.Net/RealmsAdmin/KeycloakClient.cs:177`

## Remove Realm Optional Client Scope

Removes an optional client scope from the realm.

```csharp
bool success = await client.DeleteRealmOptionalClientScopeAsync("my-company", clientScopeId);
```

**Returns:** `bool` - `true` if scope was removed

**Location:** `/src/Keycloak.ApiClient.Net/RealmsAdmin/KeycloakClient.cs:186`
