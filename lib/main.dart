import 'package:afya_id/data/models/user_model.dart';
import 'package:afya_id/data/services/user_firestore_service.dart';
import 'package:afya_id/ui/providers/patient_provider.dart';
import 'package:afya_id/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:afya_id/domain/constants/constants.dart';
import 'package:afya_id/domain/routes/routes_config.dart';
import 'package:afya_id/ui/providers/general_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:afya_id/firebase_options.dart';

import 'package:afya_id/ui/styles/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final pref = await SharedPreferences.getInstance();
  String userID = pref.getString("USERID") ?? "";
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => GeneralProvider()..getPrefs(pref),
        ),
        ChangeNotifierProvider(create: (context) => PatientProvider()),
      ],
      child: AfyaID(userID: userID),
    ),
  );
}

class AfyaID extends StatefulWidget {
  final String userID;
  const AfyaID({super.key, required this.userID});

  @override
  State<AfyaID> createState() => _AfyaIDState();
}

class _AfyaIDState extends State<AfyaID> {
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (widget.userID.isNotEmpty) {
      try {
        final general = Provider.of<GeneralProvider>(context, listen: false);
        final user = await UserFirestoreService().getUser(widget.userID);
        if (user != null && mounted) {
          general.setUserData(user);
        }
      } catch (error) {
        debugPrint('Erreur lors du chargement de l\'utilisateur: $error');
      }
    }
    if (mounted) {
      setState(() {
        _isLoadingUser = false;
      });
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    customSystemChrome(true);

    if (_isLoadingUser) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: AppColors.primaryTeal),
          ),
        ),
      );
    }

    return Consumer<GeneralProvider>(
      builder: (context, general, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: goRouter,
          title: 'AfyaID',
          darkTheme: AppTheme.darkTheme(context),
          theme: AppTheme.lightTheme(context),
          themeMode: general.isDark ? ThemeMode.dark : ThemeMode.light,
        );
      },
    );
  }
}
