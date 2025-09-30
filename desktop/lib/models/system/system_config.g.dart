// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_config.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSystemConfigCollection on Isar {
  IsarCollection<SystemConfig> get systemConfigs => this.collection();
}

const SystemConfigSchema = CollectionSchema(
  name: r'SystemConfig',
  id: -3822612866438788313,
  properties: {
    r'configType': PropertySchema(
      id: 0,
      name: r'configType',
      type: IsarType.byte,
      enumMap: _SystemConfigconfigTypeEnumValueMap,
    ),
    r'content': PropertySchema(
      id: 1,
      name: r'content',
      type: IsarType.string,
    )
  },
  estimateSize: _systemConfigEstimateSize,
  serialize: _systemConfigSerialize,
  deserialize: _systemConfigDeserialize,
  deserializeProp: _systemConfigDeserializeProp,
  idName: r'id',
  indexes: {
    r'configType': IndexSchema(
      id: 1730793599322496673,
      name: r'configType',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'configType',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _systemConfigGetId,
  getLinks: _systemConfigGetLinks,
  attach: _systemConfigAttach,
  version: '3.1.0+1',
);

int _systemConfigEstimateSize(
  SystemConfig object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.content.length * 3;
  return bytesCount;
}

void _systemConfigSerialize(
  SystemConfig object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeByte(offsets[0], object.configType.index);
  writer.writeString(offsets[1], object.content);
}

SystemConfig _systemConfigDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SystemConfig();
  object.configType =
      _SystemConfigconfigTypeValueEnumMap[reader.readByteOrNull(offsets[0])] ??
          ConfigTypeEnum.LOGIN_STATUS;
  object.content = reader.readString(offsets[1]);
  object.id = id;
  return object;
}

P _systemConfigDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (_SystemConfigconfigTypeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          ConfigTypeEnum.LOGIN_STATUS) as P;
    case 1:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _SystemConfigconfigTypeEnumValueMap = {
  'LOGIN_STATUS': 0,
  'LOGIN_TYPE': 1,
  'LOGIN_CONTENT': 2,
  'TOKEN': 3,
  'UID': 4,
  'TOKEN_EXPIRE_TIME': 5,
  'THEME_MODE': 6,
  'FIRST_START_TIME': 7,
  'NICKNAME': 8,
  'AVATAR': 9,
  'DEVICE_ID': 10,
};
const _SystemConfigconfigTypeValueEnumMap = {
  0: ConfigTypeEnum.LOGIN_STATUS,
  1: ConfigTypeEnum.LOGIN_TYPE,
  2: ConfigTypeEnum.LOGIN_CONTENT,
  3: ConfigTypeEnum.TOKEN,
  4: ConfigTypeEnum.UID,
  5: ConfigTypeEnum.TOKEN_EXPIRE_TIME,
  6: ConfigTypeEnum.THEME_MODE,
  7: ConfigTypeEnum.FIRST_START_TIME,
  8: ConfigTypeEnum.NICKNAME,
  9: ConfigTypeEnum.AVATAR,
  10: ConfigTypeEnum.DEVICE_ID,
};

Id _systemConfigGetId(SystemConfig object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _systemConfigGetLinks(SystemConfig object) {
  return [];
}

void _systemConfigAttach(
    IsarCollection<dynamic> col, Id id, SystemConfig object) {
  object.id = id;
}

extension SystemConfigByIndex on IsarCollection<SystemConfig> {
  Future<SystemConfig?> getByConfigType(ConfigTypeEnum configType) {
    return getByIndex(r'configType', [configType]);
  }

  SystemConfig? getByConfigTypeSync(ConfigTypeEnum configType) {
    return getByIndexSync(r'configType', [configType]);
  }

  Future<bool> deleteByConfigType(ConfigTypeEnum configType) {
    return deleteByIndex(r'configType', [configType]);
  }

  bool deleteByConfigTypeSync(ConfigTypeEnum configType) {
    return deleteByIndexSync(r'configType', [configType]);
  }

  Future<List<SystemConfig?>> getAllByConfigType(
      List<ConfigTypeEnum> configTypeValues) {
    final values = configTypeValues.map((e) => [e]).toList();
    return getAllByIndex(r'configType', values);
  }

  List<SystemConfig?> getAllByConfigTypeSync(
      List<ConfigTypeEnum> configTypeValues) {
    final values = configTypeValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'configType', values);
  }

  Future<int> deleteAllByConfigType(List<ConfigTypeEnum> configTypeValues) {
    final values = configTypeValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'configType', values);
  }

  int deleteAllByConfigTypeSync(List<ConfigTypeEnum> configTypeValues) {
    final values = configTypeValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'configType', values);
  }

  Future<Id> putByConfigType(SystemConfig object) {
    return putByIndex(r'configType', object);
  }

  Id putByConfigTypeSync(SystemConfig object, {bool saveLinks = true}) {
    return putByIndexSync(r'configType', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByConfigType(List<SystemConfig> objects) {
    return putAllByIndex(r'configType', objects);
  }

  List<Id> putAllByConfigTypeSync(List<SystemConfig> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'configType', objects, saveLinks: saveLinks);
  }
}

extension SystemConfigQueryWhereSort
    on QueryBuilder<SystemConfig, SystemConfig, QWhere> {
  QueryBuilder<SystemConfig, SystemConfig, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<SystemConfig, SystemConfig, QAfterWhere> anyConfigType() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'configType'),
      );
    });
  }
}

