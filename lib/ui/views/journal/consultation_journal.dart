import 'package:afya_id/domain/utils/general_utils.dart';
import 'package:flutter/material.dart';
import 'package:afya_id/ui/styles/app_colors.dart';

class ConsultationJournal extends StatelessWidget {
  const ConsultationJournal({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 32),
              _buildSearchAndFilters(context),
              const SizedBox(height: 32),
              _buildAuditList(context),
              const SizedBox(height: 48),
              _buildPaginationLoader(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Journal des Consultations',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  color: Color(0xFF97ADC4),
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Historique d\'accès sécurisé - ',
                  style: TextStyle(color: Color(0xFF97ADC4), fontSize: 14),
                ),
                const Text(
                  'Zone Kivu Nord',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.download_rounded, size: 18),
          label: const Text('Export Log (CSV)'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
            backgroundColor: const Color(0xFF333333).withValues(alpha: 0.5),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters(BuildContext context) {
    TextEditingController searchBarController = TextEditingController();
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        IntrinsicWidth(
          child: GeneralUtils().generalSearchBar(
            context,
            searchBarController: searchBarController,
          ),
        ),
        _buildFilterChip(
          'Tout afficher',
          Icons.view_list_rounded,
          active: true,
          textColor: Theme.of(context).colorScheme.surface,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        _buildFilterChip(
          'Urgence',
          Icons.warning_rounded,
          color: AppColors.red,
          textColor: AppColors.red,
        ),
        _buildFilterChip('Standard', Icons.description_rounded),
      ],
    );
  }

  Widget _buildFilterChip(
    String label,
    IconData icon, {
    bool active = false,
    Color? color,
    Color? textColor,
  }) {
    return IntrinsicWidth(
      child: GeneralUtils().generalButton(
        // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backColor: active ? (color) : Colors.transparent,
        borderColor: !active
            ? (color?.withValues(alpha: 0.2) ??
                  Colors.grey.withValues(alpha: 0.5))
            : Colors.transparent,
        radius: 8,
        // textColor: active
        // ? (color ?? Colors.white)
        // : const Color(0xFF97ADC4),
        child: Row(
          children: [
            Icon(icon, color: textColor, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditList(BuildContext context) {
    return Column(
      children: [
        _buildDateDivider('Aujourd\'hui - 25 OCT'),
        _buildAuditCard(
          context,
          time: '14:30',
          desc: 'Patient ID #9982 viewed by Dr. K. Mutombo',
          session: '8F32-X99',
          extra: 'Access granted via Trauma Unit Terminal 4',
          isEmergency: true,
        ),
        _buildAuditCard(
          context,
          time: '14:15',
          desc: 'Patient ID #9971 record updated by Inf. J. Doe',
          session: '2A91-B44',
          extra: 'Notes added: "Antibiotics administered"',
        ),
        _buildAuditCard(
          context,
          time: '13:45',
          desc: 'Patient ID #9940 lab results uploaded',
          session: 'LAB-01',
          extra: 'Type: Blood Panel (Complete)',
          icon: Icons.biotech_rounded,
        ),
        _buildDateDivider('Hier - 24 OCT'),
        _buildAuditCard(
          context,
          time: '18:20',
          desc: 'Patient ID #8812 record archived',
          session: 'SYS-OFF',
          extra: 'Data cleanup procedure',
        ),
      ],
    );
  }

  Widget _buildDateDivider(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: const Color(0xFF333333))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF607080),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ),
          Expanded(child: Container(height: 1, color: const Color(0xFF333333))),
        ],
      ),
    );
  }

  Widget _buildAuditCard(
    BuildContext context, {
    required String time,
    required String desc,
    required String session,
    required String extra,
    bool isEmergency = false,
    IconData icon = Icons.visibility_rounded,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isEmergency
              ? const Color(0xFFCC6666).withValues(alpha: 0.2)
              : const Color(0xFF333333),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 48,
            color: isEmergency
                ? const Color(0xFFCC6666)
                : AppColors.patientBlue,
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 70,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'monospace',
                  ),
                ),
                const Text(
                  'UTC+2',
                  style: TextStyle(
                    color: Color(0xFF607080),
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  (isEmergency
                          ? const Color(0xFFCC6666)
                          : AppColors.patientBlue)
                      .withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isEmergency ? Icons.visibility_rounded : icon,
              color: isEmergency
                  ? const Color(0xFFCC6666)
                  : AppColors.patientBlue,
              size: 18,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  desc,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'SESSION: $session',
                      style: const TextStyle(
                        color: Color(0xFF607080),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 2,
                      height: 2,
                      decoration: const BoxDecoration(
                        color: Color(0xFF607080),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      extra,
                      style: const TextStyle(
                        color: Color(0xFF607080),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isEmergency)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFCC6666).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFCC6666).withValues(alpha: 0.2),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.warning_rounded,
                    color: Color(0xFFCC6666),
                    size: 12,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'URGENCE',
                    style: TextStyle(
                      color: Color(0xFFCC6666),
                      fontWeight: FontWeight.bold,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF273645),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'STANDARD',
                style: TextStyle(
                  color: Color(0xFF97ADC4),
                  fontWeight: FontWeight.bold,
                  fontSize: 9,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPaginationLoader(BuildContext context) {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Charger l\'historique plus ancien...',
              style: TextStyle(
                color: Color(0xFF607080),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
