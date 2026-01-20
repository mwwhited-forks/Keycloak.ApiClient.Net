# Realm Administration - Operations

> **Document Metadata**
> Last Updated: 2026-01-20 19:30:00 UTC
> Git Commit: `9bc2d34` (9bc2d34a37e88fae053f63977e0bfbd02a61441d)
> Library Version: 2.0.2

## Overview

The Realm Administration API provides comprehensive operations for managing Keycloak realms. A realm is a space where you manage users, credentials, roles, and groups. Each realm is isolated from one another and can only manage and authenticate users that it controls.

## Key Features

- Realm CRUD operations
- Event management (admin and user events)
- Cache management (users, keys, realm)
- Import and export functionality
- Client session statistics
- Default client scopes and groups
- LDAP and SMTP testing
- User management permissions
- Event configuration

## Realm Model

The core `Realm` model includes:

```csharp
public class Realm
{
    public string Id { get; set; }
    public string Realm { get; set; }
    public string DisplayName { get; set; }
    public string DisplayNameHtml { get; set; }
    public bool? Enabled { get; set; }
    public int? SsoSessionIdleTimeout { get; set; }
    public int? SsoSessionMaxLifespan { get; set; }
    public int? AccessTokenLifespan { get; set; }
    public int? AccessCodeLifespan { get; set; }
    public bool? RegistrationAllowed { get; set; }
    public bool? RegistrationEmailAsUsername { get; set; }
    public bool? RememberMe { get; set; }
    public bool? VerifyEmail { get; set; }
    public bool? LoginWithEmailAllowed { get; set; }
    public bool? DuplicateEmailsAllowed { get; set; }
    public bool? ResetPasswordAllowed { get; set; }
    public Dictionary<string, string> SmtpServer { get; set; }
    public BrowserSecurityHeaders BrowserSecurityHeaders { get; set; }
    // Additional properties...
}
```

## Table of Contents

- [CRUD Operations](./crud-operations.md) - Create, read, update, and delete realms
- [Event Management](./events.md) - Admin and user event tracking and configuration
- [Cache Management](./cache.md) - Keys, realm, and user cache operations
- [Session Management](./sessions.md) - Client session statistics and user session control
- [Default Client Scopes](./client-scopes.md) - Default and optional client scope management
- [Default Groups](./default-groups.md) - Default group hierarchy and management
- [Import/Export Operations](./import-export.md) - Partial realm export and import
- [Testing Operations](./testing.md) - LDAP and SMTP connection testing
- [User Management Permissions](./permissions.md) - User management permission control
- [Other Operations](./other-operations.md) - Revocation policy and client description converter

## Complete Example: Realm Setup

```csharp
using Keycloak.ApiClient.Net;
using Keycloak.ApiClient.Net.Models.RealmsAdmin;

public class RealmAdministration
{
    private readonly KeycloakClient _client;

    public RealmAdministration(string url, string username, string password)
    {
        _client = new KeycloakClient(url, username, password);
    }

    public async Task SetupRealmExample()
    {
        // 1. Create new realm
        var realm = new Realm
        {
            Realm = "my-company",
            DisplayName = "My Company",
            Enabled = true,
            SsoSessionIdleTimeout = 1800,
            SsoSessionMaxLifespan = 36000,
            AccessTokenLifespan = 300,
            RegistrationAllowed = true,
            RememberMe = true,
            VerifyEmail = true,
            LoginWithEmailAllowed = true,
            ResetPasswordAllowed = true,
            SmtpServer = new Dictionary<string, string>
            {
                ["host"] = "smtp.gmail.com",
                ["port"] = "587",
                ["from"] = "noreply@mycompany.com",
                ["auth"] = "true",
                ["starttls"] = "true",
                ["user"] = "smtp-user",
                ["password"] = "smtp-password"
            }
        };

        await _client.ImportRealmAsync("master", realm);
        Console.WriteLine("Realm created");

        // 2. Configure event logging
        var eventConfig = new RealmEventsConfig
        {
            EventsEnabled = true,
            EventsExpiration = 2592000, // 30 days
            EventsListeners = new List<string> { "jboss-logging" },
            EnabledEventTypes = new List<string>
            {
                "LOGIN", "LOGOUT", "LOGIN_ERROR", "REGISTER"
            },
            AdminEventsEnabled = true,
            AdminEventsDetailsEnabled = true
        };

        await _client.UpdateRealmEventsProviderConfigurationAsync("my-company", eventConfig);
        Console.WriteLine("Event logging configured");

        // 3. Test SMTP configuration
        bool smtpWorks = await _client.TestSmtpConnectionAsync("my-company", "test@example.com");
        Console.WriteLine($"SMTP test: {(smtpWorks ? "Success" : "Failed")}");

        // 4. Get session statistics
        var stats = await _client.GetClientSessionStatsAsync("my-company");
        Console.WriteLine($"Total client sessions: {stats.Count()}");

        // 5. Export realm configuration
        var export = await _client.RealmPartialExportAsync(
            "my-company",
            exportClients: true,
            exportGroupsAndRoles: true
        );
        Console.WriteLine("Realm exported for backup");

        // 6. Monitor admin events
        var adminEvents = await _client.GetAdminEventsAsync(
            realm: "my-company",
            first: 0,
            max: 10
        );

        foreach (var evt in adminEvents)
        {
            Console.WriteLine($"Admin action: {evt.OperationType} on {evt.ResourceType}");
        }
    }
}
```

## Best Practices

1. **Realm Configuration**
   - Set appropriate session timeouts
   - Enable email verification for security
   - Configure SMTP for email functionality
   - Use strong password policies

2. **Event Logging**
   - Enable both user and admin events
   - Set appropriate event expiration
   - Monitor failed login attempts
   - Review admin events regularly

3. **Cache Management**
   - Clear caches after bulk updates
   - Monitor cache performance
   - Clear user cache after external updates

4. **Session Management**
   - Monitor session counts for anomalies
   - Implement appropriate timeouts
   - Use logout-all sparingly

5. **Import/Export**
   - Regular backup exports
   - Test imports in non-production first
   - Use version control for realm configs
   - Document custom configurations

6. **Testing**
   - Test LDAP/SMTP before production use
   - Validate configurations in staging
   - Monitor connection timeouts

## Error Codes

| HTTP Code | Meaning | Common Causes |
|-----------|---------|---------------|
| 400 | Bad Request | Invalid realm configuration, malformed data |
| 401 | Unauthorized | Invalid or expired authentication token |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not Found | Realm doesn't exist |
| 409 | Conflict | Realm already exists |
| 500 | Server Error | Keycloak internal error, LDAP/SMTP connection issues |

## Related Resources

- [Keycloak Realm API Documentation](https://www.keycloak.org/docs-api/latest/rest-api/index.html#_realms_admin_resource)
- [Keycloak Events](https://www.keycloak.org/docs/latest/server_admin/#auditing-and-events)
- [Authentication Documentation](../authentication-core.md)
- [User Management Documentation](../user-management-operations.md)
