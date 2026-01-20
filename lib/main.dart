import 'package:flutter/material.dart';
import 'package:afya_id/domain/constants/constants.dart';
import 'package:afya_id/domain/routes/routes_config.dart';
import 'package:afya_id/ui/providers/general_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ui/ui.dart';

void main() async {
  final pref = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => GeneralProvider()..getPrefs(pref),
        ),
      ],
      child: const AfyaID(),
    ),
  );
}

class AfyaID extends StatelessWidget {
  const AfyaID({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    customSystemChrome(true);

    return Consumer<GeneralProvider>(
      builder: (context, general, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: goRouter,
          title: 'AfyaID',
          darkTheme: ThemeData(
            colorScheme: .fromSeed(seedColor: AppColors.black0),
          ),
          theme: ThemeData(colorScheme: .fromSeed(seedColor: AppColors.white0)),
          themeMode: !general.isDark ? ThemeMode.dark : ThemeMode.light,
        );
      },
    );
  }
}
