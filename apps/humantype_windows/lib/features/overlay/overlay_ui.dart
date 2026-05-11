import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OverlayUI extends ConsumerWidget {
  const OverlayUI({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            const Divider(),
            _buildProgressSection(context),
            _buildLivePreview(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(FluentIcons.edit, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Text(
            'HumanType Live',
            style: FluentTheme.of(context).typography.bodyStrong?.copyWith(color: Colors.white),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(FluentIcons.chrome_minimize, size: 12, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progress', style: FluentTheme.of(context).typography.caption?.copyWith(color: Colors.grey[60])),
              Text('67%', style: FluentTheme.of(context).typography.caption?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          const ProgressBar(value: 67),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildStat(context, 'WPM', '68'),
              const SizedBox(width: 16),
              _buildStat(context, 'Chars', '847/1263'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: FluentTheme.of(context).typography.caption?.copyWith(color: Colors.grey[80], fontSize: 10)),
        Text(value, style: FluentTheme.of(context).typography.body?.copyWith(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildLivePreview(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Colors.white.withOpacity(0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LATEST OUTPUT',
            style: FluentTheme.of(context).typography.caption?.copyWith(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '"study at the University of D"',
            style: FluentTheme.of(context).typography.body?.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontFamily: 'Consolas',
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
