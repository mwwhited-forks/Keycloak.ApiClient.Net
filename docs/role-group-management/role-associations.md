# Role Associations

> **Document Metadata**
> Last Updated: 2026-01-20 19:30:00 UTC
> Git Commit: `9bc2d34` (9bc2d34a37e88fae053f63977e0bfbd02a61441d)
> Library Version: 2.0.2

## Overview

Role associations allow you to find which users and groups have been assigned specific roles. This is useful for auditing permissions, understanding access patterns, and managing role-based access control.

## Table of Contents

- [Get Groups with Role](#get-groups-with-role)
- [Get Users with Role](#get-users-with-role)

## Get Groups with Role

Retrieves groups that have a specific role assigned.

```csharp
var groups = await client.GetGroupsWithRoleNameAsync(
    realm: "my-company",
    roleName: "premium-user",
    first: 0,
    max: 100,
    full: true
);
```

**Parameters:**
- `realm` (required) - The realm name
- `roleName` (required) - The name of the role
- `first` - Offset for pagination
- `max` - Maximum results to return
- `full` - Whether to include full group details

**Note:** This method is marked as `[Obsolete("Not working yet")]`

**Location:** `/src/Keycloak.ApiClient.Net/Roles/KeycloakClient.cs:221` (realm) and `:97` (client)

## Get Users with Role

Retrieves users that have a specific role assigned.

```csharp
// Realm role
var users = await client.GetUsersWithRoleNameAsync(
    realm: "my-company",
    roleName: "premium-user",
    first: 0,
    max: 100
);

// Client role
var users = await client.GetUsersWithRoleNameAsync(
    realm: "my-company",
    clientId: clientId,
    roleName: "report-viewer",
    first: 0,
    max: 100
);

foreach (var user in users)
{
    Console.WriteLine($"User: {user.Username}");
}
```

**Parameters:**
- `realm` (required) - The realm name
- `roleName` (required) - The name of the role (for realm roles)
- `clientId` - The client identifier (for client roles)
- `first` - Offset for pagination
- `max` - Maximum results to return

**Returns:** `IEnumerable<User>`

**Location:** `/src/Keycloak.ApiClient.Net/Roles/KeycloakClient.cs:249` (realm) and `:124` (client)

## Best Practices

1. **Auditing**
   - Regularly audit role assignments
   - Monitor users with privileged roles
   - Keep track of role usage

2. **Pagination**
   - Use pagination for large result sets
   - Start with reasonable page sizes (e.g., 100)
   - Implement progressive loading for UI

3. **Performance**
   - Cache results when appropriate
   - Use specific role queries
   - Consider role assignment patterns

4. **Security**
   - Restrict access to role association queries
   - Log audit queries
   - Monitor for unusual access patterns

## Example: Role Assignment Audit

```csharp
using Keycloak.ApiClient.Net;
using Keycloak.ApiClient.Net.Models.Users;

public async Task AuditRoleAssignments()
{
    var client = new KeycloakClient(url, username, password);
    string realm = "my-company";

    // Audit admin role
    var adminUsers = await client.GetUsersWithRoleNameAsync(
        realm: realm,
        roleName: "admin",
        first: 0,
        max: 1000
    );

    Console.WriteLine($"Users with admin role: {adminUsers.Count()}");
    foreach (var user in adminUsers)
    {
        Console.WriteLine($"  - {user.Username} ({user.Email})");
    }

    // Audit client-specific role
    string clientId = "my-app";
    var appAdmins = await client.GetUsersWithRoleNameAsync(
        realm: realm,
        clientId: clientId,
        roleName: "app-admin",
        first: 0,
        max: 1000
    );

    Console.WriteLine($"\nUsers with app-admin role: {appAdmins.Count()}");
    foreach (var user in appAdmins)
    {
        Console.WriteLine($"  - {user.Username} ({user.Email})");
    }
}
```

## Example: Finding All Users with Privileged Access

```csharp
public async Task FindPrivilegedUsers()
{
    var client = new KeycloakClient(url, username, password);
    string realm = "my-company";

    // Define privileged roles
    var privilegedRoles = new[] { "admin", "super-admin", "realm-admin" };
    var privilegedUsers = new HashSet<string>();

    foreach (var roleName in privilegedRoles)
    {
        var users = await client.GetUsersWithRoleNameAsync(
            realm: realm,
            roleName: roleName,
            first: 0,
            max: 1000
        );

        foreach (var user in users)
        {
            privilegedUsers.Add(user.Username);
        }
    }

    Console.WriteLine($"Total privileged users: {privilegedUsers.Count}");
    foreach (var username in privilegedUsers)
    {
        Console.WriteLine($"  - {username}");
    }
}
```

## Example: Role Distribution Report

```csharp
public async Task GenerateRoleDistributionReport()
{
    var client = new KeycloakClient(url, username, password);
    string realm = "my-company";

    // Get all realm roles
    var roles = await client.GetRolesAsync(realm);

    Console.WriteLine("Role Distribution Report");
    Console.WriteLine("========================");

    foreach (var role in roles)
    {
        var users = await client.GetUsersWithRoleNameAsync(
            realm: realm,
            roleName: role.Name,
            first: 0,
            max: 10000
        );

        Console.WriteLine($"{role.Name}: {users.Count()} users");
    }
}
```

## Common Use Cases

### Access Review
Use role associations to periodically review who has access to what permissions.

### Compliance Reporting
Generate reports showing which users have privileged access for compliance audits.

### Role Usage Analysis
Identify unused or over-assigned roles to optimize your permission structure.

### Group-Based Assignment Validation
Verify that users have appropriate roles through group membership.

## Related Resources

- [Realm Role Operations](./realm-roles.md)
- [Client Role Operations](./client-roles.md)
- [Composite Role Operations](./composite-roles.md)
- [Main Documentation](./README.md)
