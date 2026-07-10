// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wrong_entry.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetWrongEntryCollection on Isar {
  IsarCollection<WrongEntry> get wrongEntrys => this.collection();
}

const WrongEntrySchema = CollectionSchema(
  name: r'WrongEntry',
  id: -7143282009015975276,
  properties: {
    r'addedAtMs': PropertySchema(
      id: 0,
      name: r'addedAtMs',
      type: IsarType.long,
    ),
    r'questionId': PropertySchema(
      id: 1,
      name: r'questionId',
      type: IsarType.string,
    ),
    r'subjectId': PropertySchema(
      id: 2,
      name: r'subjectId',
      type: IsarType.string,
    )
  },
  estimateSize: _wrongEntryEstimateSize,
  serialize: _wrongEntrySerialize,
  deserialize: _wrongEntryDeserialize,
  deserializeProp: _wrongEntryDeserializeProp,
  idName: r'id',
  indexes: {
    r'questionId': IndexSchema(
      id: 5032123391997384121,
      name: r'questionId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'questionId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _wrongEntryGetId,
  getLinks: _wrongEntryGetLinks,
  attach: _wrongEntryAttach,
  version: '3.1.0+1',
);

int _wrongEntryEstimateSize(
  WrongEntry object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.questionId.length * 3;
  {
    final value = object.subjectId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _wrongEntrySerialize(
  WrongEntry object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.addedAtMs);
  writer.writeString(offsets[1], object.questionId);
  writer.writeString(offsets[2], object.subjectId);
}

WrongEntry _wrongEntryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = WrongEntry();
  object.addedAtMs = reader.readLong(offsets[0]);
  object.id = id;
  object.questionId = reader.readString(offsets[1]);
  object.subjectId = reader.readStringOrNull(offsets[2]);
  return object;
}

P _wrongEntryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _wrongEntryGetId(WrongEntry object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _wrongEntryGetLinks(WrongEntry object) {
  return [];
}

void _wrongEntryAttach(IsarCollection<dynamic> col, Id id, WrongEntry object) {
  object.id = id;
}

extension WrongEntryByIndex on IsarCollection<WrongEntry> {
  Future<WrongEntry?> getByQuestionId(String questionId) {
    return getByIndex(r'questionId', [questionId]);
  }

  WrongEntry? getByQuestionIdSync(String questionId) {
    return getByIndexSync(r'questionId', [questionId]);
  }

  Future<bool> deleteByQuestionId(String questionId) {
    return deleteByIndex(r'questionId', [questionId]);
  }

  bool deleteByQuestionIdSync(String questionId) {
    return deleteByIndexSync(r'questionId', [questionId]);
  }

  Future<List<WrongEntry?>> getAllByQuestionId(List<String> questionIdValues) {
    final values = questionIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'questionId', values);
  }

  List<WrongEntry?> getAllByQuestionIdSync(List<String> questionIdValues) {
    final values = questionIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'questionId', values);
  }

  Future<int> deleteAllByQuestionId(List<String> questionIdValues) {
    final values = questionIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'questionId', values);
  }

  int deleteAllByQuestionIdSync(List<String> questionIdValues) {
    final values = questionIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'questionId', values);
  }

  Future<Id> putByQuestionId(WrongEntry object) {
    return putByIndex(r'questionId', object);
  }

  Id putByQuestionIdSync(WrongEntry object, {bool saveLinks = true}) {
    return putByIndexSync(r'questionId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByQuestionId(List<WrongEntry> objects) {
    return putAllByIndex(r'questionId', objects);
  }

  List<Id> putAllByQuestionIdSync(List<WrongEntry> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'questionId', objects, saveLinks: saveLinks);
  }
}

