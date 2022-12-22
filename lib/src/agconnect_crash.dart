// ignore_for_file: avoid_print, avoid_positional_boolean_parameters
/// agconnect_crash: 1.3.0+300 null safety ext
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

/// 自定义日志的级别
enum LogLevel { debug, info, warning, error }

/// 崩溃收集服务入口类
class AGCCrash {
  static const MethodChannel _channel = MethodChannel('com.huawei.flutter/agconnect_crash');

  /// 获取AGCCrash实例
  static final AGCCrash instance = AGCCrash();

  Future<void> onFlutterError(FlutterErrorDetails details) async {
    FlutterError.dumpErrorToConsole(details, forceReport: true);
    recordError(details.exceptionAsString(), details.stack);
  }

  Future<void> recordError(dynamic exception, StackTrace? _stack, {bool fatal = false}) async {
    assert(exception != null);
    final StackTrace stack = _stack ?? StackTrace.current;
    print('Error caught by AGCCrash : ${exception.toString()} \n${stack.toString()}');
    await _channel.invokeMethod<void>('recordError', <String, String>{
      'reason': exception.toString(),
      'stack': stack.toString(),
      'fatal': fatal.toString(),
    });
    return;
  }

  /// 制造一个崩溃，用于开发者调试
  Future<void> testIt() {
    return _channel.invokeMethod('testIt');
  }

  /// 设置是否收集和上报应用的崩溃信息，默认为true
  /// enable为true表示收集并上报崩溃信息，false表示不收集且不上报崩溃信息。
  Future<void> enableCrashCollection(bool enable) {
    return _channel.invokeMethod('enableCrashCollection', <String, bool>{
      'enable': enable,
    });
  }

  /// 设置自定义用户标识符
  Future<void> setUserId(String userId) {
    return _channel.invokeMethod('setUserId', <String, String>{
      'userId': userId,
    });
  }

  /// 添加自定义键值对
  Future<void> setCustomKey(String key, dynamic value) {
    return _channel.invokeMethod('setCustomKey', <String, String>{'key': key, 'value': value.toString()});
  }

  /// 添加自定义日志
  Future<void> log({required String message, LogLevel level = LogLevel.info}) {
    return _channel.invokeMethod('customLog', <String, dynamic>{'level': level.index, 'message': message});
  }
}
