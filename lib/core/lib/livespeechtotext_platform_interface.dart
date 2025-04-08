import 'dart:async';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:tts_by_ai/core/lib/livespeechtotext_event_channel.dart';
import 'package:tts_by_ai/core/lib/livespeechtotext_method_channel.dart';

abstract class LivespeechtotextPlatform extends PlatformInterface {
  /// Constructs a LivespeechtotextPlatform.
  LivespeechtotextPlatform() : super(token: _token);

  static final Object _token = Object();
  static LivespeechtotextPlatform _methodChannel =
      MethodChannelLivespeechtotext();
  static LivespeechtotextPlatform _eventChannel =
      EventChannelLivespeechtotext();

  /// The default instance of [LivespeechtotextPlatform] to use.
  ///
  /// Defaults to [MethodChannelLivespeechtotext].
  static LivespeechtotextPlatform get instance => _methodChannel;

  /// The instance for [EventChannelLivespeechtotext]
  static LivespeechtotextPlatform get eventInstance => _eventChannel;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [LivespeechtotextPlatform] when
  /// they register themselves.
  static set instance(LivespeechtotextPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _methodChannel = instance;
    _eventChannel = instance;
  }

  /// Platform-specific method to register event
  StreamSubscription<dynamic> addEventListener(
    String eventName,
    Function(dynamic) callback,
  ) {
    throw UnimplementedError('addEventListener() has not been implemented.');
  }

  /// Platform-specific method to get local display name
  Future<String?> getLocaleDisplayName() async {
    throw UnimplementedError(
        'getLocaleDisplayName() has not been implemented.');
  }

  /// Platform-specific method to get supported language
  Future<Map<String, String>?> getSupportedLocales() {
    throw UnimplementedError('getSupportedLocales() has not been implemented.');
  }

  /// Platform-specific method to get recognized text
  Future<String?> getText() {
    throw UnimplementedError('getText() has not been implemented.');
  }

  /// Platform-specific method to change recognizer language
  Future<dynamic> setLocale(String languageTag) {
    throw UnimplementedError('setLocale() has not been implemented.');
  }

  /// Platform-specific method to start speech-to-text
  Future<String?> start() {
    throw UnimplementedError('start() has not been implemented.');
  }

  /// Platform-specific method to stop speech-to-text
  Future<String?> stop() {
    throw UnimplementedError('stop() has not been implemented.');
  }
}
