import 'dart:async';

import 'package:flutter/services.dart';

class LargeFileCopy {
  final String sourceFilePath;
  final String distFilePath;
  LargeFileCopy(this.sourceFilePath, this.distFilePath);

  static const MethodChannel _channel = const MethodChannel('ch.ideenkaffee.largefilecopy');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  Future<bool> execute() async {
    final bool successful = await _channel.invokeMethod('copyLargeFile', <String, dynamic>{
      'sourceFilePath': this.sourceFilePath,
      'distFilePath': this.distFilePath,
    });
    return successful;
  }
}
