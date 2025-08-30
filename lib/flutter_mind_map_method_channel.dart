import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_mind_map_platform_interface.dart';

/// An implementation of [FlutterMindMapPlatform] that uses method channels.
class MethodChannelFlutterMindMap extends FlutterMindMapPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_mind_map');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
