# Keycloak.ApiClient.Net - API Documentation

> **Document Metadata**
> Last Updated: 2026-01-20 19:30:00 UTC
> Git Commit: `9bc2d34` (9bc2d34a37e88fae053f63977e0bfbd02a61441d)
> Library Version: 2.0.2

## Overview

This documentation provides comprehensive guides for using the Keycloak.ApiClient.Net library to interact with the Keycloak Admin REST API. Each document includes detailed explanations, code examples, and sequence diagrams showing how operations work.

## Documentation Structure

The documentation is organized by feature sets (epics) to help you quickly find the operations you need:

### 🔐 [Authentication - Core Operations](./authentication-core.md)

Learn how to authenticate with Keycloak using different authentication modes.

**Topics Covered:**
- Username and Password Authentication
- Client Secret Authentication
- Token Function Authentication (Custom)
- Combined Authentication
- Authentication Flow Sequence Diagrams
- Token Management and Caching
- Security Best Practices

**Key Operations:**
- Initialize `KeycloakClient` with different auth modes
- Custom token acquisition
- Serialization configuration

**Use Cases:**
- Admin console access
- Service-to-service authentication
- Custom authentication flows
- Token refresh strategies

---

### 👤 [User Management - Operations](./user-management-operations.md)

Complete guide to managing users, credentials, and user sessions.

**Topics Covered:**
- User CRUD operations
- Password management and reset
- Credential management
- Group membership
- Federated identity (Social Login)
- Session management
- Email actions and verification
- Consent management

**Key Operations:**
- `CreateUserAsync`, `GetUsersAsync`, `UpdateUserAsync`, `DeleteUserAsync`
- `ResetUserPasswordAsync`, `SetUserPasswordAsync`
- `GetUserGroupsAsync`, `UpdateUserGroupAsync`
- `GetUserSessionsAsync`, `RemoveUserSessionsAsync`
- `VerifyUserEmailAddressAsync`, `SendUserUpdateAccountEmailAsync`
- `AddUserSocialLoginProviderAsync`, `GetUserSocialLoginsAsync`

**Use Cases:**
- User registration and onboarding
- Password reset workflows
- User impersonation
- Session monitoring and logout
- Email verification
- Social login integration

---

### 🔧 [Client Management - Operations](./client-management-operations.md)

Comprehensive guide for managing OAuth 2.0/OpenID Connect clients.

**Topics Covered:**
- Client CRUD operations
- Client secret generation
- Client scope management (default and optional)
- Session statistics and monitoring
- Protocol mapper evaluation
- Service account management
- Client authorization permissions
- Cluster node management

**Key Operations:**
- `CreateClientAsync`, `GetClientsAsync`, `UpdateClientAsync`, `DeleteClientAsync`
- `GenerateClientSecretAsync`, `GetClientSecretAsync`
- `GetDefaultClientScopesAsync`, `GetOptionalClientScopesAsync`
- `GetClientSessionCountAsync`, `GetClientUserSessionsAsync`
- `GenerateClientRegistrationAccessTokenAsync`
- `GetResourcesOwnedByClientAsync` (UMA)

**Use Cases:**
- Register new applications
- Configure OAuth/OIDC clients
- Manage client credentials
- Monitor client sessions
- Setup service accounts
- UMA resource management

---

### 🌐 [Realm Administration - Operations](./realm-administration-operations.md)

Guide to managing Keycloak realms and realm-level configurations.

**Topics Covered:**
- Realm CRUD operations
- Event management (admin and user events)
- Cache management
- Import and export functionality
- Session statistics
- Default client scopes and groups
- LDAP and SMTP testing
- User management permissions

**Key Operations:**
- `ImportRealmAsync`, `GetRealmsAsync`, `UpdateRealmAsync`, `DeleteRealmAsync`
- `GetAdminEventsAsync`, `GetEventsAsync`, `DeleteAdminEventsAsync`
- `ClearKeysCacheAsync`, `ClearRealmCacheAsync`, `ClearUserCacheAsync`
- `RealmPartialExportAsync`, `RealmPartialImportAsync`
- `RemoveUserSessionsAsync` (logout all users)
- `TestLdapConnectionAsync`, `TestSmtpConnectionAsync`

