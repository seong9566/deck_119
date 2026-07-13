// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AttemptRecordsTable extends AttemptRecords
    with TableInfo<$AttemptRecordsTable, AttemptRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttemptRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<String> questionId = GeneratedColumn<String>(
    'question_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCorrectMeta = const VerificationMeta(
    'isCorrect',
  );
  @override
  late final GeneratedColumn<bool> isCorrect = GeneratedColumn<bool>(
    'is_correct',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_correct" IN (0, 1))',
    ),
  );
  static const VerificationMeta _timestampMsMeta = const VerificationMeta(
    'timestampMs',
  );
  @override
  late final GeneratedColumn<int> timestampMs = GeneratedColumn<int>(
    'timestamp_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
    'subject_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _selectedIndexMeta = const VerificationMeta(
    'selectedIndex',
  );
  @override
  late final GeneratedColumn<int> selectedIndex = GeneratedColumn<int>(
    'selected_index',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    questionId,
    isCorrect,
    timestampMs,
    subjectId,
    selectedIndex,
    mode,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attempt_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttemptRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('is_correct')) {
      context.handle(
        _isCorrectMeta,
        isCorrect.isAcceptableOrUnknown(data['is_correct']!, _isCorrectMeta),
      );
    } else if (isInserting) {
      context.missing(_isCorrectMeta);
    }
    if (data.containsKey('timestamp_ms')) {
      context.handle(
        _timestampMsMeta,
        timestampMs.isAcceptableOrUnknown(
          data['timestamp_ms']!,
          _timestampMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timestampMsMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    }
    if (data.containsKey('selected_index')) {
      context.handle(
        _selectedIndexMeta,
        selectedIndex.isAcceptableOrUnknown(
          data['selected_index']!,
          _selectedIndexMeta,
        ),
      );
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AttemptRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttemptRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_id'],
      )!,
      isCorrect: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_correct'],
      )!,
      timestampMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timestamp_ms'],
      )!,
      subjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject_id'],
      ),
      selectedIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}selected_index'],
      ),
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      ),
    );
  }

  @override
  $AttemptRecordsTable createAlias(String alias) {
    return $AttemptRecordsTable(attachedDatabase, alias);
  }
}

class AttemptRecord extends DataClass implements Insertable<AttemptRecord> {
  final int id;
  final String questionId;
  final bool isCorrect;

