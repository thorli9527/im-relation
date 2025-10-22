// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend_message_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetFriendMessageEntityCollection on Isar {
  IsarCollection<FriendMessageEntity> get friendMessageEntitys =>
      this.collection();
}

const FriendMessageEntitySchema = CollectionSchema(
  name: r'FriendMessageEntity',
  id: -4459918421248848584,
  properties: {
    r'deliveryStatus': PropertySchema(
      id: 0,
      name: r'deliveryStatus',
      type: IsarType.long,
    ),
    r'friendId': PropertySchema(id: 1, name: r'friendId', type: IsarType.long),
    r'isOutgoing': PropertySchema(
      id: 2,
      name: r'isOutgoing',
      type: IsarType.bool,
    ),
    r'kind': PropertySchema(id: 3, name: r'kind', type: IsarType.long),
    r'messageId': PropertySchema(
      id: 4,
      name: r'messageId',
      type: IsarType.long,
    ),
    r'ownerId': PropertySchema(id: 5, name: r'ownerId', type: IsarType.long),
    r'payload': PropertySchema(
      id: 6,
      name: r'payload',
      type: IsarType.longList,
    ),
    r'receiverId': PropertySchema(
      id: 7,
      name: r'receiverId',
      type: IsarType.long,
    ),
    r'senderId': PropertySchema(id: 8, name: r'senderId', type: IsarType.long),
    r'textPreview': PropertySchema(
      id: 9,
      name: r'textPreview',
      type: IsarType.string,
    ),
    r'timestamp': PropertySchema(
      id: 10,
      name: r'timestamp',
      type: IsarType.long,
    ),
  },
  estimateSize: _friendMessageEntityEstimateSize,
  serialize: _friendMessageEntitySerialize,
  deserialize: _friendMessageEntityDeserialize,
  deserializeProp: _friendMessageEntityDeserializeProp,
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
    r'messageId': IndexSchema(
      id: -635287409172016016,
      name: r'messageId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'messageId',
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
  getId: _friendMessageEntityGetId,
  getLinks: _friendMessageEntityGetLinks,
  attach: _friendMessageEntityAttach,
  version: '3.1.0+1',
);

int _friendMessageEntityEstimateSize(
  FriendMessageEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.payload.length * 8;
  {
    final value = object.textPreview;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _friendMessageEntitySerialize(
  FriendMessageEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.deliveryStatus);
  writer.writeLong(offsets[1], object.friendId);
  writer.writeBool(offsets[2], object.isOutgoing);
  writer.writeLong(offsets[3], object.kind);
  writer.writeLong(offsets[4], object.messageId);
  writer.writeLong(offsets[5], object.ownerId);
  writer.writeLongList(offsets[6], object.payload);
  writer.writeLong(offsets[7], object.receiverId);
  writer.writeLong(offsets[8], object.senderId);
  writer.writeString(offsets[9], object.textPreview);
  writer.writeLong(offsets[10], object.timestamp);
}

FriendMessageEntity _friendMessageEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FriendMessageEntity();
  object.deliveryStatus = reader.readLong(offsets[0]);
  object.friendId = reader.readLong(offsets[1]);
  object.id = id;
  object.isOutgoing = reader.readBool(offsets[2]);
  object.kind = reader.readLong(offsets[3]);
  object.messageId = reader.readLong(offsets[4]);
  object.ownerId = reader.readLong(offsets[5]);
  object.payload = reader.readLongList(offsets[6]) ?? [];
  object.receiverId = reader.readLong(offsets[7]);
  object.senderId = reader.readLong(offsets[8]);
  object.textPreview = reader.readStringOrNull(offsets[9]);
  object.timestamp = reader.readLong(offsets[10]);
  return object;
}

P _friendMessageEntityDeserializeProp<P>(
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
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLongList(offset) ?? []) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _friendMessageEntityGetId(FriendMessageEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _friendMessageEntityGetLinks(
  FriendMessageEntity object,
) {
  return [];
}

void _friendMessageEntityAttach(
  IsarCollection<dynamic> col,
  Id id,
  FriendMessageEntity object,
) {
  object.id = id;
}

extension FriendMessageEntityByIndex on IsarCollection<FriendMessageEntity> {
  Future<FriendMessageEntity?> getByMessageId(int messageId) {
    return getByIndex(r'messageId', [messageId]);
  }

  FriendMessageEntity? getByMessageIdSync(int messageId) {
    return getByIndexSync(r'messageId', [messageId]);
  }

  Future<bool> deleteByMessageId(int messageId) {
    return deleteByIndex(r'messageId', [messageId]);
  }

  bool deleteByMessageIdSync(int messageId) {
    return deleteByIndexSync(r'messageId', [messageId]);
  }

  Future<List<FriendMessageEntity?>> getAllByMessageId(
    List<int> messageIdValues,
  ) {
    final values = messageIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'messageId', values);
  }

  List<FriendMessageEntity?> getAllByMessageIdSync(List<int> messageIdValues) {
    final values = messageIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'messageId', values);
  }

  Future<int> deleteAllByMessageId(List<int> messageIdValues) {
    final values = messageIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'messageId', values);
  }

  int deleteAllByMessageIdSync(List<int> messageIdValues) {
    final values = messageIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'messageId', values);
  }

  Future<Id> putByMessageId(FriendMessageEntity object) {
    return putByIndex(r'messageId', object);
  }

  Id putByMessageIdSync(FriendMessageEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'messageId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByMessageId(List<FriendMessageEntity> objects) {
    return putAllByIndex(r'messageId', objects);
  }

  List<Id> putAllByMessageIdSync(
    List<FriendMessageEntity> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'messageId', objects, saveLinks: saveLinks);
  }
}

