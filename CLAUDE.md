# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Keycloak.ApiClient.Net is a .NET 9.0 client library for the Keycloak Admin REST API. It provides a fluent, resource-oriented interface for managing Keycloak administrative features including users, groups, realms, clients, roles, authentication, and authorization.

## Build and Test Commands

### Building
```bash
dotnet build -c Release
```

### Running Tests
```bash
# Run all tests
dotnet test -c Release

# Or use the provided script (iterates through all test projects)
pwsh ./build/test.ps1

# Run tests for a specific project
cd test/Keycloak.ApiClient.Net.Tests
dotnet test -c Release

# Run a specific test
dotnet test --filter "FullyQualifiedName~KeycloakClientShould.GetUsersAsync"
```

### Creating NuGet Package
```bash
pwsh ./build/build.ps1 -BuildVersionNumber "2.0.2"
```

## Architecture

### Partial Class Design Pattern

The `KeycloakClient` class is split into multiple partial classes organized by Keycloak resource type. This modular structure keeps related API methods together:

- **Main class**: `src/Keycloak.ApiClient.Net/KeycloakClient.cs` - Contains constructors, authentication setup, and base URL configuration
- **Resource partials**: Each subdirectory (Users, Clients, Groups, Roles, etc.) contains its own `KeycloakClient.cs` with methods for that resource
- **Examples**:
  - `Users/KeycloakClient.cs` - User CRUD operations
  - `Clients/KeycloakClient.cs` - Client management
  - `Groups/KeycloakClient.cs` - Group operations
  - `Roles/KeycloakClient.cs` - Role management
  - `AuthenticationManagement/KeycloakClient.cs` - Authentication flows

When adding new Keycloak API endpoints, create a new partial class in the appropriate resource directory.

### Authentication

The client supports multiple authentication modes:

1. **Username/Password**: `new KeycloakClient(url, userName, password)`
2. **Client Secret**: `new KeycloakClient(url, clientSecret)`
3. **Token Provider**: `new KeycloakClient(url, getTokenFunc)`
4. **Combined**: `new KeycloakClient(url, userName, password, clientSecret, getTokenFunc)`

Authentication uses the `admin-cli` client by default and obtains tokens via the OpenID Connect token endpoint (`/realms/{realm}/protocol/openid-connect/token`). Token handling is in `Common/Extensions/FlurlRequestExtensions.cs`.

### HTTP Client (Flurl)

The library uses Flurl.Http 4.0.2 for HTTP operations with Newtonsoft.Json serialization:

- Named HTTP clients: `KeycloakDefaultClientName` and `KeycloakAuthenticateClientName`
- JSON serialization: CamelCase with null value handling (nulls are ignored)
- Custom serializer can be set via `SetSerializer(ISerializer)`

### Base URL Pattern

The `GetBaseUrl` method creates authenticated Flurl requests:
- `GetBaseUrl(realm)` - Returns authenticated request
- `GetBaseUrl(realm, withAuthentication: false)` - Returns unauthenticated request (for public endpoints)

All API methods follow this pattern:
```csharp
GetBaseUrl(realm)
    .AppendPathSegment($"/admin/realms/{realm}/...")
    .GetJsonAsync<T>()
```

### Models

Models are organized by resource type in `Models/` subdirectories:
- Models mirror Keycloak's JSON representations
- Use Newtonsoft.Json attributes for serialization control
- Key models: `User`, `Client`, `Role`, `Group`, `Realm`, etc.
- New in 2.0: `CountResponse`, `ManagementPermissionReference`, `ComponentTypeRepresentation`

### Test Structure

Tests mirror the source structure with partial classes:
- Base test class: `test/Keycloak.ApiClient.Net.Tests/KeycloakClientShould.cs`
- Resource-specific tests: Each resource has `ResourceName/KeycloakClientShould.cs`
- Test configuration: Uses `appsettings.json` with keys like `MLA:BaseUrl`, `MLA:AdminUsername`, `MLA:AdminPassword`
- Framework: xUnit with async test methods

## Development Guidelines

### Adding New API Endpoints

1. Create or update the partial class in the appropriate resource directory
2. Follow naming convention: `{Action}{Resource}Async` (e.g., `GetUsersAsync`, `CreateClientAsync`)
3. For create operations returning IDs, provide both boolean success and ID-returning variants:
   ```csharp
   public async Task<bool> CreateUserAsync(string realm, User user)
   public async Task<string> CreateAndRetrieveUserIdAsync(string realm, User user)
   ```
4. Extract resource ID from `Location` header when creating resources
5. Add corresponding test in `test/.../ResourceName/KeycloakClientShould.cs`

### Error Handling

- Methods return `IFlurlResponse` for full control over status codes
- Success check: `response.StatusCode >= 200 && response.StatusCode < 300`
- 501 Not Implemented responses are handled in recent versions

### Working with Flurl 4.0

- Use `IFlurlResponse` instead of dynamic responses
- Access headers via `response.Headers.FirstOrDefault("HeaderName")`
- Methods use `PostJsonAsync`, `GetJsonAsync`, `PutJsonAsync`, `DeleteAsync`
- Configure JSON serializer via `FlurlHttp.Clients` setup

## Dependencies

- .NET 9.0 SDK (specified in global.json)
- Flurl.Http 4.0.2 with Newtonsoft.Json support
- Newtonsoft.Json 13.0.3
- xUnit for testing
- Requires Keycloak 17+ with Admin REST API

## Package Information

- Package ID: Keycloak.ApiClient.Net
- Current version: 2.0.2
- Signed assembly using `Keycloak.ApiClient.Net.snk`
- NuGet artifacts output to `artifacts/` directory
