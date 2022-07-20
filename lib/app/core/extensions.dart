import 'package:get/get_utils/src/extensions/string_extensions.dart';
import 'dart:io';

extension StringExtensions on String {
  String get sort => toLowerCase().removeAllWhitespace;

  String get removeExtension => replaceAll('.pdf.enc', '');
}

extension FileExtention on FileSystemEntity {
  String get name {
    return path.split("/").last;
  }
}
