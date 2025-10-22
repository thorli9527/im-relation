// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outbox_message_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetOutboxMessageEntityCollection on Isar {
  IsarCollection<OutboxMessageEntity> get outboxMessageEntitys =>
      this.collection();
}

const OutboxMessageEntitySchema = CollectionSchema(
  name: r'OutboxMessageEntity',
  id: -7095668574231720309,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.long,
    ),
    r'isGroup': PropertySchema(id: 1, name: r'isGroup', type: IsarType.bool),
    r'kind': PropertySchema(id: 2, name: r'kind', type: IsarType.long),
    r'messageId': PropertySchema(
      id: 3,
      name: r'messageId',
      type: IsarType.long,
    ),
    r'ownerId': PropertySchema(id: 4, name: r'ownerId', type: IsarType.long),
    r'payload': PropertySchema(
      id: 5,
      name: r'payload',
      type: IsarType.longList,
    ),
    r'payloadType': PropertySchema(
      id: 6,
      name: r'payloadType',
      type: IsarType.string,
    ),
    r'status': PropertySchema(id: 7, name: r'status', type: IsarType.long),
    r'targetId': PropertySchema(id: 8, name: r'targetId', type: IsarType.long),
  },
  estimateSize: _outboxMessageEntityEstimateSize,
  serialize: _outboxMessageEntitySerialize,
  deserialize: _outboxMessageEntityDeserialize,
  deserializeProp: _outboxMessageEntityDeserializeProp,
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
    r'targetId': IndexSchema(
      id: -7400732725972739031,
      name: r'targetId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'targetId',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'createdAt': IndexSchema(
      id: -3433535483987302584,
      name: r'createdAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'createdAt',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},
  getId: _outboxMessageEntityGetId,
  getLinks: _outboxMessageEntityGetLinks,
  attach: _outboxMessageEntityAttach,
  version: '3.1.0+1',
);

int _outboxMessageEntityEstimateSize(
  OutboxMessageEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.payload.length * 8;
  bytesCount += 3 + object.payloadType.length * 3;
  return bytesCount;
}

void _outboxMessageEntitySerialize(
  OutboxMessageEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.createdAt);
  writer.writeBool(offsets[1], object.isGroup);
  writer.writeLong(offsets[2], object.kind);
  writer.writeLong(offsets[3], object.messageId);
  writer.writeLong(offsets[4], object.ownerId);
  writer.writeLongList(offsets[5], object.payload);
  writer.writeString(offsets[6], object.payloadType);
  writer.writeLong(offsets[7], object.status);
  writer.writeLong(offsets[8], object.targetId);
}

OutboxMessageEntity _outboxMessageEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = OutboxMessageEntity();
  object.createdAt = reader.readLong(offsets[0]);
  object.id = id;
  object.isGroup = reader.readBool(offsets[1]);
  object.kind = reader.readLong(offsets[2]);
  object.messageId = reader.readLongOrNull(offsets[3]);
  object.ownerId = reader.readLong(offsets[4]);
  object.payload = reader.readLongList(offsets[5]) ?? [];
  object.payloadType = reader.readString(offsets[6]);
  object.status = reader.readLong(offsets[7]);
  object.targetId = reader.readLong(offsets[8]);
  return object;
}

P _outboxMessageEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readLongList(offset) ?? []) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _outboxMessageEntityGetId(OutboxMessageEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _outboxMessageEntityGetLinks(
  OutboxMessageEntity object,
) {
  return [];
}

void _outboxMessageEntityAttach(
  IsarCollection<dynamic> col,
  Id id,
  OutboxMessageEntity object,
) {
  object.id = id;
}

extension OutboxMessageEntityQueryWhereSort
    on QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QWhere> {
  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterWhere>
  anyOwnerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'ownerId'),
      );
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterWhere>
  anyTargetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'targetId'),
      );
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterWhere>
  anyCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'createdAt'),
      );
    });
  }
}

