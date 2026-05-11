import 'dart:math';

import 'package:flutter/material.dart';
import 'package:humantype_shared/humantype_shared.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme.dart';

class SectionBuilderSheet extends StatefulWidget {
  const SectionBuilderSheet({
    super.key,
    this.initial,
    required this.onSave,
  });

  final Section? initial;
  final ValueChanged<Section> onSave;

  @override
  State<SectionBuilderSheet> createState() => _SectionBuilderSheetState();
}

class _SectionBuilderSheetState extends State<SectionBuilderSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _contentController;
  late final TextEditingController _tabCountController;
  late final TextEditingController _fieldNameController;
  late final TextEditingController _preActionValueController;
  late final TextEditingController _postActionValueController;

  TargetType _targetType = TargetType.activeWindow;
  TypingMode _mode = TypingMode.text;
  SpeedProfileType _speedType = SpeedProfileType.medium;
  int _customWpm = 60;
  int _errorsPerLine = 0;
  CorrectionStyle _correctionStyle = CorrectionStyle.wordEnd;
  final Set<ErrorType> _errorTypes = {ErrorType.adjacentKey};
  PreActionType _preActionType = PreActionType.none;
  PostActionType _postActionType = PostActionType.none;
  bool _waitForManualStart = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _nameController = TextEditingController(text: initial?.name ?? '');
    _contentController = TextEditingController(text: initial?.content ?? '');
    _tabCountController = TextEditingController(
      text: initial?.target.tabCount?.toString() ?? '1',
    );
    _fieldNameController =
        TextEditingController(text: initial?.target.fieldName ?? '');
    _preActionValueController = TextEditingController();
    _postActionValueController = TextEditingController();

    if (initial != null) {
      _targetType = initial.target.type;
      _mode = initial.mode;
      _speedType = initial.speed.type;
      _customWpm = initial.speed.wpm;
      _errorsPerLine = initial.errors.errorsPerLine;
      _correctionStyle = initial.errors.correctionStyle;
      _errorTypes.clear();
      _errorTypes.addAll(initial.errors.allowedErrorTypes);
      _preActionType = initial.preAction.type;
      _postActionType = initial.postAction.type;
      _waitForManualStart = initial.waitForManualStart;
      if (initial.preAction.waitSeconds != null) {
        _preActionValueController.text =
            initial.preAction.waitSeconds.toString();
      } else if (initial.preAction.key != null) {
        _preActionValueController.text = initial.preAction.key!;
      } else if (initial.preAction.hotkey != null) {
        _preActionValueController.text = initial.preAction.hotkey!.join(',');
      }
      if (initial.postAction.waitSeconds != null) {
        _postActionValueController.text =
            initial.postAction.waitSeconds.toString();
      } else if (initial.postAction.key != null) {
        _postActionValueController.text = initial.postAction.key!;
      } else if (initial.postAction.hotkey != null) {
        _postActionValueController.text = initial.postAction.hotkey!.join(',');
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contentController.dispose();
    _tabCountController.dispose();
    _fieldNameController.dispose();
    _preActionValueController.dispose();
    _postActionValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(HumanTypeSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: HumanTypeSpacing.lg),
                decoration: BoxDecoration(
                  color: HumanTypeColors.borderDefault,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Text('Section setup', style: HumanTypeText.heading1),
            const SizedBox(height: HumanTypeSpacing.lg),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Section name'),
            ),
            const SizedBox(height: HumanTypeSpacing.md),
            TextField(
              controller: _contentController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Content'),
            ),
            const SizedBox(height: HumanTypeSpacing.lg),
            _buildTargetSelector(),
            const SizedBox(height: HumanTypeSpacing.lg),
            _buildModeSelector(),
            const SizedBox(height: HumanTypeSpacing.lg),
            _buildSpeedSelector(),
            const SizedBox(height: HumanTypeSpacing.lg),
            _buildErrorControls(),
            const SizedBox(height: HumanTypeSpacing.lg),
            _buildPreActionControls(),
            const SizedBox(height: HumanTypeSpacing.lg),
            _buildPostActionControls(),
            const SizedBox(height: HumanTypeSpacing.lg),
            SwitchListTile(
              value: _waitForManualStart,
              activeColor: HumanTypeColors.accentPrimary,
              onChanged: (value) {
                setState(() => _waitForManualStart = value);
              },
              title:
                  Text('Wait for manual start', style: HumanTypeText.bodyLarge),
              subtitle: Text(
                'Pause and wait for your tap before typing this section.',
                style: HumanTypeText.bodySmall,
              ),
            ),
            const SizedBox(height: HumanTypeSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: HumanTypeSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _save,
                    child: const Text('Save section'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: HumanTypeSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Target', style: HumanTypeText.heading2),
        const SizedBox(height: HumanTypeSpacing.sm),
        DropdownButtonFormField<TargetType>(
          value: _targetType,
          items: TargetType.values
              .map((value) => DropdownMenuItem(
                    value: value,
                    child: Text(value.name),
                  ))
              .toList(),
          onChanged: (value) => setState(() => _targetType = value!),
          decoration: const InputDecoration(labelText: 'Target type'),
        ),
        const SizedBox(height: HumanTypeSpacing.sm),
        if (_targetType == TargetType.tabN)
          TextField(
            controller: _tabCountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Tab count'),
          ),
        if (_targetType == TargetType.clickField)
          TextField(
            controller: _fieldNameController,
            decoration: const InputDecoration(labelText: 'Field name'),
          ),
      ],
    );
  }

  Widget _buildModeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mode', style: HumanTypeText.heading2),
        const SizedBox(height: HumanTypeSpacing.sm),
        DropdownButtonFormField<TypingMode>(
          value: _mode,
          items: TypingMode.values
              .map((value) => DropdownMenuItem(
                    value: value,
                    child: Text(value.name),
                  ))
              .toList(),
          onChanged: (value) => setState(() => _mode = value!),
          decoration: const InputDecoration(labelText: 'Typing mode'),
        ),
      ],
    );
  }

  Widget _buildSpeedSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Speed', style: HumanTypeText.heading2),
        const SizedBox(height: HumanTypeSpacing.sm),
        DropdownButtonFormField<SpeedProfileType>(
          value: _speedType,
          items: SpeedProfileType.values
              .map((value) => DropdownMenuItem(
                    value: value,
                    child: Text(value.name),
                  ))
              .toList(),
          onChanged: (value) => setState(() => _speedType = value!),
          decoration: const InputDecoration(labelText: 'Speed profile'),
        ),
        if (_speedType == SpeedProfileType.custom) ...[
          const SizedBox(height: HumanTypeSpacing.sm),
          Slider(
            value: _customWpm.toDouble(),
            min: 10,
            max: 140,
            divisions: 26,
            label: '$_customWpm WPM',
            onChanged: (value) => setState(() => _customWpm = value.round()),
          ),
        ]
      ],
    );
  }

  Widget _buildErrorControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Errors', style: HumanTypeText.heading2),
        const SizedBox(height: HumanTypeSpacing.sm),
        Slider(
          value: _errorsPerLine.toDouble(),
          min: 0,
          max: 5,
          divisions: 5,
          label: '$_errorsPerLine per line',
          onChanged: (value) => setState(() => _errorsPerLine = value.round()),
        ),
        const SizedBox(height: HumanTypeSpacing.sm),
        DropdownButtonFormField<CorrectionStyle>(
          value: _correctionStyle,
          items: CorrectionStyle.values
              .map((value) => DropdownMenuItem(
                    value: value,
                    child: Text(value.name),
                  ))
              .toList(),
          onChanged: (value) => setState(() => _correctionStyle = value!),
          decoration: const InputDecoration(labelText: 'Correction style'),
        ),
        const SizedBox(height: HumanTypeSpacing.sm),
        Wrap(
          spacing: HumanTypeSpacing.sm,
          runSpacing: HumanTypeSpacing.sm,
          children: ErrorType.values.map((type) {
            final selected = _errorTypes.contains(type);
            return FilterChip(
              label: Text(type.name),
              selected: selected,
              onSelected: (value) {
                setState(() {
                  if (value) {
                    _errorTypes.add(type);
                  } else if (_errorTypes.length > 1) {
                    _errorTypes.remove(type);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPreActionControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Before typing', style: HumanTypeText.heading2),
        const SizedBox(height: HumanTypeSpacing.sm),
        DropdownButtonFormField<PreActionType>(
          value: _preActionType,
          items: PreActionType.values
              .map((value) => DropdownMenuItem(
                    value: value,
                    child: Text(value.name),
                  ))
              .toList(),
          onChanged: (value) => setState(() => _preActionType = value!),
          decoration: const InputDecoration(labelText: 'Pre-action'),
        ),
        if (_preActionType != PreActionType.none &&
            _preActionType != PreActionType.waitForTap) ...[
          const SizedBox(height: HumanTypeSpacing.sm),
          TextField(
            controller: _preActionValueController,
            decoration: const InputDecoration(labelText: 'Value'),
          ),
        ]
      ],
    );
  }

  Widget _buildPostActionControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('After typing', style: HumanTypeText.heading2),
        const SizedBox(height: HumanTypeSpacing.sm),
        DropdownButtonFormField<PostActionType>(
          value: _postActionType,
          items: PostActionType.values
              .map((value) => DropdownMenuItem(
                    value: value,
                    child: Text(value.name),
                  ))
              .toList(),
          onChanged: (value) => setState(() => _postActionType = value!),
          decoration: const InputDecoration(labelText: 'Post-action'),
        ),
        if (_postActionType != PostActionType.none &&
            _postActionType != PostActionType.pressEnter &&
            _postActionType != PostActionType.pressTab) ...[
          const SizedBox(height: HumanTypeSpacing.sm),
          TextField(
            controller: _postActionValueController,
            decoration: const InputDecoration(labelText: 'Value'),
          ),
        ]
      ],
    );
  }

  void _save() {
    final id = widget.initial?.id ?? const Uuid().v4();
    final name = _nameController.text.trim();
    final content = _contentController.text.trim();

    final target = _buildTarget();
    final speed = _speedType == SpeedProfileType.custom
        ? SpeedProfile.custom(_customWpm)
        : SpeedProfile.preset(_speedType);
    final errors = ErrorProfile(
      errorsPerLine: _errorsPerLine,
      allowedErrorTypes: _errorTypes.toList(),
      correctionStyle: _correctionStyle,
    );

    final preAction = _buildPreAction();
    final postAction = _buildPostAction();

    final section = Section(
      id: id,
      name: name.isEmpty ? 'Untitled section' : name,
      content: content,
      target: target,
      mode: _mode,
      speed: speed,
      errors: errors,
      preAction: preAction,
      postAction: postAction,
      waitForManualStart: _waitForManualStart,
    );

    widget.onSave(section);
    Navigator.pop(context);
  }

  SectionTarget _buildTarget() {
    switch (_targetType) {
      case TargetType.activeWindow:
        return SectionTarget.activeWindow();
      case TargetType.tabN:
        final count = int.tryParse(_tabCountController.text) ?? 1;
        return SectionTarget(
          type: TargetType.tabN,
          tabCount: max(1, count),
        );
      case TargetType.clickField:
        return SectionTarget(
          type: TargetType.clickField,
          fieldName: _fieldNameController.text.trim(),
        );
    }
  }

  PreAction _buildPreAction() {
    final value = _preActionValueController.text.trim();
    switch (_preActionType) {
      case PreActionType.none:
        return PreAction.none();
      case PreActionType.waitForTap:
        return const PreAction(type: PreActionType.waitForTap);
      case PreActionType.waitSeconds:
        return PreAction(
          type: PreActionType.waitSeconds,
          waitSeconds: int.tryParse(value) ?? 0,
        );
      case PreActionType.pressKey:
        return PreAction(
          type: PreActionType.pressKey,
          key: value,
        );
      case PreActionType.pressHotkey:
        return PreAction(
          type: PreActionType.pressHotkey,
          hotkey: value
              .split(',')
              .map((part) => part.trim())
              .where((part) => part.isNotEmpty)
              .toList(),
        );
    }
  }

  PostAction _buildPostAction() {
    final value = _postActionValueController.text.trim();
    switch (_postActionType) {
      case PostActionType.none:
        return PostAction.none();
      case PostActionType.waitSeconds:
        return PostAction(
          type: PostActionType.waitSeconds,
          waitSeconds: int.tryParse(value) ?? 0,
        );
      case PostActionType.pressEnter:
        return const PostAction(type: PostActionType.pressEnter, key: 'enter');
      case PostActionType.pressTab:
        return const PostAction(type: PostActionType.pressTab, key: 'tab');
      case PostActionType.pressHotkey:
        return PostAction(
          type: PostActionType.pressHotkey,
          hotkey: value
              .split(',')
              .map((part) => part.trim())
              .where((part) => part.isNotEmpty)
              .toList(),
        );
    }
  }
}
