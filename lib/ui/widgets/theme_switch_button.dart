import 'package:flutter/material.dart';
import 'package:afya_id/ui/providers/general_provider.dart';
import 'package:provider/provider.dart';

class ThemeSwitchButton extends StatelessWidget {
  const ThemeSwitchButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<GeneralProvider>(context);
    return Switch(
      value: theme.isDark,
      onChanged: (value) {
        theme.changeTheme(value);
      },
    );
  }
}