extension FriendMessageEntityQueryWhereSort
    on QueryBuilder<FriendMessageEntity, FriendMessageEntity, QWhere> {
  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterWhere>
  anyOwnerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'ownerId'),
      );
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterWhere>
  anyFriendId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'friendId'),
      );
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterWhere>
  anyMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'messageId'),
      );
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterWhere>
  anyTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'timestamp'),
      );
    });
  }
}

extension FriendMessageEntityQueryWhere
    on QueryBuilder<FriendMessageEntity, FriendMessageEntity, QWhereClause> {
  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterWhereClause>
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

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterWhereClause>
  idBetween(
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

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterWhereClause>
  ownerIdEqualTo(int ownerId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'ownerId', value: [ownerId]),
      );
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterWhereClause>
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

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterWhereClause>
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

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterWhereClause>
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

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterWhereClause>
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

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterWhereClause>
  friendIdEqualTo(int friendId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'friendId', value: [friendId]),
      );
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterWhereClause>
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

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterWhereClause>
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

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterWhereClause>
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

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterWhereClause>
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

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterWhereClause>
  messageIdEqualTo(int messageId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'messageId', value: [messageId]),
      );
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterWhereClause>
  messageIdNotEqualTo(int messageId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'messageId',
                lower: [],
                upper: [messageId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'messageId',
                lower: [messageId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'messageId',
                lower: [messageId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'messageId',
                lower: [],
                upper: [messageId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterWhereClause>
  messageIdGreaterThan(int messageId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'messageId',
          lower: [messageId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterWhereClause>
  messageIdLessThan(int messageId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'messageId',
          lower: [],
          upper: [messageId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterWhereClause>
  messageIdBetween(
    int lowerMessageId,
    int upperMessageId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'messageId',
          lower: [lowerMessageId],
          includeLower: includeLower,
          upper: [upperMessageId],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterWhereClause>
  timestampEqualTo(int timestamp) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'timestamp', value: [timestamp]),
      );
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterWhereClause>
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

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterWhereClause>
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

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterWhereClause>
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

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterWhereClause>
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

extension FriendMessageEntityQueryFilter
    on
        QueryBuilder<
          FriendMessageEntity,
          FriendMessageEntity,
          QFilterCondition
        > {
  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
  deliveryStatusEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'deliveryStatus', value: value),
      );
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
  deliveryStatusGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'deliveryStatus',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
  deliveryStatusLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'deliveryStatus',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
  deliveryStatusBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'deliveryStatus',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
  friendIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'friendId', value: value),
      );
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
  isOutgoingEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isOutgoing', value: value),
      );
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
  kindEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'kind', value: value),
      );
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
  messageIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'messageId', value: value),
      );
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
  messageIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'messageId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
  messageIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'messageId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
  messageIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'messageId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
  ownerIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'ownerId', value: value),
      );
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
  payloadElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'payload', value: value),
      );
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
  payloadLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'payload', length, true, length, true);
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
  payloadIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'payload', 0, true, 0, true);
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
  payloadIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'payload', 0, false, 999999, true);
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
  payloadLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'payload', 0, true, length, include);
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
  payloadLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'payload', length, include, 999999, true);
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
  receiverIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'receiverId', value: value),
      );
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
  receiverIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'receiverId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
  receiverIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'receiverId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
  receiverIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'receiverId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
  senderIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'senderId', value: value),
      );
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
  senderIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'senderId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
  senderIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'senderId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
  senderIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'senderId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
  textPreviewIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'textPreview'),
      );
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
  textPreviewIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'textPreview'),
      );
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
  textPreviewEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'textPreview',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
  textPreviewGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'textPreview',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
  textPreviewLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'textPreview',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
  textPreviewBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'textPreview',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
  textPreviewStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'textPreview',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
  textPreviewEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'textPreview',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
  textPreviewContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'textPreview',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
  textPreviewMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'textPreview',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
  textPreviewIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'textPreview', value: ''),
      );
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
  textPreviewIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'textPreview', value: ''),
      );
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
  timestampEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'timestamp', value: value),
      );
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterFilterCondition>
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

extension FriendMessageEntityQueryObject
    on
        QueryBuilder<
          FriendMessageEntity,
          FriendMessageEntity,
          QFilterCondition
        > {}

extension FriendMessageEntityQueryLinks
    on
        QueryBuilder<
          FriendMessageEntity,
          FriendMessageEntity,
          QFilterCondition
        > {}

