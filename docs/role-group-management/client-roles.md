# Client Role Operations

> **Document Metadata**
> Last Updated: 2026-01-20 19:30:00 UTC
> Git Commit: `9bc2d34` (9bc2d34a37e88fae053f63977e0bfbd02a61441d)
> Library Version: 2.0.2

## Overview

Client roles are specific to a particular client application within a realm. They provide fine-grained access control for individual applications. This section covers all CRUD operations for client-level roles.

## Table of Contents

- [Create Client Role](#create-client-role)
- [Get Client Roles](#get-client-roles)
- [Get Client Role by Name](#get-client-role-by-name)
- [Update Client Role](#update-client-role)
- [Delete Client Role](#delete-client-role)

## Create Client Role

Creates a new client-specific role.

```csharp
var role = new Role
{
    Name = "report-viewer",
    Description = "Can view reports in the application",
    Composite = false
};

bool success = await client.CreateRoleAsync("my-company", clientId, role);
```

**Returns:** `bool` - `true` if role was created successfully

**Location:** `/src/Keycloak.ApiClient.Net/Roles/KeycloakClient.cs:15`

## Get Client Roles

Retrieves roles for a specific client.

```csharp
var clientRoles = await client.GetRolesAsync(
    realm: "my-company",
    clientId: clientId,
    search: "admin",
    first: 0,
    max: 20
);

foreach (var role in clientRoles)
{
    Console.WriteLine($"Client Role: {role.Name}");
}
```

**Parameters:**
- `realm` (required) - The realm name
- `clientId` (required) - The client identifier
- `first` - Offset for pagination
- `max` - Maximum results to return
- `search` - Search term for role names

**Returns:** `IEnumerable<Role>`

**Location:** `/src/Keycloak.ApiClient.Net/Roles/KeycloakClient.cs:24`

## Get Client Role by Name

Retrieves a specific client role by its name.

```csharp
Role role = await client.GetRoleByNameAsync("my-company", clientId, "report-viewer");
```

**Returns:** `Role`

**Location:** `/src/Keycloak.ApiClient.Net/Roles/KeycloakClient.cs:40`

## Update Client Role

Updates an existing client role.

```csharp
role.Description = "Updated description";
bool success = await client.UpdateRoleByNameAsync("my-company", clientId, "report-viewer", role);
```

**Returns:** `bool` - `true` if update was successful

**Location:** `/src/Keycloak.ApiClient.Net/Roles/KeycloakClient.cs:45`

## Delete Client Role

Deletes a client role.

```csharp
bool success = await client.DeleteRoleByNameAsync("my-company", clientId, "report-viewer");
```

**Returns:** `bool` - `true` if deletion was successful

**Location:** `/src/Keycloak.ApiClient.Net/Roles/KeycloakClient.cs:54`

## Best Practices

1. **Application-Specific Roles**
   - Use client roles for application-specific permissions
   - Keep roles focused on the application's needs
   - Avoid duplicating realm-level functionality

2. **Naming Conventions**
   - Use clear, descriptive names
   - Include context if needed (e.g., `report-viewer`, `document-editor`)
   - Keep names consistent across clients

3. **Role Scope**
   - Client roles are isolated to the client
   - Use realm roles for cross-application permissions
   - Consider composite roles that include both client and realm roles

4. **Role Management**
   - Regularly review client roles
   - Remove unused roles
   - Document role purposes

## Example: Complete Client Role Setup

```csharp
using Keycloak.ApiClient.Net;
using Keycloak.ApiClient.Net.Models.Roles;

public async Task SetupClientRoles()
{
    var client = new KeycloakClient(url, username, password);
    string realm = "my-company";
    string clientId = "my-app";

    // Create viewer role
    var viewerRole = new Role
    {
        Name = "viewer",
        Description = "Can view data"
    };
    await client.CreateRoleAsync(realm, clientId, viewerRole);

    // Create editor role
    var editorRole = new Role
    {
        Name = "editor",
        Description = "Can edit data",
        Composite = true
    };
    await client.CreateRoleAsync(realm, clientId, editorRole);

    // Make editor include viewer permissions
    var viewer = await client.GetRoleByNameAsync(realm, clientId, "viewer");
    await client.AddCompositesToRoleAsync(realm, clientId, "editor", new[] { viewer });

    // List all client roles
    var roles = await client.GetRolesAsync(realm, clientId);
    foreach (var role in roles)
    {
        Console.WriteLine($"Client Role: {role.Name}");
    }
}
```

## Related Resources

- [Realm Role Operations](./realm-roles.md)
- [Composite Role Operations](./composite-roles.md)
- [Role Associations](./role-associations.md)
- [Main Documentation](./README.md)