**Use Cases:**
- Multi-tenant setup
- Event auditing and monitoring
- Realm backup and restore
- Performance optimization (cache clearing)
- LDAP/SMTP configuration testing
- Mass user logout

---

### 👥 [Role and Group Management - Operations](./role-group-management-operations.md)

Complete guide to managing roles and groups for authorization.

**Topics Covered:**
- Realm role operations
- Client role operations
- Composite role management
- Group CRUD operations
- Group hierarchy management
- Group member management
- Role and group permissions

**Key Operations:**
- `CreateRoleAsync`, `GetRolesAsync`, `UpdateRoleByNameAsync`, `DeleteRoleByNameAsync`
- `AddCompositesToRoleAsync`, `GetRoleCompositesAsync`, `RemoveCompositesFromRoleAsync`
- `GetUsersWithRoleNameAsync`, `GetGroupsWithRoleNameAsync`
- `CreateGroupAsync`, `GetGroupHierarchyAsync`, `UpdateGroupAsync`, `DeleteGroupAsync`
- `SetOrCreateGroupChildAsync`, `GetGroupUsersAsync`

**Use Cases:**
- Role-Based Access Control (RBAC)
- Permission hierarchies
- Organizational structure modeling
- Department and team management
- Role inheritance through groups

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

### Sequence Diagrams

Each major operation includes a sequence diagram showing the flow between:
- **Application**: Your code using the library
- **KeycloakClient**: The client library
- **Keycloak Server**: The Keycloak backend
- **Other Components**: Email services, LDAP, etc.

These diagrams use Mermaid syntax and help visualize:
- Authentication flows
- API request/response patterns
- Error handling paths
- Multi-step operations

### Code Examples

All examples are complete and runnable. They follow these conventions:
- Use `async/await` patterns
- Include error handling where relevant
- Show both simple and advanced usage
- Demonstrate best practices

### API Location References

Each operation includes a reference like:
```
Location: /src/Keycloak.ApiClient.Net/Users/KeycloakClient.cs:18
```

This shows where in the source code the operation is implemented, helping you:
- Find the exact implementation
- Understand parameter requirements
- See the underlying HTTP calls

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

| Feature | Documentation | Coverage |
|---------|---------------|----------|
| Authentication | ✅ authentication-core.md | Complete |
| Users | ✅ user-management-operations.md | Complete |
| Clients | ✅ client-management-operations.md | Complete |
| Realms | ✅ realm-administration-operations.md | Complete |
| Roles | ✅ role-group-management-operations.md | Complete |
| Groups | ✅ role-group-management-operations.md | Complete |
| Client Scopes | ⚠️ Covered in client-management | Partial |
| Identity Providers | ⚠️ Covered in user-management | Partial |
| Components | 📋 Planned | Pending |
| Protocol Mappers | 📋 Planned | Pending |
| Authorization | 📋 Planned | Pending |

## Additional Resources

### Official Keycloak Documentation
- [Keycloak Admin REST API](https://www.keycloak.org/docs-api/latest/rest-api/)
- [Keycloak Server Documentation](https://www.keycloak.org/documentation.html)
- [OAuth 2.0 Specification](https://oauth.net/2/)
- [OpenID Connect](https://openid.net/connect/)

### Library Resources
- [GitHub Repository](https://github.com/your-repo/Keycloak.ApiClient.Net)
- [NuGet Package](https://www.nuget.org/packages/Keycloak.ApiClient.Net)
- [Release Notes](../CHANGELOG.md)
- [Main README](../../README.md)

## Support and Contributions

### Getting Help
- Review the documentation for your specific use case
- Check the sequence diagrams to understand the flow
- Look at the complete examples for working code
- Search existing issues on GitHub

### Contributing
If you find errors or want to improve the documentation:
1. Fork the repository
2. Update the relevant documentation file
3. Submit a pull request
4. Follow the existing documentation style

## Documentation Version

**Library Version**: 2.0.0
**Documentation Last Updated**: January 2025
**Keycloak Compatibility**: 17+

---

## Quick Navigation

- **New to the library?** Start with [Authentication](./authentication-core.md)
- **Managing users?** See [User Management](./user-management-operations.md)
- **Setting up apps?** Check [Client Management](./client-management-operations.md)
- **Configuring realms?** Review [Realm Administration](./realm-administration-operations.md)
- **Working with permissions?** Read [Role and Group Management](./role-group-management-operations.md)
