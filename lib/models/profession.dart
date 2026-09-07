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
      icon: resolveIcon(json['id'] as String?),
    );
  }

  static IconData resolveIcon(String? id) {
    switch (id) {
      case 'police_detective':
        return Icons.policy_outlined;
      case 'interior_designer':
        return Icons.chair_outlined;
      case 'doctor':
        return Icons.medical_services_outlined;
      case 'lawyer':
        return Icons.gavel_outlined;
      case 'photographer':
        return Icons.camera_alt_outlined;
      case 'architect_engineer':
        return Icons.foundation_outlined;
      case 'chef_nutritionist':
        return Icons.restaurant_outlined;
      case 'psychologist':
        return Icons.psychology_outlined;
      case 'marketing_advertiser':
        return Icons.campaign_outlined;
      case 'agronomist':
        return Icons.eco_outlined;
      case 'fire_safety_inspector':
        return Icons.local_fire_department_outlined;
      case 'geologist_naturalist':
        return Icons.terrain_outlined;
      case 'fashion_designer':
        return Icons.checkroom_outlined;
      case 'mechanical_engineer':
        return Icons.precision_manufacturing_outlined;
      case 'historian_archeologist':
        return Icons.auto_stories_outlined;
      default:
        return Icons.person_search_outlined;
    }
  }
}
