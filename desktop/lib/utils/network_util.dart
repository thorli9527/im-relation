import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkUtil {
  /// 检查设备是否有网络连接
  static Future<bool> hasNetworkConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  /// 获取当前网络类型
  static Future<String> getNetworkType() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    switch (connectivityResult) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.none:
        return 'None';
      default:
        return 'Unknown';
    }
  }
}
