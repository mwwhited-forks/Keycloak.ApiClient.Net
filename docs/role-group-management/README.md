# Role and Group Management

> **Document Metadata**
> Last Updated: 2026-01-20 19:30:00 UTC
> Git Commit: `9bc2d34` (9bc2d34a37e88fae053f63977e0bfbd02a61441d)
> Library Version: 2.0.2

## Overview

The Role and Group Management APIs provide comprehensive operations for managing authorization through roles and organizing users through groups in Keycloak. Roles define permissions and access levels, while groups provide a way to organize users and assign common attributes or roles.

## Key Concepts

### Roles
- **Realm Roles**: Global roles available across all clients in a realm
- **Client Roles**: Specific to a particular client application
- **Composite Roles**: Roles that contain other roles
- **Role Mappings**: Assignment of roles to users or groups

### Groups
- **Hierarchical Structure**: Groups can have parent-child relationships
- **Attributes**: Groups can have custom attributes
- **Role Inheritance**: Users inherit roles from their groups
- **Member Management**: Users can belong to multiple groups

## Role Model

```csharp
public class Role
{
    public string Id { get; set; }
    public string Name { get; set; }
    public string Description { get; set; }
    public bool? Composite { get; set; }
    public bool? ClientRole { get; set; }
    public string ContainerId { get; set; }
    public Dictionary<string, object> Attributes { get; set; }
}
```

## Group Model

```csharp
public class Group
{
    public string Id { get; set; }
    public string Name { get; set; }
    public string Path { get; set; }
    public List<Group> SubGroups { get; set; }
    public Dictionary<string, object> Attributes { get; set; }
    public List<string> RealmRoles { get; set; }
    public Dictionary<string, object> ClientRoles { get; set; }
}
```

## Table of Contents

### Role Operations
- [Realm Role Operations](./realm-roles.md) - Create, read, update, and delete realm-level roles
- [Client Role Operations](./client-roles.md) - Manage client-specific roles
- [Composite Role Operations](./composite-roles.md) - Build role hierarchies with composite roles
- [Role Associations](./role-associations.md) - Find users and groups with specific roles
- [Role Authorization Permissions](./role-permissions.md) - Manage role-level permissions

### Group Operations
- [Group CRUD Operations](./group-crud.md) - Create, read, update, and delete groups
- [Group Hierarchy Operations](./group-hierarchy.md) - Manage parent-child group relationships
- [Group Members](./group-members.md) - Manage group membership
- [Group Permissions](./group-permissions.md) - Configure group authorization permissions

## Complete Example: Role and Group Setup

```csharp
using Keycloak.ApiClient.Net;
using Keycloak.ApiClient.Net.Models.Roles;
using Keycloak.ApiClient.Net.Models.Groups;

public class RoleGroupManagement
{
    private readonly KeycloakClient _client;

    public RoleGroupManagement(string url, string username, string password)
    {
        _client = new KeycloakClient(url, username, password);
    }

    public async Task SetupRolesAndGroupsExample()
    {
        string realm = "my-company";

        // 1. Create realm roles
        var userRole = new Role
        {
            Name = "user",
            Description = "Basic user role"
        };
        await _client.CreateRoleAsync(realm, userRole);

        var premiumRole = new Role
        {
            Name = "premium-user",
            Description = "Premium subscription users",
            Composite = true
        };
        await _client.CreateRoleAsync(realm, premiumRole);

        var adminRole = new Role
        {
            Name = "admin",
            Description = "Administrator role",
            Composite = true
        };
        await _client.CreateRoleAsync(realm, adminRole);

        Console.WriteLine("Roles created");

        // 2. Create composite role relationships
        var baseUserRole = await _client.GetRoleByNameAsync(realm, "user");
        var compositeRoles = new List<Role> { baseUserRole };

        await _client.AddCompositesToRoleAsync(realm, "premium-user", compositeRoles);
        Console.WriteLine("Premium-user role now includes user role");

        var premiumUserRole = await _client.GetRoleByNameAsync(realm, "premium-user");
        var adminComposites = new List<Role> { premiumUserRole };

        await _client.AddCompositesToRoleAsync(realm, "admin", adminComposites);
        Console.WriteLine("Admin role now includes premium-user and user roles");

        // 3. Create group hierarchy
        var engineeringGroup = new Group
        {
            Name = "Engineering",
            Attributes = new Dictionary<string, object>
            {
                ["department"] = new[] { "IT" }
            }
        };
        await _client.CreateGroupAsync(realm, engineeringGroup);

        // Get the created group to get its ID
        var groups = await _client.GetGroupHierarchyAsync(realm, search: "Engineering");
        var engGroup = groups.FirstOrDefault();

        if (engGroup != null)
        {
            // Create subgroups
            var frontendTeam = new Group
            {
                Name = "Frontend Team"
            };
            await _client.SetOrCreateGroupChildAsync(realm, engGroup.Id, frontendTeam);

            var backendTeam = new Group
            {
                Name = "Backend Team"
            };
            await _client.SetOrCreateGroupChildAsync(realm, engGroup.Id, backendTeam);

            Console.WriteLine("Engineering group with teams created");

            // 4. Get group members
            var members = await _client.GetGroupUsersAsync(realm, engGroup.Id);
            Console.WriteLine($"Engineering group has {members.Count()} members");

            // 5. View role composites
            var adminCompositeRoles = await _client.GetRoleCompositesAsync(realm, "admin");
            Console.WriteLine($"Admin role includes {adminCompositeRoles.Count()} composite roles:");
            foreach (var role in adminCompositeRoles)
            {
                Console.WriteLine($"  - {role.Name}");
            }

            // 6. Find users with specific role
            var adminUsers = await _client.GetUsersWithRoleNameAsync(realm, "admin");
            Console.WriteLine($"Users with admin role: {adminUsers.Count()}");
        }
    }
}
```

