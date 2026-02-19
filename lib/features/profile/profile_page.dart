import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/app_preferences.dart';
import '../auth/presentation/bloc/auth_bloc.dart';
import '../auth/presentation/bloc/auth_event.dart';
import '../auth/presentation/bloc/auth_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Notification prefs
  bool _pushNotif = true;
  bool _emailNotif = true;
  bool _resumeAlerts = true;
  bool _jobAlerts = false;

  // Settings prefs
  bool _autoSave = true;
  bool _showTips = true;
  bool _compactMode = false;
  String _fontSize = 'Medium';

  void _openNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => Container(
          decoration: BoxDecoration(
            color: Theme.of(ctx).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _sheetHandle(ctx, 'Notifications', Icons.notifications_outlined),
              _switchTile(
                ctx,
                setSheet,
                icon: Icons.phone_android_outlined,
                title: 'Push Notifications',
                subtitle: 'Receive alerts on your device',
                value: _pushNotif,
                onChanged: (v) {
                  setState(() => _pushNotif = v);
                  setSheet(() {});
                },
              ),
              const Divider(height: 1, indent: 16),
              _switchTile(
                ctx,
                setSheet,
                icon: Icons.email_outlined,
                title: 'Email Notifications',
                subtitle: 'Get updates in your inbox',
                value: _emailNotif,
                onChanged: (v) {
                  setState(() => _emailNotif = v);
                  setSheet(() {});
                },
              ),
              const Divider(height: 1, indent: 16),
              _switchTile(
                ctx,
                setSheet,
                icon: Icons.description_outlined,
                title: 'Resume Alerts',
                subtitle: 'Notify when resume is viewed',
                value: _resumeAlerts,
                onChanged: (v) {
                  setState(() => _resumeAlerts = v);
                  setSheet(() {});
                },
              ),
              const Divider(height: 1, indent: 16),
              _switchTile(
                ctx,
                setSheet,
                icon: Icons.work_outline,
                title: 'Job Match Alerts',
                subtitle: 'Get notified of matching jobs',
                value: _jobAlerts,
                onChanged: (v) {
                  setState(() => _jobAlerts = v);
                  setSheet(() {});
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _openLanguage(BuildContext context) {
    const languages = [
      {
        'code': 'English',
        'label': 'English',
        'native': 'English',
        'flag': '🇬🇧',
      },
      {'code': 'Hindi', 'label': 'Hindi', 'native': 'हिन्दी', 'flag': '🇮🇳'},
      {
        'code': 'Gujarati',
        'label': 'Gujarati',
        'native': 'ગુજરાતી',
        'flag': '🇮🇳',
      },
    ];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => Container(
          decoration: BoxDecoration(
            color: Theme.of(ctx).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _sheetHandle(ctx, 'Select Language', Icons.language_outlined),
              ...languages.map((lang) {
                final selected = languageNotifier.value == lang['code'];
                return Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 4,
                      ),
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary.withValues(alpha: 0.12)
                              : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            lang['flag']!,
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                      ),
                      title: Text(
                        lang['label']!,
                        style: TextStyle(
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: selected ? AppColors.primary : null,
                        ),
                      ),
                      subtitle: Text(
                        lang['native']!,
                        style: TextStyle(
                          color: selected
                              ? AppColors.primary.withValues(alpha: 0.7)
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                      trailing: selected
                          ? const Icon(
                              Icons.check_circle,
                              color: AppColors.primary,
                            )
                          : const Icon(
                              Icons.radio_button_unchecked,
                              color: Colors.grey,
                            ),
                      onTap: () {
                        languageNotifier.value = lang['code']!;
                        setState(() {});
                        setSheet(() {});
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.language, color: Colors.white),
                                const SizedBox(width: 10),
                                Text('Language changed to ${lang["label"]}'),
                              ],
                            ),
                            backgroundColor: AppColors.primary,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 76),
                  ],
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _openSettings(BuildContext context) {
    const fontSizes = ['Small', 'Medium', 'Large'];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => Container(
          decoration: BoxDecoration(
            color: Theme.of(ctx).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _sheetHandle(ctx, 'Settings', Icons.settings_outlined),
              _switchTile(
                ctx,
                setSheet,
                icon: Icons.save_outlined,
                title: 'Auto Save',
                subtitle: 'Automatically save resume edits',
                value: _autoSave,
                onChanged: (v) {
                  setState(() => _autoSave = v);
                  setSheet(() {});
                },
              ),
              const Divider(height: 1, indent: 16),
              _switchTile(
                ctx,
                setSheet,
                icon: Icons.lightbulb_outline,
                title: 'Show Tips',
                subtitle: 'Display helpful hints while editing',
                value: _showTips,
                onChanged: (v) {
                  setState(() => _showTips = v);
                  setSheet(() {});
                },
              ),
              const Divider(height: 1, indent: 16),
              _switchTile(
                ctx,
                setSheet,
                icon: Icons.view_compact_outlined,
                title: 'Compact Mode',
                subtitle: 'Reduce spacing for more content',
                value: _compactMode,
                onChanged: (v) {
                  setState(() => _compactMode = v);
                  setSheet(() {});
                },
              ),
              const Divider(height: 1, indent: 16),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.text_fields_outlined,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Font Size',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            'Adjust text size in resume',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: fontSizes.map((size) {
                        final sel = _fontSize == size;
                        return Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _fontSize = size);
                              setSheet(() {});
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: sel
                                    ? AppColors.primary
                                    : Colors.grey.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                size,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: sel
                                      ? Colors.white
                                      : AppColors.textSecondaryLight,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetHandle(BuildContext ctx, String title, IconData icon) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 12, bottom: 4),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              Text(
                title,
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _switchTile(
    BuildContext ctx,
    StateSetter setSheet, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  void _openEditProfile(
    BuildContext context,
    String currentName,
    String currentEmail,
  ) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: currentName);
    final emailCtrl = TextEditingController(text: currentEmail);
    final oldPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    bool obscureOld = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(ctx).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 4),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.edit_outlined,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Edit Profile',
                          style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Username
                            TextFormField(
                              controller: nameCtrl,
                              decoration: InputDecoration(
                                labelText: 'Username',
                                prefixIcon: const Icon(Icons.person_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Username cannot be empty'
                                  : null,
                            ),
                            const SizedBox(height: 14),
                            // Email
                            TextFormField(
                              controller: emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                prefixIcon: const Icon(Icons.email_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty)
                                  return 'Email cannot be empty';
                                if (!RegExp(
                                  r'^[\w.-]+@[\w.-]+\.[a-z]{2,}$',
                                ).hasMatch(v.trim())) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Change Password',
                              style: Theme.of(ctx).textTheme.titleSmall
                                  ?.copyWith(
                                    color: AppColors.textSecondaryLight,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                            ),
                            const SizedBox(height: 10),
                            // Old Password
                            TextFormField(
                              controller: oldPassCtrl,
                              obscureText: obscureOld,
                              decoration: InputDecoration(
                                labelText: 'Old Password',
                                prefixIcon: const Icon(Icons.lock_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscureOld
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                  onPressed: () =>
                                      setSheet(() => obscureOld = !obscureOld),
                                ),
                              ),
                              validator: (v) {
                                if (newPassCtrl.text.isNotEmpty &&
                                    (v == null || v.isEmpty)) {
                                  return 'Enter your current password to change it';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            // New Password
                            TextFormField(
                              controller: newPassCtrl,
                              obscureText: obscureNew,
                              decoration: InputDecoration(
                                labelText: 'New Password',
                                prefixIcon: const Icon(
                                  Icons.lock_open_outlined,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscureNew
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                  onPressed: () =>
                                      setSheet(() => obscureNew = !obscureNew),
                                ),
                              ),
                              validator: (v) {
                                if (v != null && v.isNotEmpty && v.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            // Confirm Password
                            TextFormField(
                              controller: confirmPassCtrl,
                              obscureText: obscureConfirm,
                              decoration: InputDecoration(
                                labelText: 'Confirm New Password',
                                prefixIcon: const Icon(Icons.lock_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscureConfirm
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                  onPressed: () => setSheet(
                                    () => obscureConfirm = !obscureConfirm,
                                  ),
                                ),
                              ),
                              validator: (v) {
                                if (newPassCtrl.text.isNotEmpty &&
                                    v != newPassCtrl.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            // Save Button
                            ElevatedButton(
                              onPressed: isSaving
                                  ? null
                                  : () async {
                                      if (!formKey.currentState!.validate())
                                        return;
                                      setSheet(() => isSaving = true);
                                      // Simulate save delay
                                      await Future.delayed(
                                        const Duration(milliseconds: 900),
                                      );
                                      setSheet(() => isSaving = false);
                                      if (ctx.mounted) {
                                        Navigator.of(ctx).pop();
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: const Row(
                                              children: [
                                                Icon(
                                                  Icons.check_circle,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(width: 10),
                                                Text(
                                                  'Profile updated successfully!',
                                                ),
                                              ],
                                            ),
                                            backgroundColor: AppColors.success,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: isSaving
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Save Changes',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.profile)),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return const Center(child: Text('Not authenticated'));
          }

          final user = state.user;

          return SingleChildScrollView(
            padding: const EdgeInsets.only(top: 24, left: 16, right: 16),
            child: Column(
              children: [
                // Profile Header
                Card(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 24,
                      left: 16,
                      right: 16,
                      bottom: 16,
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.primary,
                          backgroundImage: user.photoURL != null
                              ? NetworkImage(user.photoURL!)
                              : null,
                          child: user.photoURL == null
                              ? Text(
                                  user.displayName[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.displayName,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondaryLight),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () => _openEditProfile(
                            context,
                            user.displayName,
                            user.email,
                          ),
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text(AppStrings.editProfile),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Settings
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.dark_mode_outlined),
                        title: const Text(AppStrings.darkMode),
                        trailing: ValueListenableBuilder<ThemeMode>(
                          valueListenable: themeNotifier,
                          builder: (_, mode, __) => Switch.adaptive(
                            value: mode == ThemeMode.dark,
                            onChanged: (value) {
                              themeNotifier.value = value
                                  ? ThemeMode.dark
                                  : ThemeMode.light;
                            },
                            activeColor: AppColors.primary,
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.notifications_outlined),
                        title: const Text(AppStrings.notifications),
                        subtitle: Text(
                          _pushNotif ? 'On' : 'Off',
                          style: TextStyle(
                            fontSize: 12,
                            color: _pushNotif
                                ? AppColors.success
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _openNotifications(context),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.language_outlined),
                        title: const Text(AppStrings.language),
                        subtitle: ValueListenableBuilder<String>(
                          valueListenable: languageNotifier,
                          builder: (_, lang, __) => Text(
                            lang,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _openLanguage(context),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.settings_outlined),
                        title: const Text(AppStrings.settings),
                        subtitle: Text(
                          'Font: $_fontSize  •  Auto-save: ${_autoSave ? "On" : "Off"}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _openSettings(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Danger Zone
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.help_outline,
                          color: AppColors.info,
                        ),
                        title: const Text('Help & Support'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Handle help
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(
                          Icons.info_outline,
                          color: AppColors.info,
                        ),
                        title: const Text('About'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Handle about
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(
                          Icons.logout,
                          color: AppColors.error,
                        ),
                        title: const Text(
                          AppStrings.logout,
                          style: TextStyle(color: AppColors.error),
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Logout'),
                              content: const Text(
                                'Are you sure you want to logout?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(AppStrings.cancel),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    context.read<AuthBloc>().add(
                                      const SignOutEvent(),
                                    );
                                    Navigator.of(context).pop();
                                    Navigator.of(
                                      context,
                                    ).pushReplacementNamed(AppRoutes.login);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.error,
                                  ),
                                  child: const Text(AppStrings.logout),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // App Version
                Text(
                  'ResumeIQ v1.0.0',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiaryLight,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
