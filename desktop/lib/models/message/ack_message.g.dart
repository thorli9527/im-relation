// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ack_message.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAckMessageCollection on Isar {
  IsarCollection<AckMessage> get ackMessages => this.collection();
}

const AckMessageSchema = CollectionSchema(
  name: r'AckMessage',
  id: -6912835618639380575,
  properties: {
    r'ackTimestamp': PropertySchema(
      id: 0,
      name: r'ackTimestamp',
      type: IsarType.dateTime,
    ),
    r'errorCode': PropertySchema(
      id: 1,
      name: r'errorCode',
      type: IsarType.long,
    ),
    r'lastSendTime': PropertySchema(
      id: 2,
      name: r'lastSendTime',
      type: IsarType.dateTime,
    ),
    r'maxRetries': PropertySchema(
      id: 3,
      name: r'maxRetries',
      type: IsarType.long,
    ),
    r'messageId': PropertySchema(
      id: 4,
      name: r'messageId',
      type: IsarType.long,
    ),
    r'messageType': PropertySchema(
      id: 5,
      name: r'messageType',
      type: IsarType.long,
    ),
    r'retryCount': PropertySchema(
      id: 6,
      name: r'retryCount',
      type: IsarType.long,
    ),
    r'retryInterval': PropertySchema(
      id: 7,
      name: r'retryInterval',
      type: IsarType.long,
    ),
    r'status': PropertySchema(
      id: 8,
      name: r'status',
      type: IsarType.string,
      enumMap: _AckMessagestatusEnumValueMap,
    ),
    r'timestamp': PropertySchema(
      id: 9,
      name: r'timestamp',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _ackMessageEstimateSize,
  serialize: _ackMessageSerialize,
  deserialize: _ackMessageDeserialize,
  deserializeProp: _ackMessageDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _ackMessageGetId,
  getLinks: _ackMessageGetLinks,
  attach: _ackMessageAttach,
  version: '3.1.0+1',
);

int _ackMessageEstimateSize(
  AckMessage object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.status.name.length * 3;
  return bytesCount;
}

void _ackMessageSerialize(
  AckMessage object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.ackTimestamp);
  writer.writeLong(offsets[1], object.errorCode);
  writer.writeDateTime(offsets[2], object.lastSendTime);
  writer.writeLong(offsets[3], object.maxRetries);
  writer.writeLong(offsets[4], object.messageId);
  writer.writeLong(offsets[5], object.messageType);
  writer.writeLong(offsets[6], object.retryCount);
  writer.writeLong(offsets[7], object.retryInterval);
  writer.writeString(offsets[8], object.status.name);
  writer.writeDateTime(offsets[9], object.timestamp);
}

AckMessage _ackMessageDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AckMessage(
    ackTimestamp: reader.readDateTimeOrNull(offsets[0]),
    errorCode: reader.readLongOrNull(offsets[1]),
    lastSendTime: reader.readDateTimeOrNull(offsets[2]),
    maxRetries: reader.readLongOrNull(offsets[3]) ?? 3,
    messageId: reader.readLong(offsets[4]),
    messageType: reader.readLong(offsets[5]),
    retryCount: reader.readLongOrNull(offsets[6]) ?? 0,
    retryInterval: reader.readLongOrNull(offsets[7]) ?? 1000,
    status:
        _AckMessagestatusValueEnumMap[reader.readStringOrNull(offsets[8])] ??
            AckStatus.pending,
  );
  object.id = id;
  object.timestamp = reader.readDateTime(offsets[9]);
  return object;
}

P _ackMessageDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset) ?? 3) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 7:
      return (reader.readLongOrNull(offset) ?? 1000) as P;
    case 8:
      return (_AckMessagestatusValueEnumMap[reader.readStringOrNull(offset)] ??
          AckStatus.pending) as P;
    case 9:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _AckMessagestatusEnumValueMap = {
  r'pending': r'pending',
  r'sent': r'sent',
  r'acknowledged': r'acknowledged',
  r'failed': r'failed',
  r'timeout': r'timeout',
  r'offline': r'offline',
};
const _AckMessagestatusValueEnumMap = {
  r'pending': AckStatus.pending,
  r'sent': AckStatus.sent,
  r'acknowledged': AckStatus.acknowledged,
  r'failed': AckStatus.failed,
  r'timeout': AckStatus.timeout,
  r'offline': AckStatus.offline,
};

