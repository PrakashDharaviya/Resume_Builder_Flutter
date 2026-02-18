// Mock Network Info - UI Only
// No actual network checking

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async {
    // Mock always connected for UI testing
    await Future.delayed(const Duration(milliseconds: 100));
    return true;
  }
}
