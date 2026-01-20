# Client Management - Operations

> **Document Metadata**
> Last Updated: 2026-01-20 19:30:00 UTC
> Git Commit: `9bc2d34` (9bc2d34a37e88fae053f63977e0bfbd02a61441d)
> Library Version: 2.0.2

## Overview

The Client Management API provides comprehensive operations for managing OAuth 2.0/OpenID Connect clients in Keycloak. Clients represent applications and services that can request authentication and obtain tokens from Keycloak.

## Key Features

- Client CRUD operations
- Client secret generation and retrieval
- Client scope management (default and optional)
- Service account management
- Session management and statistics
- Client registration tokens
- Client authorization permissions
- Protocol mapper evaluation
- Cluster node management

## Client Model

The core `Client` model includes:

```csharp
public class Client
{
    public string Id { get; set; }
    public string ClientId { get; set; }
    public string Name { get; set; }
    public string Description { get; set; }
    public string RootUrl { get; set; }
    public string BaseUrl { get; set; }
    public bool? Enabled { get; set; }
    public bool? PublicClient { get; set; }
    public bool? BearerOnly { get; set; }
    public bool? ServiceAccountsEnabled { get; set; }
    public bool? DirectAccessGrantsEnabled { get; set; }
    public bool? StandardFlowEnabled { get; set; }
    public bool? ImplicitFlowEnabled { get; set; }
    public List<string> RedirectUris { get; set; }
    public List<string> WebOrigins { get; set; }
    public string Protocol { get; set; }
    public Dictionary<string, string> Attributes { get; set; }
    // Additional properties...
}
```

## Table of Contents

- [CRUD Operations](./crud-operations.md) - Create, read, update, and delete clients
- [Client Secret Management](./secrets.md) - Generate and retrieve client secrets
- [Client Scope Management](./scopes.md) - Manage default and optional client scopes
- [Session and Statistics Management](./sessions.md) - Monitor and manage client sessions
- [Protocol Mapper Evaluation](./protocol-mappers.md) - Evaluate protocol mappers and token generation
- [Service Account Management](./service-accounts.md) - Manage service account users
- [Client Authorization Permissions](./authorization.md) - Manage client authorization permissions
- [Cluster Node Management](./cluster-nodes.md) - Register and manage cluster nodes
- [Revocation and Registration](./revocation.md) - Push revocation policies and generate registration tokens
- [Resource Management](./resources.md) - Manage UMA resources owned by clients

## Client Types and Use Cases

### Public Client

```csharp
var publicClient = new Client
{
    ClientId = "my-spa",
    PublicClient = true,
    StandardFlowEnabled = true,
    ImplicitFlowEnabled = false, // Not recommended
    RedirectUris = new List<string> { "https://myapp.com/*" }
};
```

**Use Cases:** Single Page Applications (SPAs), Mobile Apps

**Security:** Cannot securely store secrets, uses PKCE for authorization code flow

### Confidential Client

```csharp
var confidentialClient = new Client
{
    ClientId = "my-api",
    PublicClient = false,
    ServiceAccountsEnabled = true,
    // Secret will be generated separately
};
```

**Use Cases:** Backend services, APIs, server-side applications

**Security:** Can securely store client secrets

### Bearer-Only Client

```csharp
var bearerClient = new Client
{
    ClientId = "my-resource-server",
    BearerOnly = true,
    // Used for validating tokens only
};
```

**Use Cases:** Resource servers that only validate tokens

**Security:** Doesn't participate in login flows

## Complete Example: Client Lifecycle