extension SystemConfigQueryWhere
    on QueryBuilder<SystemConfig, SystemConfig, QWhereClause> {
  QueryBuilder<SystemConfig, SystemConfig, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SystemConfig, SystemConfig, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<SystemConfig, SystemConfig, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SystemConfig, SystemConfig, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SystemConfig, SystemConfig, QAfterWhereClause> idBetween(
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

  QueryBuilder<SystemConfig, SystemConfig, QAfterWhereClause> configTypeEqualTo(
      ConfigTypeEnum configType) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'configType',
        value: [configType],
      ));
    });
  }

  QueryBuilder<SystemConfig, SystemConfig, QAfterWhereClause>
      configTypeNotEqualTo(ConfigTypeEnum configType) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'configType',
              lower: [],
              upper: [configType],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'configType',
              lower: [configType],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'configType',
              lower: [configType],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'configType',
              lower: [],
              upper: [configType],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SystemConfig, SystemConfig, QAfterWhereClause>
      configTypeGreaterThan(
    ConfigTypeEnum configType, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'configType',
        lower: [configType],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<SystemConfig, SystemConfig, QAfterWhereClause>
      configTypeLessThan(
    ConfigTypeEnum configType, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'configType',
        lower: [],
        upper: [configType],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<SystemConfig, SystemConfig, QAfterWhereClause> configTypeBetween(
    ConfigTypeEnum lowerConfigType,
    ConfigTypeEnum upperConfigType, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'configType',
        lower: [lowerConfigType],
        includeLower: includeLower,
        upper: [upperConfigType],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SystemConfigQueryFilter
    on QueryBuilder<SystemConfig, SystemConfig, QFilterCondition> {
  QueryBuilder<SystemConfig, SystemConfig, QAfterFilterCondition>
      configTypeEqualTo(ConfigTypeEnum value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'configType',
        value: value,
      ));
    });
  }

  QueryBuilder<SystemConfig, SystemConfig, QAfterFilterCondition>
      configTypeGreaterThan(
    ConfigTypeEnum value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'configType',
        value: value,
      ));
    });
  }

  QueryBuilder<SystemConfig, SystemConfig, QAfterFilterCondition>
      configTypeLessThan(
    ConfigTypeEnum value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'configType',
        value: value,
      ));
    });
  }

  QueryBuilder<SystemConfig, SystemConfig, QAfterFilterCondition>
      configTypeBetween(
    ConfigTypeEnum lower,
    ConfigTypeEnum upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'configType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SystemConfig, SystemConfig, QAfterFilterCondition>
      contentEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SystemConfig, SystemConfig, QAfterFilterCondition>
      contentGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SystemConfig, SystemConfig, QAfterFilterCondition>
      contentLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SystemConfig, SystemConfig, QAfterFilterCondition>
      contentBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'content',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SystemConfig, SystemConfig, QAfterFilterCondition>
      contentStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SystemConfig, SystemConfig, QAfterFilterCondition>
      contentEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SystemConfig, SystemConfig, QAfterFilterCondition>
      contentContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SystemConfig, SystemConfig, QAfterFilterCondition>
      contentMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'content',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SystemConfig, SystemConfig, QAfterFilterCondition>
      contentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'content',
        value: '',
      ));
    });
  }

  QueryBuilder<SystemConfig, SystemConfig, QAfterFilterCondition>
      contentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'content',
        value: '',
      ));
    });
  }

  QueryBuilder<SystemConfig, SystemConfig, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SystemConfig, SystemConfig, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<SystemConfig, SystemConfig, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<SystemConfig, SystemConfig, QAfterFilterCondition> idBetween(
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
}

extension SystemConfigQueryObject
    on QueryBuilder<SystemConfig, SystemConfig, QFilterCondition> {}

extension SystemConfigQueryLinks
    on QueryBuilder<SystemConfig, SystemConfig, QFilterCondition> {}

extension SystemConfigQuerySortBy
    on QueryBuilder<SystemConfig, SystemConfig, QSortBy> {
  QueryBuilder<SystemConfig, SystemConfig, QAfterSortBy> sortByConfigType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'configType', Sort.asc);
    });
  }

  QueryBuilder<SystemConfig, SystemConfig, QAfterSortBy>
      sortByConfigTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'configType', Sort.desc);
    });
  }

  QueryBuilder<SystemConfig, SystemConfig, QAfterSortBy> sortByContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.asc);
    });
  }

  QueryBuilder<SystemConfig, SystemConfig, QAfterSortBy> sortByContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.desc);
    });
  }
}

extension SystemConfigQuerySortThenBy
    on QueryBuilder<SystemConfig, SystemConfig, QSortThenBy> {
  QueryBuilder<SystemConfig, SystemConfig, QAfterSortBy> thenByConfigType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'configType', Sort.asc);
    });
  }

  QueryBuilder<SystemConfig, SystemConfig, QAfterSortBy>
      thenByConfigTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'configType', Sort.desc);
    });
  }

  QueryBuilder<SystemConfig, SystemConfig, QAfterSortBy> thenByContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.asc);
    });
  }

  QueryBuilder<SystemConfig, SystemConfig, QAfterSortBy> thenByContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.desc);
    });
  }

  QueryBuilder<SystemConfig, SystemConfig, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SystemConfig, SystemConfig, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }
}

extension SystemConfigQueryWhereDistinct
    on QueryBuilder<SystemConfig, SystemConfig, QDistinct> {
  QueryBuilder<SystemConfig, SystemConfig, QDistinct> distinctByConfigType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'configType');
    });
  }

  QueryBuilder<SystemConfig, SystemConfig, QDistinct> distinctByContent(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'content', caseSensitive: caseSensitive);
    });
  }
}

extension SystemConfigQueryProperty
    on QueryBuilder<SystemConfig, SystemConfig, QQueryProperty> {
  QueryBuilder<SystemConfig, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SystemConfig, ConfigTypeEnum, QQueryOperations>
      configTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'configType');
    });
  }

  QueryBuilder<SystemConfig, String, QQueryOperations> contentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'content');
    });
  }
}
