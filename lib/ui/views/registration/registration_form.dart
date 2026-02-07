import 'package:afya_id/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:afya_id/ui/styles/app_colors.dart';
import 'package:afya_id/data/models/patient_model.dart';
import 'package:afya_id/data/services/patient_firestore_service.dart';

class RegistrationForm extends StatefulWidget {
  final PatientModel? patientToEdit;

  const RegistrationForm({super.key, this.patientToEdit});

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  String? _selectedBloodType;
  String? _selectedGender;
  bool _isLoading = false;
  List<String> _chronicConditions = [];
  bool _consentChecked = false;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _nationalIdController = TextEditingController();
  final TextEditingController _chronicConditionsInputController =
      TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();

  final PatientFirestoreService _patientService = PatientFirestoreService();

  @override
  void initState() {
    super.initState();
    _selectedBloodType = 'A+';
    _selectedGender = 'M';

    // Si on édite un patient existant
    if (widget.patientToEdit != null) {
      _loadPatientData(widget.patientToEdit!);
    }
  }

  void _loadPatientData(PatientModel patient) {
    _firstNameController.text = patient.firstName;
    _lastNameController.text = patient.lastName;
    _locationController.text = patient.location;
    _dateOfBirthController.text = patient.dateOfBirth.toString().split(' ')[0];
    _nationalIdController.text = patient.nationalId;
    _allergiesController.text = patient.allergy;
    _selectedBloodType = patient.bloodGroup;
    _selectedGender = patient.gender;
    _chronicConditions = List.from(patient.chronicConditions);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _locationController.dispose();
    _dateOfBirthController.dispose();
    _nationalIdController.dispose();
    _chronicConditionsInputController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }

  Future<void> _savePatient() async {
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _nationalIdController.text.isEmpty) {
      snackbarMessage(
        context,
        text: "Veuillez remplir tous les champs obligatoires",
      );
      // return;
    }

    if (!_consentChecked) {
      snackbarMessage(context, text: "Veuillez confirmer le consentement");
      // return;
    }

    setState(() => _isLoading = true);

