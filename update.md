# Update

Date: 2026-05-11

## Summary
- Initialized Flutter Android app scaffold at apps/humantype_android.
- Initialized Flutter Windows app scaffold at apps/humantype_windows.
- Initialized shared Dart package scaffold at packages/humantype_shared.
- Created folder skeletons for shared package, Android features, Windows features, and bridge modules.
- Aligned pubspec dependencies and SDK constraints to match the provided spec for Android, Windows, and shared package.
- Replaced the default Android counter app with the HumanType shell (theme, router, and initial screens).
- Added shared package models, protocol types, and connection helpers for cross-platform use.
- Wired Android connection state to use shared connection models.
- Fixed Android theme and connection chip compile issues.

## Android App (Agent 1)
- App shell wired with GoRouter and Riverpod.
- Design system implemented in core theme and used across screens.
- Home screen with connection status chip, mode cards, and quick actions.
- Initial Connect, Text Mode, Code Mode, Templates, History, and Settings screens.

## Shared Package
- Added shared models: device, connected device, section, session, template, field map.
- Added protocol types: message types, message wrapper, capability model.
- Added connection helpers: device registry, message router, mDNS placeholder.
- Exports consolidated via humantype_shared.dart.

## Commands Run
- flutter create --org com.humantype --platforms=android apps/humantype_android
- flutter create --org com.humantype --platforms=windows apps/humantype_windows
- flutter create --template=package packages/humantype_shared

## Notes
- pubspec updates were applied for dependencies and environment constraints.
- Shared package now exports all models and protocol types via humantype_shared.dart.
- Date parsing in shared models now handles missing timestamps safely.
- Connection status chip now explicitly references shared connection enums.
