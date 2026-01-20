# Protocol Mapper Evaluation

> **Document Metadata**
> Last Updated: 2026-01-20 19:30:00 UTC
> Git Commit: `9bc2d34` (9bc2d34a37e88fae053f63977e0bfbd02a61441d)
> Library Version: 2.0.2

This document covers protocol mapper evaluation and token generation testing for Keycloak clients.

## Table of Contents

- [Get Protocol Mappers in Token Generation](#get-protocol-mappers-in-token-generation)
- [Get Client Granted Scope Mappings](#get-client-granted-scope-mappings)
- [Get Client Not Granted Scope Mappings](#get-client-not-granted-scope-mappings)
- [Generate Example Access Token](#generate-example-access-token)

## Get Protocol Mappers in Token Generation

Evaluates which protocol mappers would be used in token generation.

```csharp
IEnumerable<ClientScopeEvaluateResourceProtocolMapperEvaluation> mappers =
    await keycloakClient.GetProtocolMappersInTokenGenerationAsync(
        realm: "master",
        clientId: clientUUID,
        scope: "openid profile email"
    );

foreach (var mapper in mappers)
{
    Console.WriteLine($"Mapper: {mapper.ProtocolMapper}");
}
```

**Returns:** `IEnumerable<ClientScopeEvaluateResourceProtocolMapperEvaluation>`

**Location:** `/src/Keycloak.ApiClient.Net/Clients/KeycloakClient.cs:131`

## Get Client Granted Scope Mappings

Gets granted scope mappings for evaluation.

```csharp
IEnumerable<Role> grantedRoles =
    await keycloakClient.GetClientGrantedScopeMappingsAsync(
        realm: "master",
        clientId: clientUUID,
        roleContainerId: roleContainerId,
        scope: "openid"
    );
```

**Returns:** `IEnumerable<Role>`

**Location:** `/src/Keycloak.ApiClient.Net/Clients/KeycloakClient.cs:145`

## Get Client Not Granted Scope Mappings

Gets scope mappings that are not granted.

```csharp
IEnumerable<Role> notGrantedRoles =
    await keycloakClient.GetClientNotGrantedScopeMappingsAsync(
        realm: "master",
        clientId: clientUUID,
        roleContainerId: roleContainerId,
        scope: "openid"
    );
```

**Returns:** `IEnumerable<Role>`

**Location:** `/src/Keycloak.ApiClient.Net/Clients/KeycloakClient.cs:159`

## Generate Example Access Token

Generates an example access token for testing.

```csharp
AccessToken token = await keycloakClient.GenerateClientExampleAccessTokenAsync(
    realm: "master",
    clientId: clientUUID,
    scope: "openid profile",
    userId: userId
);
```

**Note:** This method is marked as `[Obsolete("Not working yet")]`

**Location:** `/src/Keycloak.ApiClient.Net/Clients/KeycloakClient.cs:116`