  /// 시도 시각(epoch ms).
  final int timestampMs;
  final String? subjectId;
  final int? selectedIndex;
  final String? mode;
  const AttemptRecord({
    required this.id,
    required this.questionId,
    required this.isCorrect,
    required this.timestampMs,
    this.subjectId,
    this.selectedIndex,
    this.mode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['question_id'] = Variable<String>(questionId);
    map['is_correct'] = Variable<bool>(isCorrect);
    map['timestamp_ms'] = Variable<int>(timestampMs);
    if (!nullToAbsent || subjectId != null) {
      map['subject_id'] = Variable<String>(subjectId);
    }
    if (!nullToAbsent || selectedIndex != null) {
      map['selected_index'] = Variable<int>(selectedIndex);
    }
    if (!nullToAbsent || mode != null) {
      map['mode'] = Variable<String>(mode);
    }
    return map;
  }

  AttemptRecordsCompanion toCompanion(bool nullToAbsent) {
    return AttemptRecordsCompanion(
      id: Value(id),
      questionId: Value(questionId),
      isCorrect: Value(isCorrect),
      timestampMs: Value(timestampMs),
      subjectId: subjectId == null && nullToAbsent
          ? const Value.absent()
          : Value(subjectId),
      selectedIndex: selectedIndex == null && nullToAbsent
          ? const Value.absent()
          : Value(selectedIndex),
      mode: mode == null && nullToAbsent ? const Value.absent() : Value(mode),
    );
  }

  factory AttemptRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttemptRecord(
      id: serializer.fromJson<int>(json['id']),
      questionId: serializer.fromJson<String>(json['questionId']),
      isCorrect: serializer.fromJson<bool>(json['isCorrect']),
      timestampMs: serializer.fromJson<int>(json['timestampMs']),
      subjectId: serializer.fromJson<String?>(json['subjectId']),
      selectedIndex: serializer.fromJson<int?>(json['selectedIndex']),
      mode: serializer.fromJson<String?>(json['mode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'questionId': serializer.toJson<String>(questionId),
      'isCorrect': serializer.toJson<bool>(isCorrect),
      'timestampMs': serializer.toJson<int>(timestampMs),
      'subjectId': serializer.toJson<String?>(subjectId),
      'selectedIndex': serializer.toJson<int?>(selectedIndex),
      'mode': serializer.toJson<String?>(mode),
    };
  }

  AttemptRecord copyWith({
    int? id,
    String? questionId,
    bool? isCorrect,
    int? timestampMs,
    Value<String?> subjectId = const Value.absent(),
    Value<int?> selectedIndex = const Value.absent(),
    Value<String?> mode = const Value.absent(),
  }) => AttemptRecord(
    id: id ?? this.id,
    questionId: questionId ?? this.questionId,
    isCorrect: isCorrect ?? this.isCorrect,
    timestampMs: timestampMs ?? this.timestampMs,
    subjectId: subjectId.present ? subjectId.value : this.subjectId,
    selectedIndex: selectedIndex.present
        ? selectedIndex.value
        : this.selectedIndex,
    mode: mode.present ? mode.value : this.mode,
  );
  AttemptRecord copyWithCompanion(AttemptRecordsCompanion data) {
    return AttemptRecord(
      id: data.id.present ? data.id.value : this.id,
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      isCorrect: data.isCorrect.present ? data.isCorrect.value : this.isCorrect,
      timestampMs: data.timestampMs.present
          ? data.timestampMs.value
          : this.timestampMs,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      selectedIndex: data.selectedIndex.present
          ? data.selectedIndex.value
          : this.selectedIndex,
      mode: data.mode.present ? data.mode.value : this.mode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttemptRecord(')
          ..write('id: $id, ')
          ..write('questionId: $questionId, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('timestampMs: $timestampMs, ')
          ..write('subjectId: $subjectId, ')
          ..write('selectedIndex: $selectedIndex, ')
          ..write('mode: $mode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    questionId,
    isCorrect,
    timestampMs,
    subjectId,
    selectedIndex,
    mode,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttemptRecord &&
          other.id == this.id &&
          other.questionId == this.questionId &&
          other.isCorrect == this.isCorrect &&
          other.timestampMs == this.timestampMs &&
          other.subjectId == this.subjectId &&
          other.selectedIndex == this.selectedIndex &&
          other.mode == this.mode);
}

class AttemptRecordsCompanion extends UpdateCompanion<AttemptRecord> {
  final Value<int> id;
  final Value<String> questionId;
  final Value<bool> isCorrect;
  final Value<int> timestampMs;
  final Value<String?> subjectId;
  final Value<int?> selectedIndex;
  final Value<String?> mode;
  const AttemptRecordsCompanion({
    this.id = const Value.absent(),
    this.questionId = const Value.absent(),
    this.isCorrect = const Value.absent(),
    this.timestampMs = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.selectedIndex = const Value.absent(),
    this.mode = const Value.absent(),
  });
  AttemptRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String questionId,
    required bool isCorrect,
    required int timestampMs,
    this.subjectId = const Value.absent(),
    this.selectedIndex = const Value.absent(),
    this.mode = const Value.absent(),
  }) : questionId = Value(questionId),
       isCorrect = Value(isCorrect),
       timestampMs = Value(timestampMs);
  static Insertable<AttemptRecord> custom({
    Expression<int>? id,
    Expression<String>? questionId,
    Expression<bool>? isCorrect,
    Expression<int>? timestampMs,
    Expression<String>? subjectId,
    Expression<int>? selectedIndex,
    Expression<String>? mode,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (questionId != null) 'question_id': questionId,
      if (isCorrect != null) 'is_correct': isCorrect,
      if (timestampMs != null) 'timestamp_ms': timestampMs,
      if (subjectId != null) 'subject_id': subjectId,
      if (selectedIndex != null) 'selected_index': selectedIndex,
      if (mode != null) 'mode': mode,
    });
  }

  AttemptRecordsCompanion copyWith({
    Value<int>? id,
    Value<String>? questionId,
    Value<bool>? isCorrect,
    Value<int>? timestampMs,
    Value<String?>? subjectId,
    Value<int?>? selectedIndex,
    Value<String?>? mode,
  }) {
    return AttemptRecordsCompanion(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      isCorrect: isCorrect ?? this.isCorrect,
      timestampMs: timestampMs ?? this.timestampMs,
      subjectId: subjectId ?? this.subjectId,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      mode: mode ?? this.mode,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<String>(questionId.value);
    }
    if (isCorrect.present) {
      map['is_correct'] = Variable<bool>(isCorrect.value);
    }
    if (timestampMs.present) {
      map['timestamp_ms'] = Variable<int>(timestampMs.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (selectedIndex.present) {
      map['selected_index'] = Variable<int>(selectedIndex.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttemptRecordsCompanion(')
          ..write('id: $id, ')
          ..write('questionId: $questionId, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('timestampMs: $timestampMs, ')
          ..write('subjectId: $subjectId, ')
          ..write('selectedIndex: $selectedIndex, ')
          ..write('mode: $mode')
          ..write(')'))
        .toString();
  }
}

class $WrongEntriesTable extends WrongEntries
    with TableInfo<$WrongEntriesTable, WrongEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WrongEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<String> questionId = GeneratedColumn<String>(
    'question_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addedAtMsMeta = const VerificationMeta(
    'addedAtMs',
  );
  @override
  late final GeneratedColumn<int> addedAtMs = GeneratedColumn<int>(
    'added_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
    'subject_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [questionId, addedAtMs, subjectId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wrong_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<WrongEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('added_at_ms')) {
      context.handle(
        _addedAtMsMeta,
        addedAtMs.isAcceptableOrUnknown(data['added_at_ms']!, _addedAtMsMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMsMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {questionId};
  @override
  WrongEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WrongEntry(
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_id'],
      )!,
      addedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}added_at_ms'],
      )!,
      subjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject_id'],
      ),
    );
  }

  @override
  $WrongEntriesTable createAlias(String alias) {
    return $WrongEntriesTable(attachedDatabase, alias);
  }
}

class WrongEntry extends DataClass implements Insertable<WrongEntry> {
  final String questionId;
  final int addedAtMs;
  final String? subjectId;
  const WrongEntry({
    required this.questionId,
    required this.addedAtMs,
    this.subjectId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['question_id'] = Variable<String>(questionId);
    map['added_at_ms'] = Variable<int>(addedAtMs);
    if (!nullToAbsent || subjectId != null) {
      map['subject_id'] = Variable<String>(subjectId);
    }
    return map;
  }

  WrongEntriesCompanion toCompanion(bool nullToAbsent) {
    return WrongEntriesCompanion(
      questionId: Value(questionId),
      addedAtMs: Value(addedAtMs),
      subjectId: subjectId == null && nullToAbsent
          ? const Value.absent()
          : Value(subjectId),
    );
  }

  factory WrongEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WrongEntry(
      questionId: serializer.fromJson<String>(json['questionId']),
      addedAtMs: serializer.fromJson<int>(json['addedAtMs']),
      subjectId: serializer.fromJson<String?>(json['subjectId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'questionId': serializer.toJson<String>(questionId),
      'addedAtMs': serializer.toJson<int>(addedAtMs),
      'subjectId': serializer.toJson<String?>(subjectId),
    };
  }

  WrongEntry copyWith({
    String? questionId,
    int? addedAtMs,
    Value<String?> subjectId = const Value.absent(),
  }) => WrongEntry(
    questionId: questionId ?? this.questionId,
    addedAtMs: addedAtMs ?? this.addedAtMs,
    subjectId: subjectId.present ? subjectId.value : this.subjectId,
  );
  WrongEntry copyWithCompanion(WrongEntriesCompanion data) {
    return WrongEntry(
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      addedAtMs: data.addedAtMs.present ? data.addedAtMs.value : this.addedAtMs,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WrongEntry(')
          ..write('questionId: $questionId, ')
          ..write('addedAtMs: $addedAtMs, ')
          ..write('subjectId: $subjectId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(questionId, addedAtMs, subjectId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WrongEntry &&
          other.questionId == this.questionId &&
          other.addedAtMs == this.addedAtMs &&
          other.subjectId == this.subjectId);
}

class WrongEntriesCompanion extends UpdateCompanion<WrongEntry> {
  final Value<String> questionId;
  final Value<int> addedAtMs;
  final Value<String?> subjectId;
  final Value<int> rowid;
  const WrongEntriesCompanion({
    this.questionId = const Value.absent(),
    this.addedAtMs = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WrongEntriesCompanion.insert({
    required String questionId,
    required int addedAtMs,
    this.subjectId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : questionId = Value(questionId),
       addedAtMs = Value(addedAtMs);
  static Insertable<WrongEntry> custom({
    Expression<String>? questionId,
    Expression<int>? addedAtMs,
    Expression<String>? subjectId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (questionId != null) 'question_id': questionId,
      if (addedAtMs != null) 'added_at_ms': addedAtMs,
      if (subjectId != null) 'subject_id': subjectId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WrongEntriesCompanion copyWith({
    Value<String>? questionId,
    Value<int>? addedAtMs,
    Value<String?>? subjectId,
    Value<int>? rowid,
  }) {
    return WrongEntriesCompanion(
      questionId: questionId ?? this.questionId,
      addedAtMs: addedAtMs ?? this.addedAtMs,
      subjectId: subjectId ?? this.subjectId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (questionId.present) {
      map['question_id'] = Variable<String>(questionId.value);
    }
    if (addedAtMs.present) {
      map['added_at_ms'] = Variable<int>(addedAtMs.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WrongEntriesCompanion(')
          ..write('questionId: $questionId, ')
          ..write('addedAtMs: $addedAtMs, ')
          ..write('subjectId: $subjectId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
    'subject_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastIndexMeta = const VerificationMeta(
    'lastIndex',
  );
  @override
  late final GeneratedColumn<int> lastIndex = GeneratedColumn<int>(
    'last_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _answersMeta = const VerificationMeta(
    'answers',
  );
  @override
  late final GeneratedColumn<String> answers = GeneratedColumn<String>(
    'answers',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    key,
    subjectId,
    lastIndex,
    answers,
    updatedAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Session> instance, {
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
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('last_index')) {
      context.handle(
        _lastIndexMeta,
        lastIndex.isAcceptableOrUnknown(data['last_index']!, _lastIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_lastIndexMeta);
    }
    if (data.containsKey('answers')) {
      context.handle(
        _answersMeta,
        answers.isAcceptableOrUnknown(data['answers']!, _answersMeta),
      );
    } else if (isInserting) {
      context.missing(_answersMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      subjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject_id'],
      )!,
      lastIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_index'],
      )!,
      answers: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}answers'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class Session extends DataClass implements Insertable<Session> {
  final String key;
  final String subjectId;
  final int lastIndex;
  final String answers;
  final int updatedAtMs;
  const Session({
    required this.key,
    required this.subjectId,
    required this.lastIndex,
    required this.answers,
    required this.updatedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['subject_id'] = Variable<String>(subjectId);
    map['last_index'] = Variable<int>(lastIndex);
    map['answers'] = Variable<String>(answers);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      key: Value(key),
      subjectId: Value(subjectId),
      lastIndex: Value(lastIndex),
      answers: Value(answers),
      updatedAtMs: Value(updatedAtMs),
    );
  }

  factory Session.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      key: serializer.fromJson<String>(json['key']),
      subjectId: serializer.fromJson<String>(json['subjectId']),
      lastIndex: serializer.fromJson<int>(json['lastIndex']),
      answers: serializer.fromJson<String>(json['answers']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'subjectId': serializer.toJson<String>(subjectId),
      'lastIndex': serializer.toJson<int>(lastIndex),
      'answers': serializer.toJson<String>(answers),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
    };
  }

  Session copyWith({
    String? key,
    String? subjectId,
    int? lastIndex,
    String? answers,
    int? updatedAtMs,
  }) => Session(
    key: key ?? this.key,
    subjectId: subjectId ?? this.subjectId,
    lastIndex: lastIndex ?? this.lastIndex,
    answers: answers ?? this.answers,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
  );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      key: data.key.present ? data.key.value : this.key,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      lastIndex: data.lastIndex.present ? data.lastIndex.value : this.lastIndex,
      answers: data.answers.present ? data.answers.value : this.answers,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('key: $key, ')
          ..write('subjectId: $subjectId, ')
          ..write('lastIndex: $lastIndex, ')
          ..write('answers: $answers, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(key, subjectId, lastIndex, answers, updatedAtMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.key == this.key &&
          other.subjectId == this.subjectId &&
          other.lastIndex == this.lastIndex &&
          other.answers == this.answers &&
          other.updatedAtMs == this.updatedAtMs);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<String> key;
  final Value<String> subjectId;
  final Value<int> lastIndex;
  final Value<String> answers;
  final Value<int> updatedAtMs;
  final Value<int> rowid;
  const SessionsCompanion({
    this.key = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.lastIndex = const Value.absent(),
    this.answers = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionsCompanion.insert({
    required String key,
    required String subjectId,
    required int lastIndex,
    required String answers,
    required int updatedAtMs,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       subjectId = Value(subjectId),
       lastIndex = Value(lastIndex),
       answers = Value(answers),
       updatedAtMs = Value(updatedAtMs);
  static Insertable<Session> custom({
    Expression<String>? key,
    Expression<String>? subjectId,
    Expression<int>? lastIndex,
    Expression<String>? answers,
    Expression<int>? updatedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (subjectId != null) 'subject_id': subjectId,
      if (lastIndex != null) 'last_index': lastIndex,
      if (answers != null) 'answers': answers,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionsCompanion copyWith({
    Value<String>? key,
    Value<String>? subjectId,
    Value<int>? lastIndex,
    Value<String>? answers,
    Value<int>? updatedAtMs,
    Value<int>? rowid,
  }) {
    return SessionsCompanion(
      key: key ?? this.key,
      subjectId: subjectId ?? this.subjectId,
      lastIndex: lastIndex ?? this.lastIndex,
      answers: answers ?? this.answers,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (lastIndex.present) {
      map['last_index'] = Variable<int>(lastIndex.value);
    }
    if (answers.present) {
      map['answers'] = Variable<String>(answers.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('key: $key, ')
          ..write('subjectId: $subjectId, ')
          ..write('lastIndex: $lastIndex, ')
          ..write('answers: $answers, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _themeModeMeta = const VerificationMeta(
    'themeMode',
  );
  @override
  late final GeneratedColumn<String> themeMode = GeneratedColumn<String>(
    'theme_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, themeMode];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('theme_mode')) {
      context.handle(
        _themeModeMeta,
        themeMode.isAcceptableOrUnknown(data['theme_mode']!, _themeModeMeta),
      );
    } else if (isInserting) {
      context.missing(_themeModeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      themeMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_mode'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final int id;
  final String themeMode;
  const Setting({required this.id, required this.themeMode});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['theme_mode'] = Variable<String>(themeMode);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(id: Value(id), themeMode: Value(themeMode));
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      id: serializer.fromJson<int>(json['id']),
      themeMode: serializer.fromJson<String>(json['themeMode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'themeMode': serializer.toJson<String>(themeMode),
    };
  }

  Setting copyWith({int? id, String? themeMode}) =>
      Setting(id: id ?? this.id, themeMode: themeMode ?? this.themeMode);
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      id: data.id.present ? data.id.value : this.id,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('id: $id, ')
          ..write('themeMode: $themeMode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, themeMode);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting &&
          other.id == this.id &&
          other.themeMode == this.themeMode);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<int> id;
  final Value<String> themeMode;
  const SettingsCompanion({
    this.id = const Value.absent(),
    this.themeMode = const Value.absent(),
  });
  SettingsCompanion.insert({
    this.id = const Value.absent(),
    required String themeMode,
  }) : themeMode = Value(themeMode);
  static Insertable<Setting> custom({
    Expression<int>? id,
    Expression<String>? themeMode,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (themeMode != null) 'theme_mode': themeMode,
    });
  }

  SettingsCompanion copyWith({Value<int>? id, Value<String>? themeMode}) {
    return SettingsCompanion(
      id: id ?? this.id,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<String>(themeMode.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('id: $id, ')
          ..write('themeMode: $themeMode')
          ..write(')'))
        .toString();
  }
}

class $GeneratedQuestionsTable extends GeneratedQuestions
    with TableInfo<$GeneratedQuestionsTable, GeneratedQuestion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GeneratedQuestionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
    'subject_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, subjectId, payload, createdAtMs];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'generated_questions';
  @override
  VerificationContext validateIntegrity(
    Insertable<GeneratedQuestion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GeneratedQuestion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GeneratedQuestion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      subjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject_id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
    );
  }

  @override
  $GeneratedQuestionsTable createAlias(String alias) {
    return $GeneratedQuestionsTable(attachedDatabase, alias);
  }
}

class GeneratedQuestion extends DataClass
    implements Insertable<GeneratedQuestion> {
  /// 합성 id(`ai-<us>-<i>`). 유일.
  final String id;
  final String subjectId;

  /// Question 전체를 직렬화한 JSON(QuestionDto.fromJson으로 복원).
  final String payload;
  final int createdAtMs;
  const GeneratedQuestion({
    required this.id,
    required this.subjectId,
    required this.payload,
    required this.createdAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['subject_id'] = Variable<String>(subjectId);
    map['payload'] = Variable<String>(payload);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    return map;
  }

  GeneratedQuestionsCompanion toCompanion(bool nullToAbsent) {
    return GeneratedQuestionsCompanion(
      id: Value(id),
      subjectId: Value(subjectId),
      payload: Value(payload),
      createdAtMs: Value(createdAtMs),
    );
  }

  factory GeneratedQuestion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GeneratedQuestion(
      id: serializer.fromJson<String>(json['id']),
      subjectId: serializer.fromJson<String>(json['subjectId']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'subjectId': serializer.toJson<String>(subjectId),
      'payload': serializer.toJson<String>(payload),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
    };
  }

  GeneratedQuestion copyWith({
    String? id,
    String? subjectId,
    String? payload,
    int? createdAtMs,
  }) => GeneratedQuestion(
    id: id ?? this.id,
    subjectId: subjectId ?? this.subjectId,
    payload: payload ?? this.payload,
    createdAtMs: createdAtMs ?? this.createdAtMs,
  );
  GeneratedQuestion copyWithCompanion(GeneratedQuestionsCompanion data) {
    return GeneratedQuestion(
      id: data.id.present ? data.id.value : this.id,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GeneratedQuestion(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('payload: $payload, ')
          ..write('createdAtMs: $createdAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, subjectId, payload, createdAtMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GeneratedQuestion &&
          other.id == this.id &&
          other.subjectId == this.subjectId &&
          other.payload == this.payload &&
          other.createdAtMs == this.createdAtMs);
}

class GeneratedQuestionsCompanion extends UpdateCompanion<GeneratedQuestion> {
  final Value<String> id;
  final Value<String> subjectId;
  final Value<String> payload;
  final Value<int> createdAtMs;
  final Value<int> rowid;
  const GeneratedQuestionsCompanion({
    this.id = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GeneratedQuestionsCompanion.insert({
    required String id,
    required String subjectId,
    required String payload,
    required int createdAtMs,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       subjectId = Value(subjectId),
       payload = Value(payload),
       createdAtMs = Value(createdAtMs);
  static Insertable<GeneratedQuestion> custom({
    Expression<String>? id,
    Expression<String>? subjectId,
    Expression<String>? payload,
    Expression<int>? createdAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (subjectId != null) 'subject_id': subjectId,
      if (payload != null) 'payload': payload,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GeneratedQuestionsCompanion copyWith({
    Value<String>? id,
    Value<String>? subjectId,
    Value<String>? payload,
    Value<int>? createdAtMs,
    Value<int>? rowid,
  }) {
    return GeneratedQuestionsCompanion(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      payload: payload ?? this.payload,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GeneratedQuestionsCompanion(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('payload: $payload, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingAiRequestsTable extends PendingAiRequests
    with TableInfo<$PendingAiRequestsTable, PendingAiRequest> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingAiRequestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _docIdMeta = const VerificationMeta('docId');
  @override
  late final GeneratedColumn<String> docId = GeneratedColumn<String>(
    'doc_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
    'subject_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearScopeMeta = const VerificationMeta(
    'yearScope',
  );
  @override
  late final GeneratedColumn<String> yearScope = GeneratedColumn<String>(
    'year_scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    docId,
    subjectId,
    yearScope,
    createdAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_ai_requests';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingAiRequest> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('doc_id')) {
      context.handle(
        _docIdMeta,
        docId.isAcceptableOrUnknown(data['doc_id']!, _docIdMeta),
      );
    } else if (isInserting) {
      context.missing(_docIdMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('year_scope')) {
      context.handle(
        _yearScopeMeta,
        yearScope.isAcceptableOrUnknown(data['year_scope']!, _yearScopeMeta),
      );
    } else if (isInserting) {
      context.missing(_yearScopeMeta);
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {docId};
  @override
  PendingAiRequest map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingAiRequest(
      docId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}doc_id'],
      )!,
      subjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject_id'],
      )!,
      yearScope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}year_scope'],
      )!,
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
    );
  }

  @override
  $PendingAiRequestsTable createAlias(String alias) {
    return $PendingAiRequestsTable(attachedDatabase, alias);
  }
}

class PendingAiRequest extends DataClass
    implements Insertable<PendingAiRequest> {
  /// Firestore gen_requests doc id.
  final String docId;
  final String subjectId;

  /// 회수 시 year 매핑에 필요("2025"|"2026"|"all").
  final String yearScope;
  final int createdAtMs;
  const PendingAiRequest({
    required this.docId,
    required this.subjectId,
    required this.yearScope,
    required this.createdAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['doc_id'] = Variable<String>(docId);
    map['subject_id'] = Variable<String>(subjectId);
    map['year_scope'] = Variable<String>(yearScope);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    return map;
  }

  PendingAiRequestsCompanion toCompanion(bool nullToAbsent) {
    return PendingAiRequestsCompanion(
      docId: Value(docId),
      subjectId: Value(subjectId),
      yearScope: Value(yearScope),
      createdAtMs: Value(createdAtMs),
    );
  }

  factory PendingAiRequest.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingAiRequest(
      docId: serializer.fromJson<String>(json['docId']),
      subjectId: serializer.fromJson<String>(json['subjectId']),
      yearScope: serializer.fromJson<String>(json['yearScope']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'docId': serializer.toJson<String>(docId),
      'subjectId': serializer.toJson<String>(subjectId),
      'yearScope': serializer.toJson<String>(yearScope),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
    };
  }

  PendingAiRequest copyWith({
    String? docId,
    String? subjectId,
    String? yearScope,
    int? createdAtMs,
  }) => PendingAiRequest(
    docId: docId ?? this.docId,
    subjectId: subjectId ?? this.subjectId,
    yearScope: yearScope ?? this.yearScope,
    createdAtMs: createdAtMs ?? this.createdAtMs,
  );
  PendingAiRequest copyWithCompanion(PendingAiRequestsCompanion data) {
    return PendingAiRequest(
      docId: data.docId.present ? data.docId.value : this.docId,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      yearScope: data.yearScope.present ? data.yearScope.value : this.yearScope,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingAiRequest(')
          ..write('docId: $docId, ')
          ..write('subjectId: $subjectId, ')
          ..write('yearScope: $yearScope, ')
          ..write('createdAtMs: $createdAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(docId, subjectId, yearScope, createdAtMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingAiRequest &&
          other.docId == this.docId &&
          other.subjectId == this.subjectId &&
          other.yearScope == this.yearScope &&
          other.createdAtMs == this.createdAtMs);
}

class PendingAiRequestsCompanion extends UpdateCompanion<PendingAiRequest> {
  final Value<String> docId;
  final Value<String> subjectId;
  final Value<String> yearScope;
  final Value<int> createdAtMs;
  final Value<int> rowid;
  const PendingAiRequestsCompanion({
    this.docId = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.yearScope = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PendingAiRequestsCompanion.insert({
    required String docId,
    required String subjectId,
    required String yearScope,
    required int createdAtMs,
    this.rowid = const Value.absent(),
  }) : docId = Value(docId),
       subjectId = Value(subjectId),
       yearScope = Value(yearScope),
       createdAtMs = Value(createdAtMs);
  static Insertable<PendingAiRequest> custom({
    Expression<String>? docId,
    Expression<String>? subjectId,
    Expression<String>? yearScope,
    Expression<int>? createdAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (docId != null) 'doc_id': docId,
      if (subjectId != null) 'subject_id': subjectId,
      if (yearScope != null) 'year_scope': yearScope,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PendingAiRequestsCompanion copyWith({
    Value<String>? docId,
    Value<String>? subjectId,
    Value<String>? yearScope,
    Value<int>? createdAtMs,
    Value<int>? rowid,
  }) {
    return PendingAiRequestsCompanion(
      docId: docId ?? this.docId,
      subjectId: subjectId ?? this.subjectId,
      yearScope: yearScope ?? this.yearScope,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (docId.present) {
      map['doc_id'] = Variable<String>(docId.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (yearScope.present) {
      map['year_scope'] = Variable<String>(yearScope.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingAiRequestsCompanion(')
          ..write('docId: $docId, ')
          ..write('subjectId: $subjectId, ')
          ..write('yearScope: $yearScope, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AttemptRecordsTable attemptRecords = $AttemptRecordsTable(this);
  late final $WrongEntriesTable wrongEntries = $WrongEntriesTable(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $GeneratedQuestionsTable generatedQuestions =
      $GeneratedQuestionsTable(this);
  late final $PendingAiRequestsTable pendingAiRequests =
      $PendingAiRequestsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    attemptRecords,
    wrongEntries,
    sessions,
    settings,
    generatedQuestions,
    pendingAiRequests,
  ];
}

typedef $$AttemptRecordsTableCreateCompanionBuilder =
    AttemptRecordsCompanion Function({
      Value<int> id,
      required String questionId,
      required bool isCorrect,
      required int timestampMs,
      Value<String?> subjectId,
      Value<int?> selectedIndex,
      Value<String?> mode,
    });
typedef $$AttemptRecordsTableUpdateCompanionBuilder =
    AttemptRecordsCompanion Function({
      Value<int> id,
      Value<String> questionId,
      Value<bool> isCorrect,
      Value<int> timestampMs,
      Value<String?> subjectId,
      Value<int?> selectedIndex,
      Value<String?> mode,
    });

class $$AttemptRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $AttemptRecordsTable> {
  $$AttemptRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timestampMs => $composableBuilder(
    column: $table.timestampMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get selectedIndex => $composableBuilder(
    column: $table.selectedIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AttemptRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttemptRecordsTable> {
  $$AttemptRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timestampMs => $composableBuilder(
    column: $table.timestampMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get selectedIndex => $composableBuilder(
    column: $table.selectedIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AttemptRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttemptRecordsTable> {
  $$AttemptRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCorrect =>
      $composableBuilder(column: $table.isCorrect, builder: (column) => column);

  GeneratedColumn<int> get timestampMs => $composableBuilder(
    column: $table.timestampMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<int> get selectedIndex => $composableBuilder(
    column: $table.selectedIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);
}

class $$AttemptRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttemptRecordsTable,
          AttemptRecord,
          $$AttemptRecordsTableFilterComposer,
          $$AttemptRecordsTableOrderingComposer,
          $$AttemptRecordsTableAnnotationComposer,
          $$AttemptRecordsTableCreateCompanionBuilder,
          $$AttemptRecordsTableUpdateCompanionBuilder,
          (
            AttemptRecord,
            BaseReferences<_$AppDatabase, $AttemptRecordsTable, AttemptRecord>,
          ),
          AttemptRecord,
          PrefetchHooks Function()
        > {
  $$AttemptRecordsTableTableManager(
    _$AppDatabase db,
    $AttemptRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttemptRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttemptRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttemptRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> questionId = const Value.absent(),
                Value<bool> isCorrect = const Value.absent(),
                Value<int> timestampMs = const Value.absent(),
                Value<String?> subjectId = const Value.absent(),
                Value<int?> selectedIndex = const Value.absent(),
                Value<String?> mode = const Value.absent(),
              }) => AttemptRecordsCompanion(
                id: id,
                questionId: questionId,
                isCorrect: isCorrect,
                timestampMs: timestampMs,
                subjectId: subjectId,
                selectedIndex: selectedIndex,
                mode: mode,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String questionId,
                required bool isCorrect,
                required int timestampMs,
                Value<String?> subjectId = const Value.absent(),
                Value<int?> selectedIndex = const Value.absent(),
                Value<String?> mode = const Value.absent(),
              }) => AttemptRecordsCompanion.insert(
                id: id,
                questionId: questionId,
                isCorrect: isCorrect,
                timestampMs: timestampMs,
                subjectId: subjectId,
                selectedIndex: selectedIndex,
                mode: mode,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AttemptRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttemptRecordsTable,
      AttemptRecord,
      $$AttemptRecordsTableFilterComposer,
      $$AttemptRecordsTableOrderingComposer,
      $$AttemptRecordsTableAnnotationComposer,
      $$AttemptRecordsTableCreateCompanionBuilder,
      $$AttemptRecordsTableUpdateCompanionBuilder,
      (
        AttemptRecord,
        BaseReferences<_$AppDatabase, $AttemptRecordsTable, AttemptRecord>,
      ),
      AttemptRecord,
      PrefetchHooks Function()
    >;
typedef $$WrongEntriesTableCreateCompanionBuilder =
    WrongEntriesCompanion Function({
      required String questionId,
      required int addedAtMs,
      Value<String?> subjectId,
      Value<int> rowid,
    });
typedef $$WrongEntriesTableUpdateCompanionBuilder =
    WrongEntriesCompanion Function({
      Value<String> questionId,
      Value<int> addedAtMs,
      Value<String?> subjectId,
      Value<int> rowid,
    });

class $$WrongEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $WrongEntriesTable> {
  $$WrongEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get addedAtMs => $composableBuilder(
    column: $table.addedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WrongEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $WrongEntriesTable> {
  $$WrongEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get addedAtMs => $composableBuilder(
    column: $table.addedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WrongEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WrongEntriesTable> {
  $$WrongEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get addedAtMs =>
      $composableBuilder(column: $table.addedAtMs, builder: (column) => column);

  GeneratedColumn<String> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);
}

class $$WrongEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WrongEntriesTable,
          WrongEntry,
          $$WrongEntriesTableFilterComposer,
          $$WrongEntriesTableOrderingComposer,
          $$WrongEntriesTableAnnotationComposer,
          $$WrongEntriesTableCreateCompanionBuilder,
          $$WrongEntriesTableUpdateCompanionBuilder,
          (
            WrongEntry,
            BaseReferences<_$AppDatabase, $WrongEntriesTable, WrongEntry>,
          ),
          WrongEntry,
          PrefetchHooks Function()
        > {
  $$WrongEntriesTableTableManager(_$AppDatabase db, $WrongEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WrongEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WrongEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WrongEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> questionId = const Value.absent(),
                Value<int> addedAtMs = const Value.absent(),
                Value<String?> subjectId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WrongEntriesCompanion(
                questionId: questionId,
                addedAtMs: addedAtMs,
                subjectId: subjectId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String questionId,
                required int addedAtMs,
                Value<String?> subjectId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WrongEntriesCompanion.insert(
                questionId: questionId,
                addedAtMs: addedAtMs,
                subjectId: subjectId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WrongEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WrongEntriesTable,
      WrongEntry,
      $$WrongEntriesTableFilterComposer,
      $$WrongEntriesTableOrderingComposer,
      $$WrongEntriesTableAnnotationComposer,
      $$WrongEntriesTableCreateCompanionBuilder,
      $$WrongEntriesTableUpdateCompanionBuilder,
      (
        WrongEntry,
        BaseReferences<_$AppDatabase, $WrongEntriesTable, WrongEntry>,
      ),
      WrongEntry,
      PrefetchHooks Function()
    >;
typedef $$SessionsTableCreateCompanionBuilder =
    SessionsCompanion Function({
      required String key,
      required String subjectId,
      required int lastIndex,
      required String answers,
      required int updatedAtMs,
      Value<int> rowid,
    });
typedef $$SessionsTableUpdateCompanionBuilder =
    SessionsCompanion Function({
      Value<String> key,
      Value<String> subjectId,
      Value<int> lastIndex,
      Value<String> answers,
      Value<int> updatedAtMs,
      Value<int> rowid,
    });

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
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

  ColumnFilters<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastIndex => $composableBuilder(
    column: $table.lastIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get answers => $composableBuilder(
    column: $table.answers,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
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

  ColumnOrderings<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastIndex => $composableBuilder(
    column: $table.lastIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get answers => $composableBuilder(
    column: $table.answers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<int> get lastIndex =>
      $composableBuilder(column: $table.lastIndex, builder: (column) => column);

  GeneratedColumn<String> get answers =>
      $composableBuilder(column: $table.answers, builder: (column) => column);

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTable,
          Session,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (Session, BaseReferences<_$AppDatabase, $SessionsTable, Session>),
          Session,
          PrefetchHooks Function()
        > {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> subjectId = const Value.absent(),
                Value<int> lastIndex = const Value.absent(),
                Value<String> answers = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion(
                key: key,
                subjectId: subjectId,
                lastIndex: lastIndex,
                answers: answers,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String subjectId,
                required int lastIndex,
                required String answers,
                required int updatedAtMs,
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion.insert(
                key: key,
                subjectId: subjectId,
                lastIndex: lastIndex,
                answers: answers,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTable,
      Session,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (Session, BaseReferences<_$AppDatabase, $SessionsTable, Session>),
      Session,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableCreateCompanionBuilder =
    SettingsCompanion Function({Value<int> id, required String themeMode});
typedef $$SettingsTableUpdateCompanionBuilder =
    SettingsCompanion Function({Value<int> id, Value<String> themeMode});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
              }) => SettingsCompanion(id: id, themeMode: themeMode),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String themeMode,
              }) => SettingsCompanion.insert(id: id, themeMode: themeMode),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;
typedef $$GeneratedQuestionsTableCreateCompanionBuilder =
    GeneratedQuestionsCompanion Function({
      required String id,
      required String subjectId,
      required String payload,
      required int createdAtMs,
      Value<int> rowid,
    });
typedef $$GeneratedQuestionsTableUpdateCompanionBuilder =
    GeneratedQuestionsCompanion Function({
      Value<String> id,
      Value<String> subjectId,
      Value<String> payload,
      Value<int> createdAtMs,
      Value<int> rowid,
    });

class $$GeneratedQuestionsTableFilterComposer
    extends Composer<_$AppDatabase, $GeneratedQuestionsTable> {
  $$GeneratedQuestionsTableFilterComposer({
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

  ColumnFilters<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GeneratedQuestionsTableOrderingComposer
    extends Composer<_$AppDatabase, $GeneratedQuestionsTable> {
  $$GeneratedQuestionsTableOrderingComposer({
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

  ColumnOrderings<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GeneratedQuestionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GeneratedQuestionsTable> {
  $$GeneratedQuestionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );
}

class $$GeneratedQuestionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GeneratedQuestionsTable,
          GeneratedQuestion,
          $$GeneratedQuestionsTableFilterComposer,
          $$GeneratedQuestionsTableOrderingComposer,
          $$GeneratedQuestionsTableAnnotationComposer,
          $$GeneratedQuestionsTableCreateCompanionBuilder,
          $$GeneratedQuestionsTableUpdateCompanionBuilder,
          (
            GeneratedQuestion,
            BaseReferences<
              _$AppDatabase,
              $GeneratedQuestionsTable,
              GeneratedQuestion
            >,
          ),
          GeneratedQuestion,
          PrefetchHooks Function()
        > {
  $$GeneratedQuestionsTableTableManager(
    _$AppDatabase db,
    $GeneratedQuestionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GeneratedQuestionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GeneratedQuestionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GeneratedQuestionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> subjectId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GeneratedQuestionsCompanion(
                id: id,
                subjectId: subjectId,
                payload: payload,
                createdAtMs: createdAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String subjectId,
                required String payload,
                required int createdAtMs,
                Value<int> rowid = const Value.absent(),
              }) => GeneratedQuestionsCompanion.insert(
                id: id,
                subjectId: subjectId,
                payload: payload,
                createdAtMs: createdAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GeneratedQuestionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GeneratedQuestionsTable,
      GeneratedQuestion,
      $$GeneratedQuestionsTableFilterComposer,
      $$GeneratedQuestionsTableOrderingComposer,
      $$GeneratedQuestionsTableAnnotationComposer,
      $$GeneratedQuestionsTableCreateCompanionBuilder,
      $$GeneratedQuestionsTableUpdateCompanionBuilder,
      (
        GeneratedQuestion,
        BaseReferences<
          _$AppDatabase,
          $GeneratedQuestionsTable,
          GeneratedQuestion
        >,
      ),
      GeneratedQuestion,
      PrefetchHooks Function()
    >;
typedef $$PendingAiRequestsTableCreateCompanionBuilder =
    PendingAiRequestsCompanion Function({
      required String docId,
      required String subjectId,
      required String yearScope,
      required int createdAtMs,
      Value<int> rowid,
    });
typedef $$PendingAiRequestsTableUpdateCompanionBuilder =
    PendingAiRequestsCompanion Function({
      Value<String> docId,
      Value<String> subjectId,
      Value<String> yearScope,
      Value<int> createdAtMs,
      Value<int> rowid,
    });

class $$PendingAiRequestsTableFilterComposer
    extends Composer<_$AppDatabase, $PendingAiRequestsTable> {
  $$PendingAiRequestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get docId => $composableBuilder(
    column: $table.docId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get yearScope => $composableBuilder(
    column: $table.yearScope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingAiRequestsTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingAiRequestsTable> {
  $$PendingAiRequestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get docId => $composableBuilder(
    column: $table.docId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get yearScope => $composableBuilder(
    column: $table.yearScope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingAiRequestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingAiRequestsTable> {
  $$PendingAiRequestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get docId =>
      $composableBuilder(column: $table.docId, builder: (column) => column);

  GeneratedColumn<String> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<String> get yearScope =>
      $composableBuilder(column: $table.yearScope, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );
}

class $$PendingAiRequestsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PendingAiRequestsTable,
          PendingAiRequest,
          $$PendingAiRequestsTableFilterComposer,
          $$PendingAiRequestsTableOrderingComposer,
          $$PendingAiRequestsTableAnnotationComposer,
          $$PendingAiRequestsTableCreateCompanionBuilder,
          $$PendingAiRequestsTableUpdateCompanionBuilder,
          (
            PendingAiRequest,
            BaseReferences<
              _$AppDatabase,
              $PendingAiRequestsTable,
              PendingAiRequest
            >,
          ),
          PendingAiRequest,
          PrefetchHooks Function()
        > {
  $$PendingAiRequestsTableTableManager(
    _$AppDatabase db,
    $PendingAiRequestsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingAiRequestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingAiRequestsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingAiRequestsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> docId = const Value.absent(),
                Value<String> subjectId = const Value.absent(),
                Value<String> yearScope = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PendingAiRequestsCompanion(
                docId: docId,
                subjectId: subjectId,
                yearScope: yearScope,
                createdAtMs: createdAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String docId,
                required String subjectId,
                required String yearScope,
                required int createdAtMs,
                Value<int> rowid = const Value.absent(),
              }) => PendingAiRequestsCompanion.insert(
                docId: docId,
                subjectId: subjectId,
                yearScope: yearScope,
                createdAtMs: createdAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingAiRequestsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PendingAiRequestsTable,
      PendingAiRequest,
      $$PendingAiRequestsTableFilterComposer,
      $$PendingAiRequestsTableOrderingComposer,
      $$PendingAiRequestsTableAnnotationComposer,
      $$PendingAiRequestsTableCreateCompanionBuilder,
      $$PendingAiRequestsTableUpdateCompanionBuilder,
      (
        PendingAiRequest,
        BaseReferences<
          _$AppDatabase,
          $PendingAiRequestsTable,
          PendingAiRequest
        >,
      ),
      PendingAiRequest,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AttemptRecordsTableTableManager get attemptRecords =>
      $$AttemptRecordsTableTableManager(_db, _db.attemptRecords);
  $$WrongEntriesTableTableManager get wrongEntries =>
      $$WrongEntriesTableTableManager(_db, _db.wrongEntries);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$GeneratedQuestionsTableTableManager get generatedQuestions =>
      $$GeneratedQuestionsTableTableManager(_db, _db.generatedQuestions);
  $$PendingAiRequestsTableTableManager get pendingAiRequests =>
      $$PendingAiRequestsTableTableManager(_db, _db.pendingAiRequests);
}
