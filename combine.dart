#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';
import 'common.dart';

void main() {
  Map<String, dynamic> map = {};
  for (final p in paras) {
    File f = File("jsons/$p.json");
    if (!f.existsSync()) {
      print("$p para not available");
      continue;
    }
    map[p.toString()] = jsonDecode(f.readAsStringSync());
  }
  String json = const JsonEncoder.withIndent(" ").convert(map);
  File("mutashabiha_data.json").writeAsStringSync(json);
}
