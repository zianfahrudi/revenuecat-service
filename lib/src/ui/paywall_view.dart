import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../revenuecat_service.dart';
import 'paywall_style.dart';

class PaywallView extends StatefulWidget {
  final String title;
  final String description;
  final List<String> features;
  final PaywallStyle style;
  final VoidCallback? onPurchaseSuccess;
  final VoidCallback? onRestoreSuccess;
  final String? offeringId; // Optional: specify a specific offering to show

  const PaywallView({
    super.key,
    this.title = 'Upgrade to Premium',
    this.description = 'Unlock all features and remove ads.',
    this.features = const [],
    this.style = const PaywallStyle(),
    this.onPurchaseSuccess,
    this.onRestoreSuccess,
    this.offeringId,
  });

  @override
  State<PaywallView> createState() => _PaywallViewState();
}

class _PaywallViewState extends State<PaywallView> {
  bool _isLoading = true;
  List<Package> _packages = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Logic to fetch specific offering if ID is provided, or default via service
      // The service currently returns 'availablePackages' from current offering.
      // We might want to expand service to get specific offering if needed,
      // but for now let's use what we have.

      // If offeringId is provided, we might need to access Offerings object directly.
      // But let's stick to the simple service API we built first.
      // TODO: Update Service to fetch specific offering if needed.
      final packages = await RevenueCatService.instance.getOfferings();

      if (mounted) {
        setState(() {
          _packages = packages;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load offerings. Please try again later.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _onPurchase(Package package) async {
    setState(() => _isLoading = true);
    try {
      final success = await RevenueCatService.instance.purchasePackage(package);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Purchase successful!')));
          widget.onPurchaseSuccess?.call();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Purchase failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onRestore() async {
    setState(() => _isLoading = true);
    try {
      await RevenueCatService.instance.restorePurchases();
      // Check if restored
      if (RevenueCatService.instance.isPremium) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Purchases restored!')));
          widget.onRestoreSuccess?.call();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No active subscriptions found to restore.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Restore failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: widget.style.backgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: widget.style.backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!, textAlign: TextAlign.center),
              TextButton(onPressed: _loadOfferings, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: widget.style.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Premium',
          style: widget.style.titleStyle.copyWith(fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: widget.style.titleStyle.color),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.title,
                style: widget.style.titleStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                widget.description,
                style: widget.style.descriptionStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (widget.features.isNotEmpty) ...[
                Expanded(
                  child: ListView.separated(
                    itemCount: widget.features.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: widget.style.primaryColor,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.features[index],
                              style: widget.style.featureTextStyle,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ] else
                const Spacer(),
              const SizedBox(height: 24),
              // Packages List
              ..._packages.map(
                (package) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.style.buttonColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            widget.style.cornerRadius,
                          ),
                        ),
                      ),
                      onPressed: () => _onPurchase(package),
                      child: Column(
                        children: [
                          Text(
                            package.storeProduct.title,
                            style: widget.style.buttonTextStyle,
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            package.storeProduct.priceString,
                            style: widget.style.buttonTextStyle.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              TextButton(
                onPressed: _onRestore,
                child: Text(
                  'Restore Purchases',
                  style: TextStyle(color: widget.style.primaryColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
