import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

class WdaManager {
  /// Enables/Disables screen capture protection for the given HWND.
  /// When enabled, the window will appear black or be completely omitted 
  /// from screenshots and screen recordings (OBS, Snipping Tool, etc.)
  static void setExcludeFromCapture(int hwnd, bool exclude) {
    // WDA_EXCLUDEFROMCAPTURE = 0x00000011
    // WDA_NONE = 0x00000000
    final int affinity = exclude ? 0x00000011 : 0x00000000;
    
    final result = SetWindowDisplayAffinity(hwnd, affinity);
    
    if (result == 0) {
      print('[WdaManager] Failed to set window display affinity. Error: ${GetLastError()}');
    } else {
      print('[WdaManager] Window display affinity set to: $affinity');
    }
  }

  /// Helper to find the HWND of the current Flutter window by title
  static int findWindow(String title) {
    final TEXT_title = title.toNativeUtf16();
    final hwnd = FindWindow(nullptr, TEXT_title);
    free(TEXT_title);
    return hwnd;
  }
}
