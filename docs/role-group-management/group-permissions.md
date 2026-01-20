# Group Permissions

> **Document Metadata**
> Last Updated: 2026-01-20 19:30:00 UTC
> Git Commit: `9bc2d34` (9bc2d34a37e88fae053f63977e0bfbd02a61441d)
> Library Version: 2.0.2

## Overview

Group authorization permissions control who can manage groups and their members within Keycloak. These fine-grained permissions allow you to delegate group management capabilities without granting full administrative access to the realm.

## Table of Contents

- [Get Group Authorization Permissions](#get-group-authorization-permissions)
- [Set Group Authorization Permissions](#set-group-authorization-permissions)

## Get Group Authorization Permissions

Retrieves authorization permissions for a group.

```csharp
ManagementPermission permissions =
    await client.GetGroupClientAuthorizationPermissionsInitializedAsync(
        "my-company",
        groupId
    );

Console.WriteLine($"Permissions Enabled: {permissions.Enabled}");
```

**Parameters:**
- `realm` (required) - The realm name
- `groupId` (required) - The group identifier

**Returns:** `ManagementPermission`

**Location:** `/src/Keycloak.ApiClient.Net/Groups/KeycloakClient.cs:95`

## Set Group Authorization Permissions

Initializes or updates authorization permissions for a group.

```csharp
var permissions = new ManagementPermission
{
    Enabled = true
};

ManagementPermission result =
    await client.SetGroupClientAuthorizationPermissionsInitializedAsync(
        "my-company",
        groupId,
        permissions
    );
```

**Parameters:**
- `realm` (required) - The realm name
- `groupId` (required) - The group identifier
- `permissions` (required) - The management permission settings

**Returns:** `ManagementPermission`

**Location:** `/src/Keycloak.ApiClient.Net/Groups/KeycloakClient.cs:100`

## ManagementPermission Model

```csharp
public class ManagementPermission
{
    public bool Enabled { get; set; }
    public string Resource { get; set; }
    public Dictionary<string, string> ScopePermissions { get; set; }
}
```

## Understanding Group Permissions

### Permission Types

Group permissions can control:
- **View**: Who can view the group and its members
- **Manage**: Who can modify group attributes
- **Manage Members**: Who can add/remove group members
- **View Members**: Who can see group membership

### Permission Scope

- Permissions are group-specific
- Can be delegated to specific roles or users
- Independent of realm-level admin permissions
- Inherited by subgroups (depending on configuration)

## Best Practices

1. **Permission Delegation**
   - Enable permissions for groups requiring delegated management
   - Use fine-grained permissions instead of full admin access
   - Document permission policies

2. **Security**
   - Enable permissions only when necessary
   - Audit permission changes regularly
   - Review delegated permissions periodically

3. **Organizational Structure**
   - Use permissions to enable department-level group management
   - Align permissions with organizational hierarchy
   - Monitor permission usage

4. **Testing**
   - Test permission settings before production deployment
   - Verify permission inheritance in hierarchies
   - Validate access control policies

## Example: Setting Up Group Permissions

```csharp
using Keycloak.ApiClient.Net;
using Keycloak.ApiClient.Net.Models.Groups;

public async Task SetupGroupPermissions()
{
    var client = new KeycloakClient(url, username, password);
    string realm = "my-company";

    // Get the group
    var groups = await client.GetGroupHierarchyAsync(realm, search: "Engineering");
    var engineeringGroup = groups.FirstOrDefault();

    if (engineeringGroup != null)
    {
        // Enable permissions for the group
        var permissions = new ManagementPermission
        {
            Enabled = true
        };

        var result = await client.SetGroupClientAuthorizationPermissionsInitializedAsync(
            realm,
            engineeringGroup.Id,
            permissions
        );

        Console.WriteLine($"Permissions enabled: {result.Enabled}");
        Console.WriteLine($"Resource: {result.Resource}");

        if (result.ScopePermissions != null)
        {
            Console.WriteLine("Scope permissions:");
            foreach (var scope in result.ScopePermissions)
            {
                Console.WriteLine($"  {scope.Key}: {scope.Value}");
            }
        }
    }
}
```

## Example: Checking Group Permissions

```csharp
public async Task CheckGroupPermissions()
{
    var client = new KeycloakClient(url, username, password);
    string realm = "my-company";
    string groupId = "engineering-group-id";

    var permissions = await client.GetGroupClientAuthorizationPermissionsInitializedAsync(
        realm,
        groupId
    );

    if (permissions.Enabled)
    {
        Console.WriteLine("Group permissions are enabled");
        Console.WriteLine($"Resource ID: {permissions.Resource}");

        if (permissions.ScopePermissions != null && permissions.ScopePermissions.Any())
        {
            Console.WriteLine("\nConfigured scope permissions:");
            foreach (var scope in permissions.ScopePermissions)
            {
                Console.WriteLine($"  {scope.Key}:");
                Console.WriteLine($"    Permission ID: {scope.Value}");
            }
        }
    }
    else
    {
        Console.WriteLine("Group permissions are not enabled");
        Console.WriteLine("Enable permissions to allow delegated management");
    }
}
```

## Example: Batch Permission Setup

```csharp
public async Task EnablePermissionsForMultipleGroups()
{
    var client = new KeycloakClient(url, username, password);
    string realm = "my-company";

    // Get all top-level groups
    var groups = await client.GetGroupHierarchyAsync(realm);

    var permissions = new ManagementPermission
    {
        Enabled = true
    };

    Console.WriteLine("Enabling permissions for all groups:");
    Console.WriteLine("===================================");

    foreach (var group in groups)
    {
        try
        {
            var result = await client.SetGroupClientAuthorizationPermissionsInitializedAsync(
                realm,
                group.Id,
                permissions
            );

            Console.WriteLine($"✓ {group.Name}: Permissions enabled");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"✗ {group.Name}: Failed - {ex.Message}");
        }
    }
}
```

## Example: Audit Group Permissions

```csharp
public async Task AuditGroupPermissions()
{
    var client = new KeycloakClient(url, username, password);
    string realm = "my-company";

    var groups = await client.GetGroupHierarchyAsync(realm);

    Console.WriteLine("Group Permissions Audit");
    Console.WriteLine("======================");

    foreach (var group in groups)
    {
        try
        {
            var permissions = await client.GetGroupClientAuthorizationPermissionsInitializedAsync(
                realm,
                group.Id
            );

            Console.WriteLine($"\n{group.Name} ({group.Path})");
            Console.WriteLine($"  Enabled: {permissions.Enabled}");

            if (permissions.Enabled && permissions.Resource != null)
            {
                Console.WriteLine($"  Resource: {permissions.Resource}");

                if (permissions.ScopePermissions != null)
                {
                    Console.WriteLine($"  Scopes: {permissions.ScopePermissions.Count}");
                }
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"\n{group.Name}: Error - {ex.Message}");
        }

        // Audit subgroups recursively
        if (group.SubGroups != null)
        {
            await AuditSubGroupPermissions(client, realm, group.SubGroups, 1);
        }
    }
}

private async Task AuditSubGroupPermissions(KeycloakClient client, string realm,
    List<Group> subGroups, int level)
{
    var indent = new string(' ', level * 2);
    foreach (var subGroup in subGroups)
    {
        try
        {
            var permissions = await client.GetGroupClientAuthorizationPermissionsInitializedAsync(
                realm,
                subGroup.Id
            );

            Console.WriteLine($"\n{indent}{subGroup.Name} ({subGroup.Path})");
            Console.WriteLine($"{indent}  Enabled: {permissions.Enabled}");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"\n{indent}{subGroup.Name}: Error - {ex.Message}");
        }

        if (subGroup.SubGroups != null)
        {
            await AuditSubGroupPermissions(client, realm, subGroup.SubGroups, level + 1);
        }
    }
}
```

## Common Use Cases

### Department Management
Enable permissions for department groups so department managers can manage their own team members.

### Delegated Administration
Allow specific users to manage certain groups without full realm admin access.

### Self-Service Groups
Enable groups for self-service membership management in community or project-based organizations.

### Compliance
Enable permissions to track who can manage sensitive groups and maintain audit trails.

## Important Notes

1. **Authorization Services**
   - Requires Keycloak authorization services to be enabled
   - May require additional Keycloak configuration
   - Check your Keycloak version for feature availability

2. **Permission Configuration**
   - Enabling permissions creates authorization resources
   - Fine-grained permissions require policy configuration in Keycloak admin console
   - Scope permissions control specific management operations

3. **Performance**
   - Permission checks add overhead
   - Cache permission results when possible
   - Monitor performance with permissions enabled

## Related Resources

- [Keycloak Authorization Services](https://www.keycloak.org/docs/latest/authorization_services/)
- [Group CRUD Operations](./group-crud.md)
- [Group Hierarchy Operations](./group-hierarchy.md)
- [Group Members](./group-members.md)
- [Main Documentation](./README.md)
