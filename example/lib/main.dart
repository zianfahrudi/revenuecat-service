import 'package:flutter/material.dart';
import 'package:revenuecat_service/revenuecat_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the service with dummy configuration for the example
  await RevenueCatService.instance.init(
    RevenueCatConfig(
      googlePlayKey: 'goog_dummy_key',
      appStoreKey: 'appl_dummy_key',
      entitlementId: 'premium',
      isTestMode: true,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('RevenueCat Service Example')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ValueListenableBuilder<bool>(
                valueListenable: RevenueCatService.instance.isPremiumNotifier,
                builder: (context, isPremium, child) {
                  return Text('Premium Status: ${isPremium ? "PRO" : "FREE"}');
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PaywallView(
                        title: "Get Pro Access",
                        description:
                            "Access all features with a simple monthly subscription.",
                        features: const [
                          "Remove Ads",
                          "Unlimited Access",
                          "Priority Support",
                        ],
                        style: PaywallStyle(
                          primaryColor: Colors.deepPurple,
                          buttonColor: Colors.deepPurpleAccent,
                        ),
                        onPurchaseSuccess: () {
                          Navigator.of(context).pop();
                        },
                        onRestoreSuccess: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  );
                },
                child: const Text('Show Paywall'),
              ),
              const SizedBox(height: 20),
              ValueListenableBuilder<Set<String>>(
                valueListenable:
                    UsageLimitService.instance.freeClientIdsNotifier,
                builder: (context, freeIds, _) {
                  return Text(
                    'Free Clients Used: ${freeIds.length} / ${UsageLimitService.instance.maxFreeClients}',
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
