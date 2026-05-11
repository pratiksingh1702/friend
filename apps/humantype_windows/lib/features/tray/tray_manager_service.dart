import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

class TrayManagerService with TrayListener {
  static final TrayManagerService _instance = TrayManagerService._internal();
  factory TrayManagerService() => _instance;
  TrayManagerService._internal();

  Future<void> init() async {
    await trayManager.setIcon('assets/app_icon.ico'); // Make sure this exists later
    
    List<MenuItem> items = [
      MenuItem(
        key: 'show_window',
        label: 'Show Dashboard',
      ),
      MenuItem.separator(),
      MenuItem(
        key: 'exit_app',
        label: 'Exit HumanType',
      ),
    ];
    Menu menu = Menu(items: items);
    await trayManager.setContextMenu(menu);
    trayManager.addListener(this);
  }

  @override
  void onTrayIconMouseDown() {
    windowManager.show();
    windowManager.focus();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    if (menuItem.key == 'show_window') {
      windowManager.show();
      windowManager.focus();
    } else if (menuItem.key == 'exit_app') {
      await windowManager.close();
    }
  }
}
