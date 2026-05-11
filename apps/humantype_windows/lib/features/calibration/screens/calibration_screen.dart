import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/field_mapper.dart';

class CalibrationScreen extends ConsumerStatefulWidget {
  const CalibrationScreen({super.key});

  @override
  ConsumerState<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends ConsumerState<CalibrationScreen> {
  bool _isCalibrating = false;

  @override
  Widget build(BuildContext context) {
    final fields = ref.watch(fieldMapperProvider);

    return ScaffoldPage(
      header: PageHeader(
        title: const Text('Field Calibration'),
        commandBar: CommandBar(
          mainAxisAlignment: MainAxisAlignment.end,
          primaryItems: [
            CommandBarButton(
              icon: const Icon(FluentIcons.add),
              label: const Text('Add Field'),
              onPressed: () => setState(() => _isCalibrating = true),
            ),
          ],
        ),
      ),
      content: Stack(
        children: [
          _buildFieldList(fields),
          if (_isCalibrating) _buildCalibrationOverlay(),
        ],
      ),
    );
  }

  Widget _buildFieldList(List<FieldMapEntry> fields) {
    if (fields.isEmpty) {
      return const Center(
        child: Text('No fields calibrated yet. Click "Add Field" to start.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: fields.length,
      itemBuilder: (context, index) {
        final field = fields[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(field.name),
            subtitle: Text('X: ${field.x.toInt()}, Y: ${field.y.toInt()}'),
            trailing: IconButton(
              icon: const Icon(FluentIcons.delete),
              onPressed: () => ref.read(fieldMapperProvider.notifier).removeEntry(field.id),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCalibrationOverlay() {
    return GestureDetector(
      onTapDown: (details) {
        _showNameDialog(details.globalPosition);
      },
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(FluentIcons.location, size: 48, color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Click exactly where the input field is on your screen',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '(The window will temporarily expand to full screen)',
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNameDialog(Offset position) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Name this field'),
        content: TextBox(
          controller: controller,
          placeholder: 'e.g. First Name, Password Field',
          autofocus: true,
        ),
        actions: [
          Button(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isCalibrating = false);
            },
          ),
          FilledButton(
            child: const Text('Save'),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final sw = MediaQuery.of(context).size.width;
                final sh = MediaQuery.of(context).size.height;
                ref.read(fieldMapperProvider.notifier).addEntry(
                      controller.text,
                      position.dx,
                      position.dy,
                      sw,
                      sh,
                    );
              }
              Navigator.pop(context);
              setState(() => _isCalibrating = false);
            },
          ),
        ],
      ),
    );
  }
}
