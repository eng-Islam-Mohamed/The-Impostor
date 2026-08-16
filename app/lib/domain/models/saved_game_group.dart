import 'package:bara_alsalfa/domain/models/persisted_game_session.dart';
import 'package:flutter/foundation.dart';

@immutable
class SavedGameGroup {
  const SavedGameGroup({
    required this.id,
    required this.name,
    required this.session,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final PersistedGameSession session;
  final DateTime updatedAt;

  SavedGameGroup copyWith({
    String? name,
    PersistedGameSession? session,
    DateTime? updatedAt,
  }) {
    return SavedGameGroup(
      id: id,
      name: name ?? this.name,
      session: session ?? this.session,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'session': session.toJson(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory SavedGameGroup.fromJson(Map<String, dynamic> json) {
    return SavedGameGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      session: PersistedGameSession.fromJson(
        json['session'] as Map<String, dynamic>,
      ),
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

@immutable
class SavedGroupsState {
  const SavedGroupsState({this.groups = const [], this.activeGroupId});

  final List<SavedGameGroup> groups;
  final String? activeGroupId;

  SavedGameGroup? get activeGroup {
    for (final group in groups) {
      if (group.id == activeGroupId) return group;
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    'activeGroupId': activeGroupId,
    'groups': groups.map((group) => group.toJson()).toList(growable: false),
  };

  factory SavedGroupsState.fromJson(Map<String, dynamic> json) {
    final groups = (json['groups'] as List<dynamic>? ?? const [])
        .map((item) => SavedGameGroup.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
    final activeId = json['activeGroupId'] as String?;
    return SavedGroupsState(
      groups: groups,
      activeGroupId: groups.any((group) => group.id == activeId)
          ? activeId
          : null,
    );
  }
}
