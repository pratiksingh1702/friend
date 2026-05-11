import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humantype_shared/humantype_shared.dart';

import '../../../core/services/local_store.dart';

final templatesProvider =
    AsyncNotifierProvider<TemplatesNotifier, List<TemplateModel>>(
  TemplatesNotifier.new,
);

class TemplatesNotifier extends AsyncNotifier<List<TemplateModel>> {
  @override
  Future<List<TemplateModel>> build() async {
    return _loadTemplates();
  }

  Future<List<TemplateModel>> _loadTemplates() async {
    final box = LocalStore.instance.templatesBox;
    return box.values
        .map((value) => TemplateModel.fromJson(value.cast<String, dynamic>()))
        .toList();
  }

  Future<void> addTemplate(TemplateModel template) async {
    final box = LocalStore.instance.templatesBox;
    await box.put(template.id, template.toJson());
    final current = state.value ?? const <TemplateModel>[];
    state = AsyncData([...current, template]);
  }

  Future<void> removeTemplate(String id) async {
    final box = LocalStore.instance.templatesBox;
    await box.delete(id);
    final current = state.value ?? const <TemplateModel>[];
    state = AsyncData(current.where((item) => item.id != id).toList());
  }
}