extension OutboxMessageEntityQueryWhere
    on QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QWhereClause> {
  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterWhereClause>
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

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterWhereClause>
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

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterWhereClause>
  ownerIdEqualTo(int ownerId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'ownerId', value: [ownerId]),
      );
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterWhereClause>
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

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterWhereClause>
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

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterWhereClause>
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

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterWhereClause>
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

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterWhereClause>
  targetIdEqualTo(int targetId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'targetId', value: [targetId]),
      );
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterWhereClause>
  targetIdNotEqualTo(int targetId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'targetId',
                lower: [],
                upper: [targetId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'targetId',
                lower: [targetId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'targetId',
                lower: [targetId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'targetId',
                lower: [],
                upper: [targetId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterWhereClause>
  targetIdGreaterThan(int targetId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'targetId',
          lower: [targetId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterWhereClause>
  targetIdLessThan(int targetId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'targetId',
          lower: [],
          upper: [targetId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterWhereClause>
  targetIdBetween(
    int lowerTargetId,
    int upperTargetId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'targetId',
          lower: [lowerTargetId],
          includeLower: includeLower,
          upper: [upperTargetId],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterWhereClause>
  createdAtEqualTo(int createdAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'createdAt', value: [createdAt]),
      );
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterWhereClause>
  createdAtNotEqualTo(int createdAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'createdAt',
                lower: [],
                upper: [createdAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'createdAt',
                lower: [createdAt],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'createdAt',
                lower: [createdAt],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'createdAt',
                lower: [],
                upper: [createdAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterWhereClause>
  createdAtGreaterThan(int createdAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'createdAt',
          lower: [createdAt],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterWhereClause>
  createdAtLessThan(int createdAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'createdAt',
          lower: [],
          upper: [createdAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterWhereClause>
  createdAtBetween(
    int lowerCreatedAt,
    int upperCreatedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'createdAt',
          lower: [lowerCreatedAt],
          includeLower: includeLower,
          upper: [upperCreatedAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension OutboxMessageEntityQueryFilter
    on
        QueryBuilder<
          OutboxMessageEntity,
          OutboxMessageEntity,
          QFilterCondition
        > {
  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterFilterCondition>
  createdAtEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterFilterCondition>
  createdAtGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterFilterCondition>
  createdAtLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterFilterCondition>
  createdAtBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterFilterCondition>
  isGroupEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isGroup', value: value),
      );
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterFilterCondition>
  kindEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'kind', value: value),
      );
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterFilterCondition>
  messageIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'messageId'),
      );
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterFilterCondition>
  messageIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'messageId'),
      );
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterFilterCondition>
  messageIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'messageId', value: value),
      );
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterFilterCondition>
  messageIdGreaterThan(int? value, {bool include = false}) {
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

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterFilterCondition>
  messageIdLessThan(int? value, {bool include = false}) {
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

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterFilterCondition>
  messageIdBetween(
    int? lower,
    int? upper, {
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

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterFilterCondition>
  ownerIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'ownerId', value: value),
      );
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterFilterCondition>
  payloadElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'payload', value: value),
      );
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterFilterCondition>
  payloadLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'payload', length, true, length, true);
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterFilterCondition>
  payloadIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'payload', 0, true, 0, true);
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterFilterCondition>
  payloadIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'payload', 0, false, 999999, true);
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterFilterCondition>
  payloadLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'payload', 0, true, length, include);
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterFilterCondition>
  payloadLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'payload', length, include, 999999, true);
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterFilterCondition>
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

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterFilterCondition>
  payloadTypeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'payloadType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterFilterCondition>
  payloadTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'payloadType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterFilterCondition>
  payloadTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'payloadType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterFilterCondition>
  payloadTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'payloadType',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterFilterCondition>
  payloadTypeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'payloadType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterFilterCondition>
  payloadTypeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'payloadType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterFilterCondition>
  payloadTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'payloadType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterFilterCondition>
  payloadTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'payloadType',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterFilterCondition>
  payloadTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'payloadType', value: ''),
      );
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterFilterCondition>
  payloadTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'payloadType', value: ''),
      );
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterFilterCondition>
  statusEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'status', value: value),
      );
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterFilterCondition>
  statusGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'status',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterFilterCondition>
  statusLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'status',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterFilterCondition>
  statusBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'status',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterFilterCondition>
  targetIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'targetId', value: value),
      );
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterFilterCondition>
  targetIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'targetId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterFilterCondition>
  targetIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'targetId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterFilterCondition>
  targetIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'targetId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension OutboxMessageEntityQueryObject
    on
        QueryBuilder<
          OutboxMessageEntity,
          OutboxMessageEntity,
          QFilterCondition
        > {}

