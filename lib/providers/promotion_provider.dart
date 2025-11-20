// lib/providers/promotion_provider.dart
import 'package:flutter/foundation.dart';
import '../models/promotion.dart';
import '../models/application.dart';

class PromotionProvider with ChangeNotifier {
  final List<Promotion> _promotions = [];
  final List<Application> _applications = [];

  List<Promotion> get promotions => List.unmodifiable(_promotions);
  List<Application> get applications => List.unmodifiable(_applications);

  void addPromotion(Promotion promotion) {
    _promotions.add(promotion);
    notifyListeners();
  }

  void updatePromotion(String id, Promotion updatedPromotion) {
    final index = _promotions.indexWhere((p) => p.id == id);
    if (index != -1) {
      _promotions[index] = updatedPromotion;
      notifyListeners();
    }
  }

  void deletePromotion(String id) {
    _promotions.removeWhere((p) => p.id == id);
    // Also remove related applications for cleanliness in demo
    _applications.removeWhere((a) => a.promotionId == id);
    notifyListeners();
  }

  List<Promotion> getActivePromotions() {
    return _promotions.where((p) => p.isActive).toList();
  }

  // Applications: influencer applies to a promotion
  void applyToPromotion({
    required String promotionId,
    required String influencerId,
    String? message,
  }) {
    final application = Application(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      promotionId: promotionId,
      influencerId: influencerId,
      message: message,
      status: ApplicationStatus.pending,
      appliedAt: DateTime.now(),
    );
    _applications.add(application);
    notifyListeners();
  }

  // Brand invites an influencer to a promotion (modeled as a pending application for demo)
  void inviteInfluencer({
    required String promotionId,
    required String influencerId,
  }) {
    applyToPromotion(
      promotionId: promotionId,
      influencerId: influencerId,
      message: 'Invitation from brand',
    );
  }

  List<Application> applicationsForInfluencer(String influencerId) {
    return _applications.where((a) => a.influencerId == influencerId).toList();
  }

  List<Application> applicationsForPromotion(String promotionId) {
    return _applications.where((a) => a.promotionId == promotionId).toList();
  }
}