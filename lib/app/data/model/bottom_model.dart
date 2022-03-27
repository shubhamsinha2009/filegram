import 'package:flutter/material.dart';

class BottomModel {
  final int index;
  final BottomType bottomType;
  final Icon? listTileIcon;
  final Color color;
  final bool showShareButton;

  BottomModel({
    required this.index,
    required this.bottomType,
    required this.listTileIcon,
    required this.color,
    required this.showShareButton,
  });
}

enum BottomType { personal, library }
final bottomModel = <BottomModel>[
  BottomModel(
    index: 0,
    bottomType: BottomType.personal,
    listTileIcon: const Icon(
      Icons.book_rounded,
      color: Colors.teal,
    ),
    color: Colors.teal,
    showShareButton: true,
  ),
  BottomModel(
    index: 1,
    bottomType: BottomType.library,
    listTileIcon: const Icon(
      Icons.play_circle,
      color: Colors.cyan,
    ),
    color: Colors.cyan,
    showShareButton: false,
  ),
];
