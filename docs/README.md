# Keycloak.ApiClient.Net - API Documentation

> **Document Metadata**
> Last Updated: 2026-01-20 20:00:00 UTC
> Git Commit: `9bc2d34` (9bc2d34a37e88fae053f63977e0bfbd02a61441d)
> Library Version: 2.0.2

## Overview

This documentation provides comprehensive guides for using the Keycloak.ApiClient.Net library to interact with the Keycloak Admin REST API. Each section includes detailed explanations, code examples, and sequence diagrams showing how operations work.

## Documentation Organization

Documentation is organized into focused folders by feature area. Each folder contains:
- **README.md** - Overview, models, key features, and navigation
- **Operation-specific files** - Detailed documentation for each operation group

This structure keeps files concise and makes finding specific operations easier.

## 🔐 Authentication

**Location:** [`./authentication/`](./authentication/)

Learn how to authenticate with Keycloak using different authentication modes.

**Topics:**
- Username and Password Authentication
- Client Secret Authentication
- Token Function Authentication (Custom)
- Combined Authentication
- Token Management and Caching
- Security Best Practices

**Use Cases:**
- Admin console access
- Service-to-service authentication
- Custom authentication flows

**[Start Here →](./authentication/README.md)**

---

## 👤 User Management

**Location:** [`./user-management/`](./user-management/)

Complete guide to managing users, credentials, and user sessions.

**Topics:**
- [User CRUD Operations](./user-management/crud-operations.md)
- [Password Management](./user-management/passwords.md)
- [Credential Management](./user-management/credentials.md)
- [Group Membership](./user-management/groups.md)
- [Federated Identity (Social Login)](./user-management/federated-identity.md)
- [Session Management](./user-management/sessions.md)
- [Email Actions](./user-management/email-actions.md)
- [Consent Management](./user-management/consents.md)
- [User Impersonation](./user-management/impersonation.md)

**Key Operations:**
- `CreateUserAsync`, `GetUsersAsync`, `UpdateUserAsync`, `DeleteUserAsync`
- `ResetUserPasswordAsync`, `SetUserPasswordAsync`
- `GetUserGroupsAsync`, `UpdateUserGroupAsync`
- `GetUserSessionsAsync`, `RemoveUserSessionsAsync`

**[Start Here →](./user-management/README.md)**

---

## 🔧 Client Management

**Location:** [`./client-management/`](./client-management/)

Comprehensive guide for managing OAuth 2.0/OpenID Connect clients.

**Topics:**
- [Client CRUD Operations](./client-management/crud-operations.md)
- [Client Secret Management](./client-management/secrets.md)
- [Client Scope Management](./client-management/scopes.md)
- [Session Statistics](./client-management/sessions.md)
- [Protocol Mapper Evaluation](./client-management/protocol-mappers.md)
- [Service Account Management](./client-management/service-accounts.md)
- [Authorization Permissions](./client-management/authorization.md)
- [Cluster Node Management](./client-management/cluster-nodes.md)
- [Revocation & Registration](./client-management/revocation.md)
- [Resource Management (UMA)](./client-management/resources.md)

**Key Operations:**
- `CreateClientAsync`, `GetClientsAsync`, `UpdateClientAsync`, `DeleteClientAsync`
- `GenerateClientSecretAsync`, `GetClientSecretAsync`
- `GetDefaultClientScopesAsync`, `GetOptionalClientScopesAsync`

**[Start Here →](./client-management/README.md)**

---

## 🌐 Realm Administration

**Location:** [`./realm-administration/`](./realm-administration/)

Guide to managing Keycloak realms and realm-level configurations.

**Topics:**
- [Realm CRUD Operations](./realm-administration/crud-operations.md)
- [Event Management](./realm-administration/events.md)
- [Cache Management](./realm-administration/cache.md)
- [Session Management](./realm-administration/sessions.md)
- [Default Client Scopes](./realm-administration/client-scopes.md)
- [Default Groups](./realm-administration/default-groups.md)
- [Import/Export Functionality](./realm-administration/import-export.md)
- [Testing Operations](./realm-administration/testing.md)
- [User Management Permissions](./realm-administration/permissions.md)
- [Other Operations](./realm-administration/other-operations.md)

**Key Operations:**
- `ImportRealmAsync`, `GetRealmsAsync`, `UpdateRealmAsync`, `DeleteRealmAsync`
- `GetAdminEventsAsync`, `GetEventsAsync`
- `ClearKeysCacheAsync`, `ClearRealmCacheAsync`, `ClearUserCacheAsync`
- `TestLdapConnectionAsync`, `TestSmtpConnectionAsync`

**[Start Here →](./realm-administration/README.md)**

---

## 👥 Role and Group Management

**Location:** [`./role-group-management/`](./role-group-management/)

Complete guide to managing roles and groups for authorization.

**Role Topics:**
- [Realm Role Operations](./role-group-management/realm-roles.md)
- [Client Role Operations](./role-group-management/client-roles.md)
- [Composite Role Operations](./role-group-management/composite-roles.md)
- [Role Associations](./role-group-management/role-associations.md)
- [Role Permissions](./role-group-management/role-permissions.md)

**Group Topics:**
- [Group CRUD Operations](./role-group-management/group-crud.md)
- [Group Hierarchy](./role-group-management/group-hierarchy.md)
- [Group Members](./role-group-management/group-members.md)
- [Group Permissions](./role-group-management/group-permissions.md)

**Key Operations:**
- `CreateRoleAsync`, `GetRolesAsync`, `UpdateRoleByNameAsync`, `DeleteRoleByNameAsync`
- `AddCompositesToRoleAsync`, `GetRoleCompositesAsync`
- `CreateGroupAsync`, `GetGroupHierarchyAsync`, `UpdateGroupAsync`, `DeleteGroupAsync`

