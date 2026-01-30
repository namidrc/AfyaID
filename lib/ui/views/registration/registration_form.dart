import 'package:flutter/material.dart';
import 'package:afya_id/ui/styles/app_colors.dart';

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({super.key});

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  String? _selectedBloodType = 'A+';

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
              const Text(
                'Nouvel Enregistrement',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Inscrire un nouveau citoyen dans la base de données de santé d\'urgence AfyaID.',
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
        const Text(
          'Nouvel Enregistrement',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
              _buildTextField('Nom Complet (Légal)', 'p.ex. John Doe'),
              _buildTextField('Numéro d\'ID National', 'ID-000-000-000'),
              _buildTextField('Date de Naissance', 'JJ/MM/AAAA', isDate: true),
              _buildDropdownField('Genre', [
                'Homme',
                'Femme',
                'Non-binaire',
                'Préfère ne pas dire',
              ]),
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
              _buildTextField(
                '',
                'Ajouter une condition et appuyer sur Entrée',
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
    String hint, {
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
          value: items.first,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (val) {},
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
          const Icon(Icons.close, size: 14, color: AppColors.primaryTeal),
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
          const Checkbox(value: true, onChanged: null),
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
            onPressed: () => Navigator.of(
              context,
            ).pop(), // Changed context.pop() to Navigator.of(context).pop() for correctness
            child: const Text(
              'ANNULER',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryTeal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text(
              'CONTINUER RÉVISION',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
