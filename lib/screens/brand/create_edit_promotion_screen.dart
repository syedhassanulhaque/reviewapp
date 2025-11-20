// lib/screens/brand/create_edit_promotion_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/promotion.dart';
import '../../../providers/promotion_provider.dart';
import '../../../providers/auth_provider.dart';

class CreateEditPromotionScreen extends StatefulWidget {
  final Promotion? promotion;

  const CreateEditPromotionScreen({Key? key, this.promotion}) : super(key: key);

  @override
  _CreateEditPromotionScreenState createState() => _CreateEditPromotionScreenState();
}

class _CreateEditPromotionScreenState extends State<CreateEditPromotionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _budgetController;
  late TextEditingController _followersController;
  late DateTime _startDate;
  late DateTime _endDate;
  final List<String> _selectedPlatforms = [];
  final List<String> _contentRequirements = [];
  final TextEditingController _platformController = TextEditingController();
  final TextEditingController _requirementController = TextEditingController();

  final List<String> _availablePlatforms = [
    'Instagram',
    'TikTok',
    'YouTube',
    'Twitter',
    'Facebook',
  ];

  @override
  void initState() {
    super.initState();
    final promotion = widget.promotion;
    _titleController = TextEditingController(text: promotion?.title ?? '');
    _descriptionController = TextEditingController(text: promotion?.description ?? '');
    _budgetController = TextEditingController(text: promotion?.budget.toString() ?? '');
    _followersController = TextEditingController(
      text: promotion?.requiredFollowers.toString() ?? '1000',
    );
    _startDate = promotion?.startDate ?? DateTime.now();
    _endDate = promotion?.endDate ?? DateTime.now().add(const Duration(days: 30));
    _selectedPlatforms.addAll(promotion?.requiredPlatforms ?? []);
    _contentRequirements.addAll(promotion?.contentRequirements ?? []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _followersController.dispose();
    _platformController.dispose();
    _requirementController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
    BuildContext context, {
    required bool isStartDate,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate.add(const Duration(days: 1)))) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _addPlatform() {
    if (_platformController.text.isNotEmpty) {
      setState(() {
        _selectedPlatforms.add(_platformController.text);
        _platformController.clear();
      });
    }
  }

  void _removePlatform(String platform) {
    setState(() {
      _selectedPlatforms.remove(platform);
    });
  }

  void _addRequirement() {
    if (_requirementController.text.isNotEmpty) {
      setState(() {
        _contentRequirements.add(_requirementController.text);
        _requirementController.clear();
      });
    }
  }

  void _removeRequirement(String requirement) {
    setState(() {
      _contentRequirements.remove(requirement);
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _selectedPlatforms.isNotEmpty) {
      final promotion = Promotion(
        id: widget.promotion?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        brandId: Provider.of<AuthProvider>(context, listen: false).user?.id ?? 'brand_demo',
        title: _titleController.text,
        description: _descriptionController.text,
        budget: double.parse(_budgetController.text),
        startDate: _startDate,
        endDate: _endDate,
        status: widget.promotion?.status ?? PromotionStatus.active,
        requiredPlatforms: _selectedPlatforms,
        requiredFollowers: int.parse(_followersController.text),
        contentRequirements: _contentRequirements,
        createdAt: widget.promotion?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final promotionProvider = Provider.of<PromotionProvider>(context, listen: false);
      if (widget.promotion == null) {
        promotionProvider.addPromotion(promotion);
      } else {
        promotionProvider.updatePromotion(promotion.id, promotion);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.promotion == null ? 'Create Promotion' : 'Edit Promotion'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _submitForm,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _budgetController,
                      decoration: const InputDecoration(
                        labelText: 'Budget (\$)',
                        border: OutlineInputBorder(),
                        prefixText: '\$',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a budget';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _followersController,
                      decoration: const InputDecoration(
                        labelText: 'Min Followers',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Enter a number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Start Date'),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => _selectDate(context, isStartDate: true),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            child: Text(
                              '${_startDate.year}-${_startDate.month}-${_startDate.day}',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('End Date'),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => _selectDate(context, isStartDate: false),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            child: Text(
                              '${_endDate.year}-${_endDate.month}-${_endDate.day}',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Required Platforms'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availablePlatforms.map((platform) {
                  final isSelected = _selectedPlatforms.contains(platform);
                  return FilterChip(
                    label: Text(platform),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedPlatforms.add(platform);
                        } else {
                          _selectedPlatforms.remove(platform);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text('Content Requirements'),
              const SizedBox(height: 8),
              ..._contentRequirements.map((req) => ListTile(
                    title: Text(req),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => _removeRequirement(req),
                    ),
                  )),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _requirementController,
                      decoration: const InputDecoration(
                        labelText: 'Add requirement',
                        border: OutlineInputBorder(),
                      ),
                      onFieldSubmitted: (_) => _addRequirement(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addRequirement,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}