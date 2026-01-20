# Advanced Operations - User Impersonation

> **Document Metadata**
> Last Updated: 2026-01-20 19:30:00 UTC
> Git Commit: `9bc2d34` (9bc2d34a37e88fae053f63977e0bfbd02a61441d)
> Library Version: 2.0.2

This document covers advanced user operations, specifically user impersonation, which allows administrators to log in as another user for troubleshooting and support purposes.

## Impersonate User

Creates an impersonation session for a user (admin logs in as user).

```csharp
IDictionary<string, object> impersonation =
    await client.ImpersonateUserAsync("master", userId);
```

**Security Note:** This is a powerful feature that should be used with caution and proper auditing.

**Returns:** `IDictionary<string, object>` containing impersonation details

**Location:** `/src/Keycloak.ApiClient.Net/Users/KeycloakClient.cs:193`

## Complete Example: User Impersonation

```csharp
using Keycloak.ApiClient.Net;
using System.Text.Json;

public class UserImpersonation
{
    private readonly KeycloakClient _client;

    public UserImpersonation(string url, string username, string password)
    {
        _client = new KeycloakClient(url, username, password);
    }

    public async Task ImpersonateForSupport(string realm, string userId, string reason)
    {
        // Log the impersonation attempt
        Console.WriteLine($"Initiating user impersonation");
        Console.WriteLine($"Realm: {realm}");
        Console.WriteLine($"Target User ID: {userId}");
        Console.WriteLine($"Reason: {reason}");
        Console.WriteLine($"Admin: {_client.Username}");
        Console.WriteLine($"Timestamp: {DateTime.UtcNow:o}");

        try
        {
            // Get user details first
            var user = await _client.GetUserAsync(realm, userId);
            Console.WriteLine($"Impersonating user: {user.Username} ({user.Email})");

            // Impersonate the user
            var impersonationData = await _client.ImpersonateUserAsync(realm, userId);

            Console.WriteLine("\nImpersonation session created:");
            foreach (var kvp in impersonationData)
            {
                Console.WriteLine($"{kvp.Key}: {JsonSerializer.Serialize(kvp.Value)}");
            }

            // Log to audit system
            await LogImpersonation(realm, userId, reason);

            Console.WriteLine("\nWARNING: You are now impersonating the user.");
            Console.WriteLine("All actions will be performed as this user.");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Failed to impersonate user: {ex.Message}");
            throw;
        }
    }

    public async Task TroubleshootUserIssue(string realm, string userEmail, string issue)
    {
        // Find user by email
        var users = await _client.GetUsersAsync(realm, email: userEmail);
        var user = users.FirstOrDefault();

        if (user == null)
        {
            Console.WriteLine($"User not found: {userEmail}");
            return;
        }

        Console.WriteLine($"\nTroubleshooting Issue: {issue}");
        Console.WriteLine($"User: {user.Username} ({user.Email})");

        // Start impersonation session
        var impersonationData = await _client.ImpersonateUserAsync(realm, user.Id);

        Console.WriteLine("\nImpersonation active. You can now:");
        Console.WriteLine("1. Navigate the application as the user");
        Console.WriteLine("2. Reproduce the reported issue");
        Console.WriteLine("3. Test fixes in real-time");
        Console.WriteLine("\nRemember to document your findings.");

        // Return impersonation details
        return;
    }

    private async Task LogImpersonation(string realm, string userId, string reason)
    {
        // Implement your audit logging here
        var auditEntry = new
        {
            Action = "USER_IMPERSONATION",
            Realm = realm,
            TargetUserId = userId,
            AdminUser = _client.Username,
            Reason = reason,
            Timestamp = DateTime.UtcNow,
            IpAddress = GetClientIpAddress() // Implement this
        };

        // Log to your audit system
        Console.WriteLine($"\nAudit Log: {JsonSerializer.Serialize(auditEntry, new JsonSerializerOptions { WriteIndented = true })}");
    }

    private string GetClientIpAddress()
    {
        // Implement IP address retrieval
        return "192.168.1.100";
    }
}
```

## Security Considerations

### When to Use Impersonation

1. **Customer Support**
   - User reports issue that can't be reproduced
   - Need to see exact user experience
   - Debugging user-specific problems

2. **Testing and QA**
   - Test role-based access controls
   - Verify user-specific configurations
   - Validate personalization features

3. **Troubleshooting**
   - Investigate permission issues
   - Debug user workflow problems
   - Analyze user-specific data issues

### When NOT to Use Impersonation

1. **Routine Tasks**
   - Use direct API calls instead
   - Don't impersonate for bulk operations
   - Avoid for automated processes

2. **Sensitive Operations**
   - Financial transactions
   - Legal document signing
   - Sensitive data modification

3. **Without Consent**
   - Never impersonate without user awareness (except critical security incidents)
   - Inform users in privacy policy
   - Consider requiring user consent

## Best Practices

### 1. Audit Everything

```csharp
public class AuditedImpersonation
{
    public async Task ImpersonateWithAudit(
        string realm,
        string userId,
        string reason,
        string ticketNumber)
    {
        var auditLog = new ImpersonationAudit
        {
            Id = Guid.NewGuid(),
            Timestamp = DateTime.UtcNow,
            AdminUsername = _client.Username,
            TargetUserId = userId,
            Realm = realm,
            Reason = reason,
            TicketNumber = ticketNumber,
            IpAddress = GetIpAddress(),
            SessionId = GetSessionId()
        };

        // Log before impersonation
        await SaveAuditLog(auditLog);

        // Perform impersonation
        var result = await _client.ImpersonateUserAsync(realm, userId);

        // Update audit log with result
        auditLog.Success = true;
        auditLog.ImpersonationData = result;
        await UpdateAuditLog(auditLog);

        return result;
    }
}
```

