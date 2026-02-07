import 'package:afya_id/domain/constants/constants.dart';
import 'package:afya_id/domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:afya_id/ui/styles/app_colors.dart';
import 'package:afya_id/ui/providers/general_provider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:afya_id/domain/routes/routes_paths.dart';

final scaffoldKey = GlobalKey<ScaffoldState>();

class HostPage extends StatelessWidget {
  const HostPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 900;

    final provider = Provider.of<GeneralProvider>(context);
    final primaryColor = provider.selectedPage == AppPages.emergency
        ? AppColors.emergencyRed
        : AppColors.primaryTeal;
    return Scaffold(
      key: scaffoldKey,
      drawer: isDesktop ? null : _buildSidebar(context, isMobile: true),
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(context),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                image: DecorationImage(
                  image: const NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuDJghyG3sgnLLmpjbr3GimYWIOMm6djdwwGlLEmEcM-9mbRr3ouzcSvRif_QusVHXN02MIz_LJ1-0uBxVHXN02MIz_LJ1-0uBxVgMUlHDuQbpXFr7CcORUpfKUaPCmSHkFty6KbzwTZiLgqY5F-7wqd2nDTdTXdALV7owKwFFHIKWk4dWNNgOARq1ch-rORVGxPDDnk0MBLFqkeEgWVkeSzSIW1ugDrLFJeUDmNhIJCu9006OCLvmjLOCtRGhtbIIVFmqgtR0mcRtE9-fQp9L1x2H43yLpIk',
                  ),
                  fit: BoxFit.cover,
                  opacity: Theme.of(context).brightness == Brightness.dark
                      ? 0.05
                      : 0.02,
                ),
              ),
              child: Column(
                children: [
                  _buildHeader(context, isDesktop, primaryColor),
                  Expanded(child: provider.selectedPage.page),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, {bool isMobile = false}) {
    final bool isCollapsed =
        !isMobile && MediaQuery.of(context).size.width < 1200;
    final primaryColor = AppColors.primaryTeal;
    final provider = Provider.of<GeneralProvider>(context);

    return Container(
      width: isMobile ? 280 : (isCollapsed ? 80 : 280),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          if (provider.userModel != null) ...[
            _buildUserInfo(
              context,
              collapsed: isCollapsed,
              primaryColor: primaryColor,
            ),
            const SizedBox(height: 32),
          ],
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: AppPages.values
                  .map(
                    (page) => _buildNavItem(
                      context,
                      icon: page.icon,
                      label: page.label,
                      active: provider.selectedPage == page,
                      collapsed: isCollapsed,
                      onTap: () {
                        provider.selectPage(page);
                        scaffoldKey.currentState?.closeDrawer();
                      },
                      primaryColor: primaryColor,
                    ),
                  )
                  .toList(),

              // const Divider(height: 32),
              // _buildNavItem(
              //   context,
              //   icon: Icons.settings_rounded,
              //   label: 'Paramètres',
              //   collapsed: isCollapsed,
              //   primaryColor: primaryColor,
              // ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildUserInfo(
    BuildContext context, {
    bool collapsed = false,
    required Color primaryColor,
  }) {
    final provider = Provider.of<GeneralProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        spacing: 12,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: const CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuA2fJBdOdctZpDLcnk6WiHGpaN_d9uCkHkIVzBgE9JNAy_SFKQOQ54mC-9JSxZDFckfA_LC91uPRKC1XiqHP6km7p_L3jfKr676shhp2jtHGBVSGNwWi-TEUhphsNGh69nMzLPyFfj0wItxeZeqVUuoUxAt-Oz4rYWDlFYciJ6FLXTnZ7CMBaA3jHWQhAyBizyr_Xs1U1ai3l7eZ7ErzCKjKseObx-64lHgpOg2ZJPGL9J1o8g-xxGM3Lc9zWZEZO6y1ULA2WprWII',
              ),
            ),
          ),
          if (!collapsed) ...[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.userModel!.fullName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    provider.userModel!.role,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    bool active = false,
    bool collapsed = false,
    VoidCallback? onTap,
    required Color primaryColor,
  }) {
    return GeneralUtils().generalButton(
      padding: EdgeInsets.zero,
      tapAction: onTap,
      radius: 12,

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: active ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          spacing: 16,
          mainAxisAlignment: collapsed
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            Expanded(
              child: Icon(
                icon,
                color: active ? Colors.white : Colors.grey,
                size: 24,
              ),
            ),
            if (!collapsed) ...[
              Expanded(
                flex: 4,
                child: Text(
                  label,
                  style: TextStyle(
                    color: active ? Colors.white : Colors.grey,
                    fontWeight: active ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isDesktop,
    Color primaryColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.9),
        border: Border(
          bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: [
          if (!isDesktop) ...[
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                scaffoldKey.currentState!.openDrawer();
              },
            ),
            const SizedBox(width: 8),
          ],
          Icon(Icons.check_box, color: primaryColor, size: 28),
          const SizedBox(width: 8),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'AFYA',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
                ),
                TextSpan(
                  text: 'ID',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Consumer<GeneralProvider>(
            builder: (context, general, child) {
              return _buildSquareIconButton(
                context,
                general.isDark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                onPressed: () => general.changeTheme(!general.isDark),
              );
            },
          ),
          const SizedBox(width: 16),
          _buildSquareIconButton(context, Icons.notifications_none_rounded),
        ],
      ),
    );
  }

  Widget _buildSquareIconButton(
    BuildContext context,
    IconData icon, {
    VoidCallback? onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, size: 20),
        onPressed: onPressed ?? () {},
      ),
    );
  }
}
