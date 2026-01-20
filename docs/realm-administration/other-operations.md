# Other Operations

> **Document Metadata**
> Last Updated: 2026-01-20 19:30:00 UTC
> Git Commit: `9bc2d34` (9bc2d34a37e88fae053f63977e0bfbd02a61441d)
> Library Version: 2.0.2

## Overview

This section covers additional realm operations that don't fit into the main categories, including revocation policy management and client description conversion.

## Revocation Policy

### Push Revocation Policy

Pushes the realm's revocation policy to all clients.

```csharp
GlobalRequestResult result = await client.PushRealmRevocationPolicyAsync("my-company");

Console.WriteLine($"Successful pushes: {result.SuccessRequests}");
Console.WriteLine($"Failed pushes: {result.FailedRequests}");
```

**Returns:** `GlobalRequestResult`

**Location:** `/src/Keycloak.ApiClient.Net/RealmsAdmin/KeycloakClient.cs:276`

## Client Description Converter

### Convert Client Description

Converts client description to Keycloak client representation.

```csharp
string samlMetadata = @"<EntityDescriptor ... >";
Client client = await keycloakClient.BasePathForImportingClientsAsync("my-company", samlMetadata);

Console.WriteLine($"Converted Client ID: {client.ClientId}");
```

**Use Case:** Import SAML or OIDC clients from metadata/descriptor files.

**Returns:** `Client`

**Location:** `/src/Keycloak.ApiClient.Net/RealmsAdmin/KeycloakClient.cs:115`