### 2. Require Justification

```csharp
public async Task ImpersonateWithJustification(
    string realm,
    string userId,
    string reason,
    string supportTicketId)
{
    if (string.IsNullOrWhiteSpace(reason))
    {
        throw new ArgumentException("Reason for impersonation is required");
    }

    if (string.IsNullOrWhiteSpace(supportTicketId))
    {
        throw new ArgumentException("Support ticket ID is required");
    }

    // Verify ticket exists and is valid
    if (!await ValidateSupportTicket(supportTicketId))
    {
        throw new InvalidOperationException("Invalid support ticket");
    }

    await _client.ImpersonateUserAsync(realm, userId);
}
```

### 3. Implement Time Limits

```csharp
public class TimeLimitedImpersonation
{
    private DateTime? _impersonationStart;
    private const int MaxImpersonationMinutes = 30;

    public async Task StartImpersonation(string realm, string userId)
    {
        await _client.ImpersonateUserAsync(realm, userId);
        _impersonationStart = DateTime.UtcNow;

        // Set up timer to warn and eventually end impersonation
        SetupImpersonationTimer();
    }

    private void CheckImpersonationTimeout()
    {
        if (_impersonationStart.HasValue)
        {
            var duration = DateTime.UtcNow - _impersonationStart.Value;
            if (duration.TotalMinutes > MaxImpersonationMinutes)
            {
                throw new TimeoutException(
                    $"Impersonation session exceeded maximum duration of {MaxImpersonationMinutes} minutes");
            }
        }
    }
}
```

### 4. Restrict Permissions

```csharp
public async Task ImpersonateWithRestrictions(string realm, string userId)
{
    // Check if admin has impersonation permission
    if (!await HasImpersonationPermission())
    {
        throw new UnauthorizedAccessException(
            "You don't have permission to impersonate users");
    }

    // Check if target user can be impersonated
    var user = await _client.GetUserAsync(realm, userId);
    if (IsProtectedUser(user))
    {
        throw new InvalidOperationException(
            "This user account is protected from impersonation");
    }

    await _client.ImpersonateUserAsync(realm, userId);
}

private bool IsProtectedUser(User user)
{
    // Protect admin accounts, service accounts, etc.
    return user.Username?.StartsWith("admin") == true ||
           user.Username?.StartsWith("service-") == true;
}
```

### 5. Notify Users

```csharp
public async Task ImpersonateWithNotification(string realm, string userId)
{
    var user = await _client.GetUserAsync(realm, userId);

    // Impersonate
    await _client.ImpersonateUserAsync(realm, userId);

    // Send notification email
    await SendImpersonationNotification(user.Email, new
    {
        AdminUsername = _client.Username,
        Timestamp = DateTime.UtcNow,
        Reason = "Customer support investigation"
    });

    Console.WriteLine($"Impersonation started and user {user.Email} has been notified");
}
```

## Compliance and Legal

### GDPR Considerations

1. **Privacy Policy**
   - Disclose impersonation capability
   - Explain when and why it's used
   - Detail data protection measures

2. **Data Protection**
   - Minimize scope of impersonation
   - Limit duration of sessions
   - Encrypt audit logs

3. **User Rights**
   - Allow users to view impersonation history
   - Provide opt-out for non-critical support
   - Honor data access requests

### Industry-Specific Requirements

#### Healthcare (HIPAA)
```csharp
// Additional logging for HIPAA compliance
public class HIPAACompliantImpersonation
{
    public async Task ImpersonatePatient(string realm, string patientUserId, string reason)
    {
        var hipaaLog = new HIPAAAccessLog
        {
            AccessType = "IMPERSONATION",
            PHIAccessed = true,
            Justification = reason,
            UserConsent = await GetPatientConsent(patientUserId)
        };

        await LogHIPAAAccess(hipaaLog);
        await _client.ImpersonateUserAsync(realm, patientUserId);
    }
}
```

#### Financial (PCI DSS)
```csharp
// Restrict impersonation of accounts with payment data
public async Task ImpersonateCustomer(string realm, string userId)
{
    var user = await _client.GetUserAsync(realm, userId);

    if (HasStoredPaymentMethods(user))
    {
        throw new InvalidOperationException(
            "Cannot impersonate users with stored payment methods. " +
            "Use alternative support methods.");
    }

    await _client.ImpersonateUserAsync(realm, userId);
}
```

## Troubleshooting

### Impersonation Failed
- Verify admin has `impersonation` role
- Check that admin is in correct realm
- Ensure target user exists and is enabled
- Review Keycloak server permissions

### Can't See User Data During Impersonation
- Check client application is using impersonation token
- Verify token contains correct user claims
- Review application's token validation logic

### Session Expired Too Quickly
- Check Keycloak session timeout settings
- Review token lifetimes
- Ensure refresh token is being used

## Related Resources

- [User Management README](./README.md)
- [Session Management](./sessions.md)
- [CRUD Operations](./crud-operations.md)
- [Keycloak Impersonation Documentation](https://www.keycloak.org/docs/latest/server_admin/#_impersonation)