extension FriendMessageEntityQuerySortBy
    on QueryBuilder<FriendMessageEntity, FriendMessageEntity, QSortBy> {
  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterSortBy>
  sortByDeliveryStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deliveryStatus', Sort.asc);
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterSortBy>
  sortByDeliveryStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deliveryStatus', Sort.desc);
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterSortBy>
  sortByFriendId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'friendId', Sort.asc);
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterSortBy>
  sortByFriendIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'friendId', Sort.desc);
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterSortBy>
  sortByIsOutgoing() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOutgoing', Sort.asc);
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterSortBy>
  sortByIsOutgoingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOutgoing', Sort.desc);
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterSortBy>
  sortByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterSortBy>
  sortByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterSortBy>
  sortByMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageId', Sort.asc);
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterSortBy>
  sortByMessageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageId', Sort.desc);
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterSortBy>
  sortByOwnerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerId', Sort.asc);
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterSortBy>
  sortByOwnerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerId', Sort.desc);
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterSortBy>
  sortByReceiverId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiverId', Sort.asc);
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterSortBy>
  sortByReceiverIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiverId', Sort.desc);
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterSortBy>
  sortBySenderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.asc);
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterSortBy>
  sortBySenderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.desc);
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterSortBy>
  sortByTextPreview() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textPreview', Sort.asc);
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterSortBy>
  sortByTextPreviewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textPreview', Sort.desc);
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterSortBy>
  sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterSortBy>
  sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension FriendMessageEntityQuerySortThenBy
    on QueryBuilder<FriendMessageEntity, FriendMessageEntity, QSortThenBy> {
  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterSortBy>
  thenByDeliveryStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deliveryStatus', Sort.asc);
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterSortBy>
  thenByDeliveryStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deliveryStatus', Sort.desc);
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterSortBy>
  thenByFriendId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'friendId', Sort.asc);
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterSortBy>
  thenByFriendIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'friendId', Sort.desc);
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterSortBy>
  thenByIsOutgoing() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOutgoing', Sort.asc);
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterSortBy>
  thenByIsOutgoingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOutgoing', Sort.desc);
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterSortBy>
  thenByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterSortBy>
  thenByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterSortBy>
  thenByMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageId', Sort.asc);
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterSortBy>
  thenByMessageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageId', Sort.desc);
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterSortBy>
  thenByOwnerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerId', Sort.asc);
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterSortBy>
  thenByOwnerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerId', Sort.desc);
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterSortBy>
  thenByReceiverId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiverId', Sort.asc);
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterSortBy>
  thenByReceiverIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiverId', Sort.desc);
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterSortBy>
  thenBySenderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.asc);
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterSortBy>
  thenBySenderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.desc);
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterSortBy>
  thenByTextPreview() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textPreview', Sort.asc);
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterSortBy>
  thenByTextPreviewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textPreview', Sort.desc);
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterSortBy>
  thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QAfterSortBy>
  thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension FriendMessageEntityQueryWhereDistinct
    on QueryBuilder<FriendMessageEntity, FriendMessageEntity, QDistinct> {
  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QDistinct>
  distinctByDeliveryStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deliveryStatus');
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QDistinct>
  distinctByFriendId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'friendId');
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QDistinct>
  distinctByIsOutgoing() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isOutgoing');
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QDistinct>
  distinctByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kind');
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QDistinct>
  distinctByMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'messageId');
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QDistinct>
  distinctByOwnerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ownerId');
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QDistinct>
  distinctByPayload() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'payload');
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QDistinct>
  distinctByReceiverId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'receiverId');
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QDistinct>
  distinctBySenderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'senderId');
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QDistinct>
  distinctByTextPreview({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'textPreview', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FriendMessageEntity, FriendMessageEntity, QDistinct>
  distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }
}

extension FriendMessageEntityQueryProperty
    on QueryBuilder<FriendMessageEntity, FriendMessageEntity, QQueryProperty> {
  QueryBuilder<FriendMessageEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<FriendMessageEntity, int, QQueryOperations>
  deliveryStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deliveryStatus');
    });
  }

  QueryBuilder<FriendMessageEntity, int, QQueryOperations> friendIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'friendId');
    });
  }

  QueryBuilder<FriendMessageEntity, bool, QQueryOperations>
  isOutgoingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isOutgoing');
    });
  }

  QueryBuilder<FriendMessageEntity, int, QQueryOperations> kindProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kind');
    });
  }

  QueryBuilder<FriendMessageEntity, int, QQueryOperations> messageIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'messageId');
    });
  }

  QueryBuilder<FriendMessageEntity, int, QQueryOperations> ownerIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ownerId');
    });
  }

  QueryBuilder<FriendMessageEntity, List<int>, QQueryOperations>
  payloadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'payload');
    });
  }

  QueryBuilder<FriendMessageEntity, int, QQueryOperations>
  receiverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'receiverId');
    });
  }

  QueryBuilder<FriendMessageEntity, int, QQueryOperations> senderIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'senderId');
    });
  }

  QueryBuilder<FriendMessageEntity, String?, QQueryOperations>
  textPreviewProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'textPreview');
    });
  }

  QueryBuilder<FriendMessageEntity, int, QQueryOperations> timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }
}
