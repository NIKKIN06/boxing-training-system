// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ExercisesTable extends Exercises
    with TableInfo<$ExercisesTable, ExerciseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _allowedStagesJsonMeta = const VerificationMeta(
    'allowedStagesJson',
  );
  @override
  late final GeneratedColumn<String> allowedStagesJson =
      GeneratedColumn<String>(
        'allowed_stages_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _allowedLevelsJsonMeta = const VerificationMeta(
    'allowedLevelsJson',
  );
  @override
  late final GeneratedColumn<String> allowedLevelsJson =
      GeneratedColumn<String>(
        'allowed_levels_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _allowedIntensitiesJsonMeta =
      const VerificationMeta('allowedIntensitiesJson');
  @override
  late final GeneratedColumn<String> allowedIntensitiesJson =
      GeneratedColumn<String>(
        'allowed_intensities_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _emphasesJsonMeta = const VerificationMeta(
    'emphasesJson',
  );
  @override
  late final GeneratedColumn<String> emphasesJson = GeneratedColumn<String>(
    'emphases_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _loadCharacterMeta = const VerificationMeta(
    'loadCharacter',
  );
  @override
  late final GeneratedColumn<String> loadCharacter = GeneratedColumn<String>(
    'load_character',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _variantsJsonMeta = const VerificationMeta(
    'variantsJson',
  );
  @override
  late final GeneratedColumn<String> variantsJson = GeneratedColumn<String>(
    'variants_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _videoUrlMeta = const VerificationMeta(
    'videoUrl',
  );
  @override
  late final GeneratedColumn<String> videoUrl = GeneratedColumn<String>(
    'video_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _videoAuthorNameMeta = const VerificationMeta(
    'videoAuthorName',
  );
  @override
  late final GeneratedColumn<String> videoAuthorName = GeneratedColumn<String>(
    'video_author_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _authorPageUrlMeta = const VerificationMeta(
    'authorPageUrl',
  );
  @override
  late final GeneratedColumn<String> authorPageUrl = GeneratedColumn<String>(
    'author_page_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deprecatedMeta = const VerificationMeta(
    'deprecated',
  );
  @override
  late final GeneratedColumn<bool> deprecated = GeneratedColumn<bool>(
    'deprecated',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deprecated" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    origin,
    type,
    allowedStagesJson,
    allowedLevelsJson,
    allowedIntensitiesJson,
    emphasesJson,
    loadCharacter,
    variantsJson,
    videoUrl,
    videoAuthorName,
    authorPageUrl,
    deprecated,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    } else if (isInserting) {
      context.missing(_originMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('allowed_stages_json')) {
      context.handle(
        _allowedStagesJsonMeta,
        allowedStagesJson.isAcceptableOrUnknown(
          data['allowed_stages_json']!,
          _allowedStagesJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_allowedStagesJsonMeta);
    }
    if (data.containsKey('allowed_levels_json')) {
      context.handle(
        _allowedLevelsJsonMeta,
        allowedLevelsJson.isAcceptableOrUnknown(
          data['allowed_levels_json']!,
          _allowedLevelsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_allowedLevelsJsonMeta);
    }
    if (data.containsKey('allowed_intensities_json')) {
      context.handle(
        _allowedIntensitiesJsonMeta,
        allowedIntensitiesJson.isAcceptableOrUnknown(
          data['allowed_intensities_json']!,
          _allowedIntensitiesJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_allowedIntensitiesJsonMeta);
    }
    if (data.containsKey('emphases_json')) {
      context.handle(
        _emphasesJsonMeta,
        emphasesJson.isAcceptableOrUnknown(
          data['emphases_json']!,
          _emphasesJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_emphasesJsonMeta);
    }
    if (data.containsKey('load_character')) {
      context.handle(
        _loadCharacterMeta,
        loadCharacter.isAcceptableOrUnknown(
          data['load_character']!,
          _loadCharacterMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_loadCharacterMeta);
    }
    if (data.containsKey('variants_json')) {
      context.handle(
        _variantsJsonMeta,
        variantsJson.isAcceptableOrUnknown(
          data['variants_json']!,
          _variantsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_variantsJsonMeta);
    }
    if (data.containsKey('video_url')) {
      context.handle(
        _videoUrlMeta,
        videoUrl.isAcceptableOrUnknown(data['video_url']!, _videoUrlMeta),
      );
    }
    if (data.containsKey('video_author_name')) {
      context.handle(
        _videoAuthorNameMeta,
        videoAuthorName.isAcceptableOrUnknown(
          data['video_author_name']!,
          _videoAuthorNameMeta,
        ),
      );
    }
    if (data.containsKey('author_page_url')) {
      context.handle(
        _authorPageUrlMeta,
        authorPageUrl.isAcceptableOrUnknown(
          data['author_page_url']!,
          _authorPageUrlMeta,
        ),
      );
    }
    if (data.containsKey('deprecated')) {
      context.handle(
        _deprecatedMeta,
        deprecated.isAcceptableOrUnknown(data['deprecated']!, _deprecatedMeta),
      );
    } else if (isInserting) {
      context.missing(_deprecatedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExerciseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      allowedStagesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}allowed_stages_json'],
      )!,
      allowedLevelsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}allowed_levels_json'],
      )!,
      allowedIntensitiesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}allowed_intensities_json'],
      )!,
      emphasesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emphases_json'],
      )!,
      loadCharacter: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}load_character'],
      )!,
      variantsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}variants_json'],
      )!,
      videoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}video_url'],
      ),
      videoAuthorName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}video_author_name'],
      ),
      authorPageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_page_url'],
      ),
      deprecated: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deprecated'],
      )!,
    );
  }

  @override
  $ExercisesTable createAlias(String alias) {
    return $ExercisesTable(attachedDatabase, alias);
  }
}

class ExerciseRow extends DataClass implements Insertable<ExerciseRow> {
  final String id;
  final String name;
  final String description;

  /// `initial` | `custom`.
  final String origin;

  /// `simple` | `single-punch` | `combination`.
  final String type;

  /// JSON array of stage wire values.
  final String allowedStagesJson;

  /// JSON arrays of dictionary ids.
  final String allowedLevelsJson;
  final String allowedIntensitiesJson;
  final String emphasesJson;

  /// `general-physical` | `special-physical` | `not-applicable` (D-34).
  final String loadCharacter;

  /// JSON array of variants with ids stable within the exercise (D-33).
  final String variantsJson;
  final String? videoUrl;
  final String? videoAuthorName;
  final String? authorPageUrl;

