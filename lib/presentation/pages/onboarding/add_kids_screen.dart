import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/new_kid_entity.dart';
import '../../../domain/entities/school_entity.dart';
import '../../providers/onboarding_provider.dart';
import '../../widgets/app_alert.dart';
import '../../widgets/app_avatar.dart';
import '../../widgets/app_chip.dart';
import '../../widgets/app_icon_button.dart';
import '../../widgets/app_input.dart';
import '../../widgets/primary_button.dart';
import 'join_circle_screen.dart';

class AddKidsScreen extends StatefulWidget {
  const AddKidsScreen({super.key});

  @override
  State<AddKidsScreen> createState() => _AddKidsScreenState();
}

/// Controllers, the picked school and the photo for one kid card.
class _KidForm {
  final name = TextEditingController();
  final age = TextEditingController();
  final medical = TextEditingController();
  final contact = TextEditingController();
  SchoolEntity? school;
  File? photo;

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

  /// "Age 8 · Photo added" — only the parts we actually have.
  String get summary {
    final bits = <String>[
      if (age.text.trim().isNotEmpty) 'Age ${age.text.trim()}',
      if (school != null) school!.name,
      if (photo != null) 'Photo added',
    ];
    return bits.isEmpty ? 'Add their details' : bits.join(' · ');
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
      medicalNotes: optional(medical),
    );
  }

  void dispose() {
    name.dispose();
    age.dispose();
    medical.dispose();
    contact.dispose();
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

  /// Lets the parent take a photo with the camera or pick one from the library.
  Future<void> _pickPhoto(_KidForm kid) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.bgScreen,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.x16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: AppSpacing.screenGutter,
                leading: const Icon(Icons.photo_camera_outlined,
                    color: AppColors.ink),
                title: Text('Take photo', style: AppTextStyles.bodyL),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                contentPadding: AppSpacing.screenGutter,
                leading: const Icon(Icons.photo_library_outlined,
                    color: AppColors.ink),
                title: Text('Choose from library', style: AppTextStyles.bodyL),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              if (kid.photo != null)
                ListTile(
                  contentPadding: AppSpacing.screenGutter,
                  leading: const Icon(Icons.delete_outline,
                      color: AppColors.statusSos),
                  title: Text(
                    'Remove photo',
                    style: AppTextStyles.bodyL
                        .copyWith(color: AppColors.statusSos),
                  ),
                  onTap: () {
                    setState(() => kid.photo = null);
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        ),
      ),
    );
    if (source == null) return;

    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        preferredCameraDevice: CameraDevice.rear,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;
      setState(() => kid.photo = File(picked.path));
    } on PlatformException catch (e) {
      _showError(
        e.code == 'camera_access_denied' || e.code == 'photo_access_denied'
            ? 'Allow access in Settings to add a photo.'
            : 'Could not open the ${source == ImageSource.camera ? 'camera' : 'photo library'}.',
      );
    }
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
    showAppAlert(context, type: AppAlertType.error, message: message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgScreen,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar — 16px gutter, the back button floats on its own row.
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.x16,
                AppSpacing.x4,
                AppSpacing.x16,
                AppSpacing.x8,
              ),
              child: AppIconButton(
                icon: Icons.arrow_back,
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.x16,
                  AppSpacing.x12,
                  AppSpacing.x16,
                  AppSpacing.x32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header sits on an extra 8px so it aligns with the pills.
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.x8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Add your kids', style: AppTextStyles.displayL),
                          const SizedBox(height: AppSpacing.x12),
                          Text(
                            'So Ride Partners and teachers know exactly who to expect.',
                            style: AppTextStyles.bodyL
                                .copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x20),
                    for (int i = 0; i < _kids.length; i++) ...[
                      if (i > 0) const SizedBox(height: AppSpacing.x20),
                      _buildKidCard(i),
                    ],
                    const SizedBox(height: AppSpacing.x20),
                    _buildAddAnother(),
                    const SizedBox(height: AppSpacing.x40),
                    Consumer<OnboardingProvider>(
                      builder: (context, provider, child) {
                        return PrimaryButton(
                          text: provider.isLoading
                              ? 'Saving...'
                              : 'Save & continue',
                          onPressed: provider.isLoading ? null : _handleSave,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Ink circle + lime plus, per the "Add another" row in the design.
  Widget _buildAddAnother() {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.x8),
      child: GestureDetector(
        onTap: _addKid,
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.ink,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, size: 18, color: AppColors.lime),
            ),
            const SizedBox(width: AppSpacing.x8),
            Flexible(
              child: Text(
                'Add another child',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelL,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKidCard(int index) {
    final kid = _kids[index];
    return Container(
      padding: const EdgeInsets.all(AppSpacing.x16),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: AppRadius.xlAll,
      ),
      child: Column(
        children: [
          // Rebuild the header as the name and age are typed.
          ListenableBuilder(
            listenable: Listenable.merge([kid.name, kid.age]),
            builder: (context, _) => Row(
              children: [
                // The design renders the kid avatar as a dark photo slot.
                AppAvatar(
                  initials: kid.initials,
                  backgroundColor: AppColors.charcoal,
                  foregroundColor: AppColors.textOnDarkMuted,
                  image: kid.photo == null ? null : FileImage(kid.photo!),
                ),
                const SizedBox(width: AppSpacing.x8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // The name is edited in place, as the design shows it.
                      TextField(
                        controller: kid.name,
                        textCapitalization: TextCapitalization.words,
                        style: AppTextStyles.headingH3,
                        cursorColor: AppColors.ink,
                        decoration: InputDecoration(
                          filled: false,
                          hintText: "Child's name",
                          hintStyle: AppTextStyles.headingH3
                              .copyWith(color: AppColors.textSecondary),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        kid.summary,
                        style: AppTextStyles.bodyS
                            .copyWith(color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.x8),
                Flexible(
                  child: AppChip(
                    label: kid.photo == null ? 'Add Photo' : 'Change Photo',
                    selected: true,
                    onTap: () => _pickPhoto(kid),
                  ),
                ),
                // The design shows a single kid; extras need a way back out.
                if (index > 0) ...[
                  const SizedBox(width: AppSpacing.x8),
                  GestureDetector(
                    onTap: () => _removeKid(index),
                    child: const Icon(
                      Icons.close,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          _schoolDropdown(kid),
          const SizedBox(height: 14),
          _cardInput(
            icon: Icons.groups_outlined,
            hint: 'Age',
            controller: kid.age,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 14),
          _cardInput(
            icon: Icons.favorite_border,
            hint: 'Medical notes',
            controller: kid.medical,
            capitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 14),
          _cardInput(
            icon: Icons.call_outlined,
            hint: 'Emergency contact',
            controller: kid.contact,
            capitalization: TextCapitalization.words,
          ),
        ],
      ),
    );
  }

  /// Input pill as it appears inside a surface card: white fill, ink icon.
  Widget _cardInput({
    required IconData icon,
    required String hint,
    required TextEditingController controller,
    TextInputType? keyboardType,
    TextCapitalization capitalization = TextCapitalization.none,
  }) {
    return AppInput(
      controller: controller,
      hintText: hint,
      icon: icon,
      keyboardType: keyboardType,
      capitalization: capitalization,
      backgroundColor: AppColors.bgScreen,
      iconColor: AppColors.ink,
    );
  }

  /// School picker styled as an Input pill on a surface card.
  Widget _schoolDropdown(_KidForm kid) {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, _) {
        final schools = provider.schools;
        return Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          decoration: BoxDecoration(
            color: AppColors.bgScreen,
            borderRadius: AppRadius.pill,
          ),
          child: Row(
            children: [
              const Icon(Icons.school_outlined, size: 24, color: AppColors.ink),
              const SizedBox(width: AppSpacing.x12),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<SchoolEntity>(
                    value: schools.contains(kid.school) ? kid.school : null,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: AppColors.ink),
                    dropdownColor: AppColors.bgScreen,
                    borderRadius: AppRadius.lgAll,
                    style: AppTextStyles.bodyL,
                    hint: Text(
                      schools.isEmpty && provider.isLoading
                          ? 'Loading schools...'
                          : 'School',
                      style: AppTextStyles.bodyL
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    items: [
                      for (final school in schools)
                        DropdownMenuItem(
                          value: school,
                          child: Text(
                            school.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: schools.isEmpty
                        ? null
                        : (school) => setState(() => kid.school = school),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
