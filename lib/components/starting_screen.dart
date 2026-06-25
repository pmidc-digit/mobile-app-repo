import 'package:flutter/material.dart';
import 'package:mseva_punjab/theme/app_theme.dart';
import 'package:mseva_punjab/utils/web_view_body_load.dart';

class StartingScreen extends StatelessWidget {
  const StartingScreen({super.key});

  static const _citizenUrl =
      'https://mseva.lgpunjab.gov.in/digit-ui/citizen';
  static const _employeeUrl =
      'https://mseva.lgpunjab.gov.in/digit-ui/employee';

  void _openPortal(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewBodyLoad(
          pageTitle: 'mSeva Punjab',
          pageUrl: url,
          headerFooterRequired: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/mSeva.jpg',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.45, 0.72, 1.0],
                colors: [
                  Colors.white.withValues(alpha: 0.05),
                  Colors.white.withValues(alpha: 0.35),
                  Colors.white.withValues(alpha: 0.88),
                  Colors.white,
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(flex: 5),
                  Text(
                    'Punjab Local Government Services',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.lightGrey,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                  ),
                  const SizedBox(height: 32),
                  _PortalButton(
                    label: 'Citizen',
                    icon: Icons.person_outline,
                    color: AppColors.blue,
                    onPressed: () => _openPortal(context, _citizenUrl),
                  ),
                  const SizedBox(height: 14),
                  _PortalButton(
                    label: 'Employee',
                    icon: Icons.badge_outlined,
                    color: AppColors.orange,
                    onPressed: () => _openPortal(context, _employeeUrl),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PortalButton extends StatelessWidget {
  const _PortalButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 22),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
        ),
      ),
    );
  }
}
