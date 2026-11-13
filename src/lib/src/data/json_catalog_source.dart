/// Supplied catalog read from a JSON resource (T-57; default
/// `assets/catalog/test-catalog.json`). Seeding by D-06 is T-32, not T-10.
/// T-10 skeleton: the path is configured, loading throws [UnimplementedError].
library;

import '../domain/catalog.dart';
import '../ports/repositories.dart';

final class JsonFileCatalogSource implements CatalogSource {
  JsonFileCatalogSource(this.path);

  final String path;

  @override
  Future<CatalogData> load() => throw UnimplementedError('CatalogSource.load');
}
