import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'revenuecat_service_method_channel.dart';

abstract class RevenuecatServicePlatform extends PlatformInterface {
  /// Constructs a RevenuecatServicePlatform.
  RevenuecatServicePlatform() : super(token: _token);

  static final Object _token = Object();

  static RevenuecatServicePlatform _instance = MethodChannelRevenuecatService();

  /// The default instance of [RevenuecatServicePlatform] to use.
  ///
  /// Defaults to [MethodChannelRevenuecatService].
  static RevenuecatServicePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [RevenuecatServicePlatform] when
  /// they register themselves.
  static set instance(RevenuecatServicePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
