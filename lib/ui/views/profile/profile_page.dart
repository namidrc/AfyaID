import 'package:flutter/material.dart';
import 'package:afya_id/ui/styles/app_colors.dart';
import 'package:afya_id/domain/utils/general_utils.dart';
import 'package:afya_id/ui/providers/general_provider.dart';
import 'package:afya_id/data/models/user_model.dart';
import 'package:afya_id/data/services/user_firestore_service.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:afya_id/domain/routes/routes_paths.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<GeneralProvider>(context, listen: false);
    final user = provider.userModel;

    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<GeneralProvider>(context, listen: false);
      final updatedUser = provider.userModel!.copyWith(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        phoneNumber: _phoneController.text,
      );

      await UserFirestoreService().updateUser(updatedUser);
      provider.setUserData(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil mis à jour avec succès'),
            backgroundColor: AppColors.green,
          ),
        );
        setState(() {
          _isEditing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: AppColors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    await GeneralUtils().confirmationDialog(
      context,
      text: 'Êtes-vous sûr de vouloir vous déconnecter?',
      icon: Icons.logout,
      confirmLabel: 'Déconnexion',
      confirmColor: AppColors.red,
      onConfirm: () async {
        final provider = Provider.of<GeneralProvider>(context, listen: false);
        await provider.logout();
        if (mounted) {
          context.go(RoutesPaths.login);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GeneralProvider>(
      builder: (context, provider, child) {
        final user = provider.userModel;

        if (user == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_off, size: 80, color: AppColors.grey),
                  const SizedBox(height: 16),
                  const Text('Aucun utilisateur connecté'),
                  const SizedBox(height: 24),
                  GeneralUtils().generalButton(
                    backColor: AppColors.primaryTeal,
                    text: 'Se connecter',
                    tapAction: () => context.go(RoutesPaths.login),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _buildHeader(user),

                    const SizedBox(height: 40),

                    // Profile Card
                    _buildProfileCard(user),

                    const SizedBox(height: 24),

                    // Info Cards
                    _buildInfoCards(user),

                    const SizedBox(height: 24),

                    // Actions
                    _buildActions(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(UserModel user) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mon Profil',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Gérez vos informations personnelles',
                style: TextStyle(color: AppColors.grey, fontSize: 16),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _isEditing = !_isEditing;
            });
          },
          icon: Icon(
            _isEditing ? Icons.close : Icons.edit,
            color: _isEditing ? AppColors.red : AppColors.primaryTeal,
          ),
          tooltip: _isEditing ? 'Annuler' : 'Modifier',
        ),
      ],
    );
  }

  Widget _buildProfileCard(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryTeal.withValues(alpha: 0.1),
              border: Border.all(color: AppColors.primaryTeal, width: 3),
            ),
            child: user.imageUrl != null && user.imageUrl!.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      user.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildAvatarFallback(user);
                      },
                    ),
                  )
                : _buildAvatarFallback(user),
          ),

          const SizedBox(height: 24),

          // Name
          Text(
            user.fullName,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          // Role Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _getRoleColor(user.role).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getRoleColor(user.role).withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              _getRoleLabel(user.role),
              style: TextStyle(
                color: _getRoleColor(user.role),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Status
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: user.isActive ? AppColors.green : AppColors.grey,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                user.isActive ? 'Actif' : 'Inactif',
                style: TextStyle(
                  color: user.isActive ? AppColors.green : AppColors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          if (_isEditing) ...[
            const SizedBox(height: 32),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(
                    controller: _firstNameController,
                    label: 'Prénom',
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _lastNameController,
                    label: 'Nom',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email,
                    enabled: false,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Téléphone',
                    icon: Icons.phone,
                  ),
                  const SizedBox(height: 24),
                  GeneralUtils().generalButton(
                    backColor: AppColors.primaryTeal,
                    tapAction: _isLoading ? null : _saveProfile,
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Enregistrer',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatarFallback(UserModel user) {
    return Center(
      child: Text(
        user.firstName.isNotEmpty && user.lastName.isNotEmpty
            ? '${user.firstName[0]}${user.lastName[0]}'.toUpperCase()
            : 'U',
        style: const TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryTeal,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryTeal, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ce champ est requis';
        }
        return null;
      },
    );
  }

  Widget _buildInfoCards(UserModel user) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            'Email',
            user.email,
            Icons.email,
            AppColors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildInfoCard(
            'Téléphone',
            user.phoneNumber ?? 'Non renseigné',
            Icons.phone,
            AppColors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        GeneralUtils().generalButton(
          backColor: AppColors.red.withValues(alpha: 0.1),
          borderColor: AppColors.red,
          tapAction: _handleLogout,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, color: AppColors.red),
              SizedBox(width: 12),
              Text(
                'Se déconnecter',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.red,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getRoleColor(String role) {
    if (role.toLowerCase().contains('urgentiste')) {
      return AppColors.emergencyRed;
    } else if (role.toLowerCase().contains('medecin')) {
      return AppColors.patientBlue;
    } else if (role.toLowerCase().contains('dentiste')) {
      return AppColors.primaryTeal;
    } else {
      return AppColors.green;
    }
  }

  String _getRoleLabel(String role) {
    if (role.toLowerCase().contains('urgentiste')) {
      return 'Urgentiste';
    } else if (role.toLowerCase().contains('medecin')) {
      return 'Médecin';
    } else if (role.toLowerCase().contains('dentiste')) {
      return 'Dentiste';
    } else if (role.toLowerCase().contains('infirmiere')) {
      return 'Infirmière';
    }
    return role;
  }
}
