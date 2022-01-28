import 'dart:async';

import 'package:flutter/services.dart';

/// File Encrypter
class FileEncrypter {
  static const _channel = MethodChannel('file_encrypter');
  // final _eventChannel = const EventChannel('file_encrypter');

  /// Encrypts file in [inFileName] to [outFileName].
  static Future<bool?> encrypt({
    required String inFilename,
    required String key,
    required String iv,
    required String outFileName,
  }) =>
      _channel.invokeMethod<bool>(
        'encrypt',
        <String, String>{
          'key': key,
          'iv': iv,
          'inFileName': inFilename,
          'outFileName': outFileName,
        },
      );

  /// Decrypts file in [inFileName] to [outFileName].
  static Future<bool?> decrypt({
    required String key,
    required String inFilename,
    required String outFileName,
  }) =>
      _channel.invokeMethod<bool>(
        'decrypt',
        <String, String>{
          'key': key,
          'inFileName': inFilename,
          'outFileName': outFileName,
        },
      );

  static Future<String?> getFileIv({
    required String inFilename,
  }) =>
      _channel.invokeMethod<String>(
        'getfileiv',
        <String, String>{
          'inFileName': inFilename,
        },
      );

  static Future<String?> generatekey() =>
      _channel.invokeMethod<String>('generatekey');

  static Future<String?> generateiv() =>
      _channel.invokeMethod<String>('generateiv');
}
