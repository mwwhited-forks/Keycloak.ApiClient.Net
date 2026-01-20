# Federated Identity Management

> **Document Metadata**
> Last Updated: 2026-01-20 19:30:00 UTC
> Git Commit: `9bc2d34` (9bc2d34a37e88fae053f63977e0bfbd02a61441d)
> Library Version: 2.0.2

This document covers federated identity management operations for linking social login providers (Google, Facebook, GitHub, etc.) to user accounts.

## Get User Social Logins

Retrieves federated identity providers linked to the user.

```csharp
IEnumerable<FederatedIdentity> identities =
    await client.GetUserSocialLoginsAsync("master", userId);

foreach (var identity in identities)
{
    Console.WriteLine($"Provider: {identity.IdentityProvider}");
    Console.WriteLine($"User ID: {identity.UserId}");
    Console.WriteLine($"Username: {identity.UserName}");
}
```

**Returns:** `IEnumerable<FederatedIdentity>`

**Location:** `/src/Keycloak.ApiClient.Net/Users/KeycloakClient.cs:138`

## Add User Social Login Provider

Links a federated identity provider to a user.

```csharp
var federatedIdentity = new FederatedIdentity
{
    IdentityProvider = "google",
    UserId = "google-user-id-123",
    UserName = "john.doe@gmail.com"
};

bool success = await client.AddUserSocialLoginProviderAsync(
    "master",
    userId,
    "google",
    federatedIdentity
);
```

**Returns:** `bool` - `true` if provider was linked successfully

**Location:** `/src/Keycloak.ApiClient.Net/Users/KeycloakClient.cs:143`

## Remove User Social Login Provider

Removes a federated identity provider from a user.

```csharp
bool success = await client.RemoveUserSocialLoginProviderAsync(
    "master",
    userId,
    "google"
);
```

**Returns:** `bool` - `true` if provider was unlinked successfully

**Location:** `/src/Keycloak.ApiClient.Net/Users/KeycloakClient.cs:152`

## Common Social Login Providers

### Google
```csharp
var googleIdentity = new FederatedIdentity
{
    IdentityProvider = "google",
    UserId = "google-user-id",
    UserName = "user@gmail.com"
};
```

### Facebook
```csharp
var facebookIdentity = new FederatedIdentity
{
    IdentityProvider = "facebook",
    UserId = "facebook-user-id",
    UserName = "facebook-username"
};
```

### GitHub
```csharp
var githubIdentity = new FederatedIdentity
{
    IdentityProvider = "github",
    UserId = "github-user-id",
    UserName = "github-username"
};
```

### Microsoft
```csharp
var microsoftIdentity = new FederatedIdentity
{
    IdentityProvider = "microsoft",
    UserId = "microsoft-user-id",
    UserName = "user@outlook.com"
};
```

## Complete Example: Managing Federated Identities

```csharp
using Keycloak.ApiClient.Net;
using Keycloak.ApiClient.Net.Models.Users;

public class FederatedIdentityManagement
{
    private readonly KeycloakClient _client;

    public FederatedIdentityManagement(string url, string username, string password)
    {
        _client = new KeycloakClient(url, username, password);
    }

    public async Task ManageSocialLogins(string realm, string userId)
    {
        // Get current social logins
        var identities = await _client.GetUserSocialLoginsAsync(realm, userId);
        Console.WriteLine($"User has {identities.Count()} social login(s) linked");

        foreach (var identity in identities)
        {
            Console.WriteLine($"Provider: {identity.IdentityProvider}");
            Console.WriteLine($"External User ID: {identity.UserId}");
            Console.WriteLine($"External Username: {identity.UserName}");
            Console.WriteLine("---");
        }

        // Link a new Google account
        var googleIdentity = new FederatedIdentity
        {
            IdentityProvider = "google",
            UserId = "google-123456789",
            UserName = "user@gmail.com"
        };

        bool added = await _client.AddUserSocialLoginProviderAsync(
            realm,
            userId,
            "google",
            googleIdentity
        );

        if (added)
        {
            Console.WriteLine("Google account linked successfully");
        }

        // Unlink the Google account
        bool removed = await _client.RemoveUserSocialLoginProviderAsync(
            realm,
            userId,
            "google"
        );

        if (removed)
        {
            Console.WriteLine("Google account unlinked successfully");
        }
    }
}
```

## Best Practices

1. **Account Linking**
   - Verify user owns the social account before linking
   - Send confirmation emails when new providers are linked
   - Allow users to manage their own linked accounts

2. **Security**
   - Validate that the external user ID matches the authenticated user
   - Implement rate limiting for provider linking operations
   - Log all provider link/unlink operations for audit

3. **User Experience**
   - Show all linked providers in user profile
   - Allow users to unlink providers (with safeguards)
   - Ensure at least one authentication method remains active

4. **Error Handling**
   - Handle cases where provider is already linked
   - Validate provider configuration exists in Keycloak
   - Provide clear error messages to users

## Use Cases

### Account Recovery
Users can use social login as an alternative authentication method if they forget their password.

### Progressive Enrollment
Allow users to sign up with a social provider and later link additional providers.

### Account Consolidation
Merge multiple accounts by linking various social providers to a single Keycloak user.

### Multi-Provider Authentication
Enable users to authenticate with different providers based on context (e.g., Google for work, GitHub for development).

## Troubleshooting

### Provider Not Found Error
- Ensure the identity provider is configured in the Keycloak realm
- Check the provider name matches the configured alias exactly

### Duplicate Link Error
- Check if the external user ID is already linked to another account
- Use `GetUserSocialLoginsAsync` to verify current links before adding

### Unlink Failed
- Verify user has at least one other authentication method
- Ensure the provider exists for the user

## Related Resources

- [User Management README](./README.md)
- [CRUD Operations](./crud-operations.md)
- [Keycloak Identity Provider Documentation](https://www.keycloak.org/docs/latest/server_admin/#_identity_broker)
