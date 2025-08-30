import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_mind_map_method_channel.dart';

abstract class FlutterMindMapPlatform extends PlatformInterface {
  /// Constructs a FlutterMindMapPlatform.
  FlutterMindMapPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterMindMapPlatform _instance = MethodChannelFlutterMindMap();

  /// The default instance of [FlutterMindMapPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterMindMap].
  static FlutterMindMapPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterMindMapPlatform] when
  /// they register themselves.
  static set instance(FlutterMindMapPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
