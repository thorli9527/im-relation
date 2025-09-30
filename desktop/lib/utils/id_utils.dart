// lib/utils/id_utils.dart
import 'package:uuid/uuid.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import 'package:riverpod/riverpod.dart';
import 'package:im_client/services/app_config_service.dart';

import '../models/system/system_config.dart';

class IdUtils {
    // 单例 UUID 生成器
    static final Uuid _uuid = Uuid();

    // 静态变量存储单例 SafeSnowflake 实例
    static SafeSnowflake? _generator;

    // 静态变量存储 ProviderContainer 引用
    static ProviderContainer? _container;

    /// 设置 ProviderContainer 引用
    static void setContainer(ProviderContainer container) {
        _container = container;
    }

    /// 获取设备ID哈希码
    static Future<String> _getDeviceIdHash() async {
        if (_container == null) {
            // 如果没有容器，返回默认值
            return 'default-device-id';
        }

        try {
            final appConfigService = await _container!.read(appConfigServiceProvider.future);
            final result = await appConfigService.getString(ConfigTypeEnum.DEVICE_ID);

            return result.fold(
                (deviceId) => deviceId,
                (exception) => 'default-device-id',
            );
        } catch (e) {
            // 出现错误时返回默认值
            return 'default-device-id';
        }
    }

    /// 获取单例 SafeSnowflake 实例
    static Future<SafeSnowflake> _getGenerator() async {
        if (_generator == null) {
            // 获取设备ID哈希码作为 nodeId
            final deviceId = await _getDeviceIdHash();
            final nodeId = deviceId.hashCode & 0x1F; // 限制在5位范围内
            _generator = SafeSnowflake(nodeId: nodeId, workerId: 7);
        }
        return _generator!;
    }

    /// 生成 UUID v4（随机）
    static String buildUuid() {
        return _uuid.v4().replaceAll("-", "");
    }

    /// 生成雪花 ID（53-bit 有序唯一 ID）
    static Future<int> buildSnowflake() async {
        final generator = await _getGenerator();
        return generator.generate();
    }
}


class SafeSnowflake {
    int nodeId;
    int workerId;
    int sequence = 0;
    int lastTimestamp = 0;

    SafeSnowflake({required int nodeId, required int workerId})
        : nodeId = nodeId & 0x1F, // 保留5位
            workerId = workerId & 0x1F; // 保留5位

    int currentTimestamp() {
        return DateTime.now().millisecondsSinceEpoch; // 与 Rust 一致：毫秒时间戳
    }

    int generate() {
        int timestamp = currentTimestamp();

        if (timestamp == lastTimestamp) {
            sequence = (sequence + 1) & 0x03; // 保留2位
            if (sequence == 0) {
                // 等待下一毫秒
                while (timestamp <= lastTimestamp) {
                    timestamp = currentTimestamp();
                }
            }
        } else {
            sequence = 0;
        }

        lastTimestamp = timestamp;

        // 拼接为 53 位以内的 ID:
        // 41 bits timestamp | 5 bits node_id | 5 bits worker_id | 2 bits sequence
        return ((timestamp & 0x1FFFFFFFFFF) << 12) | // 41 bits
        ((nodeId & 0x1F) << 7) | // 5 bits
        ((workerId & 0x1F) << 2) | // 5 bits
        (sequence & 0x03); // 2 bits
    }
}
