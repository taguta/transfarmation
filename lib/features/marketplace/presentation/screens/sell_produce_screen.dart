import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_theme.dart';

class SellProduceScreen extends StatefulWidget {
  const SellProduceScreen({super.key});

  @override
  State<SellProduceScreen> createState() => _SellProduceScreenState();
}

class _SellProduceScreenState extends State<SellProduceScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // Step 1 — Product info
  String _category = 'Grains';
  String _produceName = '';
  String _variety = '';
  double _quantity = 0;
  String _unit = 'tons';

  // Step 2 — Pricing & quality
  double _pricePerUnit = 0;
  String _quality = 'Grade A';
  bool _negotiable = true;

  // Step 3 — Location & delivery
  String _location = '';
  bool _deliveryAvailable = false;
  String? _description;

  static const _categories = [
    'Grains',
    'Vegetables',
    'Fruits',
    'Livestock',
    'Cash Crops',
    'Equipment',
  ];

  static const _units = ['tons', 'kg', 'bags', 'crates', 'heads'];

  static const _qualities = ['Grade A', 'Grade B', 'Grade C', 'Ungraded'];

  static const _provinces = [
    'Harare',
    'Bulawayo',
    'Manicaland',
    'Mashonaland Central',
    'Mashonaland East',
    'Mashonaland West',
    'Masvingo',
    'Matabeleland North',
    'Matabeleland South',
    'Midlands',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sell Produce'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: _onContinue,
        onStepCancel:
            _currentStep > 0 ? () => setState(() => _currentStep--) : null,
        controlsBuilder: (context, details) {
          final isLastStep = _currentStep == 2;
          return Padding(
            padding: const EdgeInsets.only(top: AppSpacing.lg),
            child: Row(
              children: [
                FilledButton(
                  onPressed: details.onStepContinue,
                  child: Text(isLastStep ? 'Post Listing' : 'Continue'),
                ),
                if (_currentStep > 0) ...[
                  const SizedBox(width: AppSpacing.md),
                  OutlinedButton(
                    onPressed: details.onStepCancel,
                    child: const Text('Back'),
                  ),
                ],
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Product Details'),
            subtitle:
                _currentStep > 0 && _produceName.isNotEmpty
                    ? Text('$_produceName · $_quantity $_unit')
                    : null,
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            content: _buildProductStep(),
          ),
          Step(
            title: const Text('Pricing & Quality'),
            subtitle:
                _currentStep > 1 && _pricePerUnit > 0
                    ? Text(
                      '\$${_pricePerUnit.toStringAsFixed(2)}/$_unit · $_quality',
                    )
                    : null,
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            content: _buildPricingStep(),
          ),
          Step(
            title: const Text('Location & Delivery'),
            isActive: _currentStep >= 2,
            state: _currentStep > 2 ? StepState.complete : StepState.indexed,
            content: _buildLocationStep(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductStep() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category
          DropdownButtonFormField<String>(
            value: _category,
            items:
                _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
            onChanged: (v) => setState(() => _category = v!),
            decoration: const InputDecoration(
              labelText: 'Category',
              prefixIcon: Icon(Icons.category_rounded),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Produce name
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Produce Name',
              hintText: 'e.g., White Maize, Cherry Tomatoes',
              prefixIcon: Icon(Icons.grass_rounded),
            ),
            validator:
                (v) => v == null || v.isEmpty ? 'Enter produce name' : null,
            onChanged: (v) => _produceName = v,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Variety
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Variety (optional)',
              hintText: 'e.g., SC513, Solitaire',
              prefixIcon: Icon(Icons.eco_rounded),
            ),
            onChanged: (v) => _variety = v,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Quantity + unit row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    prefixIcon: Icon(Icons.scale_rounded),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (double.tryParse(v) == null) return 'Invalid number';
                    return null;
                  },
                  onChanged: (v) => _quantity = double.tryParse(v) ?? 0,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _unit,
                  items:
                      _units
                          .map(
                            (u) => DropdownMenuItem(value: u, child: Text(u)),
                          )
                          .toList(),
                  onChanged: (v) => setState(() => _unit = v!),
                  decoration: const InputDecoration(labelText: 'Unit'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPricingStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Price
        TextFormField(
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Price per $_unit',
            hintText: 'e.g., 280.00',
            prefixIcon: const Icon(Icons.attach_money_rounded),
            prefixText: '\$ ',
          ),
          onChanged: (v) => _pricePerUnit = double.tryParse(v) ?? 0,
        ),
        const SizedBox(height: AppSpacing.lg),

        // Total preview
        if (_pricePerUnit > 0 && _quantity > 0)
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.accentSurface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Estimated Total',
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '\$${(_pricePerUnit * _quantity).toStringAsFixed(2)}',
                  style: AppTextStyles.h3.copyWith(color: AppColors.accent),
                ),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.lg),

        // Quality grade
        DropdownButtonFormField<String>(
          value: _quality,
          items:
              _qualities
                  .map((q) => DropdownMenuItem(value: q, child: Text(q)))
                  .toList(),
          onChanged: (v) => setState(() => _quality = v!),
          decoration: const InputDecoration(
            labelText: 'Quality Grade',
            prefixIcon: Icon(Icons.star_rounded),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Negotiable toggle
        SwitchListTile(
          value: _negotiable,
          onChanged: (v) => setState(() => _negotiable = v),
          title: Text(
            'Price is negotiable',
            style: AppTextStyles.labelMd.copyWith(color: AppColors.textPrimary),
          ),
          subtitle: Text(
            'Buyers can make counter-offers',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildLocationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Location
        DropdownButtonFormField<String>(
          value: _location.isEmpty ? null : _location,
          items:
              _provinces
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
          onChanged: (v) => setState(() => _location = v ?? ''),
          decoration: const InputDecoration(
            labelText: 'Location / Province',
            prefixIcon: Icon(Icons.location_on_rounded),
          ),
          validator: (v) => v == null || v.isEmpty ? 'Select a location' : null,
        ),
        const SizedBox(height: AppSpacing.lg),

        // Delivery toggle
        SwitchListTile(
          value: _deliveryAvailable,
          onChanged: (v) => setState(() => _deliveryAvailable = v),
          title: Text(
            'Delivery available',
            style: AppTextStyles.labelMd.copyWith(color: AppColors.textPrimary),
          ),
          subtitle: Text(
            'You can deliver to the buyer',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: AppSpacing.lg),

        // Description
        TextFormField(
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Description (optional)',
            hintText: 'Describe condition, harvest date, certifications, etc.',
            prefixIcon: Icon(Icons.description_rounded),
            alignLabelWithHint: true,
          ),
          onChanged: (v) => _description = v.isEmpty ? null : v,
        ),
        const SizedBox(height: AppSpacing.xl),

        // Preview summary
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Listing Preview',
                style: AppTextStyles.labelLg.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const Divider(height: AppSpacing.xl),
              _PreviewRow(
                label: 'Product',
                value:
                    _produceName.isEmpty
                        ? '–'
                        : '$_produceName${_variety.isNotEmpty ? ' ($_variety)' : ''}',
              ),
              _PreviewRow(label: 'Category', value: _category),
              _PreviewRow(label: 'Quantity', value: '$_quantity $_unit'),
              _PreviewRow(
                label: 'Price',
                value: '\$${_pricePerUnit.toStringAsFixed(2)}/$_unit',
              ),
              _PreviewRow(label: 'Quality', value: _quality),
              _PreviewRow(
                label: 'Location',
                value: _location.isEmpty ? '–' : _location,
              ),
              _PreviewRow(
                label: 'Negotiable',
                value: _negotiable ? 'Yes' : 'No',
              ),
              _PreviewRow(
                label: 'Delivery',
                value: _deliveryAvailable ? 'Available' : 'Pickup only',
              ),
              if (_description != null)
                _PreviewRow(label: 'Description', value: _description!),
            ],
          ),
        ),
      ],
    );
  }

  void _onContinue() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
      return;
    }

    // Final step — post listing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('$_produceName listed on marketplace!'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );

    context.pop();
  }
}

class _PreviewRow extends StatelessWidget {
  final String label;
  final String value;

  const _PreviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySm.copyWith(color: AppColors.textTertiary),
          ),
          Text(
            value,
            style: AppTextStyles.labelMd.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
