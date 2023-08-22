// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:io';
import 'common.dart';

class Pair {
  int s;
  int a;
  Pair(this.s, this.a);
  @override
  String toString() {
    return "$s:$a";
  }
}

class PairsLine {
  Pair src;
  List<Pair> dests;
  bool showContext = false;
  PairsLine(this.src, this.dests);
  @override
  String toString() {
    String s = "$src|";
    for (final d in dests) {
      s += "$d,";
    }
    if (s.endsWith(',')) s = s.substring(0, s.length - 1);

    if (showContext) {
      s += "\\n";
    }
    return s;
  }

  void sort() {
    dests.sort((a, b) {
      if (a.s < b.s) return -1;
      if (a.s == b.s) return 0;
      return 1;
    });
  }
}

Pair pairFromColon(String c) {
  final n = c.split(':');
  assert(n.length == 2);
  try {
    return Pair(int.parse(n.first), int.parse(n.last));
  } catch (e) {
    print("Failed: $e -- Pair is $c, pair len: ${c.length}");
    exit(1);
  }
}

int paraIdxFromPair(Pair p) {
  int ayahOffset = surahAyahOffsets[p.s - 1] + p.a;
  // last para
  if (ayahOffset > paraAyahOffset[29]) {
    return 29;
  }
  for (int i = 0; i < paraAyahOffset.length; ++i) {
    if (ayahOffset > paraAyahOffset[i]) continue;
    return i - 1;
  }
  throw "shouldn't happen, $p, ayahOffset: $ayahOffset, surah: ${p.s}";
}

void main() {
  Map<int, List<PairsLine>> data = {};

  if (!Directory('rev').existsSync()) {
    Directory('rev').createSync();
  }

  for (final f in paras) {
    print("Processing para: $f");
    final file = File("txts/$f.txt");
    if (!file.existsSync()) {
      continue;
    }
    final lines = file.readAsLinesSync();
    final int currentPara = f - 1;
    for (String l in lines) {
      if (l.contains('/')) {
        // multiple ayahs, skip for now
        print("Skipping: $l");
        continue;
      }

      bool showContext = l.endsWith('\\n');
      l = l.split('\\n').first;

      final strs = l.split('|');
      assert(strs.length == 2);
      Pair src = pairFromColon(strs[0]);
      // print("$src, -- ${paraIdxFromPair(src)}");
      List<Pair> dests = [];
      for (final p in strs[1].split(',')) {
        dests.add(pairFromColon(p));
        // print("$p, -- ${paraIdxFromPair(dests.last)}");
      }
      // print("Original: [$src - $dests]");

      for (final d in dests) {
        int para = paraIdxFromPair(d);
        if (para == currentPara) continue;
        if (!data.containsKey(para)) {
          data[para] = [];
        }
        final srcPair = d;
        PairsLine pl = PairsLine(srcPair, []);
        for (final d2 in dests) {
          if (d2 == d) continue;
          pl.dests.add(d2);
        }

        final originalSrcPara = paraIdxFromPair(src);
        if (originalSrcPara != para) {
          pl.dests.add(src);
        }
        pl.sort();
        if (pl.dests.isEmpty) {
          print("shouldn't be empty!, line was: $l, para was: $f");
          exit(1);
        }
        pl.showContext = showContext;
        // print("[${para + 1}]Generated: $pl");
        data[para]!.add(pl);
      }

      // print("$src, $dests");
    }
  }

  for (final e in data.entries) {
    final fileName = "${e.key + 1}.txt";
    e.value.sort((a, b) {
      if (a.src.s == b.src.s) {
        return a.src.a - b.src.a;
      }
      if (a.src.s < b.src.s) return -1;
      return 1;
    });
    List<String> lines = [];
    Set<String> seen = {};
    for (final l in e.value) {
      final str = l.toString();
      if (seen.contains(str)) continue;
      seen.add(str);
      lines.add(str);
    }
    // print("generated: gen/$fileName");
    File("rev/$fileName").writeAsString(lines.join('\n'));
  }
}
