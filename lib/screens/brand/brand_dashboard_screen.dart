// lib/screens/brand/brand_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/promotion.dart';
import '../../providers/auth_provider.dart';
import '../../providers/promotion_provider.dart';
import '../../widgets/main_layout.dart';
import 'create_edit_promotion_screen.dart';

class BrandDashboardScreen extends StatelessWidget {
  const BrandDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return MainLayout(
      title: 'Brand Dashboard',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(user?.displayName ?? 'Brand'),
            const SizedBox(height: 24),
            Consumer<PromotionProvider>(
              builder: (context, promoProvider, _) {
                final activePromotions = promoProvider.getActivePromotions();
                return _buildActivePromotions(activePromotions, context);
              },
            ),
            const SizedBox(height: 24),
            _buildQuickActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(String brandName) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Simple banner image to enhance visual appeal
          AspectRatio(
            aspectRatio: 16 / 6,
            child: Image.network(
              'https://images.unsplash.com/photo-1495020689067-958852a7765e?q=80&w=1200&auto=format&fit=crop',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, $brandName!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Here\'s what\'s happening with your campaigns',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivePromotions(List<Promotion> promotions, BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Active Promotions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                CircleAvatar(
                  radius: 14,
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  child: Text(
                    promotions.length.toString(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (promotions.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Text('No active promotions'),
                ),
              )
            else
              ...promotions.map((promo) => _buildPromotionCard(promo, context)).toList(),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CreateEditPromotionScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Create New Promotion'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromotionCard(Promotion promotion, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(
            'https://images.unsplash.com/photo-1542744173-8e7e53415bb0?q=80&w=300&auto=format&fit=crop',
          ),
        ),
        title: Text(promotion.title),
        subtitle: Text('${promotion.daysLeft} days left'),
        trailing: Chip(
          label: Text(
            promotion.status.toString().split('.').last,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: promotion.isActive ? Colors.green : Colors.orange,
        ),
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: Text(promotion.title),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(promotion.description),
                    const SizedBox(height: 16),
                    Text('Budget: \$${promotion.budget.toStringAsFixed(2)}'),
                    Text('Status: ${promotion.status.toString().split('.').last}'),
                    Text('Platforms: ${promotion.requiredPlatforms.join(', ')}'),
                    Text('Min Followers: ${promotion.requiredFollowers}'),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildActionButton(
                  context,
                  icon: Icons.add_circle_outline,
                  label: 'New Promotion',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CreateEditPromotionScreen(),
                      ),
                    );
                  },
                ),
                _buildActionButton(
                  context,
                  icon: Icons.people,
                  label: 'View Influencers',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const InfluencerListScreen(),
                      ),
                    );
                  },
                ),
                _buildActionButton(
                  context,
                  icon: Icons.analytics,
                  label: 'Analytics',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Analytics coming soon')),
                    );
                  },
                ),
                _buildActionButton(
                  context,
                  icon: Icons.settings,
                  label: 'Settings',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const BrandSettingsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Theme.of(context).primaryColor),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InfluencerListScreen extends StatelessWidget {
  const InfluencerListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dummyInfluencers = [
      {
        'id': 'inf1',
        'name': 'Alex Johnson',
        'platforms': ['Instagram', 'YouTube'],
        'followers': 12000,
        'avatar': 'https://images.unsplash.com/photo-1502685104226-ee32379fefbe?q=80&w=400&auto=format&fit=crop',
      },
      {
        'id': 'inf2',
        'name': 'Mia Chen',
        'platforms': ['TikTok'],
        'followers': 54000,
        'avatar': 'https://images.unsplash.com/photo-1527980965255-d3b416303d12?q=80&w=400&auto=format&fit=crop',
      },
      {
        'id': 'inf3',
        'name': 'Ravi Kumar',
        'platforms': ['Instagram', 'Twitter'],
        'followers': 22000,
        'avatar': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=400&auto=format&fit=crop',
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Influencers')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: dummyInfluencers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final inf = dummyInfluencers[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(backgroundImage: NetworkImage(inf['avatar'] as String)),
              title: Text(inf['name'] as String),
              subtitle: Text('${(inf['platforms'] as List).join(', ')} • ${(inf['followers'] as int)} followers'),
              trailing: Wrap(
                spacing: 8,
                children: [
                  IconButton(
                    icon: const Icon(Icons.visibility),
                    tooltip: 'View Profile',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Viewing ${(inf['name'])}')),
                      );
                    },
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final promoProvider = Provider.of<PromotionProvider>(context, listen: false);
                      final auth = Provider.of<AuthProvider>(context, listen: false);
                      final brandId = auth.user?.id ?? '';
                      final active = promoProvider.getActivePromotions();
                      final brandPromos = active.where((p) => p.brandId == brandId).toList();
                      final choices = brandPromos.isNotEmpty ? brandPromos : active;

                      if (choices.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No active promotions to invite for')),
                        );
                        return;
                      }

                      final selected = await showDialog<Promotion>(
                        context: context,
                        builder: (ctx) => SimpleDialog(
                          title: const Text('Invite to which promotion?'),
                          children: choices
                              .map((p) => SimpleDialogOption(
                                    onPressed: () => Navigator.pop(ctx, p),
                                    child: Text(p.title),
                                  ))
                              .toList(),
                        ),
                      );

                      if (selected != null) {
                        final influencerId = (inf['id'] as String?) ?? (inf['name'] as String);
                        promoProvider.inviteInfluencer(
                          promotionId: selected.id,
                          influencerId: influencerId,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Invited ${(inf['name'])} to "${selected.title}"')),
                        );
                      }
                    },
                    child: const Text('Invite'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class BrandSettingsScreen extends StatefulWidget {
  const BrandSettingsScreen({Key? key}) : super(key: key);

  @override
  State<BrandSettingsScreen> createState() => _BrandSettingsScreenState();
}

class _BrandSettingsScreenState extends State<BrandSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Acme Corp');
  final _websiteController = TextEditingController(text: 'https://acme.example');
  final _bioController = TextEditingController(text: 'We create awesome products.');

  @override
  void dispose() {
    _nameController.dispose();
    _websiteController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Brand Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: const NetworkImage(
                        'https://images.unsplash.com/photo-1523473827532-1c07c0dc3a19?q=80&w=200&auto=format&fit=crop',
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Logo upload coming soon')),
                        );
                      },
                      icon: const Icon(Icons.image),
                      label: const Text('Change Logo'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Brand Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _websiteController,
                decoration: const InputDecoration(
                  labelText: 'Website',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bioController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'About / Bio',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Settings saved')),
                      );
                    }
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Save Settings'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}