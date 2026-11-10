import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/leaf_badge.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Security'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 8),
              const LeafBadge(size: 64, iconSize: 36),
              const SizedBox(height: 16),
              Text(
                'Your Health, Completely Private',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${AppConstants.appName} is designed from the ground up to respect your confidentiality and bodily autonomy.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              _buildPrivacyCard(
                context,
                icon: Icons.storage_rounded,
                title: 'Local On-Device Database',
                body:
                    'All cycle records, symptoms, notes, and preferences are stored exclusively in a local SQLite database on your physical device. Nothing is hosted on a remote server.',
              ),
              const SizedBox(height: 14),

              _buildPrivacyCard(
                context,
                icon: Icons.person_off_rounded,
                title: 'No Account Required',
                body:
                    'You do not need an email, phone number, Google account, or password to use RedDay. The app has no user tracking or sign-up wall.',
              ),
              const SizedBox(height: 14),

              _buildPrivacyCard(
                context,
                icon: Icons.cloud_off_rounded,
                title: 'No Analytics or Advertising',
                body:
                    'No commercial tracking SDKs, telemetry, crash collectors, or advertising frameworks are bundled in this application. No health information is ever transmitted externally.',
              ),
              const SizedBox(height: 14),

              _buildPrivacyCard(
                context,
                icon: Icons.backup_outlined,
                title: 'Cloud Backup Opt-Out',
                body:
                    'RedDay explicitly opts out of automatic cloud backup (Android Auto Backup and Google Drive) via manifest rules so your cycle database is never silently synced to third-party clouds.',
              ),
              const SizedBox(height: 14),

              _buildPrivacyCard(
                context,
                icon: Icons.file_download_outlined,
                title: 'Exported Files Advisory',
                body:
                    'When you export a JSON backup file, it contains your personal cycle records. Store exported backup files in a secure location and avoid sharing them across untrusted networks.',
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String body,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: theme.textTheme.bodySmall?.copyWith(
                    height: 1.45,
                    color: colorScheme.onSurfaceVariant,
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
