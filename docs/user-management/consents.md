# Consent Management

> **Document Metadata**
> Last Updated: 2026-01-20 19:30:00 UTC
> Git Commit: `9bc2d34` (9bc2d34a37e88fae053f63977e0bfbd02a61441d)
> Library Version: 2.0.2

This document covers user consent management operations including retrieving and revoking user consents and offline tokens.

## Get User Consents

Retrieves consents granted by a user.

```csharp
string consents = await client.GetUserConsentsAsync("master", userId);
```

**Note:** This method is marked as `[Obsolete("Not working yet")]`

**Location:** `/src/Keycloak.ApiClient.Net/Users/KeycloakClient.cs:95`

## Revoke User Consent

Revokes a user's consent and offline tokens for a specific client.

```csharp
bool success = await client.RevokeUserConsentAndOfflineTokensAsync(
    "master",
    userId,
    clientId
);
```

**Returns:** `bool` - `true` if consent was revoked successfully

**Location:** `/src/Keycloak.ApiClient.Net/Users/KeycloakClient.cs:103`

## Complete Example: Consent Management

```csharp
using Keycloak.ApiClient.Net;

public class ConsentManagement
{
    private readonly KeycloakClient _client;

    public ConsentManagement(string url, string username, string password)
    {
        _client = new KeycloakClient(url, username, password);
    }

    public async Task RevokeClientAccess(string realm, string userId, string clientId)
    {
        // Revoke consent and offline tokens for a specific client
        bool revoked = await _client.RevokeUserConsentAndOfflineTokensAsync(
            realm,
            userId,
            clientId
        );

        if (revoked)
        {
            Console.WriteLine($"User consent revoked for client: {clientId}");
            Console.WriteLine("All offline tokens for this client have been invalidated");
        }
        else
        {
            Console.WriteLine("Failed to revoke consent");
        }
    }

    public async Task RevokeAllClientAccess(string realm, string userId, List<string> clientIds)
    {
        Console.WriteLine($"Revoking access for {clientIds.Count} clients...");

        foreach (var clientId in clientIds)
        {
            bool revoked = await _client.RevokeUserConsentAndOfflineTokensAsync(
                realm,
                userId,
                clientId
            );

            if (revoked)
            {
                Console.WriteLine($"✓ Revoked: {clientId}");
            }
            else
            {
                Console.WriteLine($"✗ Failed: {clientId}");
            }
        }
    }

    public async Task HandleDataDeletionRequest(string realm, string userId)
    {
        // Part of GDPR compliance - revoke all consents
        var clientIds = new List<string>
        {
            "mobile-app",
            "web-app",
            "admin-portal"
        };

        Console.WriteLine("Processing data deletion request...");
        Console.WriteLine("Step 1: Revoking all client consents");

        foreach (var clientId in clientIds)
        {
            await _client.RevokeUserConsentAndOfflineTokensAsync(
                realm,
                userId,
                clientId
            );
        }

        Console.WriteLine("Step 2: Logging out user from all sessions");
        await _client.RemoveUserSessionsAsync(realm, userId);

        Console.WriteLine("Step 3: Disabling user account");
        var user = await _client.GetUserAsync(realm, userId);
        user.Enabled = false;
        await _client.UpdateUserAsync(realm, userId, user);

        Console.WriteLine("Data deletion request processing complete");
    }
}
```

## Understanding Consents

### What is Consent?
Consent is explicit user permission granted to a client application to access their data or perform actions on their behalf. This is particularly important for:
- Third-party applications
- OAuth2/OIDC flows
- GDPR compliance
- Privacy requirements

### When to Revoke Consent?

1. **User Request**
   - User no longer wants to use the application
   - User wants to revoke third-party access

2. **Security Incidents**
   - Suspected unauthorized access
   - Client application compromised
   - User account security concerns

3. **Compliance**
   - GDPR "right to be forgotten" requests
   - Data access audits
   - Privacy policy changes

4. **Application Lifecycle**
   - Application decommissioned
   - Client credentials rotated
   - Integration discontinued

## Best Practices

1. **User Control**
   - Provide UI for users to view granted consents
   - Allow users to revoke consent themselves
   - Show what data each client can access

