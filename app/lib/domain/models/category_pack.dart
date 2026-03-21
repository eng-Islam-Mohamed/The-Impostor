import 'package:flutter/foundation.dart';

@immutable
class CategoryPack {
  const CategoryPack({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.difficultyLabel,
    required this.isPremium,
    required this.topics,
  });

  final String id;
  final String title;
  final String subtitle;
  final String difficultyLabel;
  final bool isPremium;
  final List<String> topics;

  CategoryPack copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? difficultyLabel,
    bool? isPremium,
    List<String>? topics,
  }) {
    return CategoryPack(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      difficultyLabel: difficultyLabel ?? this.difficultyLabel,
      isPremium: isPremium ?? this.isPremium,
      topics: topics ?? this.topics,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'difficultyLabel': difficultyLabel,
      'isPremium': isPremium,
      'topics': topics,
    };
  }

  factory CategoryPack.fromJson(Map<String, dynamic> json) {
    return CategoryPack(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      difficultyLabel: json['difficultyLabel'] as String,
      isPremium: json['isPremium'] as bool? ?? false,
      topics: (json['topics'] as List<dynamic>).cast<String>(),
    );
  }
}
