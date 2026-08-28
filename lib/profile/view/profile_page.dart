import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app.dart';
import '../../authentication/bloc/auth_bloc.dart';
import '../../authentication/bloc/auth_event.dart';
import '../../authentication/bloc/auth_state.dart';
import '../../authentication/view/login_page.dart';
import '../../shared/widgets/app_bottom_navigation.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _nameController;
  late FocusNode _nameFocusNode;

  bool _isEditing = false;
  bool _isSaving = false;


  @override
  @override
  void initState() {
    super.initState();

    final authState = context.read<AuthBloc>().state;

    final currentName = authState.user?.name.isNotEmpty == true
        ? authState.user!.name
        : authState.name;

    _nameController = TextEditingController(text: currentName);

    _nameFocusNode = FocusNode();
  }


  @override
  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }


  String _getDiceBearAvatar(String seed) {
    final encodedSeed = Uri.encodeComponent(
      seed.trim().isEmpty ? 'employee' : seed.trim(),
    );

    return 'https://api.dicebear.com/10.x/avataaars/png'
        '?seed=$encodedSeed'
        '&size=256';
  }

  List<String> _getDiceBearAvatars(String seed) {
    final safeSeed = seed.trim().isEmpty ? 'employee' : seed.trim();

    return [
      _getDiceBearAvatar('$safeSeed-avatar-1'),
      _getDiceBearAvatar('$safeSeed-avatar-2'),
      _getDiceBearAvatar('$safeSeed-avatar-3'),
      _getDiceBearAvatar('$safeSeed-avatar-4'),
      _getDiceBearAvatar('$safeSeed-avatar-5'),
      _getDiceBearAvatar('$safeSeed-avatar-6'),
    ];
  }


  void _selectDiceBearAvatar(String avatarUrl) {
    final authState = context.read<AuthBloc>().state;
    final user = authState.user;

    if (user == null) {
      Navigator.pop(context);
      _showMessage('No authenticated user found.');
      return;
    }

    context.read<AuthBloc>().add(ProfileImageChanged(avatarUrl));

    Navigator.pop(context);

    _showMessage('Avatar updated successfully.');
  }


  void _startEditing() {
    if (_isSaving) {
      return;
    }

    setState(() {
      _isEditing = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _nameFocusNode.requestFocus();
        _nameController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _nameController.text.length,
        );
      }
    });
  }


  void _cancelEditing() {
    final authState = context.read<AuthBloc>().state;

    final currentName = authState.user?.name.isNotEmpty == true
        ? authState.user!.name
        : authState.name;

    _nameController.text = currentName;

    setState(() {
      _isEditing = false;
    });

    FocusScope.of(context).unfocus();
  }


  void _saveName() {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      _showMessage('Name cannot be empty.');
      return;
    }

    if (name.length < 2) {
      _showMessage('Name must be at least 2 characters.');
      return;
    }

    final authState = context.read<AuthBloc>().state;

    final currentName = authState.user?.name ?? authState.name;

    if (name == currentName) {
      setState(() {
        _isEditing = false;
      });

      FocusScope.of(context).unfocus();

      return;
    }

    setState(() {
      _isSaving = true;
    });

    context.read<AuthBloc>().add(ProfileNameUpdated(name));
  }

  void _removeAvatar(BuildContext sheetContext) {
    context.read<AuthBloc>().add(const ProfileImageRemoved());

    Navigator.pop(sheetContext);

    _showMessage('Avatar removed.');
  }


  void _showPhotoOptions() {
    final authState = context.read<AuthBloc>().state;
    final user = authState.user;

    final hasAvatar =
        authState.profileImage != null && authState.profileImage!.isNotEmpty;

    final avatars = _getDiceBearAvatars(user?.id ?? authState.name);

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final isDark = theme.brightness == Brightness.dark;

        final avatarTileBg = isDark
            ? theme.colorScheme.primary.withValues(alpha: 0.08)
            : AppColors.primaryLight;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 22),

                Text(
                  'Choose Profile Avatar',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  'Select an illustrated avatar',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.60),
                  ),
                ),

                const SizedBox(height: 22),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: avatars.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final avatarUrl = avatars[index];

                    final isSelected = authState.profileImage == avatarUrl;

                    return GestureDetector(
                      onTap: () {
                        _selectDiceBearAvatar(avatarUrl);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: avatarTileBg,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.dividerColor,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        padding: const EdgeInsets.all(6),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.network(
                                avatarUrl,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Icon(
                                      Icons.person_rounded,
                                      color: theme.colorScheme.primary,
                                      size: 40,
                                    ),
                                  );
                                },
                              ),
                            ),

                            if (isSelected)
                              Positioned(
                                right: 5,
                                top: 5,
                                child: Container(
                                  height: 24,
                                  width: 24,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                if (hasAvatar)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: theme.colorScheme.error,
                      ),
                    ),
                    title: Text(
                      'Remove avatar',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      'Use the default profile icon',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    onTap: () {
                      _removeAvatar(sheetContext);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);

        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,

          title: Text(
            'Logout',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),

          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.60),
                ),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();

                context.read<AuthBloc>().add(const LogoutRequested());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }


  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }


  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) {
        return previous.status != current.status ||
            previous.user?.name != current.user?.name ||
            previous.profileImage != current.profileImage;
      },

      listener: (context, state) {

        if (state.status == AuthStatus.initial) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );

          return;
        }


        if (_isSaving &&
            state.status == AuthStatus.authenticated &&
            state.user != null) {
          setState(() {
            _isSaving = false;
            _isEditing = false;
          });

          _nameController.text = state.user!.name;

          FocusScope.of(context).unfocus();

          _showMessage('Name updated successfully.');

          return;
        }


        if (state.status == AuthStatus.failure) {
          if (_isSaving) {
            setState(() {
              _isSaving = false;
            });
          }

          _showMessage(state.errorMessage ?? 'Something went wrong.');
        }
      },

      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;

          final avatarBg = isDark
              ? theme.colorScheme.primary.withValues(alpha: 0.08)
              : AppColors.primaryLight;


          final themeScope = ProfileThemeScope.of(context);


          final user = authState.user;

          final name = user?.name.isNotEmpty == true
              ? user!.name
              : authState.name.isNotEmpty
              ? authState.name
              : 'Employee';

          final email = user?.email ?? '';

          final role = user?.role.value ?? 'employee';

          final profileImage = authState.profileImage;


          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,

            bottomNavigationBar: const AppBottomNavigation(selectedIndex: 2),

            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Manage your account',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.60,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),

                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,

                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: Row(
                        children: [


                          GestureDetector(
                            onTap: _showPhotoOptions,

                            child: Stack(
                              clipBehavior: Clip.none,

                              children: [
                                Container(
                                  height: 78,
                                  width: 78,

                                  decoration: BoxDecoration(
                                    color: avatarBg,
                                    borderRadius: BorderRadius.circular(20),
                                  ),

                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(17),

                                    child:
                                        profileImage != null &&
                                            profileImage.isNotEmpty
                                        ? Image.network(
                                            profileImage,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return Icon(
                                                    Icons.person_rounded,
                                                    color: theme
                                                        .colorScheme
                                                        .primary,
                                                    size: 40,
                                                  );
                                                },
                                          )
                                        : Center(
                                            child: Icon(
                                              Icons.person_rounded,
                                              color: theme.colorScheme.primary,
                                              size: 40,
                                            ),
                                          ),
                                  ),
                                ),
                                Positioned(
                                  right: -5,
                                  bottom: -5,

                                  child: Container(
                                    height: 28,
                                    width: 28,

                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary,

                                      borderRadius: BorderRadius.circular(9),
                                    ),

                                    child: const Icon(
                                      Icons.edit_rounded,
                                      color: Colors.white,
                                      size: 14,
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
                                Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,

                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),

                                if (email.isNotEmpty) ...[
                                  const SizedBox(height: 4),

                                  Text(
                                    email,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,

                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.60),
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 9),

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),

                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(
                                      alpha: 0.10,
                                    ),

                                    borderRadius: BorderRadius.circular(20),
                                  ),

                                  child: Text(
                                    role,
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),

                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,

                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            'Name',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.60,
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),
                          TextField(
                            focusNode: _nameFocusNode,
                            controller: _nameController,
                            enabled: !_isSaving,
                            readOnly: !_isEditing,
                            cursorColor: theme.colorScheme.primary,
                            selectionControls: materialTextSelectionControls,
                            onTap: () {
                              if (!_isEditing && !_isSaving) {
                                _startEditing();
                              }
                            },
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.person_outline_rounded,
                                color: theme.colorScheme.primary,
                              ),

                              suffixIcon: _isSaving
                                  ? Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    )
                                  : !_isEditing
                                  ? IconButton(
                                      onPressed: _startEditing,
                                      icon: Icon(
                                        Icons.edit_rounded,
                                        color: theme.colorScheme.primary,
                                      ),
                                    )
                                  : null,

                              filled: true,
                              fillColor:
                                  theme.colorScheme.surfaceContainerHighest,

                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),

                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),

                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: theme.colorScheme.primary,
                                  width: 1.5,
                                ),
                              ),

                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),

                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: theme.colorScheme.primary,
                                  width: 1.5,
                                ),
                              ),

                              errorStyle: const TextStyle(
                                height: 0,
                                fontSize: 0,
                              ),

                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                          ),

                          if (_isEditing) ...[
                            const SizedBox(height: 14),

                            Row(
                              children: [

                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: _isSaving
                                        ? null
                                        : _cancelEditing,

                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),

                                      side: BorderSide(
                                        color: theme.dividerColor,
                                      ),

                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),

                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.60),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 10),

                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _isSaving ? null : _saveName,

                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),

                                      backgroundColor:
                                          theme.colorScheme.primary,

                                      foregroundColor: Colors.white,

                                      elevation: 0,

                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),

                                    child: const Text(
                                      'Save',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    Text(
                      'Preferences',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 14),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),

                      width: double.infinity,

                      padding: const EdgeInsets.all(18),

                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,

                        borderRadius: BorderRadius.circular(22),

                        boxShadow: theme.brightness == Brightness.light
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.035),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ]
                            : null,
                      ),

                      child: Row(
                        children: [
                        

                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),

                            height: 54,
                            width: 54,

                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.10,
                              ),

                              borderRadius: BorderRadius.circular(17),
                            ),

                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),

                              child: Icon(
                                themeScope.isDarkMode
                                    ? Icons.dark_mode_rounded
                                    : Icons.light_mode_rounded,

                                key: ValueKey(themeScope.isDarkMode),

                                color: theme.colorScheme.primary,

                                size: 26,
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Text(
                                  'Dark Mode',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),

                                  child: Text(
                                    themeScope.isDarkMode
                                        ? 'Dark appearance is enabled'
                                        : 'Use a darker appearance at night',

                                    key: ValueKey(themeScope.isDarkMode),

                                    style: TextStyle(
                                      fontSize: 12.5,
                                      height: 1.3,
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.60),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 12),

                          Switch(
                            value: themeScope.isDarkMode,
                            onChanged: themeScope.onThemeChanged,

                            thumbColor: WidgetStateProperty.resolveWith<Color>((
                              states,
                            ) {
                              if (states.contains(WidgetState.selected)) {
                                return Colors.white;
                              }
                              return theme.colorScheme.onSurface.withValues(
                                alpha: 0.65,
                              );
                            }),

                            trackColor: WidgetStateProperty.resolveWith<Color>((
                              states,
                            ) {
                              if (states.contains(WidgetState.selected)) {
                                return theme.colorScheme.primary;
                              }
                              return theme.colorScheme.onSurface.withValues(
                                alpha: 0.18,
                              );
                            }),

                            trackOutlineColor:
                                WidgetStateProperty.resolveWith<Color>((
                                  states,
                                ) {
                                  if (states.contains(WidgetState.selected)) {
                                    return theme.colorScheme.primary;
                                  }
                                  return theme.colorScheme.onSurface.withValues(
                                    alpha: 0.25,
                                  );
                                }),

                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 50),

                    SizedBox(
                      width: double.infinity,

                      child: OutlinedButton.icon(
                        onPressed: _isSaving ? null : _logout,

                        icon: const Icon(
                          Icons.logout_rounded,
                          color: Colors.white,
                        ),

                        label: const Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),

                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),

                          backgroundColor: theme.colorScheme.primary,

                          side: BorderSide(
                            color: theme.colorScheme.error.withValues(
                              alpha: 0.25,
                            ),
                          ),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
