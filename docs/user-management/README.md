# User Management - Operations

> **Document Metadata**
> Last Updated: 2026-01-20 19:30:00 UTC
> Git Commit: `9bc2d34` (9bc2d34a37e88fae053f63977e0bfbd02a61441d)
> Library Version: 2.0.2

## Overview

The User Management API provides comprehensive CRUD operations for managing users in Keycloak realms. This includes user creation, retrieval, updates, deletion, password management, group assignments, and session management.

## Key Features

- User CRUD operations
- Password management and reset
- User group membership
- Federated identity management
- Session management
- Email actions (verification, update account)
- Credential management
- User search and filtering

## User Model

The core `User` model includes:

```csharp
public class User
{
    public string Id { get; set; }
    public string Username { get; set; }
    public string Email { get; set; }
    public string FirstName { get; set; }
    public string LastName { get; set; }
    public bool? Enabled { get; set; }
    public bool? EmailVerified { get; set; }
    public List<Credentials> Credentials { get; set; }
    public List<string> RequiredActions { get; set; }
    public List<string> DisableableCredentialTypes { get; set; }
    public Dictionary<string, object> Attributes { get; set; }
    // Additional properties...
}
```

## Table of Contents

- [CRUD Operations](./crud-operations.md) - User create, read, update, delete operations
- [Password Management](./passwords.md) - Password reset, TOTP management
- [Credential Management](./credentials.md) - Credential type management
- [Group Management](./groups.md) - User group membership operations
- [Federated Identity Management](./federated-identity.md) - Social login provider management
- [Session Management](./sessions.md) - User session and logout operations
- [Email Actions](./email-actions.md) - Email verification and account update emails
- [Consent Management](./consents.md) - User consent and token revocation
- [Advanced Operations](./impersonation.md) - User impersonation

## Complete Example: User Lifecycle

```csharp
using Keycloak.ApiClient.Net;
using Keycloak.ApiClient.Net.Models.Users;

public class UserManagement
{
    private readonly KeycloakClient _client;

    public UserManagement(string url, string username, string password)
    {
        _client = new KeycloakClient(url, username, password);
    }

    public async Task UserLifecycleExample()
    {
        string realm = "master";

        // 1. Create user
        var user = new User
        {
            Username = "jane.smith",
            Email = "jane.smith@example.com",
            FirstName = "Jane",
            LastName = "Smith",
            Enabled = true,
            Credentials = new List<Credentials>
            {
                new Credentials
                {
                    Type = "password",
                    Value = "TempPassword123!",
                    Temporary = true
                }
            }
        };

        string userId = await _client.CreateAndRetrieveUserIdAsync(realm, user);
        Console.WriteLine($"User created with ID: {userId}");

        // 2. Send verification email
        await _client.VerifyUserEmailAddressAsync(realm, userId);
        Console.WriteLine("Verification email sent");

        // 3. Get user details
        user = await _client.GetUserAsync(realm, userId);
        Console.WriteLine($"User email verified: {user.EmailVerified}");

        // 4. Update user
        user.EmailVerified = true;
        await _client.UpdateUserAsync(realm, userId, user);

        // 5. Reset password
        await _client.ResetUserPasswordAsync(
            realm,
            userId,
            "NewSecurePassword123!",
            temporary: false
        );

        // 6. Get user sessions
        var sessions = await _client.GetUserSessionsAsync(realm, userId);
        Console.WriteLine($"Active sessions: {sessions.Count()}");

        // 7. Logout user
        await _client.RemoveUserSessionsAsync(realm, userId);
        Console.WriteLine("User logged out");

        // 8. Delete user (cleanup)
        await _client.DeleteUserAsync(realm, userId);
        Console.WriteLine("User deleted");
    }
}
```

## Best Practices

1. **Password Security**
   - Always use strong passwords
   - Set `Temporary = true` for initial passwords
   - Force password change on first login

2. **Email Verification**
   - Send verification emails for new users
   - Don't enable accounts until email is verified

3. **Session Management**
   - Monitor active sessions
   - Implement timeout policies
   - Provide logout functionality

4. **Error Handling**
   - Check boolean return values
   - Handle `FlurlHttpException` for API errors
   - Validate user input before API calls

5. **Performance**
   - Use pagination (`first`, `max`) for large user lists
   - Use `briefRepresentation = true` when full details aren't needed
   - Implement caching for frequently accessed data

6. **Security**
   - Never log sensitive information (passwords, tokens)
   - Implement proper audit trails
   - Use impersonation sparingly and with logging
   - Validate email addresses before sending emails

## Error Codes

| HTTP Code | Meaning | Common Causes |
|-----------|---------|---------------|
| 400 | Bad Request | Invalid user data, malformed request |
| 401 | Unauthorized | Invalid or expired authentication token |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not Found | User ID doesn't exist |
| 409 | Conflict | Username or email already exists |
| 500 | Server Error | Keycloak internal error |

## Related Resources

- [Keycloak User API Documentation](https://www.keycloak.org/docs-api/latest/rest-api/index.html#_users_resource)
- [Authentication Documentation](../authentication-core.md)
- [Group Management Documentation](../role-group-management-operations.md)
