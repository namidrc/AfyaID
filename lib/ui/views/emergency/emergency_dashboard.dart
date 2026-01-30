import 'package:afya_id/domain/domain.dart';
import 'package:afya_id/ui/views/emergency/biometric_scan_view.dart';
import 'package:flutter/material.dart';
import 'package:afya_id/ui/styles/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:afya_id/domain/routes/routes_paths.dart';

class EmergencyDashboard extends StatefulWidget {
  const EmergencyDashboard({super.key});

  @override
  State<EmergencyDashboard> createState() => _EmergencyDashboardState();
}

class _EmergencyDashboardState extends State<EmergencyDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleArea(context),
              const SizedBox(height: 60),
              _buildMainScanButton(context),
              const SizedBox(height: 80),
              _buildSecondaryActionCards(context),
              const SizedBox(height: 48),
              _buildFooterAlert(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleArea(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tableau de Bord Urgence',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: AppColors.emergencyRed,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Centre de commande mobile - Zone 4',
                    style: TextStyle(
                      color: AppColors.emergencyRed.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        _buildMiniStat('12', 'PATIENTS ACTIFS'),
        const SizedBox(width: 24),
        Container(
          width: 1,
          height: 40,
          color: Colors.grey.withValues(alpha: 0.2),
        ),
        const SizedBox(width: 24),
        _buildMiniStat('03', 'ALERTES CRITIQUES', isCritical: true),
      ],
    );
  }

  Widget _buildMiniStat(String value, String label, {bool isCritical = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isCritical ? AppColors.emergencyRed : null,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMainScanButton(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Decorative rings
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: 280 + (40 * _pulseController.value),
                height: 280 + (40 * _pulseController.value),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.emergencyRed.withValues(
                      alpha: 0.1 * (1 - _pulseController.value),
                    ),
                  ),
                ),
              );
            },
          ),
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.emergencyRed.withValues(alpha: 0.1),
              ),
            ),
          ),
          // Glow
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.emergencyRed.withValues(alpha: 0.3),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
          // Button
          GestureDetector(
            onTap: () => context.push(
              RoutesPaths.patientRecord.replaceAll(':id', '12345'),
            ),
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.emergencyRed,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.emergencyRed.withValues(alpha: 0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.favorite_rounded,
                    color: Colors.white,
                    size: 72,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'SCAN D\'URGENCE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryActionCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            Icons.face_rounded,
            'Reconnaissance Faciale',
            'Identifier via scan biométrique',
            onTap: () {
              NavigationUtils().pagePush(
                context,
                BiometricScanView(isFace: true),
              );
            },
            // onTap: () =>
            //     context.pushNamed(RoutesPaths.biometricScan, extra: true),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildActionCard(
            Icons.fingerprint_rounded,
            'Empreinte Digitale',
            'Scanner l\'index ou le pouce',
            onTap: () {
              NavigationUtils().pagePush(
                context,
                BiometricScanView(isFace: false),
              );
            },
            // onTap: () =>
            //     context.pushNamed(RoutesPaths.biometricScan, extra: false),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.emergencyRed.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.emergencyRed, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterAlert(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_rounded, color: Colors.orange, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Assurez-vous que le patient est stabilisé avant le scan.',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
