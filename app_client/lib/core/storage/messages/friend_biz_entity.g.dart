// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend_biz_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetFriendBizEntityCollection on Isar {
  IsarCollection<FriendBizEntity> get friendBizEntitys => this.collection();
}

const FriendBizEntitySchema = CollectionSchema(
  name: r'FriendBizEntity',
  id: 915414653191170766,
  properties: {
    r'eventId': PropertySchema(id: 0, name: r'eventId', type: IsarType.long),
    r'friendId': PropertySchema(id: 1, name: r'friendId', type: IsarType.long),
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
  estimateSize: _friendBizEntityEstimateSize,
  serialize: _friendBizEntitySerialize,
  deserialize: _friendBizEntityDeserialize,
  deserializeProp: _friendBizEntityDeserializeProp,
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
    r'friendId': IndexSchema(
      id: 3009825909668687770,
      name: r'friendId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'friendId',
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
  getId: _friendBizEntityGetId,
  getLinks: _friendBizEntityGetLinks,
  attach: _friendBizEntityAttach,
  version: '3.1.0+1',
);

int _friendBizEntityEstimateSize(
  FriendBizEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.payload.length * 8;
  return bytesCount;
}

void _friendBizEntitySerialize(
  FriendBizEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.eventId);
  writer.writeLong(offsets[1], object.friendId);
  writer.writeLong(offsets[2], object.kind);
  writer.writeLong(offsets[3], object.ownerId);
  writer.writeLongList(offsets[4], object.payload);
  writer.writeLong(offsets[5], object.timestamp);
}

FriendBizEntity _friendBizEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FriendBizEntity();
  object.eventId = reader.readLong(offsets[0]);
  object.friendId = reader.readLong(offsets[1]);
  object.id = id;
  object.kind = reader.readLong(offsets[2]);
  object.ownerId = reader.readLong(offsets[3]);
  object.payload = reader.readLongList(offsets[4]) ?? [];
  object.timestamp = reader.readLong(offsets[5]);
  return object;
}

P _friendBizEntityDeserializeProp<P>(
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

Id _friendBizEntityGetId(FriendBizEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _friendBizEntityGetLinks(FriendBizEntity object) {
  return [];
}

void _friendBizEntityAttach(
  IsarCollection<dynamic> col,
  Id id,
  FriendBizEntity object,
) {
  object.id = id;
}

extension FriendBizEntityByIndex on IsarCollection<FriendBizEntity> {
  Future<FriendBizEntity?> getByEventId(int eventId) {
    return getByIndex(r'eventId', [eventId]);
  }

  FriendBizEntity? getByEventIdSync(int eventId) {
    return getByIndexSync(r'eventId', [eventId]);
  }

  Future<bool> deleteByEventId(int eventId) {
    return deleteByIndex(r'eventId', [eventId]);
  }

  bool deleteByEventIdSync(int eventId) {
    return deleteByIndexSync(r'eventId', [eventId]);
  }

  Future<List<FriendBizEntity?>> getAllByEventId(List<int> eventIdValues) {
    final values = eventIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'eventId', values);
  }

  List<FriendBizEntity?> getAllByEventIdSync(List<int> eventIdValues) {
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

  Future<Id> putByEventId(FriendBizEntity object) {
    return putByIndex(r'eventId', object);
  }

  Id putByEventIdSync(FriendBizEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'eventId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByEventId(List<FriendBizEntity> objects) {
    return putAllByIndex(r'eventId', objects);
  }

  List<Id> putAllByEventIdSync(
    List<FriendBizEntity> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'eventId', objects, saveLinks: saveLinks);
  }
}

extension FriendBizEntityQueryWhereSort
    on QueryBuilder<FriendBizEntity, FriendBizEntity, QWhere> {
  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterWhere> anyOwnerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'ownerId'),
      );
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterWhere> anyFriendId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'friendId'),
      );
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterWhere> anyEventId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'eventId'),
      );
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterWhere> anyTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'timestamp'),
      );
    });
  }
}

