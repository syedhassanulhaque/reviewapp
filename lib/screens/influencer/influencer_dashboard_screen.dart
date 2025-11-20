// lib/screens/influencer/influencer_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/promotion.dart';
import '../../models/application.dart';
import '../../providers/auth_provider.dart';
import '../../providers/promotion_provider.dart';
import '../../widgets/main_layout.dart';

class InfluencerDashboardScreen extends StatelessWidget {
  const InfluencerDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    final promoProvider = Provider.of<PromotionProvider>(context);
    final availablePromotions = promoProvider.getActivePromotions();

    return MainLayout(
      title: 'Influencer Dashboard',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(user?.displayName ?? 'Influencer'),
            const SizedBox(height: 24),
            _buildAvailablePromotions(context, availablePromotions),
            const SizedBox(height: 24),
            _buildMyApplications(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(String influencerName) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $influencerName!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Discover new brand collaborations',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailablePromotions(BuildContext context, List<Promotion> promotions) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Available Promotions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (promotions.isEmpty)
              const Center(
                child: Text('No available promotions at the moment'),
              )
            else
              ...promotions.map((promo) => _buildPromotionCard(context, promo)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPromotionCard(BuildContext context, Promotion promotion) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(promotion.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(promotion.description),
            const SizedBox(height: 4),
            Text(
              '${promotion.requiredFollowers}+ followers required',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              'Budget: \$${promotion.budget.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () => _showApplyDialog(context, promotion),
          child: const Text('Apply'),
        ),
        onTap: () => _showPromotionDetails(context, promotion),
      ),
    );
  }

  Widget _buildMyApplications() {
    return Consumer2<AuthProvider, PromotionProvider>(
      builder: (context, auth, promo, _) {
        final influencerId = auth.user?.id;
        final applications = influencerId == null
            ? <Application>[]
            : promo.applicationsForInfluencer(influencerId);
        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Applications',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (applications.isEmpty)
                  const Center(
                    child: Text('You haven\'t applied to any promotions yet'),
                  )
                else
                  ...applications.map((app) {
                    final promoItem = promo.promotions.firstWhere(
                      (p) => p.id == app.promotionId,
                      orElse: () => Promotion(
                        id: app.promotionId,
                        brandId: 'unknown',
                        title: 'Unknown promotion',
                        description: '',
                        budget: 0,
                        startDate: DateTime.now(),
                        endDate: DateTime.now(),
                        requiredPlatforms: const [],
                        requiredFollowers: 0,
                        contentRequirements: const [],
                        createdAt: DateTime.now(),
                      ),
                    );
                    return ListTile(
                      title: Text(promoItem.title),
                      subtitle: Text('Status: ${app.status.toString().split('.').last}'),
                    );
                  }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showApplyDialog(BuildContext context, Promotion promotion) {
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apply to Promotion'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You\'re applying to: ${promotion.title}'),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: 'Message (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final influencerId = Provider.of<AuthProvider>(context, listen: false).user?.id;
              if (influencerId != null) {
                Provider.of<PromotionProvider>(context, listen: false).applyToPromotion(
                  promotionId: promotion.id,
                  influencerId: influencerId,
                  message: messageController.text.isEmpty ? null : messageController.text,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Application submitted successfully!')),
                );
              }
            },
            child: const Text('Submit Application'),
          ),
        ],
      ),
    );
  }

  void _showPromotionDetails(BuildContext context, Promotion promotion) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              promotion.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(promotion.description),
            const SizedBox(height: 16),
            const Text(
              'Requirements:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...promotion.contentRequirements
                .map((req) => Text('• $req'))
                .toList(),
            const SizedBox(height: 8),
            Text('Platforms: ${promotion.requiredPlatforms.join(', ')}'),
            Text('Minimum Followers: ${promotion.requiredFollowers}'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showApplyDialog(context, promotion);
                },
                child: const Text('Apply Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}