import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/new_kid_entity.dart';
import '../../../domain/entities/school_entity.dart';
import '../../providers/onboarding_provider.dart';
import '../../widgets/app_avatar.dart';
import '../../widgets/app_icon_button.dart';
import '../../widgets/primary_button.dart';
import 'join_circle_screen.dart';

class AddKidsScreen extends StatefulWidget {
  const AddKidsScreen({super.key});

  @override
  State<AddKidsScreen> createState() => _AddKidsScreenState();
}

/// Controllers and the picked school for one kid card.
class _KidForm {
  final name = TextEditingController();
  final grade = TextEditingController();
  final className = TextEditingController();
  final medical = TextEditingController();
  SchoolEntity? school;

  String get initials {
    final parts = name.text
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  /// Null when a required field is missing.
  NewKidEntity? toEntity() {
    final parts = name.text
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    final selected = school;
    if (parts.isEmpty || selected == null) return null;
    String? optional(TextEditingController c) =>
        c.text.trim().isEmpty ? null : c.text.trim();
    return NewKidEntity(
      firstName: parts.first,
      lastName: parts.length > 1 ? parts.sublist(1).join(' ') : null,
      schoolId: selected.id,
      grade: optional(grade),
      className: optional(className),
      medicalNotes: optional(medical),
    );
  }

  void dispose() {
    name.dispose();
    grade.dispose();
    className.dispose();
    medical.dispose();
  }
}

class _AddKidsScreenState extends State<AddKidsScreen> {
  final List<_KidForm> _kids = [_KidForm()];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OnboardingProvider>().loadSchools();
    });
  }

  @override
  void dispose() {
    for (final kid in _kids) {
      kid.dispose();
    }
    super.dispose();
  }

  void _addKid() {
    // A sibling most likely goes to the same school.
    setState(() => _kids.add(_KidForm()..school = _kids.last.school));
  }

  void _removeKid(int index) {
    setState(() => _kids.removeAt(index).dispose());
  }

  Future<void> _pickSchool(_KidForm kid) async {
    final schools = context.read<OnboardingProvider>().schools;
    if (schools.isEmpty) {
      _showError('No schools are available yet. Please try again later.');
      return;
    }
    final picked = await showModalBottomSheet<SchoolEntity>(
      context: context,
      backgroundColor: AppColors.bgScreen,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.x16),
          children: [
            for (final school in schools)
              ListTile(
                contentPadding: AppSpacing.screenGutter,
                leading:
                    const Icon(Icons.school_outlined, color: AppColors.ink),
                title: Text(school.name, style: AppTextStyles.bodyL),
                trailing: school == kid.school
                    ? const Icon(Icons.check, color: AppColors.ink)
                    : null,
                onTap: () => Navigator.pop(context, school),
              ),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => kid.school = picked);
  }

  Future<void> _handleSave() async {
    final entities = <NewKidEntity>[];
    for (final kid in _kids) {
      final entity = kid.toEntity();
      if (entity == null) {
        _showError("Add each child's name and school");
        return;
      }
      entities.add(entity);
    }

    final provider = context.read<OnboardingProvider>();
    final success = await provider.saveKids(entities);
    if (!mounted) return;

    if (success) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const JoinCircleScreen()),
      );
    } else {
      _showError(provider.errorMessage ?? 'Could not save your kids');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.statusSos),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgScreen,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenGutter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.x8),
              AppIconButton(
                icon: Icons.arrow_back,
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: AppSpacing.x32),
              Text('Add your kids', style: AppTextStyles.headingH1),
              const SizedBox(height: AppSpacing.x12),
              Text(
                'So other parents and teachers know exactly who to look out for.',
                style: AppTextStyles.bodyM
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.x32),
              for (int i = 0; i < _kids.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.x16),
                _buildKidCard(i),
              ],
              const SizedBox(height: AppSpacing.x16),
              // Outline = low emphasis, per the Button guidance.
              PrimaryButton(
                text: '+  Add another child',
                style: AppButtonStyle.outline,
                onPressed: _addKid,
              ),
              const SizedBox(height: AppSpacing.x40),
              Consumer<OnboardingProvider>(
                builder: (context, provider, child) {
                  return PrimaryButton(
                    text: provider.isLoading ? 'Saving...' : 'Save & continue',
                    onPressed: provider.isLoading ? null : _handleSave,
                  );
                },
              ),
              const SizedBox(height: AppSpacing.x24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKidCard(int index) {
    final kid = _kids[index];
    return Container(
      padding: const EdgeInsets.all(AppSpacing.x24),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: AppRadius.xlAll,
      ),
      child: Column(
        children: [
          // Rebuild the header as the name is typed.
          ListenableBuilder(
            listenable: kid.name,
            builder: (context, _) => Row(
              children: [
                AppAvatar(initials: kid.initials),
                const SizedBox(width: AppSpacing.x16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        kid.name.text.trim().isEmpty
                            ? 'Child ${index + 1}'
                            : kid.name.text.trim(),
                        style: AppTextStyles.headingH3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        kid.school?.name ?? 'Pick their school below',
                        style: AppTextStyles.bodyS.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (index > 0)
                  GestureDetector(
                    onTap: () => _removeKid(index),
                    child: Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.bgSurfaceStrong,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.x24),
          _buildField(kid.name, Icons.person_outline, 'Full name',
              capitalization: TextCapitalization.words),
          const SizedBox(height: AppSpacing.x12),
          GestureDetector(
            onTap: () => _pickSchool(kid),
            child: _buildRow(
              Icons.school_outlined,
              Text(
                kid.school?.name ?? 'School',
                style: AppTextStyles.bodyM.copyWith(
                  color: kid.school == null
                      ? AppColors.textSecondary
                      : AppColors.ink,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(
                Icons.keyboard_arrow_down,
                size: 20,
                color: AppColors.ink,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.x12),
          Row(
            children: [
              Expanded(
                child: _buildField(kid.grade, Icons.numbers, 'Grade'),
              ),
              const SizedBox(width: AppSpacing.x12),
              Expanded(
                child: _buildField(
                  kid.className,
                  Icons.keyboard_arrow_right,
                  'Class',
                  capitalization: TextCapitalization.characters,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.x12),
          _buildField(
            kid.medical,
            Icons.medical_services_outlined,
            'Allergies or medical notes',
            capitalization: TextCapitalization.sentences,
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    IconData icon,
    String hint, {
    TextCapitalization capitalization = TextCapitalization.none,
  }) {
    return _buildRow(
      icon,
      TextField(
        controller: controller,
        textCapitalization: capitalization,
        style: AppTextStyles.bodyM,
        cursorColor: AppColors.ink,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildRow(IconData icon, Widget child, {Widget? trailing}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x16,
        vertical: AppSpacing.x12,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgScreen,
        borderRadius: AppRadius.smAll,
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.ink),
          const SizedBox(width: AppSpacing.x12),
          Expanded(child: child),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
