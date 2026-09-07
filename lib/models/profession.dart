import 'package:flutter/material.dart';

class Profession {
  final String id;
  final String name;
  final IconData icon;
  final String description;
  final List<String> focusAreas;
  final Color accentColor;
  final bool isCustom;

  const Profession({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.focusAreas,
    this.accentColor = const Color(0xFF2563EB),
    this.isCustom = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'focusAreas': focusAreas,
      'isCustom': isCustom,
      'accentColor': accentColor.value,
      'iconCodePoint': icon.codePoint,
    };
  }

  factory Profession.fromJson(Map<String, dynamic> json) {
    return Profession(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      focusAreas: (json['focusAreas'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isCustom: json['isCustom'] as bool? ?? false,
      accentColor: json['accentColor'] != null
          ? Color(json['accentColor'] as int)
          : const Color(0xFF2563EB),
      icon: json['iconCodePoint'] != null
          ? IconData(json['iconCodePoint'] as int, fontFamily: 'MaterialIcons')
          : Icons.work_outline,
    );
  }
}
