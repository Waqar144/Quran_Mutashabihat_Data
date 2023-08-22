import 'dart:io';
import 'dart:convert';
import 'common.dart';

class MutAnchor {
  List<int> sourceAyahs = [];

  Map<String, dynamic> toJson() {
    return {'ayah': sourceAyahs.length == 1 ? sourceAyahs.first : sourceAyahs};
  }
}

class Mut {
  MutAnchor source = MutAnchor();
  List<MutAnchor> dest = [];
  int? ctx;
  Map<String, dynamic> toJson() {
    if (ctx != null) {
      return {'src': source, 'muts': dest, 'ctx': ctx};
    }
    return {'src': source, 'muts': dest};
  }
}

MutAnchor mutAnchorFromString(String s) {
  final ayahParts = s.split(',');
  MutAnchor ret = MutAnchor();
  for (final ap in ayahParts) {
    if (ap.isEmpty) continue;
    final parts = ap.split(':');
    assert(parts.length == 2);
    int surah = int.parse(parts[0]) - 1;
    int ayah = int.parse(parts[1]) - 1;
    int surahStart = surahAyahOffsets[surah];
    int surahEnd = surah + 1 < surahAyahOffsets.length
        ? surahAyahOffsets[surah + 1]
        : surahStart + 5;
    if (surahEnd - surahStart < ayah) {
      print("Invalid ayah.... $ap");
      exit(1);
    }
    int absoluteAyah = surahAyahOffsets[surah] + ayah;
    ret.sourceAyahs.add(absoluteAyah);
  }
  return ret;
}

void main(List<String> args) async {
  List<int> fileNames = [];
  if (args.isEmpty || args.length != 1) {
    fileNames = paras;
  } else {
    fileNames = [int.parse(args.single)];
  }

  for (final int p in fileNames) {
    final fileName = p;
    final file = File("txts/$fileName.txt");
    if (!file.existsSync()) continue;
    final mutTextLines = file.readAsLinesSync();
    int lnIdx = 0;
    List<Mut> muts = [];
    for (final line in mutTextLines) {
      List<String> tparts = line.split('\\');
      List<String> parts = tparts[0].split('|'); // src | dests
      assert(parts.length == 2);
      Mut m = Mut();
      m.source = mutAnchorFromString(parts[0]);
      if (tparts.length > 1 && tparts[1].isNotEmpty) {
        if (tparts[1] == 'p') {
          m.ctx = 1;
        } else if (tparts[1] == 'n') {
          m.ctx = 2;
        } else {
          print("invalid ctx type ${tparts[1]} in line: $line");
          exit(1);
        }
      }

      List<String> destParts = [];
      if (parts[1].contains('/')) {
        destParts = parts[1].split('/');
      } else {
        destParts = parts[1].split(',');
      }
      for (final p in destParts) {
        if (p.isNotEmpty) {
          try {
            m.dest.add(mutAnchorFromString(p));
          } catch (e) {
            print("ERROR $e, in line: ${lnIdx + 1}");
            exit(1);
          }
        }
      }
      muts.add(m);
      lnIdx++;
    }

    if (!Directory('jsons').existsSync()) {
      Directory('jsons').createSync();
    }

    String json = const JsonEncoder.withIndent(" ").convert(muts);
    File("jsons/$fileName.json").writeAsStringSync(json);
    // print(json);
  }
}
