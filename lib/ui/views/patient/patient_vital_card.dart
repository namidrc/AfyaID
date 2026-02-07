import 'package:flutter/material.dart';
import 'package:afya_id/ui/styles/app_colors.dart';
import 'package:afya_id/domain/utils/general_utils.dart';
import 'package:afya_id/data/models/models.dart';
import 'package:afya_id/data/services/services.dart';
import 'package:afya_id/ui/views/registration/registration_form.dart';

class PatientVitalCard extends StatefulWidget {
  final String? initialPatientId;
  const PatientVitalCard({super.key, this.initialPatientId});

  @override
  State<PatientVitalCard> createState() => _PatientVitalCardState();
}

class _PatientVitalCardState extends State<PatientVitalCard> {
  String? _selectedPatientId;
  final TextEditingController _searchController = TextEditingController();
  final PatientFirestoreService _patientService = PatientFirestoreService();
  List<PatientModel> _filteredPatients = [];

  @override
  void initState() {
    super.initState();
    _selectedPatientId = widget.initialPatientId;
  }

  void _filterPatients(String query, List<PatientModel> patients) {
    setState(() {
      if (query.isEmpty) {
        _filteredPatients = patients;
      } else {
        _filteredPatients = patients.where((patient) {
          final fullName = patient.fullName.toLowerCase();
          return fullName.contains(query.toLowerCase()) ||
              patient.id.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedPatientId != null) {
      return StreamBuilder<PatientModel?>(
        stream: _patientService.streamPatient(_selectedPatientId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Patient non trouvé'));
          }

          return _PatientDetailsView(
            patient: snapshot.data!,
            onBack: () {
              setState(() {
                _selectedPatientId = null;
              });
            },
          );
        },
      );
    }
    return _buildPatientList(context);
  }

  Widget _buildPatientList(BuildContext context) {
    return StreamBuilder<List<PatientModel>>(
      stream: _patientService.streamAllPatients(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        final patients = snapshot.data ?? [];

        // Update filtered patients when data changes
        if (_searchController.text.isEmpty) {
          _filteredPatients = patients;
        } else {
          _filterPatients(_searchController.text, patients);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Liste des Patients",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      // color: AppColors.patientBlue,
                    ),
                  ),
                  const SizedBox(height: 24),
                  GeneralUtils().generalSearchBar(
                    context,
                    searchBarController: _searchController,
                    onChanged: (query) => _filterPatients(query, patients),
                  ),
                  const SizedBox(height: 24),
                  if (_filteredPatients.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Text(
                          "Aucun patient trouvé.",
                          style: TextStyle(color: AppColors.grey),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredPatients.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final patient = _filteredPatients[index];
                        return _buildPatientListItem(context, patient);
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPatientListItem(BuildContext context, PatientModel patient) {
    return GeneralUtils().generalButton(
      padding: EdgeInsets.zero,
      backColor: Theme.of(context).colorScheme.surface,
      radius: 16,
      tapAction: () {
        setState(() {
          _selectedPatientId = patient.id;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.grey.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 30,
              backgroundImage: patient.imageUrl.isNotEmpty
                  ? NetworkImage(patient.imageUrl)
                  : null,
              child: patient.imageUrl.isEmpty
                  ? Text(
                      patient.firstName[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            // Patient Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.fullName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${patient.age} ans • ${patient.gender}",
                    style: TextStyle(color: AppColors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: AppColors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          patient.location,
                          style: TextStyle(color: AppColors.grey, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Patient ID Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.patientBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "#${patient.id}",
                style: const TextStyle(
                  color: AppColors.patientBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// ORIGINAL CONTENT REFACTORED INTO A STATLESS WIDGET FOR DETAILS

class _PatientDetailsView extends StatefulWidget {
  final PatientModel patient;
  final VoidCallback onBack;

  const _PatientDetailsView({required this.patient, required this.onBack});

  @override
  State<_PatientDetailsView> createState() => _PatientDetailsViewState();
}

class _PatientDetailsViewState extends State<_PatientDetailsView> {
  final PatientFirestoreService _patientService = PatientFirestoreService();

  Future<void> _deletePatient() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer le patient ${widget.patient.fullName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ANNULER'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('SUPPRIMER', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _patientService.deletePatient(widget.patient.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Patient supprimé avec succès')),
          );
          widget.onBack();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBreadcrumb(context),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 1000) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 4, child: _buildLeftColumn(context)),
                        const SizedBox(width: 24),
                        Expanded(flex: 5, child: _buildCenterColumn(context)),
                        const SizedBox(width: 24),
                        Expanded(flex: 3, child: _buildRightColumn(context)),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        _buildLeftColumn(context),
                        const SizedBox(height: 24),
                        _buildCenterColumn(context),
                        const SizedBox(height: 24),
                        _buildRightColumn(context),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreadcrumb(BuildContext context) {
    return Row(
      children: [
        GeneralUtils().generalButton(
          padding: EdgeInsets.symmetric(horizontal: 4),
          radius: 16,
          tapAction: widget.onBack,
          child: Row(
            children: [
              const Icon(Icons.arrow_back, size: 16, color: AppColors.grey),
              const SizedBox(width: 4),
              Text(
                'Liste Patients',
                style: TextStyle(color: AppColors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.chevron_right, size: 16, color: AppColors.grey),
        Text(
          'Fiche Patient #${widget.patient.id}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.green.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'SYNCHRONISÉ',
                style: TextStyle(
                  color: AppColors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeftColumn(BuildContext context) {
    return Column(
      children: [
        _buildIdentityCard(context),
        const SizedBox(height: 24),
        _buildVitalsCard(context),
      ],
    );
  }

  Widget _buildIdentityCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Container(
            height: 4,
            decoration: const BoxDecoration(
              color: AppColors.patientBlue,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.grey2,
                            // borderRadius: BorderRadius.circular(12),
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: NetworkImage(widget.patient.imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -4,
                          right: -4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.verified,
                              color: Colors.blue,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.patient.firstName} ${widget.patient.lastName}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.fingerprint,
                                size: 16,
                                color: AppColors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'ID: #${widget.patient.id}-AFY',
                                style: const TextStyle(
                                  color: AppColors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildPill('${widget.patient.age} ANS'),
                              const SizedBox(width: 8),
                              _buildPill(widget.patient.gender),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 48, color: AppColors.grey),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        'DATE DE NAISSANCE',
                        '12 Mai 1989',
                      ), // Placeholder, logic can be added
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        'LOCALISATION',
                        widget.patient.location,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.grey.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.grey.withValues(alpha: 0.5),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildVitalsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      color: AppColors.patientBlue,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Constantes Vitales',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Il y a 15 min',
                  style: TextStyle(color: AppColors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.grey),
          Padding(
            padding: const EdgeInsets.all(20),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildVitalMetric(
                  'FC (BPM)',
                  '88',
                  Icons.favorite,
                  Colors.pinkAccent,
                  context,
                ),
                _buildVitalMetric(
                  'SpO2 (%)',
                  '98',
                  Icons.air,
                  Colors.cyan,
                  context,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.grey.withValues(alpha: 0.3)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TENSION ARTÉRIELLE',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '120/80 mmHg',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Chip(
                  label: const Text(
                    'NORMALE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  backgroundColor: AppColors.green,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {},
            child: const Text('VOIR L\'HISTORIQUE COMPLET'),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildVitalMetric(
    String label,
    String value,
    IconData icon,
    Color color,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(icon, color: color, size: 16),
            ],
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterColumn(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildCriticalCard(
                'GROUPE SANGUIN',
                widget.patient.bloodGroup,
                Colors.redAccent,
                Icons.bloodtype,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildCriticalCard(
                'ALLERGIE SÉVÈRE',
                widget.patient.allergy,
                AppColors.surfacePatientDark,
                Icons.warning_rounded,
                isAllergy: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildMedicalHistory(context),
      ],
    );
  }

  Widget _buildCriticalCard(
    String label,
    String value,
    Color bgColor,
    IconData icon, {
    bool isAllergy = false,
  }) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: isAllergy
            ? Border.all(color: Colors.redAccent, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: bgColor.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              icon,
              color: Colors.white.withValues(alpha: 0.1),
              size: 100,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isAllergy
                      ? Colors.redAccent
                      : Colors.white.withValues(alpha: 0.8),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: isAllergy ? 24 : 40,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              if (isAllergy)
                const Text(
                  'Réaction: Anaphylaxie',
                  style: TextStyle(fontSize: 12, color: AppColors.grey),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalHistory(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.history, color: AppColors.grey, size: 20),
                    SizedBox(width: 12),
                    Text(
                      'Antécédents & Notes',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    Icons.add_circle_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.grey),
          _buildHistoryItem(
            Icons.medical_services_outlined,
            'Asthme Bronchique',
            'Actif',
            'Diagnostiqué en 2018. Crises occasionnelles.',
            Colors.blue,
          ),
          _buildHistoryItem(
            Icons.vaccines,
            'Vaccination Tétanos',
            'À jour',
            'Dernier rappel: 12 Jan 2023.',
            Colors.purple,
          ),
          _buildHistoryItem(
            Icons.sticky_note_2,
            'Note Clinique',
            'Hier',
            'Patient se plaint de légers maux de tête. Observation recommandée.',
            Colors.amber,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(
    IconData icon,
    String title,
    String status,
    String desc,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    _buildStatusPill(status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(color: AppColors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(String status) {
    final bool isSpecial = status == 'Actif' || status == 'Hier';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSpecial
            ? Colors.orange.withValues(alpha: 0.1)
            : AppColors.grey.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: isSpecial ? Colors.orange : AppColors.grey,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildRightColumn(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionButton(Icons.edit_document, 'ÉDITER', context),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                Icons.delete,
                'SUPPRIMER',
                context,
                isDelete: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildTreatmentsCard(context),
        const SizedBox(height: 24),
        _buildEmergencyContactCard(context),
      ],
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    BuildContext context, {
    bool isDelete = false,
  }) {
    return ElevatedButton.icon(
      onPressed: () {
        if (label == 'ÉDITER') {
          // Naviguer vers la page d'édition avec le patient
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  RegistrationForm(patientToEdit: widget.patient),
            ),
          );
        } else if (isDelete) {
          _deletePatient();
        }
      },
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isDelete
            ? Colors.red
            : Theme.of(context).colorScheme.onSurface,
        foregroundColor: isDelete
            ? Colors.white
            : Theme.of(context).colorScheme.surface,
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: BorderSide(
          color: isDelete
              ? Colors.red
              : Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildTreatmentsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.medication_rounded,
                color: AppColors.patientBlue,
                size: 18,
              ),
              SizedBox(width: 12),
              Text(
                'Traitements Actifs',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTreatmentItem('Ventoline 100µg', '2 bouffées si besoin'),
          const Divider(height: 32, color: AppColors.grey),
          _buildTreatmentItem('Paracétamol 1g', 'Toutes les 6h (Douleur)'),
        ],
      ),
    );
  }

  Widget _buildTreatmentItem(String title, String dosage) {
    return Row(
      children: [
        const Icon(Icons.check_circle, color: AppColors.green, size: 18),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(
              dosage,
              style: const TextStyle(color: AppColors.grey, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmergencyContactCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.contact_phone,
                color: Theme.of(context).colorScheme.primary,
                size: 18,
              ),
              const SizedBox(width: 12),
              Text(
                'Contact Urgence',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.surfacePatientDark,
                child: Icon(Icons.person, color: AppColors.grey),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Dr. Kakule", // Mocked data
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    "+243 999 123 456", // Mocked data
                    style: const TextStyle(color: AppColors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
