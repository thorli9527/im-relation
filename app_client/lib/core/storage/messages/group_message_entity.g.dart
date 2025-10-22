// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_message_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetGroupMessageEntityCollection on Isar {
  IsarCollection<GroupMessageEntity> get groupMessageEntitys =>
      this.collection();
}

const GroupMessageEntitySchema = CollectionSchema(
  name: r'GroupMessageEntity',
  id: -4577490635851110948,
  properties: {
    r'deliveryStatus': PropertySchema(
      id: 0,
      name: r'deliveryStatus',
      type: IsarType.long,
    ),
    r'groupId': PropertySchema(id: 1, name: r'groupId', type: IsarType.long),
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
    r'senderId': PropertySchema(id: 7, name: r'senderId', type: IsarType.long),
    r'textPreview': PropertySchema(
      id: 8,
      name: r'textPreview',
      type: IsarType.string,
    ),
    r'timestamp': PropertySchema(
      id: 9,
      name: r'timestamp',
      type: IsarType.long,
    ),
  },
  estimateSize: _groupMessageEntityEstimateSize,
  serialize: _groupMessageEntitySerialize,
  deserialize: _groupMessageEntityDeserialize,
  deserializeProp: _groupMessageEntityDeserializeProp,
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
  getId: _groupMessageEntityGetId,
  getLinks: _groupMessageEntityGetLinks,
  attach: _groupMessageEntityAttach,
  version: '3.1.0+1',
);

int _groupMessageEntityEstimateSize(
  GroupMessageEntity object,
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

void _groupMessageEntitySerialize(
  GroupMessageEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.deliveryStatus);
  writer.writeLong(offsets[1], object.groupId);
  writer.writeBool(offsets[2], object.isOutgoing);
  writer.writeLong(offsets[3], object.kind);
  writer.writeLong(offsets[4], object.messageId);
  writer.writeLong(offsets[5], object.ownerId);
  writer.writeLongList(offsets[6], object.payload);
  writer.writeLong(offsets[7], object.senderId);
  writer.writeString(offsets[8], object.textPreview);
  writer.writeLong(offsets[9], object.timestamp);
}

GroupMessageEntity _groupMessageEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = GroupMessageEntity();
  object.deliveryStatus = reader.readLong(offsets[0]);
  object.groupId = reader.readLong(offsets[1]);
  object.id = id;
  object.isOutgoing = reader.readBool(offsets[2]);
  object.kind = reader.readLong(offsets[3]);
  object.messageId = reader.readLong(offsets[4]);
  object.ownerId = reader.readLong(offsets[5]);
  object.payload = reader.readLongList(offsets[6]) ?? [];
  object.senderId = reader.readLong(offsets[7]);
  object.textPreview = reader.readStringOrNull(offsets[8]);
  object.timestamp = reader.readLong(offsets[9]);
  return object;
}

P _groupMessageEntityDeserializeProp<P>(
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
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _groupMessageEntityGetId(GroupMessageEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _groupMessageEntityGetLinks(
  GroupMessageEntity object,
) {
  return [];
}

void _groupMessageEntityAttach(
  IsarCollection<dynamic> col,
  Id id,
  GroupMessageEntity object,
) {
  object.id = id;
}

extension GroupMessageEntityByIndex on IsarCollection<GroupMessageEntity> {
  Future<GroupMessageEntity?> getByMessageId(int messageId) {
    return getByIndex(r'messageId', [messageId]);
  }

  GroupMessageEntity? getByMessageIdSync(int messageId) {
    return getByIndexSync(r'messageId', [messageId]);
  }

  Future<bool> deleteByMessageId(int messageId) {
    return deleteByIndex(r'messageId', [messageId]);
  }

  bool deleteByMessageIdSync(int messageId) {
    return deleteByIndexSync(r'messageId', [messageId]);
  }

  Future<List<GroupMessageEntity?>> getAllByMessageId(
    List<int> messageIdValues,
  ) {
    final values = messageIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'messageId', values);
  }

  List<GroupMessageEntity?> getAllByMessageIdSync(List<int> messageIdValues) {
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

  Future<Id> putByMessageId(GroupMessageEntity object) {
    return putByIndex(r'messageId', object);
  }

  Id putByMessageIdSync(GroupMessageEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'messageId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByMessageId(List<GroupMessageEntity> objects) {
    return putAllByIndex(r'messageId', objects);
  }

  List<Id> putAllByMessageIdSync(
    List<GroupMessageEntity> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'messageId', objects, saveLinks: saveLinks);
  }
}

extension GroupMessageEntityQueryWhereSort
    on QueryBuilder<GroupMessageEntity, GroupMessageEntity, QWhere> {
  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterWhere>
  anyOwnerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'ownerId'),
      );
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterWhere>
  anyGroupId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'groupId'),
      );
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterWhere>
  anyMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'messageId'),
      );
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterWhere>
  anyTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'timestamp'),
      );
    });
  }
}

