// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_biz_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetGroupBizEntityCollection on Isar {
  IsarCollection<GroupBizEntity> get groupBizEntitys => this.collection();
}

const GroupBizEntitySchema = CollectionSchema(
  name: r'GroupBizEntity',
  id: -2855778534922103404,
  properties: {
    r'eventId': PropertySchema(id: 0, name: r'eventId', type: IsarType.long),
    r'groupId': PropertySchema(id: 1, name: r'groupId', type: IsarType.long),
    r'kind': PropertySchema(id: 2, name: r'kind', type: IsarType.long),
    r'ownerId': PropertySchema(id: 3, name: r'ownerId', type: IsarType.long),
    r'payload': PropertySchema(
      id: 4,
      name: r'payload',
      type: IsarType.longList,
    ),
    r'timestamp': PropertySchema(
      id: 5,
      name: r'timestamp',
      type: IsarType.long,
    ),
  },
  estimateSize: _groupBizEntityEstimateSize,
  serialize: _groupBizEntitySerialize,
  deserialize: _groupBizEntityDeserialize,
  deserializeProp: _groupBizEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'ownerId': IndexSchema(
      id: -7594796109721319539,
      name: r'ownerId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'ownerId',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'groupId': IndexSchema(
      id: -8523216633229774932,
      name: r'groupId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'groupId',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'eventId': IndexSchema(
      id: -2707901133518603130,
      name: r'eventId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'eventId',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'timestamp': IndexSchema(
      id: 1852253767416892198,
      name: r'timestamp',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'timestamp',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},
  getId: _groupBizEntityGetId,
  getLinks: _groupBizEntityGetLinks,
  attach: _groupBizEntityAttach,
  version: '3.1.0+1',
);

int _groupBizEntityEstimateSize(
  GroupBizEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.payload.length * 8;
  return bytesCount;
}

void _groupBizEntitySerialize(
  GroupBizEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.eventId);
  writer.writeLong(offsets[1], object.groupId);
  writer.writeLong(offsets[2], object.kind);
  writer.writeLong(offsets[3], object.ownerId);
  writer.writeLongList(offsets[4], object.payload);
  writer.writeLong(offsets[5], object.timestamp);
}

GroupBizEntity _groupBizEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = GroupBizEntity();
  object.eventId = reader.readLong(offsets[0]);
  object.groupId = reader.readLong(offsets[1]);
  object.id = id;
  object.kind = reader.readLong(offsets[2]);
  object.ownerId = reader.readLong(offsets[3]);
  object.payload = reader.readLongList(offsets[4]) ?? [];
  object.timestamp = reader.readLong(offsets[5]);
  return object;
}

P _groupBizEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLongList(offset) ?? []) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _groupBizEntityGetId(GroupBizEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _groupBizEntityGetLinks(GroupBizEntity object) {
  return [];
}

void _groupBizEntityAttach(
  IsarCollection<dynamic> col,
  Id id,
  GroupBizEntity object,
) {
  object.id = id;
}

extension GroupBizEntityByIndex on IsarCollection<GroupBizEntity> {
  Future<GroupBizEntity?> getByEventId(int eventId) {
    return getByIndex(r'eventId', [eventId]);
  }

  GroupBizEntity? getByEventIdSync(int eventId) {
    return getByIndexSync(r'eventId', [eventId]);
  }

  Future<bool> deleteByEventId(int eventId) {
    return deleteByIndex(r'eventId', [eventId]);
  }

  bool deleteByEventIdSync(int eventId) {
    return deleteByIndexSync(r'eventId', [eventId]);
  }

  Future<List<GroupBizEntity?>> getAllByEventId(List<int> eventIdValues) {
    final values = eventIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'eventId', values);
  }

  List<GroupBizEntity?> getAllByEventIdSync(List<int> eventIdValues) {
    final values = eventIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'eventId', values);
  }

  Future<int> deleteAllByEventId(List<int> eventIdValues) {
    final values = eventIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'eventId', values);
  }

  int deleteAllByEventIdSync(List<int> eventIdValues) {
    final values = eventIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'eventId', values);
  }

  Future<Id> putByEventId(GroupBizEntity object) {
    return putByIndex(r'eventId', object);
  }

  Id putByEventIdSync(GroupBizEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'eventId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByEventId(List<GroupBizEntity> objects) {
    return putAllByIndex(r'eventId', objects);
  }

  List<Id> putAllByEventIdSync(
    List<GroupBizEntity> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'eventId', objects, saveLinks: saveLinks);
  }
}

