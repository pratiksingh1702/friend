import 'package:fluent_ui/fluent_ui.dart';

class AreaSelectionOverlay extends StatefulWidget {
  final Function(Rect) onAreaSelected;
  const AreaSelectionOverlay({super.key, required this.onAreaSelected});

  @override
  State<AreaSelectionOverlay> createState() => _AreaSelectionOverlayState();
}

class _AreaSelectionOverlayState extends State<AreaSelectionOverlay> {
  Offset? _start;
  Offset? _end;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) => setState(() => _start = details.localPosition),
      onPanUpdate: (details) => setState(() => _end = details.localPosition),
      onPanEnd: (details) {
        if (_start != null && _end != null) {
          final rect = Rect.fromPoints(_start!, _end!);
          widget.onAreaSelected(rect);
        }
        setState(() {
          _start = null;
          _end = null;
        });
      },
      child: Container(
        color: Colors.black.withOpacity(0.3),
        child: Stack(
          children: [
            if (_start != null && _end != null)
              Positioned.fromRect(
                rect: Rect.fromPoints(_start!, _end!),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green, width: 2),
                    color: Colors.green.withOpacity(0.1),
                  ),
                ),
              ),
            const Center(
              child: Text(
                'Click and drag to select OCR area',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
