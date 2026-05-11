import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../sync/services/android_sync_service.dart';
import '../services/field_mapper.dart';

class HighlightOverlay extends ConsumerWidget {
  const HighlightOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(androidSyncStateProvider);
    final fieldId = syncState.highlightFieldId;

    if (fieldId == null) return const SizedBox.shrink();

    final fields = ref.watch(fieldMapperProvider);
    final field = fields.where((e) => e.id == fieldId).firstOrNull;

    if (field == null) return const SizedBox.shrink();

    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            left: field.x - 25,
            top: field.y - 25,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 1.0, end: 1.5),
                duration: const Duration(milliseconds: 500),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue.withOpacity(0.5), width: 2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
