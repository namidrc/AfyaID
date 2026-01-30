import 'package:afya_id/domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:afya_id/ui/styles/app_colors.dart';

enum FilterType {
  all('All', "all"),
  security('Security', "security"),
  system('System', "system"),
  auth('Auth', "auth");

  final String label;
  final String data;

  const FilterType(this.label, this.data);
}

enum FilterTime {
  allTime('All Time', "all"),
  last24Hours('Last 24 Hours', "last_24_hours"),
  last7Days('Last 7 Days', "last_7_days"),
  last30Days('Last 30 Days', "last_30_days");

  final String label;
  final String data;

  const FilterTime(this.label, this.data);
}

class AuditLogs extends StatelessWidget {
  const AuditLogs({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 32),
            _buildSearchAndFilters(context),
            const SizedBox(height: 15),
            _buildAuditList(context),
            const SizedBox(height: 48),
            _buildPaginationLoader(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationLoader(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryTeal),
          ),
          const SizedBox(height: 16),
          Text('Chargement des entrées plus anciennes...'),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.3)),
      ),
      child: IntrinsicWidth(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditListItem(
    String id,
    String desc,
    String time,
    String status,
    Color statusColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 80,
            child: Text(
              id,
              style: const TextStyle(
                color: AppColors.grey,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
          Expanded(
            child: Text(
              desc,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 20),
          Text(
            time,
            style: const TextStyle(color: AppColors.grey, fontSize: 12),
          ),
          const SizedBox(width: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: statusColor.withValues(alpha: 0.2)),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 9,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Audit & Journal de Sécurité',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.green,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'SYSTÈME OPÉRATIONNEL',
              style: TextStyle(
                color: AppColors.green,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 12),
            const Text('|', style: TextStyle(color: AppColors.grey)),
            const SizedBox(width: 12),
            const Text(
              'VERSION V.1.0.0',
              style: TextStyle(
                color: AppColors.grey,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 10,
          runSpacing: 10,

          children: [
            Flexible(
              child: _buildStatCard(
                context,
                'ACTIVITÉS TOTALES',
                '1,284',
                Icons.analytics_rounded,
                Colors.blue,
              ),
            ),
            Flexible(
              child: _buildStatCard(
                context,
                'ALERTES SÉCURITÉ',
                '03',
                Icons.warning_amber_rounded,
                Colors.redAccent,
              ),
            ),
            Flexible(
              child: _buildStatCard(
                context,
                'SESSIONS ACTIVES',
                '12',
                Icons.login_rounded,
                Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters(BuildContext context) {
    TextEditingController searchController = TextEditingController();
    TextEditingController filterController = TextEditingController(
      text: FilterType.values.first.label,
    );
    TextEditingController timeController = TextEditingController(
      text: FilterTime.values.first.label,
    );
    return Row(
      spacing: 10,
      children: [
        Expanded(
          flex: 3,
          child: GeneralUtils().generalSearchBar(
            context,
            searchBarController: searchController,
          ),
        ),

        Flexible(
          child: GeneralUtils().generalDropDownButton(
            hasUnderlinedBorder: false,
            context: context,
            label: 'Filtres',
            controller: filterController,
            items: FilterType.values.map((e) => e.label).toList(),
            onChanged: () {},
          ),
        ),
        Flexible(
          child: GeneralUtils().generalDropDownButton(
            hasUnderlinedBorder: false,
            context: context,
            label: 'Filtres',
            controller: timeController,
            items: FilterTime.values.map((e) => e.label).toList(),
            onChanged: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildAuditList(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Journal d\'Audit',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          _buildAuditListItem(
            'SEC-992',
            'Accès dossier critique - Patient #9982',
            '2026-01-26 14:30:12',
            'WARNING',
            Colors.amber,
          ),
          _buildAuditListItem(
            'SYS-102',
            'Nouvel enregistrement patient - ID: #12345',
            '2026-01-26 13:15:00',
            'SUCCESS',
            Colors.green,
          ),
          _buildAuditListItem(
            'AUTH-44',
            'Connexion réussie - Dr. Sarah Kibaki',
            '2026-01-26 12:00:00',
            'SUCCESS',
            Colors.green,
          ),
          _buildAuditListItem(
            'SEC-990',
            'Tentative d\'accès non autorisée - IP 10.0.12.84',
            '2026-01-26 11:45:00',
            'CRITICAL',
            Colors.redAccent,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