extension WrongEntryQueryWhereSort
    on QueryBuilder<WrongEntry, WrongEntry, QWhere> {
  QueryBuilder<WrongEntry, WrongEntry, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension WrongEntryQueryWhere
    on QueryBuilder<WrongEntry, WrongEntry, QWhereClause> {
  QueryBuilder<WrongEntry, WrongEntry, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<WrongEntry, WrongEntry, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<WrongEntry, WrongEntry, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<WrongEntry, WrongEntry, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<WrongEntry, WrongEntry, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WrongEntry, WrongEntry, QAfterWhereClause> questionIdEqualTo(
      String questionId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'questionId',
        value: [questionId],
      ));
    });
  }

  QueryBuilder<WrongEntry, WrongEntry, QAfterWhereClause> questionIdNotEqualTo(
      String questionId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'questionId',
              lower: [],
              upper: [questionId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'questionId',
              lower: [questionId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'questionId',
              lower: [questionId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'questionId',
              lower: [],
              upper: [questionId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension WrongEntryQueryFilter
    on QueryBuilder<WrongEntry, WrongEntry, QFilterCondition> {
  QueryBuilder<WrongEntry, WrongEntry, QAfterFilterCondition> addedAtMsEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'addedAtMs',
        value: value,
      ));
    });
  }

  QueryBuilder<WrongEntry, WrongEntry, QAfterFilterCondition>
      addedAtMsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'addedAtMs',
        value: value,
      ));
    });
  }

  QueryBuilder<WrongEntry, WrongEntry, QAfterFilterCondition> addedAtMsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'addedAtMs',
        value: value,
      ));
    });
  }

  QueryBuilder<WrongEntry, WrongEntry, QAfterFilterCondition> addedAtMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'addedAtMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WrongEntry, WrongEntry, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WrongEntry, WrongEntry, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WrongEntry, WrongEntry, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WrongEntry, WrongEntry, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WrongEntry, WrongEntry, QAfterFilterCondition> questionIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'questionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongEntry, WrongEntry, QAfterFilterCondition>
      questionIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'questionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongEntry, WrongEntry, QAfterFilterCondition>
      questionIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'questionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongEntry, WrongEntry, QAfterFilterCondition> questionIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'questionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongEntry, WrongEntry, QAfterFilterCondition>
      questionIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'questionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongEntry, WrongEntry, QAfterFilterCondition>
      questionIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'questionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongEntry, WrongEntry, QAfterFilterCondition>
      questionIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'questionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongEntry, WrongEntry, QAfterFilterCondition> questionIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'questionId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongEntry, WrongEntry, QAfterFilterCondition>
      questionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'questionId',
        value: '',
      ));
    });
  }

  QueryBuilder<WrongEntry, WrongEntry, QAfterFilterCondition>
      questionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'questionId',
        value: '',
      ));
    });
  }

  QueryBuilder<WrongEntry, WrongEntry, QAfterFilterCondition>
      subjectIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'subjectId',
      ));
    });
  }

  QueryBuilder<WrongEntry, WrongEntry, QAfterFilterCondition>
      subjectIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'subjectId',
      ));
    });
  }

  QueryBuilder<WrongEntry, WrongEntry, QAfterFilterCondition> subjectIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongEntry, WrongEntry, QAfterFilterCondition>
      subjectIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'subjectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongEntry, WrongEntry, QAfterFilterCondition> subjectIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'subjectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongEntry, WrongEntry, QAfterFilterCondition> subjectIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'subjectId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongEntry, WrongEntry, QAfterFilterCondition>
      subjectIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'subjectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongEntry, WrongEntry, QAfterFilterCondition> subjectIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'subjectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongEntry, WrongEntry, QAfterFilterCondition> subjectIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'subjectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongEntry, WrongEntry, QAfterFilterCondition> subjectIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'subjectId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongEntry, WrongEntry, QAfterFilterCondition>
      subjectIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjectId',
        value: '',
      ));
    });
  }

  QueryBuilder<WrongEntry, WrongEntry, QAfterFilterCondition>
      subjectIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'subjectId',
        value: '',
      ));
    });
  }
}

extension WrongEntryQueryObject
    on QueryBuilder<WrongEntry, WrongEntry, QFilterCondition> {}

extension WrongEntryQueryLinks
    on QueryBuilder<WrongEntry, WrongEntry, QFilterCondition> {}

extension WrongEntryQuerySortBy
    on QueryBuilder<WrongEntry, WrongEntry, QSortBy> {
  QueryBuilder<WrongEntry, WrongEntry, QAfterSortBy> sortByAddedAtMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAtMs', Sort.asc);
    });
  }

  QueryBuilder<WrongEntry, WrongEntry, QAfterSortBy> sortByAddedAtMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAtMs', Sort.desc);
    });
  }

  QueryBuilder<WrongEntry, WrongEntry, QAfterSortBy> sortByQuestionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questionId', Sort.asc);
    });
  }

  QueryBuilder<WrongEntry, WrongEntry, QAfterSortBy> sortByQuestionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questionId', Sort.desc);
    });
  }

  QueryBuilder<WrongEntry, WrongEntry, QAfterSortBy> sortBySubjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectId', Sort.asc);
    });
  }

  QueryBuilder<WrongEntry, WrongEntry, QAfterSortBy> sortBySubjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectId', Sort.desc);
    });
  }
}

extension WrongEntryQuerySortThenBy
    on QueryBuilder<WrongEntry, WrongEntry, QSortThenBy> {
  QueryBuilder<WrongEntry, WrongEntry, QAfterSortBy> thenByAddedAtMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAtMs', Sort.asc);
    });
  }

  QueryBuilder<WrongEntry, WrongEntry, QAfterSortBy> thenByAddedAtMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAtMs', Sort.desc);
    });
  }

  QueryBuilder<WrongEntry, WrongEntry, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<WrongEntry, WrongEntry, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<WrongEntry, WrongEntry, QAfterSortBy> thenByQuestionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questionId', Sort.asc);
    });
  }

  QueryBuilder<WrongEntry, WrongEntry, QAfterSortBy> thenByQuestionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questionId', Sort.desc);
    });
  }

  QueryBuilder<WrongEntry, WrongEntry, QAfterSortBy> thenBySubjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectId', Sort.asc);
    });
  }

  QueryBuilder<WrongEntry, WrongEntry, QAfterSortBy> thenBySubjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectId', Sort.desc);
    });
  }
}

extension WrongEntryQueryWhereDistinct
    on QueryBuilder<WrongEntry, WrongEntry, QDistinct> {
  QueryBuilder<WrongEntry, WrongEntry, QDistinct> distinctByAddedAtMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'addedAtMs');
    });
  }

  QueryBuilder<WrongEntry, WrongEntry, QDistinct> distinctByQuestionId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'questionId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WrongEntry, WrongEntry, QDistinct> distinctBySubjectId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subjectId', caseSensitive: caseSensitive);
    });
  }
}

extension WrongEntryQueryProperty
    on QueryBuilder<WrongEntry, WrongEntry, QQueryProperty> {
  QueryBuilder<WrongEntry, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<WrongEntry, int, QQueryOperations> addedAtMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'addedAtMs');
    });
  }

  QueryBuilder<WrongEntry, String, QQueryOperations> questionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'questionId');
    });
  }

  QueryBuilder<WrongEntry, String?, QQueryOperations> subjectIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subjectId');
    });
  }
}
