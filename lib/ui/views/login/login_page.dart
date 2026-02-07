import 'package:afya_id/data/models/user_model.dart';
import 'package:afya_id/data/services/user_firestore_service.dart';
import 'package:afya_id/domain/constants/constants.dart';
import 'package:afya_id/domain/domain.dart';
import 'package:afya_id/ui/providers/general_provider.dart';
import 'package:afya_id/ui/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:afya_id/ui/styles/app_colors.dart';
import 'package:afya_id/domain/utils/general_utils.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _formKey = GlobalKey<FormState>();

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _rememberMe = false;
  List<UserModel> userList = [];
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final provider = Provider.of<GeneralProvider>(context);

    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: StreamBuilder(
        stream: UserFirestoreService().streamAllUsers(),
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.hasData) {
            userList = asyncSnapshot.data!;
          }
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo and Title
                        _buildHeader(),

                        const SizedBox(height: 60),

                        // Email field
                        _buildEmailField(),

                        const SizedBox(height: 20),

                        // Password field
                        _buildPasswordField(),

                        const SizedBox(height: 16),

                        // Remember me & Forgot password
                        _buildRememberAndForgot(),

                        const SizedBox(height: 32),

                        // Login button
                        _buildLoginButton(),

                        const SizedBox(height: 24),

                        // Divider
                        _buildDivider(),

                        const SizedBox(height: 24),

                        // Quick access cards
                        _buildQuickAccessCards(),

                        const SizedBox(height: 40),

                        // Footer
                        _buildFooter(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo/Icon
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.primaryTeal.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.local_hospital,
            size: 50,
            color: AppColors.primaryTeal,
          ),
        ),

        const SizedBox(height: 24),

        // Title
        const Text(
          'AfyaID',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Mediical management system',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'exemple@afyaid.com',
        prefixIcon: const Icon(Icons.email_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryTeal, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer votre email';
        }
        if (!value.contains('@')) {
          return 'Email invalide';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: '••••••••',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryTeal, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer votre mot de passe';
        }
        if (value.length < 6) {
          return 'Le mot de passe doit contenir au moins 6 caractères';
        }
        return null;
      },
    );
  }

  Widget _buildRememberAndForgot() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (value) {
                setState(() {
                  _rememberMe = value ?? false;
                });
              },
              activeColor: AppColors.primaryTeal,
            ),
            const Text('Remember me', style: TextStyle(fontSize: 14)),
          ],
        ),
        TextButton(
          onPressed: () {
            // TODO: Navigate to forgot password
          },
          child: const Text(
            'Forgot password?',
            style: TextStyle(
              color: AppColors.primaryTeal,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    final provider = Provider.of<GeneralProvider>(context);

    return GeneralUtils().generalButton(
      backColor: AppColors.primaryTeal,
      tapAction: () async {
        // final user = UserModel(
        //   passWord: "1234",
        //   lastLogin: DateTime.now(),
        //   id: "Kevin_Kishikanyi_kevinkish117@gmail.com_${DateTime.now().millisecondsSinceEpoch}",

        //   email: "kevinkish117@gmail.com",
        //   createdAt: DateTime.now(),
        //   firstName: "Kevin Justin",
        //   lastName: "KISHIKANYI",
        //   role: UserRoles.urgentiste.toString(),
        //   isActive: true,
        //   phoneNumber: "+243991617472",
        // );
        // await UserFirestoreService().createUser(user);

        if (!_formKey.currentState!.validate()) return;

        setState(() {
          _isLoading = true;
        });

        // Simulate login delay
        await Future.delayed(const Duration(seconds: 2));
        if (userList.any(
          (element) =>
              element.email == _emailController.text &&
              element.passWord == _passwordController.text,
        )) {
          provider.setUserData(
            userList.firstWhere(
              (element) =>
                  element.email == _emailController.text &&
                  element.passWord == _passwordController.text,
            ),
          );
          final pref = await SharedPreferences.getInstance();
          await pref.setString("USERID", provider.userModel!.id);
          context.go(RoutesPaths.host);
        } else {
          snackbarMessage(context, text: "Utilisateur non existant");
        }

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      },
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
              'Log in',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.grey.withValues(alpha: 0.3))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Quick access',
            style: TextStyle(
              color: AppColors.grey,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.grey.withValues(alpha: 0.3))),
      ],
    );
  }

  Widget _buildQuickAccessCards() {
    return Row(
      spacing: 16,
      children: [
        Expanded(
          child: _buildQuickAccessCard(
            'Emergency',
            Icons.emergency,
            AppColors.emergencyRed,
            () {
              context.go(RoutesPaths.host);
            },
          ),
        ),
        Expanded(
          child: _buildQuickAccessCard(
            'Patient',
            Icons.person,
            AppColors.patientBlue,
            () {
              context.go('/patient');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccessCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GeneralUtils().generalButton(
      padding: const EdgeInsets.all(20),
      backColor: color.withValues(alpha: 0.1),
      borderColor: color.withValues(alpha: 0.3),
      radius: 12,
      tapAction: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'Version 1.0.0',
          style: TextStyle(color: AppColors.grey, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Text(
          '© 2026 NAMI - All right reserved',
          style: TextStyle(color: AppColors.grey, fontSize: 12),
        ),
      ],
    );
  }
}
