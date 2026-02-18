# RevenueCat Service

A reusable RevenueCat service wrapper for Flutter applications, featuring built-in support for:
- Environment configuration (Test/Prod keys)
- Premium status management
- Usage limits and free tier logic

## Features

- **Singleton Access**: Easily access `RevenueCatService.instance` anywhere.
- **Environment Support**: Configure separate API keys for Google Play and App Store in both Test and Production modes.
- **Entitlement Checking**: Simplified `isPremium` status and reactive `isPremiumNotifier`.
- **Usage Limits**: Built-in `UsageLimitService` for managing free tier functionality (e.g., limited slots, watermarks).

## Getting Started

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  revenuecat_service:
    git:
      url: https://github.com/zianfahrudi/revenuecat-service.git
      ref: master # or specific tag/branch
```

## Usage

### Initialization

Initialize the service early in your app lifecycle (e.g., in `main.dart`).

```dart
import 'package:flutter/foundation.dart'; // for kDebugMode
import 'package:revenuecat_service/revenuecat_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize RevenueCat Service
  await RevenueCatService.instance.init(
    RevenueCatConfig(
      googlePlayKey: 'YOUR_ANDROID_PROD_KEY',
      appStoreKey: 'YOUR_IOS_PROD_KEY',
      // Optional: Test keys for development
      googlePlayTestKey: 'YOUR_ANDROID_TEST_KEY',
      appStoreTestKey: 'YOUR_IOS_TEST_KEY',
      entitlementId: 'premium', // Your entitlement identifier in RevenueCat
      isTestMode: kDebugMode,   // Automatically switch keys based on environment
    ),
  );

  // 2. Initialize Usage Limit Service (Optional)
  await UsageLimitService.instance.init(maxFreeClients: 3);

  runApp(const MyApp());
}
```

### Checking Premium Status

You can check the current status or listen to changes reactively.

```dart
// Reactive UI
ValueListenableBuilder<bool>(
  valueListenable: RevenueCatService.instance.isPremiumNotifier,
  builder: (context, isPremium, child) {
    return Text(isPremium ? "Premium User" : "Free User");
  },
);

// Direct check
if (RevenueCatService.instance.isPremium) {
  // Grant access
}
```

### Managing Usage Limits (Free Tier)

The `UsageLimitService` helps manage restricted features for free users (e.g., limiting the number of added items).

```dart
// Check availability
int remaining = UsageLimitService.instance.remainingClientSlots;

// Register a new item/client
bool success = UsageLimitService.instance.registerClient("unique_client_id");
if (success) {
  print("Client registered!");
} else {
  print("Limit reached. Upgrade to Premium.");
}

// Check if a specific item is within the free tier
bool isFree = UsageLimitService.instance.isClientFree("unique_client_id");
```

### Show Custom Paywall

Use the built-in `PaywallView` to show a customizable paywall that automatically fetches offerings.

```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (_) => PaywallView(
      title: "Get Pro Access",
      description: "Unlock all features with a simple monthly subscription.",
      features: const [
        "Remove Ads",
        "Unlimited Access",
        "Priority Support",
      ],
      style: PaywallStyle(
          primaryColor: Colors.deepPurple,
          buttonColor: Colors.deepPurpleAccent,
          // Custom text styles, colors, etc.
      ),
      onPurchaseSuccess: () {
          // Navigate away or show success message
          Navigator.of(context).pop();
      },
      onRestoreSuccess: () {
          Navigator.of(context).pop();
      },
    ),
  ),
);
```

## Platform Setup

This plugin uses `purchases_flutter` under the hood. Ensure you have configured RevenueCat correctly for Android and iOS.

- **Android**: Add `BILLING` permission to `AndroidManifest.xml`.
- **iOS**: Enable In-App Purchase capability in Xcode.