extension GroupMessageEntityQueryWhere
    on QueryBuilder<GroupMessageEntity, GroupMessageEntity, QWhereClause> {
  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterWhereClause>
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

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterWhereClause>
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

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterWhereClause>
  ownerIdEqualTo(int ownerId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'ownerId', value: [ownerId]),
      );
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterWhereClause>
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

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterWhereClause>
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

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterWhereClause>
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

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterWhereClause>
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

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterWhereClause>
  groupIdEqualTo(int groupId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'groupId', value: [groupId]),
      );
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterWhereClause>
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

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterWhereClause>
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

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterWhereClause>
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

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterWhereClause>
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

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterWhereClause>
  messageIdEqualTo(int messageId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'messageId', value: [messageId]),
      );
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterWhereClause>
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

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterWhereClause>
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

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterWhereClause>
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

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterWhereClause>
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

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterWhereClause>
  timestampEqualTo(int timestamp) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'timestamp', value: [timestamp]),
      );
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterWhereClause>
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

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterWhereClause>
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

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterWhereClause>
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

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterWhereClause>
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

extension GroupMessageEntityQueryFilter
    on QueryBuilder<GroupMessageEntity, GroupMessageEntity, QFilterCondition> {
  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
  deliveryStatusEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'deliveryStatus', value: value),
      );
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
  groupIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'groupId', value: value),
      );
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
  isOutgoingEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isOutgoing', value: value),
      );
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
  kindEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'kind', value: value),
      );
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
  messageIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'messageId', value: value),
      );
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
  ownerIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'ownerId', value: value),
      );
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
  payloadElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'payload', value: value),
      );
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
  payloadLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'payload', length, true, length, true);
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
  payloadIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'payload', 0, true, 0, true);
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
  payloadIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'payload', 0, false, 999999, true);
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
  payloadLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'payload', 0, true, length, include);
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
  payloadLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'payload', length, include, 999999, true);
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
  senderIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'senderId', value: value),
      );
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
  textPreviewIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'textPreview'),
      );
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
  textPreviewIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'textPreview'),
      );
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
  textPreviewIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'textPreview', value: ''),
      );
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
  textPreviewIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'textPreview', value: ''),
      );
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
  timestampEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'timestamp', value: value),
      );
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterFilterCondition>
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

extension GroupMessageEntityQueryObject
    on QueryBuilder<GroupMessageEntity, GroupMessageEntity, QFilterCondition> {}

extension GroupMessageEntityQueryLinks
    on QueryBuilder<GroupMessageEntity, GroupMessageEntity, QFilterCondition> {}