extension FriendBizEntityQueryWhere
    on QueryBuilder<FriendBizEntity, FriendBizEntity, QWhereClause> {
  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterWhereClause>
  idNotEqualTo(Id id) {
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

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterWhereClause> idBetween(
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

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterWhereClause>
  ownerIdEqualTo(int ownerId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'ownerId', value: [ownerId]),
      );
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterWhereClause>
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

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterWhereClause>
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

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterWhereClause>
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

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterWhereClause>
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

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterWhereClause>
  friendIdEqualTo(int friendId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'friendId', value: [friendId]),
      );
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterWhereClause>
  friendIdNotEqualTo(int friendId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'friendId',
                lower: [],
                upper: [friendId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'friendId',
                lower: [friendId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'friendId',
                lower: [friendId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'friendId',
                lower: [],
                upper: [friendId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterWhereClause>
  friendIdGreaterThan(int friendId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'friendId',
          lower: [friendId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterWhereClause>
  friendIdLessThan(int friendId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'friendId',
          lower: [],
          upper: [friendId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterWhereClause>
  friendIdBetween(
    int lowerFriendId,
    int upperFriendId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'friendId',
          lower: [lowerFriendId],
          includeLower: includeLower,
          upper: [upperFriendId],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterWhereClause>
  eventIdEqualTo(int eventId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'eventId', value: [eventId]),
      );
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterWhereClause>
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

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterWhereClause>
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

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterWhereClause>
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

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterWhereClause>
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

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterWhereClause>
  timestampEqualTo(int timestamp) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'timestamp', value: [timestamp]),
      );
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterWhereClause>
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

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterWhereClause>
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

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterWhereClause>
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

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterWhereClause>
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

extension FriendBizEntityQueryFilter
    on QueryBuilder<FriendBizEntity, FriendBizEntity, QFilterCondition> {
  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterFilterCondition>
  eventIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'eventId', value: value),
      );
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterFilterCondition>
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

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterFilterCondition>
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

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterFilterCondition>
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

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterFilterCondition>
  friendIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'friendId', value: value),
      );
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterFilterCondition>
  friendIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'friendId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterFilterCondition>
  friendIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'friendId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterFilterCondition>
  friendIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'friendId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterFilterCondition>
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

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterFilterCondition>
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

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterFilterCondition>
  idBetween(
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

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterFilterCondition>
  kindEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'kind', value: value),
      );
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterFilterCondition>
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

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterFilterCondition>
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

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterFilterCondition>
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

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterFilterCondition>
  ownerIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'ownerId', value: value),
      );
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterFilterCondition>
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

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterFilterCondition>
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

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterFilterCondition>
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

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterFilterCondition>
  payloadElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'payload', value: value),
      );
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterFilterCondition>
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

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterFilterCondition>
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

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterFilterCondition>
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

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterFilterCondition>
  payloadLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'payload', length, true, length, true);
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterFilterCondition>
  payloadIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'payload', 0, true, 0, true);
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterFilterCondition>
  payloadIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'payload', 0, false, 999999, true);
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterFilterCondition>
  payloadLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'payload', 0, true, length, include);
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterFilterCondition>
  payloadLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'payload', length, include, 999999, true);
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterFilterCondition>
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

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterFilterCondition>
  timestampEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'timestamp', value: value),
      );
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterFilterCondition>
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

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterFilterCondition>
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

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterFilterCondition>
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

extension FriendBizEntityQueryObject
    on QueryBuilder<FriendBizEntity, FriendBizEntity, QFilterCondition> {}

extension FriendBizEntityQueryLinks
    on QueryBuilder<FriendBizEntity, FriendBizEntity, QFilterCondition> {}

extension FriendBizEntityQuerySortBy
    on QueryBuilder<FriendBizEntity, FriendBizEntity, QSortBy> {
  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterSortBy> sortByEventId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventId', Sort.asc);
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterSortBy>
  sortByEventIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventId', Sort.desc);
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterSortBy>
  sortByFriendId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'friendId', Sort.asc);
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterSortBy>
  sortByFriendIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'friendId', Sort.desc);
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterSortBy> sortByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterSortBy>
  sortByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterSortBy> sortByOwnerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerId', Sort.asc);
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterSortBy>
  sortByOwnerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerId', Sort.desc);
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterSortBy>
  sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterSortBy>
  sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension FriendBizEntityQuerySortThenBy
    on QueryBuilder<FriendBizEntity, FriendBizEntity, QSortThenBy> {
  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterSortBy> thenByEventId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventId', Sort.asc);
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterSortBy>
  thenByEventIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventId', Sort.desc);
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterSortBy>
  thenByFriendId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'friendId', Sort.asc);
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterSortBy>
  thenByFriendIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'friendId', Sort.desc);
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterSortBy> thenByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterSortBy>
  thenByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterSortBy> thenByOwnerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerId', Sort.asc);
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterSortBy>
  thenByOwnerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerId', Sort.desc);
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterSortBy>
  thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QAfterSortBy>
  thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension FriendBizEntityQueryWhereDistinct
    on QueryBuilder<FriendBizEntity, FriendBizEntity, QDistinct> {
  QueryBuilder<FriendBizEntity, FriendBizEntity, QDistinct>
  distinctByEventId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'eventId');
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QDistinct>
  distinctByFriendId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'friendId');
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QDistinct> distinctByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kind');
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QDistinct>
  distinctByOwnerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ownerId');
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QDistinct>
  distinctByPayload() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'payload');
    });
  }

  QueryBuilder<FriendBizEntity, FriendBizEntity, QDistinct>
  distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }
}

extension FriendBizEntityQueryProperty
    on QueryBuilder<FriendBizEntity, FriendBizEntity, QQueryProperty> {
  QueryBuilder<FriendBizEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<FriendBizEntity, int, QQueryOperations> eventIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'eventId');
    });
  }

  QueryBuilder<FriendBizEntity, int, QQueryOperations> friendIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'friendId');
    });
  }

  QueryBuilder<FriendBizEntity, int, QQueryOperations> kindProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kind');
    });
  }

  QueryBuilder<FriendBizEntity, int, QQueryOperations> ownerIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ownerId');
    });
  }

  QueryBuilder<FriendBizEntity, List<int>, QQueryOperations> payloadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'payload');
    });
  }

  QueryBuilder<FriendBizEntity, int, QQueryOperations> timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }
}
