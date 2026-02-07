import 'package:afya_id/domain/domain.dart';
import 'package:afya_id/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:afya_id/ui/styles/app_colors.dart';
import 'package:afya_id/data/models/patient_model.dart';
import 'package:afya_id/data/services/patient_firestore_service.dart';
import 'package:go_router/go_router.dart';

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

    if (widget.patientToEdit != null) {
      _loadPatientData(widget.patientToEdit!);
    }
  }

  void _loadPatientData(PatientModel patient) {
    _firstNameController.text = patient.firstName;
    _lastNameController.text = patient.lastName;
    _locationController.text = patient.location;
    _dateOfBirthController.text = patient.dateOfBirth.toIso8601String().split(
      'T',
    )[0];
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
      snackbarMessage(context, text: "Please fill in all required fields");
      return;
    }

    if (!_consentChecked) {
      snackbarMessage(context, text: "Please confirm the consent");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final DateTime? dateOfBirth = DateTime.tryParse(
        _dateOfBirthController.text,
      );
      if (dateOfBirth == null) {
        throw "Invalid date format (YYYY-MM-DD)";
      }

      final patient = PatientModel(
        id:
            widget.patientToEdit?.id ??
            "${_firstNameController.text}_${_lastNameController.text}_${DateTime.now().millisecondsSinceEpoch.toString()}-AFY",
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
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
          snackbarMessage(context, text: 'Patient updated successfully');
        }
      } else {
        await _patientService.createPatient(patient);
        if (mounted)
          snackbarMessage(context, text: 'Patient created successfully');
        _resetForm();
      }
    } catch (e) {
      if (mounted) snackbarMessage(context, text: 'Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
    return Scaffold(
      appBar: context.canPop() ? AppBar() : null,
      body: SingleChildScrollView(
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
                      ? 'Edit Registration'
                      : 'New Registration',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Register a new patient in the emergency health database.',
                  style: TextStyle(color: Colors.grey),
                ),
                // const SizedBox(height: 40),
                // _buildProgressStepper(context),
                const SizedBox(height: 32),
                _buildFormSections(context),
                const SizedBox(height: 40),
                _buildConsentAndActions(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGETS DE CONSTRUCTION ---

  Widget _buildBreadcrumbs(BuildContext context) {
    return Row(
      children: [
        Text(
          'Tableau de bord',
          style: TextStyle(
            color: AppColors.primaryTeal.withOpacity(0.7),
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

  Widget _buildFormSections(BuildContext context) {
    return Column(
      children: [
        _buildSectionCard(
          context,
          icon: Icons.person_rounded,
          title: 'Personal Details',
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  SizedBox(
                    width: constraints.maxWidth > 600
                        ? (constraints.maxWidth / 2) - 12
                        : constraints.maxWidth,
                    child: _buildTextField(
                      'First Name',
                      'e.g. John',
                      _firstNameController,
                    ),
                  ),
                  SizedBox(
                    width: constraints.maxWidth > 600
                        ? (constraints.maxWidth / 2) - 12
                        : constraints.maxWidth,
                    child: _buildTextField(
                      'Last Name',
                      'e.g. Doe',
                      _lastNameController,
                    ),
                  ),
                  SizedBox(
                    width: constraints.maxWidth > 600
                        ? (constraints.maxWidth / 2) - 12
                        : constraints.maxWidth,
                    child: _buildTextField(
                      'Date of Birth',
                      'YYYY-MM-DD',
                      _dateOfBirthController,
                      isDate: true,
                    ),
                  ),
                  SizedBox(
                    width: constraints.maxWidth > 600
                        ? (constraints.maxWidth / 2) - 12
                        : constraints.maxWidth,
                    child: _buildDropdownField('Gender', ['M', 'F']),
                  ),
                  SizedBox(
                    width: constraints.maxWidth > 600
                        ? (constraints.maxWidth / 2) - 12
                        : constraints.maxWidth,
                    child: _buildTextField(
                      'National ID',
                      'ID-000-000',
                      _nationalIdController,
                    ),
                  ),
                  SizedBox(
                    width: constraints.maxWidth > 600
                        ? (constraints.maxWidth / 2) - 12
                        : constraints.maxWidth,
                    child: _buildTextField(
                      'Location',
                      'e.g. Kinshasa',
                      _locationController,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 32),
        _buildSectionCard(
          context,
          icon: Icons.medical_services_rounded,
          title: 'Medical Profile',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Blood Type',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                    .map((type) {
                      return ChoiceChip(
                        label: Text(type),
                        selected: _selectedBloodType == type,
                        onSelected: (val) =>
                            setState(() => _selectedBloodType = type),
                        checkmarkColor: AppColors.white0,
                        selectedColor: AppColors.primaryTeal,
                        labelStyle: TextStyle(
                          color: _selectedBloodType == type
                              ? Colors.white
                              : null,
                        ),
                      );
                    })
                    .toList(),
              ),
              const SizedBox(height: 24),
              _buildTextField(
                'Critical Allergies',
                'Penicillin...',
                _allergiesController,
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              const Text(
                'Chronic Conditions',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (_chronicConditions.isNotEmpty)
                Wrap(
                  spacing: 8,
                  children: _chronicConditions
                      .map((c) => _buildStatusTag(c))
                      .toList(),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      '',
                      'Add a condition',
                      _chronicConditionsInputController,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _addChronicCondition,
                    icon: const Icon(Icons.add),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primaryTeal,
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
          title: 'Biometric Enrollment',
          child: IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _buildBiometricCard(
                    Icons.face_rounded,
                    'Facial Recognition',
                    'Capture front portrait.',
                    false,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildBiometricCard(
                    Icons.fingerprint_rounded,
                    'Fingerprint',
                    'Scan right index finger.',
                    true,
                  ),
                ),
              ],
            ),
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
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryTeal),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
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
            alignment: .center,
            child: Center(
              child: Icon(icon, color: AppColors.primaryTeal, size: 40),
            ),
          ),
          if (!AdaptiveUtil.isCompact(context)) ...[
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
          ],
          const SizedBox(height: 24),
          Spacer(),
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
              label: !AdaptiveUtil.isCompact(context)
                  ? Text(
                      !isFingerPrint ? 'CAPTURE FACE' : 'REGISTER FINGERPRINT',
                    )
                  : Container(),
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

  /// NOTE: Added missing controller in TextField
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
        if (label.isNotEmpty)
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        const SizedBox(height: 8),
        TextField(
          controller:
              controller, // IMPORTANT: Without this, the entered text is not captured
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
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedGender,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (val) => setState(() => _selectedGender = val),
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).scaffoldBackgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusTag(String label) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(color: AppColors.primaryTeal, fontSize: 12),
      ),
      backgroundColor: AppColors.primaryTeal.withOpacity(0.1),
      onDeleted: () => setState(() => _chronicConditions.remove(label)),
      deleteIconColor: AppColors.primaryTeal,
    );
  }

  Widget _buildConsentAndActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryTeal.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          CheckboxListTile(
            value: _consentChecked,
            onChanged: (val) => setState(() => _consentChecked = val ?? false),
            title: const Text(
              'Consent Agreement',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text(
              'The patient consents to the storage of emergency data.',
              style: TextStyle(color: AppColors.grey),
            ),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: .maxFinite,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: .end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _savePatient,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          widget.patientToEdit != null ? 'UPDATE' : 'CONTINUE',
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// NOTE: Precise age calculation logic
int calculateAge(DateTime birthDate) {
  DateTime today = DateTime.now();
  int age = today.year - birthDate.year;
  if (today.month < birthDate.month ||
      (today.month == birthDate.month && today.day < birthDate.day)) {
    age--;
  }
  return age;
}
