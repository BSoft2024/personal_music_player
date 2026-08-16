import 'package:excel/excel.dart';
import 'package:flutter/services.dart';
import '../models/song.dart';
import '../utils/slugify.dart';

class PlaylistService {
  // Core columns that are always expected
  static const _coreColumns = [
    'Song Title',
    'Album / Release Title',
    'Type',
    'Release Year',
  ];

  /// Loads songs from the spreadsheet.
  /// Tries assets/songs.xlsx first, then falls back to assets/sample_songs.xlsx.
  static Future<List<Song>> loadSongs() async {
    ByteData bytes;
    try {
      bytes = await rootBundle.load('assets/songs.xlsx');
    } catch (_) {
      bytes = await rootBundle.load('assets/sample_songs.xlsx');
    }

    final excel = Excel.decodeBytes(bytes.buffer.asUint8List());
    final sheet = excel.tables.keys.first;
    final rows = excel.tables[sheet]!.rows;

    if (rows.isEmpty) {
      throw Exception('Spreadsheet is empty');
    }

    // Find header row (first non-empty row)
    int headerIndex = 0;
    for (var i = 0; i < rows.length; i++) {
      final firstCell = rows[i].isNotEmpty ? rows[i][0]?.value?.toString().trim() : null;
      if (firstCell != null && firstCell.isNotEmpty) {
        headerIndex = i;
        break;
      }
    }

    final headerRow = rows[headerIndex];
    final colIndex = <String, int>{};
    for (var i = 0; i < headerRow.length; i++) {
      final val = headerRow[i]?.value?.toString().trim();
      if (val != null && val.isNotEmpty) {
        colIndex[val] = i;
      }
    }

    // Check required columns
    for (final required in _coreColumns) {
      if (!colIndex.containsKey(required)) {
        throw Exception('Missing required column in spreadsheet: "$required"');
      }
    }

    // Everything that is not a core column is treated as an instrument column
    final instrumentColumns = colIndex.keys
        .where((k) => !_coreColumns.contains(k))
        .toList();

    final songs = <Song>[];

    for (var r = headerIndex + 1; r < rows.length; r++) {
      final row = rows[r];
      if (row.isEmpty) continue;

      final title = row[colIndex['Song Title']!]?.value?.toString().trim();
      if (title == null || title.isEmpty) continue;

      final album = row[colIndex['Album / Release Title']!]?.value?.toString().trim() ?? '';
      final type = row[colIndex['Type']!]?.value?.toString().trim() ?? 'Single';

      int year = 0;
      final yearCell = row[colIndex['Release Year']!];
      if (yearCell?.value != null) {
        final raw = yearCell!.value;
        if (raw is IntCellValue) {
          year = raw.value;
        } else if (raw is DoubleCellValue) {
          year = raw.value.toInt();
        } else {
          year = int.tryParse(raw.toString()) ?? 0;
        }
      }

      final instruments = <String>{};
      for (final instr in instrumentColumns) {
        final cell = row[colIndex[instr]!];
        final val = cell?.value?.toString().trim().toLowerCase();
        if (val == 'x' || val == 'yes' || val == '1' || val == 'true') {
          instruments.add(instr);
        }
      }

      final slug = slugify(title);
      songs.add(Song(
        title: title,
        album: album,
        type: type,
        year: year,
        instruments: instruments,
        audioAsset: 'assets/audio/$slug.flac', // change to .wav or .mp3 if you prefer
        coverAsset: 'assets/covers/$slug.jpg',
      ));
    }

    return songs;
  }

  /// Returns all unique instrument names found across the loaded songs.
  static List<String> instrumentsFromSongs(List<Song> songs) {
    final set = <String>{};
    for (final s in songs) {
      set.addAll(s.instruments);
    }
    final list = set.toList()..sort();
    return list;
  }
}
