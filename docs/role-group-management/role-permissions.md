# Role Authorization Permissions

> **Document Metadata**
> Last Updated: 2026-01-20 19:30:00 UTC
> Git Commit: `9bc2d34` (9bc2d34a37e88fae053f63977e0bfbd02a61441d)
> Library Version: 2.0.2

## Overview

Role authorization permissions control who can manage and assign roles within Keycloak. These fine-grained permissions allow you to delegate role management capabilities without granting full administrative access.

## Table of Contents

- [Get Role Authorization Permissions](#get-role-authorization-permissions)
- [Set Role Authorization Permissions](#set-role-authorization-permissions)

## Get Role Authorization Permissions

Retrieves authorization permissions for a role.

```csharp
ManagementPermission permissions =
    await client.GetRoleAuthorizationPermissionsInitializedAsync(
        "my-company",
        "premium-user"
    );
```

**Parameters:**
- `realm` (required) - The realm name
- `roleName` (required) - The name of the role

**Returns:** `ManagementPermission`

**Note:** This method is marked as `[Obsolete("501 Not Implemented")]`

**Location:** `/src/Keycloak.ApiClient.Net/Roles/KeycloakClient.cs:238` (realm) and `:113` (client)

## Set Role Authorization Permissions

Initializes or updates authorization permissions for a role.

```csharp
var permissions = new ManagementPermission
{
    Enabled = true
};

ManagementPermission result =
    await client.SetRoleAuthorizationPermissionsInitializedAsync(
        "my-company",
        "premium-user",
        permissions
    );
```

**Parameters:**
- `realm` (required) - The realm name
- `roleName` (required) - The name of the role
- `permissions` (required) - The management permission settings

**Returns:** `ManagementPermission`

**Location:** `/src/Keycloak.ApiClient.Net/Roles/KeycloakClient.cs:243` (realm) and `:118` (client)

## ManagementPermission Model

```csharp
public class ManagementPermission
{
    public bool Enabled { get; set; }
    public string Resource { get; set; }
    public Dictionary<string, string> ScopePermissions { get; set; }
}
```

## Best Practices

1. **Permission Delegation**
   - Enable permissions for roles that need delegated management
   - Use fine-grained permissions instead of full admin access
   - Document permission policies

2. **Security**
   - Enable permissions only when necessary
   - Audit permission changes
   - Review delegated permissions regularly

3. **Role-Based Administration**
   - Use permissions to enable department-level role management
   - Combine with group permissions for organizational structure
   - Monitor permission usage

4. **Testing**
   - Test permission settings before production deployment
   - Verify permission inheritance
   - Validate access control

## Example: Setting Up Role Permissions

```csharp
using Keycloak.ApiClient.Net;
using Keycloak.ApiClient.Net.Models.Roles;

public async Task SetupRolePermissions()
{
    var client = new KeycloakClient(url, username, password);
    string realm = "my-company";

    // Enable permissions for a role
    var permissions = new ManagementPermission
    {
        Enabled = true
    };

    try
    {
        var result = await client.SetRoleAuthorizationPermissionsInitializedAsync(
            realm,
            "premium-user",
            permissions
        );

        Console.WriteLine($"Permissions enabled: {result.Enabled}");
        Console.WriteLine($"Resource: {result.Resource}");
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Error setting permissions: {ex.Message}");
        // Note: This API endpoint may not be implemented in all Keycloak versions
    }
}
```

## Example: Checking Role Permissions

```csharp
public async Task CheckRolePermissions()
{
    var client = new KeycloakClient(url, username, password);
    string realm = "my-company";

    try
    {
        var permissions = await client.GetRoleAuthorizationPermissionsInitializedAsync(
            realm,
            "premium-user"
        );

        if (permissions.Enabled)
        {
            Console.WriteLine("Role permissions are enabled");
            Console.WriteLine($"Resource: {permissions.Resource}");

            if (permissions.ScopePermissions != null)
            {
                Console.WriteLine("Scope permissions:");
                foreach (var scope in permissions.ScopePermissions)
                {
                    Console.WriteLine($"  {scope.Key}: {scope.Value}");
                }
            }
        }
        else
        {
            Console.WriteLine("Role permissions are not enabled");
        }
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Error getting permissions: {ex.Message}");
        // Note: This API endpoint may not be implemented in all Keycloak versions
    }
}
```

## Important Notes

1. **API Availability**
   - These endpoints may not be available in all Keycloak versions
   - Check your Keycloak version documentation
   - The methods are marked as obsolete with "501 Not Implemented"

2. **Keycloak Configuration**
   - Authorization services must be enabled in Keycloak
   - Fine-grained permissions require proper Keycloak configuration
   - Consult Keycloak documentation for setup

3. **Alternative Approaches**
   - Consider using realm roles for admin delegation
   - Use client-specific admin roles
   - Implement custom authorization logic if needed

## Related Resources

- [Keycloak Authorization Services](https://www.keycloak.org/docs/latest/authorization_services/)
- [Realm Role Operations](./realm-roles.md)
- [Client Role Operations](./client-roles.md)
- [Main Documentation](./README.md)
