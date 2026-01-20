# Client Scope Management

> **Document Metadata**
> Last Updated: 2026-01-20 19:30:00 UTC
> Git Commit: `9bc2d34` (9bc2d34a37e88fae053f63977e0bfbd02a61441d)
> Library Version: 2.0.2

This document covers the management of client scopes, including default and optional scopes assigned to clients.

## Table of Contents

- [Get Default Client Scopes](#get-default-client-scopes)
- [Add Default Client Scope](#add-default-client-scope)
- [Remove Default Client Scope](#remove-default-client-scope)
- [Get Optional Client Scopes](#get-optional-client-scopes)
- [Add Optional Client Scope](#add-optional-client-scope)
- [Remove Optional Client Scope](#remove-optional-client-scope)

## Get Default Client Scopes

Retrieves default scopes assigned to a client.

```csharp
IEnumerable<ClientScope> scopes =
    await keycloakClient.GetDefaultClientScopesAsync("master", clientUUID);

foreach (var scope in scopes)
{
    Console.WriteLine($"Scope: {scope.Name}");
}
```

**Returns:** `IEnumerable<ClientScope>`

**Location:** `/src/Keycloak.ApiClient.Net/Clients/KeycloakClient.cs:92`

## Add Default Client Scope

Assigns a default scope to a client.

```csharp
bool success = await keycloakClient.UpdateDefaultClientScopeAsync(
    "master",
    clientUUID,
    clientScopeId
);
```

**Returns:** `bool` - `true` if scope was assigned

**Location:** `/src/Keycloak.ApiClient.Net/Clients/KeycloakClient.cs:97`

## Remove Default Client Scope

Removes a default scope from a client.

```csharp
bool success = await keycloakClient.DeleteDefaultClientScopeAsync(
    "master",
    clientUUID,
    clientScopeId
);
```

**Returns:** `bool` - `true` if scope was removed

**Location:** `/src/Keycloak.ApiClient.Net/Clients/KeycloakClient.cs:106`

## Get Optional Client Scopes

Retrieves optional scopes available to a client.

```csharp
IEnumerable<ClientScope> scopes =
    await keycloakClient.GetOptionalClientScopesAsync("master", clientUUID);
```

**Returns:** `IEnumerable<ClientScope>`

**Location:** `/src/Keycloak.ApiClient.Net/Clients/KeycloakClient.cs:235`

## Add Optional Client Scope

Assigns an optional scope to a client.

```csharp
bool success = await keycloakClient.UpdateOptionalClientScopeAsync(
    "master",
    clientUUID,
    clientScopeId
);
```

**Returns:** `bool` - `true` if scope was assigned

**Location:** `/src/Keycloak.ApiClient.Net/Clients/KeycloakClient.cs:240`

## Remove Optional Client Scope

Removes an optional scope from a client.

```csharp
bool success = await keycloakClient.DeleteOptionalClientScopeAsync(
    "master",
    clientUUID,
    clientScopeId
);
```

**Returns:** `bool` - `true` if scope was removed

**Location:** `/src/Keycloak.ApiClient.Net/Clients/KeycloakClient.cs:249`
