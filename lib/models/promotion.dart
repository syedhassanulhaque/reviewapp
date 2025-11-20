import 'package:meta/meta.dart';

enum PromotionStatus {
  draft,
  active,
  paused,
  completed,
  cancelled,
}

class Promotion {
  final String id;
  final String brandId;
  final String title;
  final String description;
  final double budget;
  final DateTime startDate;
  final DateTime endDate;
  final PromotionStatus status;
  final List<String> requiredPlatforms;
  final int requiredFollowers;
  final List<String> contentRequirements;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String>? appliedInfluencers;
  final List<String>? approvedInfluencers;

  Promotion({
    required this.id,
    required this.brandId,
    required this.title,
    required this.description,
    required this.budget,
    required this.startDate,
    required this.endDate,
    this.status = PromotionStatus.draft,
    required this.requiredPlatforms,
    required this.requiredFollowers,
    required this.contentRequirements,
    required this.createdAt,
    this.updatedAt,
    this.appliedInfluencers,
    this.approvedInfluencers,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['id'],
      brandId: json['brandId'],
      title: json['title'],
      description: json['description'],
      budget: (json['budget'] as num).toDouble(),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      status: PromotionStatus.values.firstWhere(
        (e) => e.toString() == 'PromotionStatus.${json['status']}',
        orElse: () => PromotionStatus.draft,
      ),
      requiredPlatforms: List<String>.from(json['requiredPlatforms']),
      requiredFollowers: json['requiredFollowers'],
      contentRequirements: List<String>.from(json['contentRequirements']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      appliedInfluencers: json['appliedInfluencers'] != null ? List<String>.from(json['appliedInfluencers']) : null,
      approvedInfluencers: json['approvedInfluencers'] != null ? List<String>.from(json['approvedInfluencers']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brandId': brandId,
      'title': title,
      'description': description,
      'budget': budget,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status.toString().split('.').last,
      'requiredPlatforms': requiredPlatforms,
      'requiredFollowers': requiredFollowers,
      'contentRequirements': contentRequirements,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'appliedInfluencers': appliedInfluencers,
      'approvedInfluencers': approvedInfluencers,
    };
  }

  // Helper methods
  bool get isActive => status == PromotionStatus.active;
  bool get canApply => isActive && DateTime.now().isBefore(endDate);
  int get daysLeft => endDate.difference(DateTime.now()).inDays;
}