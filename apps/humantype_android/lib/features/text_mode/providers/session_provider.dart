import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humantype_shared/humantype_shared.dart';
import 'package:uuid/uuid.dart';

final sessionProvider = NotifierProvider<SessionNotifier, SessionModel>(
  SessionNotifier.new,
);

class SessionNotifier extends Notifier<SessionModel> {
  @override
  SessionModel build() {
    return SessionModel.empty(const Uuid().v4());
  }

  void addSection(Section section) {
    final updated = [...state.sections, section];
    state = state.copyWith(sections: updated);
  }

  void updateSection(Section section) {
    final updated = state.sections
        .map((entry) => entry.id == section.id ? section : entry)
        .toList();
    state = state.copyWith(sections: updated);
  }

  void removeSection(String id) {
    final updated =
        state.sections.where((section) => section.id != id).toList();
    state = state.copyWith(sections: updated);
  }

  void reorderSections(int oldIndex, int newIndex) {
    final updated = [...state.sections];
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = updated.removeAt(oldIndex);
    updated.insert(newIndex, item);
    state = state.copyWith(sections: updated);
  }

  void setStatus(SessionStatus status) {
    state = state.copyWith(status: status);
  }

  void setCurrentSectionIndex(int index) {
    state = state.copyWith(currentSectionIndex: index);
  }

  void resetSession() {
    state = SessionModel.empty(const Uuid().v4());
  }
}
