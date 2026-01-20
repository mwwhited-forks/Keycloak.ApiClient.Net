# Credential Management

> **Document Metadata**
> Last Updated: 2026-01-20 19:30:00 UTC
> Git Commit: `9bc2d34` (9bc2d34a37e88fae053f63977e0bfbd02a61441d)
> Library Version: 2.0.2

This document covers credential management operations for disabling specific credential types for users.

## Disable User Credentials

Disables specific credential types for a user.

```csharp
var credentialTypes = new List<string> { "otp", "password" };
bool success = await client.DisableUserCredentialsAsync("master", userId, credentialTypes);
```

**Common Credential Types:**
- `password` - Password-based authentication
- `otp` - One-Time Password (TOTP/HOTP)
- `webauthn` - WebAuthn credentials
- `kerberos` - Kerberos authentication

**Returns:** `bool` - `true` if credentials were disabled successfully

**Location:** `/src/Keycloak.ApiClient.Net/Users/KeycloakClient.cs:112`

## Use Cases

### Temporarily Disable Password Authentication
```csharp
// Disable password login (e.g., when investigating security incident)
var credentialTypes = new List<string> { "password" };
await client.DisableUserCredentialsAsync("master", userId, credentialTypes);
```

### Disable Two-Factor Authentication
```csharp
// Remove OTP requirement
var credentialTypes = new List<string> { "otp" };
await client.DisableUserCredentialsAsync("master", userId, credentialTypes);
```

### Disable Multiple Credential Types
```csharp
// Disable all authentication methods temporarily
var credentialTypes = new List<string> { "password", "otp", "webauthn" };
await client.DisableUserCredentialsAsync("master", userId, credentialTypes);
```

## Best Practices

1. **Use for Temporary Lockouts**
   - Disable credentials instead of deleting the user account
   - Easier to restore access when needed

2. **Document Credential Changes**
   - Log all credential disable operations
   - Include reason and admin who performed the action

3. **Security Considerations**
   - Disabling credentials doesn't invalidate existing sessions
   - Consider also logging out the user with `RemoveUserSessionsAsync`

4. **Recovery Process**
   - Document how to re-enable credentials
   - Have a clear process for credential restoration

## Related Resources

- [User Management README](./README.md)
- [Password Management](./passwords.md)
- [Session Management](./sessions.md)