  /// Deprecated initial exercise (D-06).
  final bool deprecated;
  const ExerciseRow({
    required this.id,
    required this.name,
    required this.description,
    required this.origin,
    required this.type,
    required this.allowedStagesJson,
    required this.allowedLevelsJson,
    required this.allowedIntensitiesJson,
    required this.emphasesJson,
    required this.loadCharacter,
    required this.variantsJson,
    this.videoUrl,
    this.videoAuthorName,
    this.authorPageUrl,
    required this.deprecated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    map['origin'] = Variable<String>(origin);
    map['type'] = Variable<String>(type);
    map['allowed_stages_json'] = Variable<String>(allowedStagesJson);
    map['allowed_levels_json'] = Variable<String>(allowedLevelsJson);
    map['allowed_intensities_json'] = Variable<String>(allowedIntensitiesJson);
    map['emphases_json'] = Variable<String>(emphasesJson);
    map['load_character'] = Variable<String>(loadCharacter);
    map['variants_json'] = Variable<String>(variantsJson);
    if (!nullToAbsent || videoUrl != null) {
      map['video_url'] = Variable<String>(videoUrl);
    }
    if (!nullToAbsent || videoAuthorName != null) {
      map['video_author_name'] = Variable<String>(videoAuthorName);
    }
    if (!nullToAbsent || authorPageUrl != null) {
      map['author_page_url'] = Variable<String>(authorPageUrl);
    }
    map['deprecated'] = Variable<bool>(deprecated);
    return map;
  }

  ExercisesCompanion toCompanion(bool nullToAbsent) {
    return ExercisesCompanion(
      id: Value(id),
      name: Value(name),
      description: Value(description),
      origin: Value(origin),
      type: Value(type),
      allowedStagesJson: Value(allowedStagesJson),
      allowedLevelsJson: Value(allowedLevelsJson),
      allowedIntensitiesJson: Value(allowedIntensitiesJson),
      emphasesJson: Value(emphasesJson),
      loadCharacter: Value(loadCharacter),
      variantsJson: Value(variantsJson),
      videoUrl: videoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(videoUrl),
      videoAuthorName: videoAuthorName == null && nullToAbsent
          ? const Value.absent()
          : Value(videoAuthorName),
      authorPageUrl: authorPageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(authorPageUrl),
      deprecated: Value(deprecated),
    );
  }

  factory ExerciseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      origin: serializer.fromJson<String>(json['origin']),
      type: serializer.fromJson<String>(json['type']),
      allowedStagesJson: serializer.fromJson<String>(json['allowedStagesJson']),
      allowedLevelsJson: serializer.fromJson<String>(json['allowedLevelsJson']),
      allowedIntensitiesJson: serializer.fromJson<String>(
        json['allowedIntensitiesJson'],
      ),
      emphasesJson: serializer.fromJson<String>(json['emphasesJson']),
      loadCharacter: serializer.fromJson<String>(json['loadCharacter']),
      variantsJson: serializer.fromJson<String>(json['variantsJson']),
      videoUrl: serializer.fromJson<String?>(json['videoUrl']),
      videoAuthorName: serializer.fromJson<String?>(json['videoAuthorName']),
      authorPageUrl: serializer.fromJson<String?>(json['authorPageUrl']),
      deprecated: serializer.fromJson<bool>(json['deprecated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'origin': serializer.toJson<String>(origin),
      'type': serializer.toJson<String>(type),
      'allowedStagesJson': serializer.toJson<String>(allowedStagesJson),
      'allowedLevelsJson': serializer.toJson<String>(allowedLevelsJson),
      'allowedIntensitiesJson': serializer.toJson<String>(
        allowedIntensitiesJson,
      ),
      'emphasesJson': serializer.toJson<String>(emphasesJson),
      'loadCharacter': serializer.toJson<String>(loadCharacter),
      'variantsJson': serializer.toJson<String>(variantsJson),
      'videoUrl': serializer.toJson<String?>(videoUrl),
      'videoAuthorName': serializer.toJson<String?>(videoAuthorName),
      'authorPageUrl': serializer.toJson<String?>(authorPageUrl),
      'deprecated': serializer.toJson<bool>(deprecated),
    };
  }

  ExerciseRow copyWith({
    String? id,
    String? name,
    String? description,
    String? origin,
    String? type,
    String? allowedStagesJson,
    String? allowedLevelsJson,
    String? allowedIntensitiesJson,
    String? emphasesJson,
    String? loadCharacter,
    String? variantsJson,
    Value<String?> videoUrl = const Value.absent(),
    Value<String?> videoAuthorName = const Value.absent(),
    Value<String?> authorPageUrl = const Value.absent(),
    bool? deprecated,
  }) => ExerciseRow(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    origin: origin ?? this.origin,
    type: type ?? this.type,
    allowedStagesJson: allowedStagesJson ?? this.allowedStagesJson,
    allowedLevelsJson: allowedLevelsJson ?? this.allowedLevelsJson,
    allowedIntensitiesJson:
        allowedIntensitiesJson ?? this.allowedIntensitiesJson,
    emphasesJson: emphasesJson ?? this.emphasesJson,
    loadCharacter: loadCharacter ?? this.loadCharacter,
    variantsJson: variantsJson ?? this.variantsJson,
    videoUrl: videoUrl.present ? videoUrl.value : this.videoUrl,
    videoAuthorName: videoAuthorName.present
        ? videoAuthorName.value
        : this.videoAuthorName,
    authorPageUrl: authorPageUrl.present
        ? authorPageUrl.value
        : this.authorPageUrl,
    deprecated: deprecated ?? this.deprecated,
  );
  ExerciseRow copyWithCompanion(ExercisesCompanion data) {
    return ExerciseRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      origin: data.origin.present ? data.origin.value : this.origin,
      type: data.type.present ? data.type.value : this.type,
      allowedStagesJson: data.allowedStagesJson.present
          ? data.allowedStagesJson.value
          : this.allowedStagesJson,
      allowedLevelsJson: data.allowedLevelsJson.present
          ? data.allowedLevelsJson.value
          : this.allowedLevelsJson,
      allowedIntensitiesJson: data.allowedIntensitiesJson.present
          ? data.allowedIntensitiesJson.value
          : this.allowedIntensitiesJson,
      emphasesJson: data.emphasesJson.present
          ? data.emphasesJson.value
          : this.emphasesJson,
      loadCharacter: data.loadCharacter.present
          ? data.loadCharacter.value
          : this.loadCharacter,
      variantsJson: data.variantsJson.present
          ? data.variantsJson.value
          : this.variantsJson,
      videoUrl: data.videoUrl.present ? data.videoUrl.value : this.videoUrl,
      videoAuthorName: data.videoAuthorName.present
          ? data.videoAuthorName.value
          : this.videoAuthorName,
      authorPageUrl: data.authorPageUrl.present
          ? data.authorPageUrl.value
          : this.authorPageUrl,
      deprecated: data.deprecated.present
          ? data.deprecated.value
          : this.deprecated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('origin: $origin, ')
          ..write('type: $type, ')
          ..write('allowedStagesJson: $allowedStagesJson, ')
          ..write('allowedLevelsJson: $allowedLevelsJson, ')
          ..write('allowedIntensitiesJson: $allowedIntensitiesJson, ')
          ..write('emphasesJson: $emphasesJson, ')
          ..write('loadCharacter: $loadCharacter, ')
          ..write('variantsJson: $variantsJson, ')
          ..write('videoUrl: $videoUrl, ')
          ..write('videoAuthorName: $videoAuthorName, ')
          ..write('authorPageUrl: $authorPageUrl, ')
          ..write('deprecated: $deprecated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    origin,
    type,
    allowedStagesJson,
    allowedLevelsJson,
    allowedIntensitiesJson,
    emphasesJson,
    loadCharacter,
    variantsJson,
    videoUrl,
    videoAuthorName,
    authorPageUrl,
    deprecated,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.origin == this.origin &&
          other.type == this.type &&
          other.allowedStagesJson == this.allowedStagesJson &&
          other.allowedLevelsJson == this.allowedLevelsJson &&
          other.allowedIntensitiesJson == this.allowedIntensitiesJson &&
          other.emphasesJson == this.emphasesJson &&
          other.loadCharacter == this.loadCharacter &&
          other.variantsJson == this.variantsJson &&
          other.videoUrl == this.videoUrl &&
          other.videoAuthorName == this.videoAuthorName &&
          other.authorPageUrl == this.authorPageUrl &&
          other.deprecated == this.deprecated);
}

class ExercisesCompanion extends UpdateCompanion<ExerciseRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> description;
  final Value<String> origin;
  final Value<String> type;
  final Value<String> allowedStagesJson;
  final Value<String> allowedLevelsJson;
  final Value<String> allowedIntensitiesJson;
  final Value<String> emphasesJson;
  final Value<String> loadCharacter;
  final Value<String> variantsJson;
  final Value<String?> videoUrl;
  final Value<String?> videoAuthorName;
  final Value<String?> authorPageUrl;
  final Value<bool> deprecated;
  final Value<int> rowid;
  const ExercisesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.origin = const Value.absent(),
    this.type = const Value.absent(),
    this.allowedStagesJson = const Value.absent(),
    this.allowedLevelsJson = const Value.absent(),
    this.allowedIntensitiesJson = const Value.absent(),
    this.emphasesJson = const Value.absent(),
    this.loadCharacter = const Value.absent(),
    this.variantsJson = const Value.absent(),
    this.videoUrl = const Value.absent(),
    this.videoAuthorName = const Value.absent(),
    this.authorPageUrl = const Value.absent(),
    this.deprecated = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExercisesCompanion.insert({
    required String id,
    required String name,
    required String description,
    required String origin,
    required String type,
    required String allowedStagesJson,
    required String allowedLevelsJson,
    required String allowedIntensitiesJson,
    required String emphasesJson,
    required String loadCharacter,
    required String variantsJson,
    this.videoUrl = const Value.absent(),
    this.videoAuthorName = const Value.absent(),
    this.authorPageUrl = const Value.absent(),
    required bool deprecated,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       description = Value(description),
       origin = Value(origin),
       type = Value(type),
       allowedStagesJson = Value(allowedStagesJson),
       allowedLevelsJson = Value(allowedLevelsJson),
       allowedIntensitiesJson = Value(allowedIntensitiesJson),
       emphasesJson = Value(emphasesJson),
       loadCharacter = Value(loadCharacter),
       variantsJson = Value(variantsJson),
       deprecated = Value(deprecated);
  static Insertable<ExerciseRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? origin,
    Expression<String>? type,
    Expression<String>? allowedStagesJson,
    Expression<String>? allowedLevelsJson,
    Expression<String>? allowedIntensitiesJson,
    Expression<String>? emphasesJson,
    Expression<String>? loadCharacter,
    Expression<String>? variantsJson,
    Expression<String>? videoUrl,
    Expression<String>? videoAuthorName,
    Expression<String>? authorPageUrl,
    Expression<bool>? deprecated,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (origin != null) 'origin': origin,
      if (type != null) 'type': type,
      if (allowedStagesJson != null) 'allowed_stages_json': allowedStagesJson,
      if (allowedLevelsJson != null) 'allowed_levels_json': allowedLevelsJson,
      if (allowedIntensitiesJson != null)
        'allowed_intensities_json': allowedIntensitiesJson,
      if (emphasesJson != null) 'emphases_json': emphasesJson,
      if (loadCharacter != null) 'load_character': loadCharacter,
      if (variantsJson != null) 'variants_json': variantsJson,
      if (videoUrl != null) 'video_url': videoUrl,
      if (videoAuthorName != null) 'video_author_name': videoAuthorName,
      if (authorPageUrl != null) 'author_page_url': authorPageUrl,
      if (deprecated != null) 'deprecated': deprecated,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExercisesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? description,
    Value<String>? origin,
    Value<String>? type,
    Value<String>? allowedStagesJson,
    Value<String>? allowedLevelsJson,
    Value<String>? allowedIntensitiesJson,
    Value<String>? emphasesJson,
    Value<String>? loadCharacter,
    Value<String>? variantsJson,
    Value<String?>? videoUrl,
    Value<String?>? videoAuthorName,
    Value<String?>? authorPageUrl,
    Value<bool>? deprecated,
    Value<int>? rowid,
  }) {
    return ExercisesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      origin: origin ?? this.origin,
      type: type ?? this.type,
      allowedStagesJson: allowedStagesJson ?? this.allowedStagesJson,
      allowedLevelsJson: allowedLevelsJson ?? this.allowedLevelsJson,
      allowedIntensitiesJson:
          allowedIntensitiesJson ?? this.allowedIntensitiesJson,
      emphasesJson: emphasesJson ?? this.emphasesJson,
      loadCharacter: loadCharacter ?? this.loadCharacter,
      variantsJson: variantsJson ?? this.variantsJson,
      videoUrl: videoUrl ?? this.videoUrl,
      videoAuthorName: videoAuthorName ?? this.videoAuthorName,
      authorPageUrl: authorPageUrl ?? this.authorPageUrl,
      deprecated: deprecated ?? this.deprecated,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (allowedStagesJson.present) {
      map['allowed_stages_json'] = Variable<String>(allowedStagesJson.value);
    }
    if (allowedLevelsJson.present) {
      map['allowed_levels_json'] = Variable<String>(allowedLevelsJson.value);
    }
    if (allowedIntensitiesJson.present) {
      map['allowed_intensities_json'] = Variable<String>(
        allowedIntensitiesJson.value,
      );
    }
    if (emphasesJson.present) {
      map['emphases_json'] = Variable<String>(emphasesJson.value);
    }
    if (loadCharacter.present) {
      map['load_character'] = Variable<String>(loadCharacter.value);
    }
    if (variantsJson.present) {
      map['variants_json'] = Variable<String>(variantsJson.value);
    }
    if (videoUrl.present) {
      map['video_url'] = Variable<String>(videoUrl.value);
    }
    if (videoAuthorName.present) {
      map['video_author_name'] = Variable<String>(videoAuthorName.value);
    }
    if (authorPageUrl.present) {
      map['author_page_url'] = Variable<String>(authorPageUrl.value);
    }
    if (deprecated.present) {
      map['deprecated'] = Variable<bool>(deprecated.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExercisesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('origin: $origin, ')
          ..write('type: $type, ')
          ..write('allowedStagesJson: $allowedStagesJson, ')
          ..write('allowedLevelsJson: $allowedLevelsJson, ')
          ..write('allowedIntensitiesJson: $allowedIntensitiesJson, ')
          ..write('emphasesJson: $emphasesJson, ')
          ..write('loadCharacter: $loadCharacter, ')
          ..write('variantsJson: $variantsJson, ')
          ..write('videoUrl: $videoUrl, ')
          ..write('videoAuthorName: $videoAuthorName, ')
          ..write('authorPageUrl: $authorPageUrl, ')
          ..write('deprecated: $deprecated, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CatalogMetaTable extends CatalogMeta
    with TableInfo<$CatalogMetaTable, CatalogMetaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalog_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatalogMetaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  CatalogMetaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogMetaRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $CatalogMetaTable createAlias(String alias) {
    return $CatalogMetaTable(attachedDatabase, alias);
  }
}

class CatalogMetaRow extends DataClass implements Insertable<CatalogMetaRow> {
  final String key;
  final String value;
  const CatalogMetaRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  CatalogMetaCompanion toCompanion(bool nullToAbsent) {
    return CatalogMetaCompanion(key: Value(key), value: Value(value));
  }

  factory CatalogMetaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogMetaRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  CatalogMetaRow copyWith({String? key, String? value}) =>
      CatalogMetaRow(key: key ?? this.key, value: value ?? this.value);
  CatalogMetaRow copyWithCompanion(CatalogMetaCompanion data) {
    return CatalogMetaRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogMetaRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogMetaRow &&
          other.key == this.key &&
          other.value == this.value);
}

class CatalogMetaCompanion extends UpdateCompanion<CatalogMetaRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const CatalogMetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatalogMetaCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<CatalogMetaRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatalogMetaCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return CatalogMetaCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatalogMetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrainingPlansTable extends TrainingPlans
    with TableInfo<$TrainingPlansTable, TrainingPlanRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrainingPlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modifiedAtMeta = const VerificationMeta(
    'modifiedAt',
  );
  @override
  late final GeneratedColumn<DateTime> modifiedAt = GeneratedColumn<DateTime>(
    'modified_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _generationParametersJsonMeta =
      const VerificationMeta('generationParametersJson');
  @override
  late final GeneratedColumn<String> generationParametersJson =
      GeneratedColumn<String>(
        'generation_parameters_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _stagesJsonMeta = const VerificationMeta(
    'stagesJson',
  );
  @override
  late final GeneratedColumn<String> stagesJson = GeneratedColumn<String>(
    'stages_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _warningsJsonMeta = const VerificationMeta(
    'warningsJson',
  );
  @override
  late final GeneratedColumn<String> warningsJson = GeneratedColumn<String>(
    'warnings_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    modifiedAt,
    generationParametersJson,
    stagesJson,
    warningsJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'training_plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrainingPlanRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('modified_at')) {
      context.handle(
        _modifiedAtMeta,
        modifiedAt.isAcceptableOrUnknown(data['modified_at']!, _modifiedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_modifiedAtMeta);
    }
    if (data.containsKey('generation_parameters_json')) {
      context.handle(
        _generationParametersJsonMeta,
        generationParametersJson.isAcceptableOrUnknown(
          data['generation_parameters_json']!,
          _generationParametersJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_generationParametersJsonMeta);
    }
    if (data.containsKey('stages_json')) {
      context.handle(
        _stagesJsonMeta,
        stagesJson.isAcceptableOrUnknown(data['stages_json']!, _stagesJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_stagesJsonMeta);
    }
    if (data.containsKey('warnings_json')) {
      context.handle(
        _warningsJsonMeta,
        warningsJson.isAcceptableOrUnknown(
          data['warnings_json']!,
          _warningsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_warningsJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrainingPlanRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrainingPlanRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      modifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}modified_at'],
      )!,
      generationParametersJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}generation_parameters_json'],
      )!,
      stagesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stages_json'],
      )!,
      warningsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}warnings_json'],
      )!,
    );
  }

  @override
  $TrainingPlansTable createAlias(String alias) {
    return $TrainingPlansTable(attachedDatabase, alias);
  }
}

class TrainingPlanRow extends DataClass implements Insertable<TrainingPlanRow> {
  final String id;
  final String name;

  /// Set on successful save or overwrite (SPEC-GATE v1.1, REV-009).
  final DateTime modifiedAt;

  /// JSON of the five generation parameters (D-14, D-31).
  final String generationParametersJson;

  /// JSON of three stages with item copies (SRS §4.5).
  final String stagesJson;

  /// JSON of the warnings at the moment of saving (AC-F-010, BDD-014): they
  /// are not recomputed from the catalog, so a catalog update does not
  /// rewrite a saved plan (AC-F-011, D-06).
  final String warningsJson;
  const TrainingPlanRow({
    required this.id,
    required this.name,
    required this.modifiedAt,
    required this.generationParametersJson,
    required this.stagesJson,
    required this.warningsJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['modified_at'] = Variable<DateTime>(modifiedAt);
    map['generation_parameters_json'] = Variable<String>(
      generationParametersJson,
    );
    map['stages_json'] = Variable<String>(stagesJson);
    map['warnings_json'] = Variable<String>(warningsJson);
    return map;
  }

  TrainingPlansCompanion toCompanion(bool nullToAbsent) {
    return TrainingPlansCompanion(
      id: Value(id),
      name: Value(name),
      modifiedAt: Value(modifiedAt),
      generationParametersJson: Value(generationParametersJson),
      stagesJson: Value(stagesJson),
      warningsJson: Value(warningsJson),
    );
  }

  factory TrainingPlanRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrainingPlanRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      modifiedAt: serializer.fromJson<DateTime>(json['modifiedAt']),
      generationParametersJson: serializer.fromJson<String>(
        json['generationParametersJson'],
      ),
      stagesJson: serializer.fromJson<String>(json['stagesJson']),
      warningsJson: serializer.fromJson<String>(json['warningsJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'modifiedAt': serializer.toJson<DateTime>(modifiedAt),
      'generationParametersJson': serializer.toJson<String>(
        generationParametersJson,
      ),
      'stagesJson': serializer.toJson<String>(stagesJson),
      'warningsJson': serializer.toJson<String>(warningsJson),
    };
  }

  TrainingPlanRow copyWith({
    String? id,
    String? name,
    DateTime? modifiedAt,
    String? generationParametersJson,
    String? stagesJson,
    String? warningsJson,
  }) => TrainingPlanRow(
    id: id ?? this.id,
    name: name ?? this.name,
    modifiedAt: modifiedAt ?? this.modifiedAt,
    generationParametersJson:
        generationParametersJson ?? this.generationParametersJson,
    stagesJson: stagesJson ?? this.stagesJson,
    warningsJson: warningsJson ?? this.warningsJson,
  );
  TrainingPlanRow copyWithCompanion(TrainingPlansCompanion data) {
    return TrainingPlanRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      modifiedAt: data.modifiedAt.present
          ? data.modifiedAt.value
          : this.modifiedAt,
      generationParametersJson: data.generationParametersJson.present
          ? data.generationParametersJson.value
          : this.generationParametersJson,
      stagesJson: data.stagesJson.present
          ? data.stagesJson.value
          : this.stagesJson,
      warningsJson: data.warningsJson.present
          ? data.warningsJson.value
          : this.warningsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrainingPlanRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('generationParametersJson: $generationParametersJson, ')
          ..write('stagesJson: $stagesJson, ')
          ..write('warningsJson: $warningsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    modifiedAt,
    generationParametersJson,
    stagesJson,
    warningsJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrainingPlanRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.modifiedAt == this.modifiedAt &&
          other.generationParametersJson == this.generationParametersJson &&
          other.stagesJson == this.stagesJson &&
          other.warningsJson == this.warningsJson);
}

class TrainingPlansCompanion extends UpdateCompanion<TrainingPlanRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> modifiedAt;
  final Value<String> generationParametersJson;
  final Value<String> stagesJson;
  final Value<String> warningsJson;
  final Value<int> rowid;
  const TrainingPlansCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.modifiedAt = const Value.absent(),
    this.generationParametersJson = const Value.absent(),
    this.stagesJson = const Value.absent(),
    this.warningsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrainingPlansCompanion.insert({
    required String id,
    required String name,
    required DateTime modifiedAt,
    required String generationParametersJson,
    required String stagesJson,
    required String warningsJson,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       modifiedAt = Value(modifiedAt),
       generationParametersJson = Value(generationParametersJson),
       stagesJson = Value(stagesJson),
       warningsJson = Value(warningsJson);
  static Insertable<TrainingPlanRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? modifiedAt,
    Expression<String>? generationParametersJson,
    Expression<String>? stagesJson,
    Expression<String>? warningsJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (modifiedAt != null) 'modified_at': modifiedAt,
      if (generationParametersJson != null)
        'generation_parameters_json': generationParametersJson,
      if (stagesJson != null) 'stages_json': stagesJson,
      if (warningsJson != null) 'warnings_json': warningsJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrainingPlansCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<DateTime>? modifiedAt,
    Value<String>? generationParametersJson,
    Value<String>? stagesJson,
    Value<String>? warningsJson,
    Value<int>? rowid,
  }) {
    return TrainingPlansCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      generationParametersJson:
          generationParametersJson ?? this.generationParametersJson,
      stagesJson: stagesJson ?? this.stagesJson,
      warningsJson: warningsJson ?? this.warningsJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (modifiedAt.present) {
      map['modified_at'] = Variable<DateTime>(modifiedAt.value);
    }
    if (generationParametersJson.present) {
      map['generation_parameters_json'] = Variable<String>(
        generationParametersJson.value,
      );
    }
    if (stagesJson.present) {
      map['stages_json'] = Variable<String>(stagesJson.value);
    }
    if (warningsJson.present) {
      map['warnings_json'] = Variable<String>(warningsJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrainingPlansCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('generationParametersJson: $generationParametersJson, ')
          ..write('stagesJson: $stagesJson, ')
          ..write('warningsJson: $warningsJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CompletedTrainingsTable extends CompletedTrainings
    with TableInfo<$CompletedTrainingsTable, CompletedTrainingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompletedTrainingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localStartDateMeta = const VerificationMeta(
    'localStartDate',
  );
  @override
  late final GeneratedColumn<String> localStartDate = GeneratedColumn<String>(
    'local_start_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _executedPlanJsonMeta = const VerificationMeta(
    'executedPlanJson',
  );
  @override
  late final GeneratedColumn<String> executedPlanJson = GeneratedColumn<String>(
    'executed_plan_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startedAt,
    localStartDate,
    executedPlanJson,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'completed_trainings';
  @override
  VerificationContext validateIntegrity(
    Insertable<CompletedTrainingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('local_start_date')) {
      context.handle(
        _localStartDateMeta,
        localStartDate.isAcceptableOrUnknown(
          data['local_start_date']!,
          _localStartDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localStartDateMeta);
    }
    if (data.containsKey('executed_plan_json')) {
      context.handle(
        _executedPlanJsonMeta,
        executedPlanJson.isAcceptableOrUnknown(
          data['executed_plan_json']!,
          _executedPlanJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_executedPlanJsonMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CompletedTrainingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CompletedTrainingRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      localStartDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_start_date'],
      )!,
      executedPlanJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}executed_plan_json'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $CompletedTrainingsTable createAlias(String alias) {
    return $CompletedTrainingsTable(attachedDatabase, alias);
  }
}

class CompletedTrainingRow extends DataClass
    implements Insertable<CompletedTrainingRow> {
  final String id;
  final DateTime startedAt;

  /// Local start date `YYYY-MM-DD` for analytics grouping.
  final String localStartDate;

  /// JSON copy of the executed plan (D-19, D-20).
  final String executedPlanJson;
  final String? note;
  const CompletedTrainingRow({
    required this.id,
    required this.startedAt,
    required this.localStartDate,
    required this.executedPlanJson,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['local_start_date'] = Variable<String>(localStartDate);
    map['executed_plan_json'] = Variable<String>(executedPlanJson);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  CompletedTrainingsCompanion toCompanion(bool nullToAbsent) {
    return CompletedTrainingsCompanion(
      id: Value(id),
      startedAt: Value(startedAt),
      localStartDate: Value(localStartDate),
      executedPlanJson: Value(executedPlanJson),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory CompletedTrainingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CompletedTrainingRow(
      id: serializer.fromJson<String>(json['id']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      localStartDate: serializer.fromJson<String>(json['localStartDate']),
      executedPlanJson: serializer.fromJson<String>(json['executedPlanJson']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'localStartDate': serializer.toJson<String>(localStartDate),
      'executedPlanJson': serializer.toJson<String>(executedPlanJson),
      'note': serializer.toJson<String?>(note),
    };
  }

  CompletedTrainingRow copyWith({
    String? id,
    DateTime? startedAt,
    String? localStartDate,
    String? executedPlanJson,
    Value<String?> note = const Value.absent(),
  }) => CompletedTrainingRow(
    id: id ?? this.id,
    startedAt: startedAt ?? this.startedAt,
    localStartDate: localStartDate ?? this.localStartDate,
    executedPlanJson: executedPlanJson ?? this.executedPlanJson,
    note: note.present ? note.value : this.note,
  );
  CompletedTrainingRow copyWithCompanion(CompletedTrainingsCompanion data) {
    return CompletedTrainingRow(
      id: data.id.present ? data.id.value : this.id,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      localStartDate: data.localStartDate.present
          ? data.localStartDate.value
          : this.localStartDate,
      executedPlanJson: data.executedPlanJson.present
          ? data.executedPlanJson.value
          : this.executedPlanJson,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CompletedTrainingRow(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('localStartDate: $localStartDate, ')
          ..write('executedPlanJson: $executedPlanJson, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, startedAt, localStartDate, executedPlanJson, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompletedTrainingRow &&
          other.id == this.id &&
          other.startedAt == this.startedAt &&
          other.localStartDate == this.localStartDate &&
          other.executedPlanJson == this.executedPlanJson &&
          other.note == this.note);
}

class CompletedTrainingsCompanion
    extends UpdateCompanion<CompletedTrainingRow> {
  final Value<String> id;
  final Value<DateTime> startedAt;
  final Value<String> localStartDate;
  final Value<String> executedPlanJson;
  final Value<String?> note;
  final Value<int> rowid;
  const CompletedTrainingsCompanion({
    this.id = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.localStartDate = const Value.absent(),
    this.executedPlanJson = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CompletedTrainingsCompanion.insert({
    required String id,
    required DateTime startedAt,
    required String localStartDate,
    required String executedPlanJson,
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       startedAt = Value(startedAt),
       localStartDate = Value(localStartDate),
       executedPlanJson = Value(executedPlanJson);
  static Insertable<CompletedTrainingRow> custom({
    Expression<String>? id,
    Expression<DateTime>? startedAt,
    Expression<String>? localStartDate,
    Expression<String>? executedPlanJson,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedAt != null) 'started_at': startedAt,
      if (localStartDate != null) 'local_start_date': localStartDate,
      if (executedPlanJson != null) 'executed_plan_json': executedPlanJson,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CompletedTrainingsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? startedAt,
    Value<String>? localStartDate,
    Value<String>? executedPlanJson,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return CompletedTrainingsCompanion(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      localStartDate: localStartDate ?? this.localStartDate,
      executedPlanJson: executedPlanJson ?? this.executedPlanJson,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (localStartDate.present) {
      map['local_start_date'] = Variable<String>(localStartDate.value);
    }
    if (executedPlanJson.present) {
      map['executed_plan_json'] = Variable<String>(executedPlanJson.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompletedTrainingsCompanion(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('localStartDate: $localStartDate, ')
          ..write('executedPlanJson: $executedPlanJson, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ExercisesTable exercises = $ExercisesTable(this);
  late final $CatalogMetaTable catalogMeta = $CatalogMetaTable(this);
  late final $TrainingPlansTable trainingPlans = $TrainingPlansTable(this);
  late final $CompletedTrainingsTable completedTrainings =
      $CompletedTrainingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    exercises,
    catalogMeta,
    trainingPlans,
    completedTrainings,
  ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$ExercisesTableCreateCompanionBuilder = ExercisesCompanion Function({
  required String id,
  required String name,
  required String description,
  required String origin,
  required String type,
  required String allowedStagesJson,
  required String allowedLevelsJson,
  required String allowedIntensitiesJson,
  required String emphasesJson,
  required String loadCharacter,
  required String variantsJson,
  Value<String?> videoUrl,
  Value<String?> videoAuthorName,
  Value<String?> authorPageUrl,
  required bool deprecated,
  Value<int> rowid,
});
typedef $$ExercisesTableUpdateCompanionBuilder = ExercisesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> description,
  Value<String> origin,
  Value<String> type,
  Value<String> allowedStagesJson,
  Value<String> allowedLevelsJson,
  Value<String> allowedIntensitiesJson,
  Value<String> emphasesJson,
  Value<String> loadCharacter,
  Value<String> variantsJson,
  Value<String?> videoUrl,
  Value<String?> videoAuthorName,
  Value<String?> authorPageUrl,
  Value<bool> deprecated,
  Value<int> rowid,
});

class $$ExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get allowedStagesJson => $composableBuilder(
    column: $table.allowedStagesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get allowedLevelsJson => $composableBuilder(
    column: $table.allowedLevelsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get allowedIntensitiesJson => $composableBuilder(
    column: $table.allowedIntensitiesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emphasesJson => $composableBuilder(
    column: $table.emphasesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get loadCharacter => $composableBuilder(
    column: $table.loadCharacter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get variantsJson => $composableBuilder(
    column: $table.variantsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get videoUrl => $composableBuilder(
    column: $table.videoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get videoAuthorName => $composableBuilder(
    column: $table.videoAuthorName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorPageUrl => $composableBuilder(
    column: $table.authorPageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deprecated => $composableBuilder(
    column: $table.deprecated,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get allowedStagesJson => $composableBuilder(
    column: $table.allowedStagesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get allowedLevelsJson => $composableBuilder(
    column: $table.allowedLevelsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get allowedIntensitiesJson => $composableBuilder(
    column: $table.allowedIntensitiesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emphasesJson => $composableBuilder(
    column: $table.emphasesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get loadCharacter => $composableBuilder(
    column: $table.loadCharacter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get variantsJson => $composableBuilder(
    column: $table.variantsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get videoUrl => $composableBuilder(
    column: $table.videoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get videoAuthorName => $composableBuilder(
    column: $table.videoAuthorName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorPageUrl => $composableBuilder(
    column: $table.authorPageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deprecated => $composableBuilder(
    column: $table.deprecated,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get allowedStagesJson => $composableBuilder(
    column: $table.allowedStagesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get allowedLevelsJson => $composableBuilder(
    column: $table.allowedLevelsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get allowedIntensitiesJson => $composableBuilder(
    column: $table.allowedIntensitiesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get emphasesJson => $composableBuilder(
    column: $table.emphasesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get loadCharacter => $composableBuilder(
    column: $table.loadCharacter,
    builder: (column) => column,
  );

  GeneratedColumn<String> get variantsJson => $composableBuilder(
    column: $table.variantsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get videoUrl =>
      $composableBuilder(column: $table.videoUrl, builder: (column) => column);

  GeneratedColumn<String> get videoAuthorName => $composableBuilder(
    column: $table.videoAuthorName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get authorPageUrl => $composableBuilder(
    column: $table.authorPageUrl,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get deprecated => $composableBuilder(
    column: $table.deprecated,
    builder: (column) => column,
  );
}

class $$ExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExercisesTable,
          ExerciseRow,
          $$ExercisesTableFilterComposer,
          $$ExercisesTableOrderingComposer,
          $$ExercisesTableAnnotationComposer,
          $$ExercisesTableCreateCompanionBuilder,
          $$ExercisesTableUpdateCompanionBuilder,
          (
            ExerciseRow,
            BaseReferences<_$AppDatabase, $ExercisesTable, ExerciseRow>,
          ),
          ExerciseRow,
          PrefetchHooks Function()
        > {
  $$ExercisesTableTableManager(_$AppDatabase db, $ExercisesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> allowedStagesJson = const Value.absent(),
                Value<String> allowedLevelsJson = const Value.absent(),
                Value<String> allowedIntensitiesJson = const Value.absent(),
                Value<String> emphasesJson = const Value.absent(),
                Value<String> loadCharacter = const Value.absent(),
                Value<String> variantsJson = const Value.absent(),
                Value<String?> videoUrl = const Value.absent(),
                Value<String?> videoAuthorName = const Value.absent(),
                Value<String?> authorPageUrl = const Value.absent(),
                Value<bool> deprecated = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExercisesCompanion(
                id: id,
                name: name,
                description: description,
                origin: origin,
                type: type,
                allowedStagesJson: allowedStagesJson,
                allowedLevelsJson: allowedLevelsJson,
                allowedIntensitiesJson: allowedIntensitiesJson,
                emphasesJson: emphasesJson,
                loadCharacter: loadCharacter,
                variantsJson: variantsJson,
                videoUrl: videoUrl,
                videoAuthorName: videoAuthorName,
                authorPageUrl: authorPageUrl,
                deprecated: deprecated,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String description,
                required String origin,
                required String type,
                required String allowedStagesJson,
                required String allowedLevelsJson,
                required String allowedIntensitiesJson,
                required String emphasesJson,
                required String loadCharacter,
                required String variantsJson,
                Value<String?> videoUrl = const Value.absent(),
                Value<String?> videoAuthorName = const Value.absent(),
                Value<String?> authorPageUrl = const Value.absent(),
                required bool deprecated,
                Value<int> rowid = const Value.absent(),
              }) => ExercisesCompanion.insert(
                id: id,
                name: name,
                description: description,
                origin: origin,
                type: type,
                allowedStagesJson: allowedStagesJson,
                allowedLevelsJson: allowedLevelsJson,
                allowedIntensitiesJson: allowedIntensitiesJson,
                emphasesJson: emphasesJson,
                loadCharacter: loadCharacter,
                variantsJson: variantsJson,
                videoUrl: videoUrl,
                videoAuthorName: videoAuthorName,
                authorPageUrl: authorPageUrl,
                deprecated: deprecated,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExercisesTable, ExerciseRow>(table),
                  BaseReferences<_$AppDatabase, $ExercisesTable, ExerciseRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExercisesTable,
      ExerciseRow,
      $$ExercisesTableFilterComposer,
      $$ExercisesTableOrderingComposer,
      $$ExercisesTableAnnotationComposer,
      $$ExercisesTableCreateCompanionBuilder,
      $$ExercisesTableUpdateCompanionBuilder,
      (
        ExerciseRow,
        BaseReferences<_$AppDatabase, $ExercisesTable, ExerciseRow>,
      ),
      ExerciseRow,
      PrefetchHooks Function()
    >;
typedef $$CatalogMetaTableCreateCompanionBuilder =
    CatalogMetaCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$CatalogMetaTableUpdateCompanionBuilder =
    CatalogMetaCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$CatalogMetaTableFilterComposer
    extends Composer<_$AppDatabase, $CatalogMetaTable> {
  $$CatalogMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CatalogMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $CatalogMetaTable> {
  $$CatalogMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CatalogMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $CatalogMetaTable> {
  $$CatalogMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$CatalogMetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CatalogMetaTable,
          CatalogMetaRow,
          $$CatalogMetaTableFilterComposer,
          $$CatalogMetaTableOrderingComposer,
          $$CatalogMetaTableAnnotationComposer,
          $$CatalogMetaTableCreateCompanionBuilder,
          $$CatalogMetaTableUpdateCompanionBuilder,
          (
            CatalogMetaRow,
            BaseReferences<_$AppDatabase, $CatalogMetaTable, CatalogMetaRow>,
          ),
          CatalogMetaRow,
          PrefetchHooks Function()
        > {
  $$CatalogMetaTableTableManager(_$AppDatabase db, $CatalogMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatalogMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatalogMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => CatalogMetaCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => CatalogMetaCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CatalogMetaTable, CatalogMetaRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CatalogMetaTable,
                    CatalogMetaRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CatalogMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CatalogMetaTable,
      CatalogMetaRow,
      $$CatalogMetaTableFilterComposer,
      $$CatalogMetaTableOrderingComposer,
      $$CatalogMetaTableAnnotationComposer,
      $$CatalogMetaTableCreateCompanionBuilder,
      $$CatalogMetaTableUpdateCompanionBuilder,
      (
        CatalogMetaRow,
        BaseReferences<_$AppDatabase, $CatalogMetaTable, CatalogMetaRow>,
      ),
      CatalogMetaRow,
      PrefetchHooks Function()
    >;
typedef $$TrainingPlansTableCreateCompanionBuilder =
    TrainingPlansCompanion Function({
      required String id,
      required String name,
      required DateTime modifiedAt,
      required String generationParametersJson,
      required String stagesJson,
      required String warningsJson,
      Value<int> rowid,
    });
typedef $$TrainingPlansTableUpdateCompanionBuilder =
    TrainingPlansCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<DateTime> modifiedAt,
      Value<String> generationParametersJson,
      Value<String> stagesJson,
      Value<String> warningsJson,
      Value<int> rowid,
    });

class $$TrainingPlansTableFilterComposer
    extends Composer<_$AppDatabase, $TrainingPlansTable> {
  $$TrainingPlansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get generationParametersJson => $composableBuilder(
    column: $table.generationParametersJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stagesJson => $composableBuilder(
    column: $table.stagesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get warningsJson => $composableBuilder(
    column: $table.warningsJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TrainingPlansTableOrderingComposer
    extends Composer<_$AppDatabase, $TrainingPlansTable> {
  $$TrainingPlansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get generationParametersJson => $composableBuilder(
    column: $table.generationParametersJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stagesJson => $composableBuilder(
    column: $table.stagesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get warningsJson => $composableBuilder(
    column: $table.warningsJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TrainingPlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrainingPlansTable> {
  $$TrainingPlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get generationParametersJson => $composableBuilder(
    column: $table.generationParametersJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get stagesJson => $composableBuilder(
    column: $table.stagesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get warningsJson => $composableBuilder(
    column: $table.warningsJson,
    builder: (column) => column,
  );
}

class $$TrainingPlansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TrainingPlansTable,
          TrainingPlanRow,
          $$TrainingPlansTableFilterComposer,
          $$TrainingPlansTableOrderingComposer,
          $$TrainingPlansTableAnnotationComposer,
          $$TrainingPlansTableCreateCompanionBuilder,
          $$TrainingPlansTableUpdateCompanionBuilder,
          (
            TrainingPlanRow,
            BaseReferences<_$AppDatabase, $TrainingPlansTable, TrainingPlanRow>,
          ),
          TrainingPlanRow,
          PrefetchHooks Function()
        > {
  $$TrainingPlansTableTableManager(_$AppDatabase db, $TrainingPlansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrainingPlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrainingPlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrainingPlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> modifiedAt = const Value.absent(),
                Value<String> generationParametersJson = const Value.absent(),
                Value<String> stagesJson = const Value.absent(),
                Value<String> warningsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrainingPlansCompanion(
                id: id,
                name: name,
                modifiedAt: modifiedAt,
                generationParametersJson: generationParametersJson,
                stagesJson: stagesJson,
                warningsJson: warningsJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required DateTime modifiedAt,
                required String generationParametersJson,
                required String stagesJson,
                required String warningsJson,
                Value<int> rowid = const Value.absent(),
              }) => TrainingPlansCompanion.insert(
                id: id,
                name: name,
                modifiedAt: modifiedAt,
                generationParametersJson: generationParametersJson,
                stagesJson: stagesJson,
                warningsJson: warningsJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TrainingPlansTable, TrainingPlanRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $TrainingPlansTable,
                    TrainingPlanRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TrainingPlansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TrainingPlansTable,
      TrainingPlanRow,
      $$TrainingPlansTableFilterComposer,
      $$TrainingPlansTableOrderingComposer,
      $$TrainingPlansTableAnnotationComposer,
      $$TrainingPlansTableCreateCompanionBuilder,
      $$TrainingPlansTableUpdateCompanionBuilder,
      (
        TrainingPlanRow,
        BaseReferences<_$AppDatabase, $TrainingPlansTable, TrainingPlanRow>,
      ),
      TrainingPlanRow,
      PrefetchHooks Function()
    >;
typedef $$CompletedTrainingsTableCreateCompanionBuilder =
    CompletedTrainingsCompanion Function({
      required String id,
      required DateTime startedAt,
      required String localStartDate,
      required String executedPlanJson,
      Value<String?> note,
      Value<int> rowid,
    });
typedef $$CompletedTrainingsTableUpdateCompanionBuilder =
    CompletedTrainingsCompanion Function({
      Value<String> id,
      Value<DateTime> startedAt,
      Value<String> localStartDate,
      Value<String> executedPlanJson,
      Value<String?> note,
      Value<int> rowid,
    });

class $$CompletedTrainingsTableFilterComposer
    extends Composer<_$AppDatabase, $CompletedTrainingsTable> {
  $$CompletedTrainingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localStartDate => $composableBuilder(
    column: $table.localStartDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get executedPlanJson => $composableBuilder(
    column: $table.executedPlanJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CompletedTrainingsTableOrderingComposer
    extends Composer<_$AppDatabase, $CompletedTrainingsTable> {
  $$CompletedTrainingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localStartDate => $composableBuilder(
    column: $table.localStartDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get executedPlanJson => $composableBuilder(
    column: $table.executedPlanJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CompletedTrainingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CompletedTrainingsTable> {
  $$CompletedTrainingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<String> get localStartDate => $composableBuilder(
    column: $table.localStartDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get executedPlanJson => $composableBuilder(
    column: $table.executedPlanJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$CompletedTrainingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CompletedTrainingsTable,
          CompletedTrainingRow,
          $$CompletedTrainingsTableFilterComposer,
          $$CompletedTrainingsTableOrderingComposer,
          $$CompletedTrainingsTableAnnotationComposer,
          $$CompletedTrainingsTableCreateCompanionBuilder,
          $$CompletedTrainingsTableUpdateCompanionBuilder,
          (
            CompletedTrainingRow,
            BaseReferences<
              _$AppDatabase,
              $CompletedTrainingsTable,
              CompletedTrainingRow
            >,
          ),
          CompletedTrainingRow,
          PrefetchHooks Function()
        > {
  $$CompletedTrainingsTableTableManager(
    _$AppDatabase db,
    $CompletedTrainingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompletedTrainingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompletedTrainingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompletedTrainingsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<String> localStartDate = const Value.absent(),
                Value<String> executedPlanJson = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompletedTrainingsCompanion(
                id: id,
                startedAt: startedAt,
                localStartDate: localStartDate,
                executedPlanJson: executedPlanJson,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime startedAt,
                required String localStartDate,
                required String executedPlanJson,
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompletedTrainingsCompanion.insert(
                id: id,
                startedAt: startedAt,
                localStartDate: localStartDate,
                executedPlanJson: executedPlanJson,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CompletedTrainingsTable, CompletedTrainingRow>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $CompletedTrainingsTable,
                    CompletedTrainingRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CompletedTrainingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CompletedTrainingsTable,
      CompletedTrainingRow,
      $$CompletedTrainingsTableFilterComposer,
      $$CompletedTrainingsTableOrderingComposer,
      $$CompletedTrainingsTableAnnotationComposer,
      $$CompletedTrainingsTableCreateCompanionBuilder,
      $$CompletedTrainingsTableUpdateCompanionBuilder,
      (
        CompletedTrainingRow,
        BaseReferences<
          _$AppDatabase,
          $CompletedTrainingsTable,
          CompletedTrainingRow
        >,
      ),
      CompletedTrainingRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ExercisesTableTableManager get exercises =>
      $$ExercisesTableTableManager(_db, _db.exercises);
  $$CatalogMetaTableTableManager get catalogMeta =>
      $$CatalogMetaTableTableManager(_db, _db.catalogMeta);
  $$TrainingPlansTableTableManager get trainingPlans =>
      $$TrainingPlansTableTableManager(_db, _db.trainingPlans);
  $$CompletedTrainingsTableTableManager get completedTrainings =>
      $$CompletedTrainingsTableTableManager(_db, _db.completedTrainings);
}