Id _ackMessageGetId(AckMessage object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _ackMessageGetLinks(AckMessage object) {
  return [];
}

void _ackMessageAttach(IsarCollection<dynamic> col, Id id, AckMessage object) {
  object.id = id;
}

extension AckMessageQueryWhereSort
    on QueryBuilder<AckMessage, AckMessage, QWhere> {
  QueryBuilder<AckMessage, AckMessage, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AckMessageQueryWhere
    on QueryBuilder<AckMessage, AckMessage, QWhereClause> {
  QueryBuilder<AckMessage, AckMessage, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<AckMessage, AckMessage, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterWhereClause> idBetween(
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
}

extension AckMessageQueryFilter
    on QueryBuilder<AckMessage, AckMessage, QFilterCondition> {
  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition>
      ackTimestampIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'ackTimestamp',
      ));
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition>
      ackTimestampIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'ackTimestamp',
      ));
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition>
      ackTimestampEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ackTimestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition>
      ackTimestampGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ackTimestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition>
      ackTimestampLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ackTimestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition>
      ackTimestampBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ackTimestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition>
      errorCodeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'errorCode',
      ));
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition>
      errorCodeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'errorCode',
      ));
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition> errorCodeEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'errorCode',
        value: value,
      ));
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition>
      errorCodeGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'errorCode',
        value: value,
      ));
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition> errorCodeLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'errorCode',
        value: value,
      ));
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition> errorCodeBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'errorCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition> idBetween(
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

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition>
      lastSendTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastSendTime',
      ));
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition>
      lastSendTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastSendTime',
      ));
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition>
      lastSendTimeEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSendTime',
        value: value,
      ));
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition>
      lastSendTimeGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastSendTime',
        value: value,
      ));
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition>
      lastSendTimeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastSendTime',
        value: value,
      ));
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition>
      lastSendTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastSendTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition> maxRetriesEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maxRetries',
        value: value,
      ));
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition>
      maxRetriesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'maxRetries',
        value: value,
      ));
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition>
      maxRetriesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'maxRetries',
        value: value,
      ));
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition> maxRetriesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'maxRetries',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition> messageIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'messageId',
        value: value,
      ));
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition>
      messageIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'messageId',
        value: value,
      ));
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition> messageIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'messageId',
        value: value,
      ));
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition> messageIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'messageId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition>
      messageTypeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'messageType',
        value: value,
      ));
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition>
      messageTypeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'messageType',
        value: value,
      ));
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition>
      messageTypeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'messageType',
        value: value,
      ));
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition>
      messageTypeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'messageType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition> retryCountEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'retryCount',
        value: value,
      ));
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition>
      retryCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'retryCount',
        value: value,
      ));
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition>
      retryCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'retryCount',
        value: value,
      ));
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition> retryCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'retryCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition>
      retryIntervalEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'retryInterval',
        value: value,
      ));
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition>
      retryIntervalGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'retryInterval',
        value: value,
      ));
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition>
      retryIntervalLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'retryInterval',
        value: value,
      ));
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition>
      retryIntervalBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'retryInterval',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition> statusEqualTo(
    AckStatus value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition> statusGreaterThan(
    AckStatus value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition> statusLessThan(
    AckStatus value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition> statusBetween(
    AckStatus lower,
    AckStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition> statusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition> statusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition> statusContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition> statusMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition> statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition> timestampEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition>
      timestampGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition> timestampLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterFilterCondition> timestampBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AckMessageQueryObject
    on QueryBuilder<AckMessage, AckMessage, QFilterCondition> {}

extension AckMessageQueryLinks
    on QueryBuilder<AckMessage, AckMessage, QFilterCondition> {}

extension AckMessageQuerySortBy
    on QueryBuilder<AckMessage, AckMessage, QSortBy> {
  QueryBuilder<AckMessage, AckMessage, QAfterSortBy> sortByAckTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ackTimestamp', Sort.asc);
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterSortBy> sortByAckTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ackTimestamp', Sort.desc);
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterSortBy> sortByErrorCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorCode', Sort.asc);
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterSortBy> sortByErrorCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorCode', Sort.desc);
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterSortBy> sortByLastSendTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSendTime', Sort.asc);
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterSortBy> sortByLastSendTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSendTime', Sort.desc);
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterSortBy> sortByMaxRetries() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxRetries', Sort.asc);
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterSortBy> sortByMaxRetriesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxRetries', Sort.desc);
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterSortBy> sortByMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageId', Sort.asc);
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterSortBy> sortByMessageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageId', Sort.desc);
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterSortBy> sortByMessageType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageType', Sort.asc);
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterSortBy> sortByMessageTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageType', Sort.desc);
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterSortBy> sortByRetryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryCount', Sort.asc);
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterSortBy> sortByRetryCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryCount', Sort.desc);
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterSortBy> sortByRetryInterval() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryInterval', Sort.asc);
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterSortBy> sortByRetryIntervalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryInterval', Sort.desc);
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterSortBy> sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterSortBy> sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension AckMessageQuerySortThenBy
    on QueryBuilder<AckMessage, AckMessage, QSortThenBy> {
  QueryBuilder<AckMessage, AckMessage, QAfterSortBy> thenByAckTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ackTimestamp', Sort.asc);
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterSortBy> thenByAckTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ackTimestamp', Sort.desc);
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterSortBy> thenByErrorCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorCode', Sort.asc);
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterSortBy> thenByErrorCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorCode', Sort.desc);
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterSortBy> thenByLastSendTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSendTime', Sort.asc);
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterSortBy> thenByLastSendTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSendTime', Sort.desc);
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterSortBy> thenByMaxRetries() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxRetries', Sort.asc);
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterSortBy> thenByMaxRetriesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxRetries', Sort.desc);
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterSortBy> thenByMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageId', Sort.asc);
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterSortBy> thenByMessageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageId', Sort.desc);
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterSortBy> thenByMessageType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageType', Sort.asc);
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterSortBy> thenByMessageTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageType', Sort.desc);
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterSortBy> thenByRetryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryCount', Sort.asc);
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterSortBy> thenByRetryCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryCount', Sort.desc);
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterSortBy> thenByRetryInterval() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryInterval', Sort.asc);
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterSortBy> thenByRetryIntervalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryInterval', Sort.desc);
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterSortBy> thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<AckMessage, AckMessage, QAfterSortBy> thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension AckMessageQueryWhereDistinct
    on QueryBuilder<AckMessage, AckMessage, QDistinct> {
  QueryBuilder<AckMessage, AckMessage, QDistinct> distinctByAckTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ackTimestamp');
    });
  }

  QueryBuilder<AckMessage, AckMessage, QDistinct> distinctByErrorCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'errorCode');
    });
  }

  QueryBuilder<AckMessage, AckMessage, QDistinct> distinctByLastSendTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSendTime');
    });
  }

  QueryBuilder<AckMessage, AckMessage, QDistinct> distinctByMaxRetries() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maxRetries');
    });
  }

  QueryBuilder<AckMessage, AckMessage, QDistinct> distinctByMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'messageId');
    });
  }

  QueryBuilder<AckMessage, AckMessage, QDistinct> distinctByMessageType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'messageType');
    });
  }

  QueryBuilder<AckMessage, AckMessage, QDistinct> distinctByRetryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'retryCount');
    });
  }

  QueryBuilder<AckMessage, AckMessage, QDistinct> distinctByRetryInterval() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'retryInterval');
    });
  }

  QueryBuilder<AckMessage, AckMessage, QDistinct> distinctByStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AckMessage, AckMessage, QDistinct> distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }
}

extension AckMessageQueryProperty
    on QueryBuilder<AckMessage, AckMessage, QQueryProperty> {
  QueryBuilder<AckMessage, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AckMessage, DateTime?, QQueryOperations> ackTimestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ackTimestamp');
    });
  }

  QueryBuilder<AckMessage, int?, QQueryOperations> errorCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'errorCode');
    });
  }

  QueryBuilder<AckMessage, DateTime?, QQueryOperations> lastSendTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSendTime');
    });
  }

  QueryBuilder<AckMessage, int, QQueryOperations> maxRetriesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maxRetries');
    });
  }

  QueryBuilder<AckMessage, int, QQueryOperations> messageIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'messageId');
    });
  }

  QueryBuilder<AckMessage, int, QQueryOperations> messageTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'messageType');
    });
  }

  QueryBuilder<AckMessage, int, QQueryOperations> retryCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'retryCount');
    });
  }

  QueryBuilder<AckMessage, int, QQueryOperations> retryIntervalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'retryInterval');
    });
  }

  QueryBuilder<AckMessage, AckStatus, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<AckMessage, DateTime, QQueryOperations> timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }
}
