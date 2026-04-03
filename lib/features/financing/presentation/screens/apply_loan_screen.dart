import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_theme.dart';

class ApplyLoanScreen extends StatefulWidget {
  const ApplyLoanScreen({super.key});

  @override
  State<ApplyLoanScreen> createState() => _ApplyLoanScreenState();
}

class _ApplyLoanScreenState extends State<ApplyLoanScreen> {
  int _currentStep = 0;
  final _formKeys = List.generate(4, (_) => GlobalKey<FormState>());

  // Step 1: Personal
  final _farmNameController = TextEditingController(text: 'Moyo Family Farm');
  String _province = 'Mashonaland East';

  // Step 2: Farm details
  final _farmSizeController = TextEditingController();
  String _cropType = 'Maize';
  String _farmingType = 'Rainfed';

  // Step 3: Loan details
  final _amountController = TextEditingController();
  String _loanPurpose = 'Input Purchase';
  String _repaymentPeriod = '6 months';

  // Step 4: Review — no controllers needed

  bool _submitted = false;

  @override
  void dispose() {
    _farmNameController.dispose();
    _farmSizeController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _next() {
    if (_formKeys[_currentStep].currentState?.validate() ?? false) {
      if (_currentStep < 3) {
        setState(() => _currentStep++);
      } else {
        _submit();
      }
    }
  }

  void _back() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      context.pop();
    }
  }

  void _submit() {
    setState(() => _submitted = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) return _buildSuccessView(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _back,
        ),
        title: const Text('Apply for Loan'),
      ),
      body: Column(
        children: [
          // Step indicator
          _buildStepIndicator(),
          const Divider(height: 1),

          // Step content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: _buildCurrentStep(),
            ),
          ),

          // Bottom actions
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    const steps = ['Farm Info', 'Crop Details', 'Loan', 'Review'];
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: List.generate(steps.length, (i) {
          final isActive = i == _currentStep;
          final isDone = i < _currentStep;
          return Expanded(
            child: Row(
              children: [
                if (i > 0)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isDone ? AppColors.primary : AppColors.border,
                    ),
                  ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color:
                        isDone
                            ? AppColors.primary
                            : isActive
                            ? AppColors.primarySurface
                            : AppColors.surfaceElevated,
                    shape: BoxShape.circle,
                    border:
                        isActive
                            ? Border.all(color: AppColors.primary, width: 2)
                            : null,
                  ),
                  child: Center(
                    child:
                        isDone
                            ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                            : Text(
                              '${i + 1}',
                              style: AppTextStyles.labelSm.copyWith(
                                color:
                                    isActive
                                        ? AppColors.primary
                                        : AppColors.textTertiary,
                              ),
                            ),
                  ),
                ),
                if (i < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isDone ? AppColors.primary : AppColors.border,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildFarmInfoStep();
      case 1:
        return _buildCropDetailsStep();
      case 2:
        return _buildLoanDetailsStep();
      case 3:
        return _buildReviewStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildFarmInfoStep() {
    return Form(
      key: _formKeys[0],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Farm Information',
            style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Tell us about your farming operation',
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          TextFormField(
            controller: _farmNameController,
            decoration: const InputDecoration(
              labelText: 'Farm Name',
              prefixIcon: Icon(Icons.agriculture_rounded),
            ),
            validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: AppSpacing.lg),
          DropdownButtonFormField<String>(
            initialValue: _province,
            decoration: const InputDecoration(
              labelText: 'Province',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
            items:
                [
                      'Mashonaland East',
                      'Mashonaland West',
                      'Mashonaland Central',
                      'Manicaland',
                      'Masvingo',
                      'Midlands',
                      'Matabeleland North',
                      'Matabeleland South',
                      'Harare',
                      'Bulawayo',
                    ]
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
            onChanged: (v) => setState(() => _province = v!),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: _farmSizeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Farm Size (hectares)',
              prefixIcon: Icon(Icons.landscape_rounded),
            ),
            validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildCropDetailsStep() {
    return Form(
      key: _formKeys[1],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Crop Details',
            style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'What are you growing this season?',
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          DropdownButtonFormField<String>(
            initialValue: _cropType,
            decoration: const InputDecoration(
              labelText: 'Primary Crop',
              prefixIcon: Icon(Icons.grass_rounded),
            ),
            items:
                [
                      'Maize',
                      'Tobacco',
                      'Soya Beans',
                      'Cotton',
                      'Wheat',
                      'Groundnuts',
                      'Sunflower',
                      'Sugar Cane',
                    ]
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
            onChanged: (v) => setState(() => _cropType = v!),
          ),
          const SizedBox(height: AppSpacing.lg),
          DropdownButtonFormField<String>(
            initialValue: _farmingType,
            decoration: const InputDecoration(
              labelText: 'Farming Type',
              prefixIcon: Icon(Icons.water_drop_outlined),
            ),
            items: const [
              DropdownMenuItem(value: 'Rainfed', child: Text('Rainfed')),
              DropdownMenuItem(value: 'Irrigated', child: Text('Irrigated')),
              DropdownMenuItem(value: 'Mixed', child: Text('Mixed')),
            ],
            onChanged: (v) => setState(() => _farmingType = v!),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Expected yield info
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.infoSurface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.info,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Expected yield for $_cropType ($_farmingType): 4-6 tons/ha',
                    style: AppTextStyles.bodySm.copyWith(color: AppColors.info),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoanDetailsStep() {
    return Form(
      key: _formKeys[2],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Loan Details',
            style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'How much funding do you need?',
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Loan Amount (USD)',
              prefixIcon: Icon(Icons.attach_money_rounded),
              hintText: 'e.g. 1500',
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Required';
              final amount = double.tryParse(v);
              if (amount == null || amount <= 0) return 'Enter a valid amount';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          DropdownButtonFormField<String>(
            initialValue: _loanPurpose,
            decoration: const InputDecoration(
              labelText: 'Loan Purpose',
              prefixIcon: Icon(Icons.category_outlined),
            ),
            items: const [
              DropdownMenuItem(
                value: 'Input Purchase',
                child: Text('Input Purchase (seed, fertilizer)'),
              ),
              DropdownMenuItem(
                value: 'Equipment',
                child: Text('Equipment & Machinery'),
              ),
              DropdownMenuItem(
                value: 'Land Preparation',
                child: Text('Land Preparation'),
              ),
              DropdownMenuItem(
                value: 'Irrigation',
                child: Text('Irrigation Setup'),
              ),
              DropdownMenuItem(
                value: 'Livestock',
                child: Text('Livestock Purchase'),
              ),
            ],
            onChanged: (v) => setState(() => _loanPurpose = v!),
          ),
          const SizedBox(height: AppSpacing.lg),
          DropdownButtonFormField<String>(
            initialValue: _repaymentPeriod,
            decoration: const InputDecoration(
              labelText: 'Repayment Period',
              prefixIcon: Icon(Icons.calendar_today_outlined),
            ),
            items: const [
              DropdownMenuItem(value: '3 months', child: Text('3 months')),
              DropdownMenuItem(value: '6 months', child: Text('6 months')),
              DropdownMenuItem(value: '12 months', child: Text('12 months')),
              DropdownMenuItem(value: '24 months', child: Text('24 months')),
            ],
            onChanged: (v) => setState(() => _repaymentPeriod = v!),
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Estimated repayment
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.accentSurface,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estimated Monthly Repayment',
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _amountController.text.isNotEmpty
                      ? '\$${((double.tryParse(_amountController.text) ?? 0) * 1.12 / 6).toStringAsFixed(0)}/month'
                      : '--',
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'at 12% annual interest',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    return Form(
      key: _formKeys[3],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review Application',
            style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Please confirm all details before submitting',
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          _ReviewSection(
            title: 'Farm Information',
            icon: Icons.agriculture_rounded,
            items: {
              'Farm Name': _farmNameController.text,
              'Province': _province,
              'Farm Size': '${_farmSizeController.text} ha',
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          _ReviewSection(
            title: 'Crop Details',
            icon: Icons.grass_rounded,
            items: {'Primary Crop': _cropType, 'Farming Type': _farmingType},
          ),
          const SizedBox(height: AppSpacing.lg),
          _ReviewSection(
            title: 'Loan Details',
            icon: Icons.account_balance_wallet_rounded,
            items: {
              'Amount': '\$${_amountController.text}',
              'Purpose': _loanPurpose,
              'Repayment': _repaymentPeriod,
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _back,
                  child: const Text('Back'),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: AppSpacing.md),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _next,
                child: Text(
                  _currentStep == 3 ? 'Submit Application' : 'Continue',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.successSurface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                    size: 56,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  'Application Submitted!',
                  style: AppTextStyles.h1.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Your loan application has been saved locally and will be synced when connected. Lenders will review your application soon.',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxxl),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => context.go('/financing'),
                    child: const Text('View My Loans'),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Back to Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Map<String, String> items;

  const _ReviewSection({
    required this.title,
    required this.icon,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: AppTextStyles.labelLg.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...items.entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    e.key,
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  Text(
                    e.value,
                    style: AppTextStyles.labelMd.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