2. **Logging and Audit**
   - Log all consent revocation operations
   - Include timestamp, admin/user, and reason
   - Maintain audit trail for compliance

3. **Notification**
   - Notify users when consent is revoked
   - Inform users of consequences (loss of access)
   - Provide re-authorization instructions if needed

4. **Scope Management**
   - Only request necessary scopes
   - Review and minimize scope requirements
   - Update scopes as requirements change

5. **Token Cleanup**
   - Revoke offline tokens when consent is revoked
   - Clear any cached tokens
   - Invalidate refresh tokens

## Use Cases

### User Privacy Controls
```csharp
// User wants to disconnect a mobile app
await client.RevokeUserConsentAndOfflineTokensAsync(
    "master",
    userId,
    "mobile-app-client-id"
);

// Notify user
Console.WriteLine("Mobile app access revoked. You'll need to sign in again.");
```

### Security Incident Response
```csharp
// Client app compromised - revoke all user consents
var affectedClientId = "compromised-app";

// Get all users (implement pagination for production)
var users = await client.GetUsersAsync("master");

foreach (var user in users)
{
    await client.RevokeUserConsentAndOfflineTokensAsync(
        "master",
        user.Id,
        affectedClientId
    );
}

Console.WriteLine("All user consents revoked for compromised application");
```

### GDPR Compliance
```csharp
// User exercises "right to be forgotten"
public async Task ProcessGDPRDeletion(string realm, string userId)
{
    // 1. Get all clients
    var clientIds = GetAllClientIds(); // Implement this

    // 2. Revoke all consents
    foreach (var clientId in clientIds)
    {
        await client.RevokeUserConsentAndOfflineTokensAsync(realm, userId, clientId);
    }

    // 3. Logout user
    await client.RemoveUserSessionsAsync(realm, userId);

    // 4. Anonymize or delete user
    await client.DeleteUserAsync(realm, userId);
}
```

### Application Decommissioning
```csharp
// Retiring an old application
var retiredClientId = "legacy-app";
var users = await client.GetUsersAsync("master");

int revokedCount = 0;

foreach (var user in users)
{
    bool revoked = await client.RevokeUserConsentAndOfflineTokensAsync(
        "master",
        user.Id,
        retiredClientId
    );

    if (revoked)
    {
        revokedCount++;
    }
}

Console.WriteLine($"Revoked consent for {revokedCount} users");
```

## Offline Tokens

### What are Offline Tokens?
Offline tokens are long-lived refresh tokens that allow clients to obtain new access tokens without user interaction, even when the user is offline.

### Why Revoke Offline Tokens?
- **Security**: Limit token lifetime
- **Access Control**: Remove persistent access
- **Compliance**: Enforce periodic re-authentication
- **User Privacy**: Limit data access window

## Relationship with Sessions

Revoking consent is different from logging out:

| Operation | Consent Revocation | Session Logout |
|-----------|-------------------|----------------|
| **Scope** | Client-specific | All applications |
| **Tokens** | Revokes offline tokens for one client | Invalidates all session tokens |
| **Effect** | User can still use other apps | User logged out everywhere |
| **Use Case** | Remove third-party access | Security incident, password change |

### Combined Approach
```csharp
// For maximum security, do both
await client.RevokeUserConsentAndOfflineTokensAsync("master", userId, clientId);
await client.RemoveUserSessionsAsync("master", userId);
```

## Troubleshooting

### Consent Not Revoked
- Verify client ID is correct
- Check that user had granted consent
- Ensure admin has proper permissions
- Check Keycloak server logs

### User Can Still Access Application
- Client may be using cached tokens
- Session tokens are separate from consent
- Application may not be checking token validity
- Consider also calling `RemoveUserSessionsAsync`

### Error: Client Not Found
- Verify client exists in the realm
- Check client ID spelling
- Ensure client is enabled

## Related Resources

- [User Management README](./README.md)
- [Session Management](./sessions.md)
- [CRUD Operations](./crud-operations.md)
- [Keycloak Consent Documentation](https://www.keycloak.org/docs/latest/server_admin/#_consent)
- [GDPR Compliance Guide](https://gdpr.eu/)
