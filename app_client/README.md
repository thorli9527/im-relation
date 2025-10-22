# app_client

A new Flutter project.

## Desktop network access

Desktop builds are configured to allow outbound gRPC and HTTP traffic:

- **macOS** – `Runner/DebugProfile.entitlements` and `Runner/Release.entitlements` include both `com.apple.security.network.client` and `com.apple.security.network.server`, and the build configurations point at those entitlements via `CODE_SIGN_ENTITLEMENTS`.
- **Windows** – Win32 builds allow network access by default; the project ships with the standard `runner.exe.manifest`.
- **Linux** – GTK builds are unrestricted for outbound sockets, so no extra manifest entries are required.

Rebuild the platform-specific projects after pulling these changes (e.g. `flutter clean && flutter run -d macos`) to ensure the entitlements are applied.
