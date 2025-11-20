enum ApplicationStatus {
  pending,
  approved,
  rejected,
  withdrawn,
}

class Application {
  final String id;
  final String promotionId;
  final String influencerId;
  final String? message;
  final ApplicationStatus status;
  final DateTime appliedAt;
  final DateTime? reviewedAt;
  final String? reviewNotes;

  Application({
    required this.id,
    required this.promotionId,
    required this.influencerId,
    this.message,
    this.status = ApplicationStatus.pending,
    required this.appliedAt,
    this.reviewedAt,
    this.reviewNotes,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id'],
      promotionId: json['promotionId'],
      influencerId: json['influencerId'],
      message: json['message'],
      status: ApplicationStatus.values.firstWhere(
        (e) => e.toString() == 'ApplicationStatus.${json['status']}',
        orElse: () => ApplicationStatus.pending,
      ),
      appliedAt: DateTime.parse(json['appliedAt']),
      reviewedAt: json['reviewedAt'] != null ? DateTime.parse(json['reviewedAt']) : null,
      reviewNotes: json['reviewNotes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'promotionId': promotionId,
      'influencerId': influencerId,
      'message': message,
      'status': status.toString().split('.').last,
      'appliedAt': appliedAt.toIso8601String(),
      'reviewedAt': reviewedAt?.toIso8601String(),
      'reviewNotes': reviewNotes,
    };
  }
}