```csharp
using Keycloak.ApiClient.Net;
using Keycloak.ApiClient.Net.Models.Clients;

public class ClientManagement
{
    private readonly KeycloakClient _client;

    public ClientManagement(string url, string username, string password)
    {
        _client = new KeycloakClient(url, username, password);
    }

    public async Task ClientLifecycleExample()
    {
        string realm = "master";

        // 1. Create a confidential client
        var client = new Client
        {
            ClientId = "my-backend-service",
            Name = "My Backend Service",
            Description = "Backend service for my application",
            Enabled = true,
            PublicClient = false,
            ServiceAccountsEnabled = true,
            StandardFlowEnabled = false,
            DirectAccessGrantsEnabled = false,
            Protocol = "openid-connect",
            RedirectUris = new List<string>
            {
                "https://api.myapp.com/*"
            }
        };

        string clientUUID = await _client.CreateClientAndRetrieveClientIdAsync(realm, client);
        Console.WriteLine($"Client created with UUID: {clientUUID}");

        // 2. Generate client secret
        var credentials = await _client.GenerateClientSecretAsync(realm, clientUUID);
        Console.WriteLine($"Client Secret: {credentials.Value}");
        // IMPORTANT: Store this secret securely!

        // 3. Assign client scopes
        var allScopes = await _client.GetOptionalClientScopesAsync(realm, clientUUID);
        var emailScope = allScopes.FirstOrDefault(s => s.Name == "email");

        if (emailScope != null)
        {
            await _client.UpdateDefaultClientScopeAsync(realm, clientUUID, emailScope.Id);
            Console.WriteLine("Email scope added as default");
        }

        // 4. Get client details
        var retrievedClient = await _client.GetClientAsync(realm, clientUUID);
        Console.WriteLine($"Client enabled: {retrievedClient.Enabled}");

        // 5. Monitor sessions
        long sessionCount = await _client.GetClientSessionCountAsync(realm, clientUUID);
        Console.WriteLine($"Active sessions: {sessionCount}");

        var sessions = await _client.GetClientUserSessionsAsync(realm, clientUUID, 0, 10);
        foreach (var session in sessions)
        {
            Console.WriteLine($"  Session: {session.Username} - {session.Start}");
        }

        // 6. Update client configuration
        retrievedClient.Description = "Updated description";
        await _client.UpdateClientAsync(realm, clientUUID, retrievedClient);
        Console.WriteLine("Client updated");

        // 7. Delete client (cleanup)
        await _client.DeleteClientAsync(realm, clientUUID);
        Console.WriteLine("Client deleted");
    }
}
```

## Best Practices

1. **Client Secrets**
   - Store secrets securely (environment variables, secrets manager)
   - Rotate secrets regularly
   - Never commit secrets to version control
   - Use different secrets for different environments

2. **Redirect URIs**
   - Use specific URIs, avoid wildcards when possible
   - Always use HTTPS in production
   - Validate all redirect URIs

3. **Client Scopes**
   - Assign only necessary scopes
   - Use default scopes for always-needed claims
   - Use optional scopes for user-consent claims

4. **Session Management**
   - Monitor session counts for anomalies
   - Implement session timeout policies
   - Clean up offline sessions periodically

5. **Service Accounts**
   - Use for server-to-server communication
   - Assign minimal required roles
   - Monitor service account usage

6. **Client Configuration**
   - Disable unused grant types
   - Enable standard flow for web apps
   - Enable direct access grants only when necessary

## Error Codes

| HTTP Code | Meaning | Common Causes |
|-----------|---------|---------------|
| 400 | Bad Request | Invalid client configuration, malformed URIs |
| 401 | Unauthorized | Invalid or expired authentication token |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not Found | Client UUID doesn't exist |
| 409 | Conflict | ClientId already exists |
| 500 | Server Error | Keycloak internal error |

## Related Resources

- [Keycloak Client API Documentation](https://www.keycloak.org/docs-api/latest/rest-api/index.html#_clients_resource)
- [OAuth 2.0 Client Types](https://oauth.net/2/client-types/)
- [OpenID Connect Clients](https://openid.net/specs/openid-connect-core-1_0.html#ClientAuthentication)
- [Authentication Documentation](../authentication-core.md)