extension GroupMessageEntityQuerySortBy
    on QueryBuilder<GroupMessageEntity, GroupMessageEntity, QSortBy> {
  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterSortBy>
  sortByDeliveryStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deliveryStatus', Sort.asc);
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterSortBy>
  sortByDeliveryStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deliveryStatus', Sort.desc);
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterSortBy>
  sortByGroupId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupId', Sort.asc);
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterSortBy>
  sortByGroupIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupId', Sort.desc);
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterSortBy>
  sortByIsOutgoing() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOutgoing', Sort.asc);
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterSortBy>
  sortByIsOutgoingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOutgoing', Sort.desc);
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterSortBy>
  sortByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterSortBy>
  sortByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterSortBy>
  sortByMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageId', Sort.asc);
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterSortBy>
  sortByMessageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageId', Sort.desc);
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterSortBy>
  sortByOwnerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerId', Sort.asc);
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterSortBy>
  sortByOwnerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerId', Sort.desc);
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterSortBy>
  sortBySenderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.asc);
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterSortBy>
  sortBySenderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.desc);
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterSortBy>
  sortByTextPreview() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textPreview', Sort.asc);
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterSortBy>
  sortByTextPreviewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textPreview', Sort.desc);
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterSortBy>
  sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterSortBy>
  sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension GroupMessageEntityQuerySortThenBy
    on QueryBuilder<GroupMessageEntity, GroupMessageEntity, QSortThenBy> {
  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterSortBy>
  thenByDeliveryStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deliveryStatus', Sort.asc);
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterSortBy>
  thenByDeliveryStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deliveryStatus', Sort.desc);
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterSortBy>
  thenByGroupId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupId', Sort.asc);
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterSortBy>
  thenByGroupIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupId', Sort.desc);
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterSortBy>
  thenByIsOutgoing() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOutgoing', Sort.asc);
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterSortBy>
  thenByIsOutgoingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOutgoing', Sort.desc);
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterSortBy>
  thenByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterSortBy>
  thenByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterSortBy>
  thenByMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageId', Sort.asc);
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterSortBy>
  thenByMessageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageId', Sort.desc);
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterSortBy>
  thenByOwnerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerId', Sort.asc);
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterSortBy>
  thenByOwnerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerId', Sort.desc);
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterSortBy>
  thenBySenderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.asc);
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterSortBy>
  thenBySenderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.desc);
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterSortBy>
  thenByTextPreview() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textPreview', Sort.asc);
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterSortBy>
  thenByTextPreviewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textPreview', Sort.desc);
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterSortBy>
  thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QAfterSortBy>
  thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension GroupMessageEntityQueryWhereDistinct
    on QueryBuilder<GroupMessageEntity, GroupMessageEntity, QDistinct> {
  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QDistinct>
  distinctByDeliveryStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deliveryStatus');
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QDistinct>
  distinctByGroupId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'groupId');
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QDistinct>
  distinctByIsOutgoing() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isOutgoing');
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QDistinct>
  distinctByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kind');
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QDistinct>
  distinctByMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'messageId');
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QDistinct>
  distinctByOwnerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ownerId');
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QDistinct>
  distinctByPayload() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'payload');
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QDistinct>
  distinctBySenderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'senderId');
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QDistinct>
  distinctByTextPreview({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'textPreview', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GroupMessageEntity, GroupMessageEntity, QDistinct>
  distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }
}

extension GroupMessageEntityQueryProperty
    on QueryBuilder<GroupMessageEntity, GroupMessageEntity, QQueryProperty> {
  QueryBuilder<GroupMessageEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<GroupMessageEntity, int, QQueryOperations>
  deliveryStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deliveryStatus');
    });
  }

  QueryBuilder<GroupMessageEntity, int, QQueryOperations> groupIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'groupId');
    });
  }

  QueryBuilder<GroupMessageEntity, bool, QQueryOperations>
  isOutgoingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isOutgoing');
    });
  }

  QueryBuilder<GroupMessageEntity, int, QQueryOperations> kindProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kind');
    });
  }

  QueryBuilder<GroupMessageEntity, int, QQueryOperations> messageIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'messageId');
    });
  }

  QueryBuilder<GroupMessageEntity, int, QQueryOperations> ownerIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ownerId');
    });
  }

  QueryBuilder<GroupMessageEntity, List<int>, QQueryOperations>
  payloadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'payload');
    });
  }

  QueryBuilder<GroupMessageEntity, int, QQueryOperations> senderIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'senderId');
    });
  }

  QueryBuilder<GroupMessageEntity, String?, QQueryOperations>
  textPreviewProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'textPreview');
    });
  }

  QueryBuilder<GroupMessageEntity, int, QQueryOperations> timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }
}
