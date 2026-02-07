import 'package:afya_id/domain/domain.dart';
import 'package:afya_id/ui/providers/general_provider.dart';
import 'package:afya_id/ui/views/emergency/biometric_scan_view.dart';
import 'package:afya_id/ui/views/patient/patient_vital_card.dart';
import 'package:flutter/material.dart';
import 'package:afya_id/ui/styles/app_colors.dart';
import 'package:afya_id/data/models/patient_model.dart';
import 'package:afya_id/data/services/patient_firestore_service.dart';
import 'package:provider/provider.dart';

class EmergencyDashboard extends StatefulWidget {
  const EmergencyDashboard({super.key});

  @override
  State<EmergencyDashboard> createState() => _EmergencyDashboardState();
}

class _EmergencyDashboardState extends State<EmergencyDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  final TextEditingController _searchController = TextEditingController();
  final PatientFirestoreService _patientService = PatientFirestoreService();
  List<PatientModel> _searchResults = [];
  bool _showSearchResults = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_searchController.text.isEmpty) {
      setState(() {
        _showSearchResults = false;
        _searchResults = [];
      });
    } else {
      _searchPatients(_searchController.text);
    }
  }

  Future<void> _searchPatients(String query) async {
    try {
      final results = await _patientService.searchPatientsByName(query);
      setState(() {
        _searchResults = results;
        _showSearchResults = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur de recherche: $e')));
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Sinon, afficher le tableau de bord d'urgence
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              _buildTitleArea(context),
              const SizedBox(height: 20),
              _buildSearchBar(context),
              const SizedBox(height: 10),

              if (_showSearchResults && _searchResults.isNotEmpty)
                _buildSearchResultsList(context)
              else ...[
                const SizedBox(height: 60),
                _buildMainScanButton(context),
                const SizedBox(height: 80),
                _buildSecondaryActionCards(context),
                const SizedBox(height: 48),
                _buildFooterAlert(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un patient par nom ou ID...',
                border: InputBorder.none,
                hintStyle: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() {
                  _showSearchResults = false;
                  _searchResults = [];
                });
              },
              child: const Icon(Icons.close, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchResultsList(BuildContext context) {
    final provider = Provider.of<GeneralProvider>(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final patient = _searchResults[index];
          return InkWell(
            onTap: () {
              setState(() {
                NavigationUtils().pagePush(
                  context,
                  PatientVitalCard(initialPatientId: patient.id),
                );
                // _searchController.clear();
                // _showSearchResults = false;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryTeal.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primaryTeal.withValues(
                      alpha: 0.1,
                    ),
                    child: Text(
                      '${patient.firstName[0]}${patient.lastName[0]}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryTeal,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient.fullName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'ID: ${patient.id}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Groupe Sanguin: ${patient.bloodGroup}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward, color: AppColors.primaryTeal),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTitleArea(BuildContext context) {
    return SizedBox(
      width: .maxFinite,
      child: Wrap(
        spacing: 24,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.end,
        alignment: WrapAlignment.spaceBetween,
        children: [
          IntrinsicWidth(
            child: Column(
              spacing: 4,
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
                Row(
                  spacing: 4,
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: AppColors.emergencyRed,
                      size: 16,
                    ),
                    Expanded(
                      child: Text(
                        'Centre de commande mobile - Zone 4',
                        style: TextStyle(
                          color: AppColors.emergencyRed.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Spacer(),
          _buildMiniStat('12', 'PATIENTS ACTIFS'),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.withValues(alpha: 0.2),
          ),
          _buildMiniStat('03', 'ALERTES CRITIQUES', isCritical: true),
        ],
      ),
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
            // onTap: () => context.push(
            //   RoutesPaths.patientRecord.replaceAll(':id', '12345'),
            // ),
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
    return IntrinsicHeight(
      child: Row(
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
      ),
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
          mainAxisAlignment: .center,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.emergencyRed.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.emergencyRed, size: 32),
              ),
            ),
            const SizedBox(width: 16),
            if (!AdaptiveUtil.isCompact(context))
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
            Expanded(
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.grey,
                size: 16,
              ),
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
