import 'dart:io';
import 'package:fixnum/fixnum.dart';
import 'package:path_provider/path_provider.dart';

//
// class SnowflakeIdGenerator {
//   static const int datacenterBits = 5;
//   static const int workerBits = 5;
//   static const int sequenceBits = 12;
//
//   static const int maxDatacenterId = (1 << datacenterBits) - 1; // 31
//   static const int maxWorkerId = (1 << workerBits) - 1;         // 31
//   static const int sequenceMask = (1 << sequenceBits) - 1;      // 4095
//
//   final int datacenterId;
//   final int workerId;
//
//   late int _epoch;
//   int _lastTimestamp = -1;
//   int _sequence = 0;
//
//   SnowflakeIdGenerator({
//     required this.datacenterId,
//     required this.workerId,
//   }) {
//     if (datacenterId > maxDatacenterId || workerId > maxWorkerId) {
//       throw ArgumentError("Invalid datacenterId or workerId");
//     }
//   }
//
//   /// 初始化 epoch，持久化首次启动时间
//   Future<void> init() async {
//     final dir = await getApplicationDocumentsDirectory();
//     final file = File('${dir.path}/snowflake_epoch.txt');
//     if (await file.exists()) {
//       _epoch = int.tryParse(await file.readAsString()) ?? _currentTimeMillis();
//     } else {
//       _epoch = _currentTimeMillis();
//       await file.writeAsString('$_epoch');
//     }
//   }
//
//   Int64 nextId() {
//     int timestamp = _currentTimeMillis();
//
//     if (timestamp < _lastTimestamp) {
//       throw Exception("Clock moved backwards");
//     }
//
//     if (timestamp == _lastTimestamp) {
//       _sequence = (_sequence + 1) & sequenceMask;
//       if (_sequence == 0) {
//         // wait next millis
//         while ((timestamp = _currentTimeMillis()) <= _lastTimestamp) {}
//       }
//     } else {
//       _sequence = 0;
//     }
//
//     _lastTimestamp = timestamp;
//
//     return Int64(((timestamp - _epoch) << (datacenterBits + workerBits + sequenceBits)) |
//     (datacenterId << (workerBits + sequenceBits)) |
//     (workerId << sequenceBits) |
//     _sequence);
//   }
//
//   int _currentTimeMillis() => DateTime.now().toUtc().millisecondsSinceEpoch;
// }
