import 'package:afya_id/ui/views/emergency/emergency_dashboard.dart';
import 'package:afya_id/ui/views/journal/consultation_journal.dart';
import 'package:afya_id/ui/views/patient/patient_vital_card.dart';
import 'package:afya_id/ui/views/views.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:afya_id/ui/styles/app_colors.dart';
import '../../ui/styles/app_icons.dart';

double appPadding(BuildContext context) =>
    MediaQuery.sizeOf(context).width * 0.015;

const String appName = "afyaid";

const double appRadius = 25;

// const String appFont = "Inter";

enum Genre { M, F }

enum AppPages {
  emergency('Emergency', EmergencyDashboard()),
  addPatient('AddPatient', RegistrationForm()),
  docPatient('DocPatient', PatientVitalCard()),
  consultation('Consultation', ConsultationJournal()),
  journalAudit('JournalAudit', AuditLogs());

  // Champs personnalisés
  final String label;
  final Widget page;

  // Constructeur constant
  const AppPages(this.label, this.page);

  // Une méthode pour vérifier si c'est un homme
  // bool get estHomme => this == AppPages.M;
}

SizedBox noDataError(BuildContext context, {String? text, IconData? icon}) {
  return SizedBox(
    height: 150,
    child: Column(
      spacing: 10,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon ?? AppIcons.empty, size: 35),
        Text(text ?? "Pas de données"),
      ],
    ),
  );
}

void customSystemChrome(bool isDark) {
  return SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: isDark ? AppColors.black0 : AppColors.white0,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: isDark
          ? Brightness.dark
          : Brightness.light,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
    ),
  );
}