extension GroupBizEntityQueryWhereSort
    on QueryBuilder<GroupBizEntity, GroupBizEntity, QWhere> {
  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterWhere> anyOwnerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'ownerId'),
      );
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterWhere> anyGroupId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'groupId'),
      );
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterWhere> anyEventId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'eventId'),
      );
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterWhere> anyTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'timestamp'),
      );
    });
  }
}

extension GroupBizEntityQueryWhere
    on QueryBuilder<GroupBizEntity, GroupBizEntity, QWhereClause> {
  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
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

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterWhereClause>
  ownerIdEqualTo(int ownerId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'ownerId', value: [ownerId]),
      );
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterWhereClause>
  ownerIdNotEqualTo(int ownerId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'ownerId',
                lower: [],
                upper: [ownerId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'ownerId',
                lower: [ownerId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'ownerId',
                lower: [ownerId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'ownerId',
                lower: [],
                upper: [ownerId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterWhereClause>
  ownerIdGreaterThan(int ownerId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'ownerId',
          lower: [ownerId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterWhereClause>
  ownerIdLessThan(int ownerId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'ownerId',
          lower: [],
          upper: [ownerId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterWhereClause>
  ownerIdBetween(
    int lowerOwnerId,
    int upperOwnerId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'ownerId',
          lower: [lowerOwnerId],
          includeLower: includeLower,
          upper: [upperOwnerId],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterWhereClause>
  groupIdEqualTo(int groupId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'groupId', value: [groupId]),
      );
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterWhereClause>
  groupIdNotEqualTo(int groupId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'groupId',
                lower: [],
                upper: [groupId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'groupId',
                lower: [groupId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'groupId',
                lower: [groupId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'groupId',
                lower: [],
                upper: [groupId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterWhereClause>
  groupIdGreaterThan(int groupId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'groupId',
          lower: [groupId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterWhereClause>
  groupIdLessThan(int groupId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'groupId',
          lower: [],
          upper: [groupId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterWhereClause>
  groupIdBetween(
    int lowerGroupId,
    int upperGroupId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'groupId',
          lower: [lowerGroupId],
          includeLower: includeLower,
          upper: [upperGroupId],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterWhereClause>
  eventIdEqualTo(int eventId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'eventId', value: [eventId]),
      );
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterWhereClause>
  eventIdNotEqualTo(int eventId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'eventId',
                lower: [],
                upper: [eventId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'eventId',
                lower: [eventId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'eventId',
                lower: [eventId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'eventId',
                lower: [],
                upper: [eventId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterWhereClause>
  eventIdGreaterThan(int eventId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'eventId',
          lower: [eventId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterWhereClause>
  eventIdLessThan(int eventId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'eventId',
          lower: [],
          upper: [eventId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterWhereClause>
  eventIdBetween(
    int lowerEventId,
    int upperEventId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'eventId',
          lower: [lowerEventId],
          includeLower: includeLower,
          upper: [upperEventId],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterWhereClause>
  timestampEqualTo(int timestamp) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'timestamp', value: [timestamp]),
      );
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterWhereClause>
  timestampNotEqualTo(int timestamp) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'timestamp',
                lower: [],
                upper: [timestamp],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'timestamp',
                lower: [timestamp],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'timestamp',
                lower: [timestamp],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'timestamp',
                lower: [],
                upper: [timestamp],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterWhereClause>
  timestampGreaterThan(int timestamp, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'timestamp',
          lower: [timestamp],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterWhereClause>
  timestampLessThan(int timestamp, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'timestamp',
          lower: [],
          upper: [timestamp],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterWhereClause>
  timestampBetween(
    int lowerTimestamp,
    int upperTimestamp, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'timestamp',
          lower: [lowerTimestamp],
          includeLower: includeLower,
          upper: [upperTimestamp],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension GroupBizEntityQueryFilter
    on QueryBuilder<GroupBizEntity, GroupBizEntity, QFilterCondition> {
  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterFilterCondition>
  eventIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'eventId', value: value),
      );
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterFilterCondition>
  eventIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'eventId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterFilterCondition>
  eventIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'eventId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterFilterCondition>
  eventIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'eventId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterFilterCondition>
  groupIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'groupId', value: value),
      );
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterFilterCondition>
  groupIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'groupId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterFilterCondition>
  groupIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'groupId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterFilterCondition>
  groupIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'groupId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterFilterCondition>
  kindEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'kind', value: value),
      );
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterFilterCondition>
  kindGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'kind',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterFilterCondition>
  kindLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'kind',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterFilterCondition>
  kindBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'kind',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterFilterCondition>
  ownerIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'ownerId', value: value),
      );
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterFilterCondition>
  ownerIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'ownerId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterFilterCondition>
  ownerIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'ownerId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterFilterCondition>
  ownerIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'ownerId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterFilterCondition>
  payloadElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'payload', value: value),
      );
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterFilterCondition>
  payloadElementGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'payload',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterFilterCondition>
  payloadElementLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'payload',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterFilterCondition>
  payloadElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'payload',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterFilterCondition>
  payloadLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'payload', length, true, length, true);
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterFilterCondition>
  payloadIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'payload', 0, true, 0, true);
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterFilterCondition>
  payloadIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'payload', 0, false, 999999, true);
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterFilterCondition>
  payloadLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'payload', 0, true, length, include);
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterFilterCondition>
  payloadLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'payload', length, include, 999999, true);
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterFilterCondition>
  payloadLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'payload',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterFilterCondition>
  timestampEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'timestamp', value: value),
      );
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterFilterCondition>
  timestampGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'timestamp',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterFilterCondition>
  timestampLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'timestamp',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterFilterCondition>
  timestampBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'timestamp',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension GroupBizEntityQueryObject
    on QueryBuilder<GroupBizEntity, GroupBizEntity, QFilterCondition> {}

extension GroupBizEntityQueryLinks
    on QueryBuilder<GroupBizEntity, GroupBizEntity, QFilterCondition> {}

extension GroupBizEntityQuerySortBy
    on QueryBuilder<GroupBizEntity, GroupBizEntity, QSortBy> {
  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterSortBy> sortByEventId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventId', Sort.asc);
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterSortBy>
  sortByEventIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventId', Sort.desc);
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterSortBy> sortByGroupId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupId', Sort.asc);
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterSortBy>
  sortByGroupIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupId', Sort.desc);
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterSortBy> sortByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterSortBy> sortByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterSortBy> sortByOwnerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerId', Sort.asc);
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterSortBy>
  sortByOwnerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerId', Sort.desc);
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterSortBy> sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterSortBy>
  sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension GroupBizEntityQuerySortThenBy
    on QueryBuilder<GroupBizEntity, GroupBizEntity, QSortThenBy> {
  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterSortBy> thenByEventId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventId', Sort.asc);
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterSortBy>
  thenByEventIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventId', Sort.desc);
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterSortBy> thenByGroupId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupId', Sort.asc);
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterSortBy>
  thenByGroupIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupId', Sort.desc);
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterSortBy> thenByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterSortBy> thenByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterSortBy> thenByOwnerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerId', Sort.asc);
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterSortBy>
  thenByOwnerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerId', Sort.desc);
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterSortBy> thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QAfterSortBy>
  thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension GroupBizEntityQueryWhereDistinct
    on QueryBuilder<GroupBizEntity, GroupBizEntity, QDistinct> {
  QueryBuilder<GroupBizEntity, GroupBizEntity, QDistinct> distinctByEventId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'eventId');
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QDistinct> distinctByGroupId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'groupId');
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QDistinct> distinctByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kind');
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QDistinct> distinctByOwnerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ownerId');
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QDistinct> distinctByPayload() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'payload');
    });
  }

  QueryBuilder<GroupBizEntity, GroupBizEntity, QDistinct>
  distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }
}

extension GroupBizEntityQueryProperty
    on QueryBuilder<GroupBizEntity, GroupBizEntity, QQueryProperty> {
  QueryBuilder<GroupBizEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<GroupBizEntity, int, QQueryOperations> eventIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'eventId');
    });
  }

  QueryBuilder<GroupBizEntity, int, QQueryOperations> groupIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'groupId');
    });
  }

  QueryBuilder<GroupBizEntity, int, QQueryOperations> kindProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kind');
    });
  }

  QueryBuilder<GroupBizEntity, int, QQueryOperations> ownerIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ownerId');
    });
  }

  QueryBuilder<GroupBizEntity, List<int>, QQueryOperations> payloadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'payload');
    });
  }

  QueryBuilder<GroupBizEntity, int, QQueryOperations> timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }
}
