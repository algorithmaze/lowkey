
import 'dart:convert';
import 'dart:typed_data';

extension StringExtension on String {
  Uint8List toUint8List() {
    return Uint8List.fromList(utf8.encode(this));
  }
}

extension Uint8ListExtension on Uint8List {
  String toDartString() {
    return utf8.decode(this);
  }
}
