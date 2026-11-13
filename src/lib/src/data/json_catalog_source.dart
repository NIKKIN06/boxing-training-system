/// Supplied catalog read from a JSON resource (T-57; default
/// `assets/catalog/test-catalog.json`): version, dictionaries (SRS §4.4) and
/// initial exercises. Seeding by D-06 is done by `CatalogService.initialize`.
library;

import 'dart:convert';
import 'dart:io';

import '../domain/catalog.dart';
import '../domain/enums.dart';
import '../domain/exercise_json.dart';
import '../ports/repositories.dart';

final class JsonFileCatalogSource implements CatalogSource {
  JsonFileCatalogSource(this.path);

  final String path;

  /// Throws [FileSystemException] or [FormatException] on an unreadable or
  /// malformed resource.
  @override
  Future<CatalogData> load() async {
    final decoded = jsonDecode(await File(path).readAsString());
    if (decoded is! Map<String, Object?>) {
      throw FormatException('Catalog must be a JSON object', path);
    }
    final exercises = [
      for (final e in decoded['exercises']! as List<Object?>) exerciseFromJson(e),
    ];
    for (final e in exercises) {
      if (e.origin != Origin.initial) {
        throw FormatException('Supplied exercise must be initial', e.id);
      }
    }
    return CatalogData(
      catalogVersion: decoded['catalogVersion']! as String,
      placeholder: decoded['placeholder']! as bool,
      dictionaries: [
        for (final d in decoded['dictionaries']! as List<Object?>)
          dictionaryFromJson(d),
      ],
      exercises: exercises,
    );
  }
}