## Best Practices

### Roles

1. **Role Naming**
   - Use clear, descriptive names
   - Follow consistent naming conventions
   - Use lowercase with hyphens (e.g., `premium-user`)

2. **Composite Roles**
   - Use composites for role hierarchies
   - Keep composite relationships logical
   - Document role relationships

3. **Role Assignment**
   - Assign roles through groups when possible
   - Use least privilege principle
   - Avoid direct user role assignments for large user bases

4. **Client vs Realm Roles**
   - Use realm roles for cross-application permissions
   - Use client roles for application-specific permissions
   - Keep role count manageable

### Groups

1. **Group Hierarchy**
   - Design logical hierarchies
   - Keep depth reasonable (3-4 levels max)
   - Use meaningful group names

2. **Group Attributes**
   - Use attributes for metadata
   - Keep attribute values consistent
   - Document custom attributes

3. **Group Membership**
   - Add users to groups, not individual roles
   - Use groups for organizational structure
   - Monitor group sizes for performance

4. **Permissions**
   - Enable group permissions when needed
   - Regular audit of group access
   - Document permission policies

## Common Patterns

### Role-Based Access Control (RBAC)

```csharp
// Create role hierarchy
await _client.CreateRoleAsync(realm, new Role { Name = "viewer" });
await _client.CreateRoleAsync(realm, new Role { Name = "editor", Composite = true });
await _client.CreateRoleAsync(realm, new Role { Name = "admin", Composite = true });

// Build hierarchy: admin > editor > viewer
var viewerRole = await _client.GetRoleByNameAsync(realm, "viewer");
await _client.AddCompositesToRoleAsync(realm, "editor", new[] { viewerRole });

var editorRole = await _client.GetRoleByNameAsync(realm, "editor");
await _client.AddCompositesToRoleAsync(realm, "admin", new[] { editorRole });
```

### Organizational Structure

```csharp
// Create departments
var salesGroup = new Group { Name = "Sales" };
var engineeringGroup = new Group { Name = "Engineering" };

await _client.CreateGroupAsync(realm, salesGroup);
await _client.CreateGroupAsync(realm, engineeringGroup);

// Create teams within departments
var groups = await _client.GetGroupHierarchyAsync(realm);
var sales = groups.First(g => g.Name == "Sales");
var engineering = groups.First(g => g.Name == "Engineering");

await _client.SetOrCreateGroupChildAsync(realm, sales.Id, new Group { Name = "EMEA Sales" });
await _client.SetOrCreateGroupChildAsync(realm, sales.Id, new Group { Name = "APAC Sales" });

await _client.SetOrCreateGroupChildAsync(realm, engineering.Id, new Group { Name = "Backend" });
await _client.SetOrCreateGroupChildAsync(realm, engineering.Id, new Group { Name = "Frontend" });
```

## Error Codes

| HTTP Code | Meaning | Common Causes |
|-----------|---------|---------------|
| 400 | Bad Request | Invalid role/group data, circular composite roles |
| 401 | Unauthorized | Invalid or expired authentication token |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not Found | Role/Group ID doesn't exist |
| 409 | Conflict | Role/Group name already exists |
| 500 | Server Error | Keycloak internal error |

## Related Resources

- [Keycloak Roles API Documentation](https://www.keycloak.org/docs-api/latest/rest-api/index.html#_roles_resource)
- [Keycloak Groups API Documentation](https://www.keycloak.org/docs-api/latest/rest-api/index.html#_groups_resource)
- [Role-Based Access Control (RBAC)](https://en.wikipedia.org/wiki/Role-based_access_control)
- [User Management Documentation](../user-management-operations.md)
- [Client Management Documentation](../client-management-operations.md)
