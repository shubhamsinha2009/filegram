import 'package:get/get_utils/src/extensions/string_extensions.dart';
import 'dart:io';

extension StringExtensions on String {
  String get sort => toLowerCase().removeAllWhitespace;

  String get removeExtension => replaceAll('.pdf.enc', '');
  String get removeExtensionPdf => replaceAll('.pdf', '');
  String get gmail => '$this@gmail.com';
  bool get isGmail => endsWith("@gmail.com");
}

extension FileExtention on FileSystemEntity {
  String get name {
    return path.split("/").last;
  }
}