extension OutboxMessageEntityQueryLinks
    on
        QueryBuilder<
          OutboxMessageEntity,
          OutboxMessageEntity,
          QFilterCondition
        > {}

extension OutboxMessageEntityQuerySortBy
    on QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QSortBy> {
  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterSortBy>
  sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterSortBy>
  sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterSortBy>
  sortByIsGroup() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isGroup', Sort.asc);
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterSortBy>
  sortByIsGroupDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isGroup', Sort.desc);
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterSortBy>
  sortByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterSortBy>
  sortByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterSortBy>
  sortByMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageId', Sort.asc);
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterSortBy>
  sortByMessageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageId', Sort.desc);
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterSortBy>
  sortByOwnerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerId', Sort.asc);
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterSortBy>
  sortByOwnerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerId', Sort.desc);
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterSortBy>
  sortByPayloadType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payloadType', Sort.asc);
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterSortBy>
  sortByPayloadTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payloadType', Sort.desc);
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterSortBy>
  sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterSortBy>
  sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterSortBy>
  sortByTargetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetId', Sort.asc);
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterSortBy>
  sortByTargetIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetId', Sort.desc);
    });
  }
}

extension OutboxMessageEntityQuerySortThenBy
    on QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QSortThenBy> {
  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterSortBy>
  thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterSortBy>
  thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterSortBy>
  thenByIsGroup() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isGroup', Sort.asc);
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterSortBy>
  thenByIsGroupDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isGroup', Sort.desc);
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterSortBy>
  thenByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterSortBy>
  thenByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterSortBy>
  thenByMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageId', Sort.asc);
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterSortBy>
  thenByMessageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageId', Sort.desc);
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterSortBy>
  thenByOwnerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerId', Sort.asc);
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterSortBy>
  thenByOwnerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerId', Sort.desc);
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterSortBy>
  thenByPayloadType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payloadType', Sort.asc);
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterSortBy>
  thenByPayloadTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payloadType', Sort.desc);
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterSortBy>
  thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterSortBy>
  thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterSortBy>
  thenByTargetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetId', Sort.asc);
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QAfterSortBy>
  thenByTargetIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetId', Sort.desc);
    });
  }
}

extension OutboxMessageEntityQueryWhereDistinct
    on QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QDistinct> {
  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QDistinct>
  distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QDistinct>
  distinctByIsGroup() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isGroup');
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QDistinct>
  distinctByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kind');
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QDistinct>
  distinctByMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'messageId');
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QDistinct>
  distinctByOwnerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ownerId');
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QDistinct>
  distinctByPayload() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'payload');
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QDistinct>
  distinctByPayloadType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'payloadType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QDistinct>
  distinctByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status');
    });
  }

  QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QDistinct>
  distinctByTargetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetId');
    });
  }
}

extension OutboxMessageEntityQueryProperty
    on QueryBuilder<OutboxMessageEntity, OutboxMessageEntity, QQueryProperty> {
  QueryBuilder<OutboxMessageEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<OutboxMessageEntity, int, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<OutboxMessageEntity, bool, QQueryOperations> isGroupProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isGroup');
    });
  }

  QueryBuilder<OutboxMessageEntity, int, QQueryOperations> kindProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kind');
    });
  }

  QueryBuilder<OutboxMessageEntity, int?, QQueryOperations>
  messageIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'messageId');
    });
  }

  QueryBuilder<OutboxMessageEntity, int, QQueryOperations> ownerIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ownerId');
    });
  }

  QueryBuilder<OutboxMessageEntity, List<int>, QQueryOperations>
  payloadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'payload');
    });
  }

  QueryBuilder<OutboxMessageEntity, String, QQueryOperations>
  payloadTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'payloadType');
    });
  }

  QueryBuilder<OutboxMessageEntity, int, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<OutboxMessageEntity, int, QQueryOperations> targetIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetId');
    });
  }
}
