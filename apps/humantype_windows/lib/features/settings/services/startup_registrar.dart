import 'dart:io';

/// Utility to register the Windows app for auto-launch at system startup.
/// Uses the Windows Registry via the 'reg add' command approach (no C FFI needed).
class StartupRegistrar {
  static const String _regKey =
      'HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Run';
  static const String _appName = 'HumanTypeWindows';

  /// Registers the current exe in the Windows startup registry.
  static Future<bool> enable() async {
    final String exePath = Platform.resolvedExecutable;
    try {
      final result = await Process.run(
        'reg',
        ['add', _regKey, '/v', _appName, '/t', 'REG_SZ', '/d', exePath, '/f'],
        runInShell: true,
      );
      if (result.exitCode == 0) {
        print('[StartupRegistrar] Registered for startup: $exePath');
        return true;
      } else {
        print('[StartupRegistrar] Failed: ${result.stderr}');
        return false;
      }
    } catch (e) {
      print('[StartupRegistrar] Error: $e');
      return false;
    }
  }

  /// Removes the app from the Windows startup registry.
  static Future<bool> disable() async {
    try {
      final result = await Process.run(
        'reg',
        ['delete', _regKey, '/v', _appName, '/f'],
        runInShell: true,
      );
      if (result.exitCode == 0) {
        print('[StartupRegistrar] Removed from startup.');
        return true;
      } else {
        print('[StartupRegistrar] Remove failed: ${result.stderr}');
        return false;
      }
    } catch (e) {
      print('[StartupRegistrar] Error: $e');
      return false;
    }
  }

  /// Checks if the app is currently registered for auto-start.
  static Future<bool> isEnabled() async {
    try {
      final result = await Process.run(
        'reg',
        ['query', _regKey, '/v', _appName],
        runInShell: true,
      );
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }
}
