# Cluster Node Management

> **Document Metadata**
> Last Updated: 2026-01-20 19:30:00 UTC
> Git Commit: `9bc2d34` (9bc2d34a37e88fae053f63977e0bfbd02a61441d)
> Library Version: 2.0.2

This document covers the management of cluster nodes for Keycloak clients in clustered deployments.

## Table of Contents

- [Register Client Cluster Node](#register-client-cluster-node)
- [Unregister Client Cluster Node](#unregister-client-cluster-node)
- [Test Client Cluster Nodes Availability](#test-client-cluster-nodes-availability)

## Register Client Cluster Node

Registers a cluster node for the client.

```csharp
var nodeParams = new Dictionary<string, object>
{
    ["node"] = "node1.example.com"
};

bool success = await keycloakClient.RegisterClientClusterNodeAsync(
    "master",
    clientUUID,
    nodeParams
);
```

**Returns:** `bool` - `true` if node was registered

**Location:** `/src/Keycloak.ApiClient.Net/Clients/KeycloakClient.cs:192`

## Unregister Client Cluster Node

Unregisters a cluster node from the client.

```csharp
bool success = await keycloakClient.UnregisterClientClusterNodeAsync("master", clientUUID);
```

**Returns:** `bool` - `true` if node was unregistered

**Location:** `/src/Keycloak.ApiClient.Net/Clients/KeycloakClient.cs:201`

## Test Client Cluster Nodes Availability

Tests availability of registered cluster nodes.

```csharp
GlobalRequestResult result =
    await keycloakClient.TestClientClusterNodesAvailableAsync("master", clientUUID);

Console.WriteLine($"Failed nodes: {result.FailedNodes?.Count ?? 0}");
```

**Returns:** `GlobalRequestResult`

**Location:** `/src/Keycloak.ApiClient.Net/Clients/KeycloakClient.cs:286`