    try {
      final DateTime dateOfBirth =
          DateTime.tryParse(_dateOfBirthController.text) ?? DateTime.now();
      final int age = DateTime.now().year - dateOfBirth.year;

      final patient = PatientModel(
        id:
            widget.patientToEdit?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        age: age,
        gender: _selectedGender ?? 'M',
        location: _locationController.text.trim(),
        imageUrl: widget.patientToEdit?.imageUrl ?? '',
        bloodGroup: _selectedBloodType ?? 'O+',
        allergy: _allergiesController.text.trim(),
        dateOfBirth: dateOfBirth,
        nationalId: _nationalIdController.text.trim(),
        chronicConditions: _chronicConditions,
        createdAt: widget.patientToEdit?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.patientToEdit != null) {
        await _patientService.updatePatient(patient);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Patient mis à jour avec succès')),
          );
        }
      } else {
        await _patientService.createPatient(patient);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Patient créé avec succès')),
          );
        }
        _resetForm();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _resetForm() {
    _firstNameController.clear();
    _lastNameController.clear();
    _locationController.clear();
    _dateOfBirthController.clear();
    _nationalIdController.clear();
    _chronicConditionsInputController.clear();
    _allergiesController.clear();
    setState(() {
      _selectedBloodType = 'A+';
      _selectedGender = 'M';
      _chronicConditions = [];
      _consentChecked = false;
    });
  }

  void _addChronicCondition() {
    final text = _chronicConditionsInputController.text.trim();
    if (text.isNotEmpty && !_chronicConditions.contains(text)) {
      setState(() {
        _chronicConditions.add(text);
        _chronicConditionsInputController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBreadcrumbs(context),
              const SizedBox(height: 32),
              Text(
                widget.patientToEdit != null
                    ? 'Modifier Enregistrement'
                    : 'Nouvel Enregistrement',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Inscrire un nouveau patient dans la base de données de santé d\'urgence.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),
              _buildProgressStepper(context),
              const SizedBox(height: 32),
              _buildFormSections(context),
              const SizedBox(height: 40),
              _buildConsentAndActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreadcrumbs(BuildContext context) {
    return Row(
      children: [
        Text(
          'Tableau de bord',
          style: TextStyle(
            color: AppColors.primaryTeal.withValues(alpha: 0.7),
            fontSize: 14,
          ),
        ),
        const Text(' / ', style: TextStyle(color: Colors.grey)),
        Text(
          widget.patientToEdit != null
              ? 'Modifier Enregistrement'
              : 'Nouvel Enregistrement',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildProgressStepper(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ÉTAPE 2 SUR 4',
                    style: TextStyle(
                      color: AppColors.primaryTeal,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                  const Text(
                    'Profil Médical & Biométrie',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Text(
                '50% Terminé',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.5,
              backgroundColor: AppColors.primaryTeal.withValues(alpha: 0.1),
              color: AppColors.primaryTeal,
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'IDENTITÉ',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
              Text(
                'PROFIL MÉDICAL',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryTeal,
                ),
              ),
              Text(
                'BIOMÉTRIE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              Text(
                'RÉVISION',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormSections(BuildContext context) {
    return Column(
      children: [
        _buildSectionCard(
          context,
          icon: Icons.person_rounded,
          title: 'Détails Personnels',
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: MediaQuery.of(context).size.width > 700 ? 2 : 1,
            mainAxisSpacing: 24,
            crossAxisSpacing: 24,
            childAspectRatio: 3.5,
            children: [
              _buildTextField('Prénom', 'p.ex. John', _firstNameController),
              _buildTextField('Nom', 'p.ex. Doe', _lastNameController),
              _buildTextField(
                'Date de Naissance',
                'JJ/MM/AAAA',
                isDate: true,
                _dateOfBirthController,
              ),
              _buildDropdownField('Genre', ['M', 'F']),
              _buildTextField(
                'Numéro d\'ID National',
                'ID-000-000-000',
                _nationalIdController,
              ),
              _buildTextField(
                'Localisation',
                'p.ex. Kinshasa',
                _locationController,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _buildSectionCard(
          context,
          icon: Icons.medical_services_rounded,
          title: 'Profil Médical',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Groupe Sanguin',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                    .map((type) {
                      final bool selected = _selectedBloodType == type;
                      return ChoiceChip(
                        label: Text(
                          type,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: selected ? AppColors.white0 : null,
                          ),
                        ),
                        checkmarkColor: AppColors.white0,

                        selected: selected,
                        onSelected: (val) =>
                            setState(() => _selectedBloodType = type),
                        selectedColor: AppColors.primaryTeal,
                      );
                    })
                    .toList(),
              ),
              const SizedBox(height: 24),
              _buildTextField(
                'Allergies Critiques',
                'Pénicilline, Arachides, Latex...',
                _allergiesController,
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.greenAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'STATION EN SERVICE',
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Conditions Chroniques',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _buildStatusTag('Diabète Type 2'),
                  _buildStatusTag('Hypertension'),
                ],
              ),
              const SizedBox(height: 12),
              if (_chronicConditions.isNotEmpty)
                Wrap(
                  spacing: 8,
                  children: _chronicConditions
                      .map((condition) => _buildStatusTag(condition))
                      .toList(),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      '',
                      'Ajouter une condition',
                      _chronicConditionsInputController,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _addChronicCondition,
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryTeal,
                      foregroundColor: AppColors.white0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _buildSectionCard(
          context,
          icon: Icons.fingerprint_rounded,
          title: 'Enrôlement Biométrique',
          child: Row(
            children: [
              Expanded(
                child: _buildBiometricCard(
                  Icons.face_rounded,
                  'Reconnaissance Faciale',
                  'Capturer le portrait frontal.',
                  false,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildBiometricCard(
                  Icons.fingerprint_rounded,
                  'Empreinte Digitale',
                  'Scanner l\'index droit.',
                  true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryTeal.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryTeal),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    bool isDate = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextField(
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Theme.of(context).scaffoldBackgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
            ),
            suffixIcon: isDate
                ? const Icon(Icons.calendar_today_rounded, size: 18)
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedGender,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (val) {
            setState(() {
              _selectedGender = val!;
            });
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).scaffoldBackgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryTeal.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primaryTeal,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _chronicConditions.remove(label);
              });
            },
            child: const Icon(
              Icons.close,
              size: 14,
              color: AppColors.primaryTeal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBiometricCard(
    IconData icon,
    String title,
    String subtitle,
    bool isFingerPrint,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.2),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryTeal.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primaryTeal, size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(
                !isFingerPrint
                    ? Icons.camera_alt_rounded
                    : Icons.sensors_rounded,
                size: 18,
              ),
              label: Text(
                !isFingerPrint ? 'CAPTURER VISAGE' : 'ENREGISTRER EMPREINTE',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
                foregroundColor: AppColors.white0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsentAndActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryTeal.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryTeal.withValues(alpha: 0.1),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        children: [
          Checkbox(
            value: _consentChecked,
            onChanged: (val) {
              setState(() {
                _consentChecked = val ?? false;
              });
            },
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Accord de Consentement',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  'Je confirme que le patient a donné son consentement éclairé pour le stockage des données d\'urgence et le traitement biométrique.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'ANNULER',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _isLoading ? null : _savePatient,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryTeal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    widget.patientToEdit != null
                        ? 'METTRE À JOUR'
                        : 'CONTINUER',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
    );
  }
}