**[Start Here →](./role-group-management/README.md)**

---

## Quick Start Examples

### Basic Authentication and User Retrieval

```csharp
using Keycloak.ApiClient.Net;

// Initialize client
var client = new KeycloakClient(
    "https://keycloak.example.com",
    "admin",
    "admin-password"
);

// Get users
var users = await client.GetUsersAsync("master");
foreach (var user in users)
{
    Console.WriteLine($"User: {user.Username}");
}
```

### Create a Client and Generate Secret

```csharp
var newClient = new Client
{
    ClientId = "my-app",
    Enabled = true,
    PublicClient = false,
    ServiceAccountsEnabled = true,
    RedirectUris = new List<string> { "https://myapp.com/*" }
};

string clientUUID = await client.CreateClientAndRetrieveClientIdAsync("master", newClient);
var credentials = await client.GenerateClientSecretAsync("master", clientUUID);

Console.WriteLine($"Client Secret: {credentials.Value}");
```

### Setup Role Hierarchy

```csharp
// Create base roles
await client.CreateRoleAsync("master", new Role { Name = "user" });
await client.CreateRoleAsync("master", new Role { Name = "admin", Composite = true });

// Make admin composite include user
var userRole = await client.GetRoleByNameAsync("master", "user");
await client.AddCompositesToRoleAsync("master", "admin", new[] { userRole });
```

## Understanding the Documentation

### Structure

Each feature area follows this structure:
- **README.md** - Overview, models, and table of contents
- **Specific operation files** - Detailed documentation for operation groups
- **Examples** - Complete, runnable code samples
- **Diagrams** - PlantUML sequence diagrams for complex flows

### Sequence Diagrams

Each major operation includes a sequence diagram showing the flow between:
- **Application**: Your code using the library
- **KeycloakClient**: The client library
- **Keycloak Server**: The Keycloak backend

These diagrams use Mermaid syntax and help visualize:
- Authentication flows
- API request/response patterns
- Error handling paths

### Code Examples

All examples are complete and runnable. They follow these conventions:
- Use `async/await` patterns
- Include error handling where relevant
- Show both simple and advanced usage
- Demonstrate best practices

### API References

Each operation includes:
- **Location**: Source code file and line number
- **Keycloak API**: Link to official Keycloak REST API documentation
- **Signature**: Method signature with parameters
- **Parameters**: Description of each parameter
- **Returns**: Description of return value
- **Examples**: Complete usage examples

## Common Patterns

### Error Handling

```csharp
try
{
    var users = await client.GetUsersAsync("master");
}
catch (FlurlHttpException ex)
{
    if (ex.StatusCode == 401)
    {
        Console.WriteLine("Authentication failed");
    }
    else if (ex.StatusCode == 403)
    {
        Console.WriteLine("Insufficient permissions");
    }
    else
    {
        Console.WriteLine($"Error: {ex.Message}");
    }
}
```

### Pagination

```csharp
int offset = 0;
int pageSize = 100;
bool hasMore = true;

while (hasMore)
{
    var users = await client.GetUsersAsync(
        realm: "master",
        first: offset,
        max: pageSize
    );

    foreach (var user in users)
    {
        // Process user
    }

    hasMore = users.Count() == pageSize;
    offset += pageSize;
}
```

### Configuration from Settings

```csharp
var configuration = new ConfigurationBuilder()
    .AddJsonFile("appsettings.json")
    .AddEnvironmentVariables()
    .Build();

var client = new KeycloakClient(
    url: configuration["Keycloak:Url"],
    userName: configuration["Keycloak:Username"],
    password: configuration["Keycloak:Password"]
);
```

## Feature Coverage

| Feature | Documentation | Location |
|---------|---------------|----------|
| Authentication | ✅ Complete | [./authentication/](./authentication/) |
| Users | ✅ Complete | [./user-management/](./user-management/) |
| Clients | ✅ Complete | [./client-management/](./client-management/) |
| Realms | ✅ Complete | [./realm-administration/](./realm-administration/) |
| Roles | ✅ Complete | [./role-group-management/](./role-group-management/) |
| Groups | ✅ Complete | [./role-group-management/](./role-group-management/) |

## Additional Resources

### Official Keycloak Documentation
- [Keycloak Admin REST API](https://www.keycloak.org/docs-api/latest/rest-api/)
- [Keycloak Server Documentation](https://www.keycloak.org/documentation.html)
- [OAuth 2.0 Specification](https://oauth.net/2/)
- [OpenID Connect](https://openid.net/connect/)

### Library Resources
- [GitHub Repository](https://github.com/leandrogf/Keycloak.ApiClient.Net)
- [NuGet Package](https://www.nuget.org/packages/Keycloak.ApiClient.Net)
- [Main README](../README.md)
- [CLAUDE.md](../CLAUDE.md) - Codebase guide for development

## Getting Help

- Review the documentation for your specific use case
- Check the sequence diagrams to understand the flow
- Look at the complete examples for working code
- Search existing issues on GitHub
- Refer to official Keycloak API documentation

## Documentation Version

**Library Version**: 2.0.2
**Documentation Last Updated**: January 2026
**Keycloak Compatibility**: 17+

---

## Quick Navigation

- **New to the library?** Start with [Authentication](./authentication/README.md)
- **Managing users?** See [User Management](./user-management/README.md)
- **Setting up apps?** Check [Client Management](./client-management/README.md)
- **Configuring realms?** Review [Realm Administration](./realm-administration/README.md)
- **Working with permissions?** Read [Role and Group Management](./role-group-management/README.md)
