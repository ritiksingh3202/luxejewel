import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../application/app_state.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/validation/validators.dart';
import '../../router/nav.dart';
import '../../shared/feedback.dart';
import '../../shared/widgets/luxe_button.dart';
import '../../shared/widgets/luxe_image.dart';
import '../../shared/widgets/luxe_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final AppState _app = context.read<AppState>();
  late final _name = TextEditingController(text: _app.profile?.fullName);
  late final _phone = TextEditingController(text: _app.profile?.phone);
  late final _email = TextEditingController(text: context.read<AuthController>().session?.email);
  bool _saving = false;
  bool _uploading = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (file == null || !mounted) return;
    setState(() => _uploading = true);
    final bytes = await file.readAsBytes();
    final name = file.name.contains('.') ? file.name : (file.mimeType ?? 'image/jpeg');
    final ext = name.split(RegExp(r'[./]')).last;
    if (!mounted) return;
    await runWithFeedback(context, () => _app.uploadAvatar(bytes, ext), success: 'Profile photo updated');
    if (mounted) setState(() => _uploading = false);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final ok = await runWithFeedback(
      context,
      () => _app.updateProfile(fullName: _name.text, phone: _phone.text),
      success: 'Profile saved',
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) context.popOrGo('/profile');
  }

  @override
  Widget build(BuildContext context) {
    final avatar = context.watch<AppState>().profile?.avatarUrl;
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.popOrGo('/profile'),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Edit Profile'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Stack(
                      children: [
                        ClipOval(
                          child: SizedBox(
                            width: 104,
                            height: 104,
                            child: _uploading
                                ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                                : LuxeImage(
                                    source: (avatar == null || avatar.isEmpty) ? AppAssets.avatarDefault : avatar,
                                    semanticLabel: 'Profile photo',
                                  ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Material(
                            color: AppColors.gold,
                            shape: const CircleBorder(),
                            child: IconButton(
                              tooltip: 'Change photo',
                              onPressed: _uploading ? null : _pickAvatar,
                              icon: const Icon(Icons.camera_alt_outlined, color: AppColors.bgPrimary, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  LuxeTextField(label: 'Email', controller: _email, readOnly: true),
                  const SizedBox(height: 16),
                  LuxeTextField(controller: _name, label: 'Full Name', validator: Validators.name),
                  const SizedBox(height: 16),
                  LuxeTextField(
                    controller: _phone,
                    label: 'Phone Number',
                    keyboardType: TextInputType.phone,
                    validator: (v) => Validators.phone(v, isRequired: false),
                  ),
                  const SizedBox(height: 24),
                  LuxeButton(
                    label: _saving ? 'Saving…' : 'Save Changes',
                    expanded: true,
                    onPressed: _saving ? null : _save,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
