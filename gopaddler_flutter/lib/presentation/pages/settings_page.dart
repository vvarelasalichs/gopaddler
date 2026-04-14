import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:gopaddler_flutter/data/repositories/user_repository.dart';
import 'package:gopaddler_flutter/presentation/bloc/settings/settings_bloc.dart';
import 'package:gopaddler_flutter/presentation/pages/choose_boat_page.dart';
import 'package:gopaddler_flutter/presentation/pages/choose_sport_page.dart';
import 'package:gopaddler_flutter/presentation/pages/calibration_page.dart';
import 'package:gopaddler_flutter/presentation/pages/profile_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late UserRepository _userRepository;

  @override
  void initState() {
    super.initState();
    _userRepository = GetIt.instance<UserRepository>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Section
            _buildSectionHeader(context, 'Profile'),
            _buildSettingsTile(
              context,
              'Account',
              'Manage your profile information',
              Icons.person,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              ),
            ),

            const SizedBox(height: 24),

            // Preferences Section
            _buildSectionHeader(context, 'Preferences'),
            BlocBuilder<SettingsBloc, SettingsState>(
              builder: (context, state) {
                if (state is SettingsLoaded) {
                  return Column(
                    children: [
                      _buildSettingsTile(
                        context,
                        'Sport Type',
                        state.settings.sportType ?? 'Select sport',
                        Icons.sports,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChooseSportPage(
                              onSportSelected: (sport) {
                                context
                                    .read<SettingsBloc>()
                                    .add(UpdateSportTypeEvent(sport));
                              },
                            ),
                          ),
                        ),
                      ),
                      _buildSettingsTile(
                        context,
                        'Boat Type',
                        state.settings.boatType ?? 'Select boat',
                        Icons.directions_boat,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChooseBoatPage(
                              onBoatSelected: (boat) {
                                context
                                    .read<SettingsBloc>()
                                    .add(UpdateBoatTypeEvent(boat));
                              },
                            ),
                          ),
                        ),
                      ),
                      _buildSettingsTile(
                        context,
                        'Units',
                        state.settings.preferredUnit == 'km'
                            ? 'Kilometers'
                            : 'Miles',
                        Icons.straighten,
                        () {
                          _showUnitSelection(context, state.settings.preferredUnit);
                        },
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            const SizedBox(height: 24),

            // Sensors Section
            _buildSectionHeader(context, 'Sensors'),
            _buildSettingsTile(
              context,
              'Calibration',
              'Calibrate GPS, HR, Accelerometer',
              Icons.tune,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CalibrationPage()),
              ),
            ),

            const SizedBox(height: 24),

            // Synchronization Section
            _buildSectionHeader(context, 'Synchronization'),
            BlocBuilder<SettingsBloc, SettingsState>(
              builder: (context, state) {
                if (state is SettingsLoaded) {
                  return Column(
                    children: [
                      _buildSwitchTile(
                        context,
                        'Auto Sync',
                        'Automatically sync sessions',
                        state.settings.autoSync,
                        (value) {
                          context
                              .read<SettingsBloc>()
                              .add(UpdateAutoSyncEvent(value));
                        },
                      ),
                      _buildSwitchTile(
                        context,
                        'WiFi Only',
                        'Sync only on WiFi',
                        state.settings.syncOnWiFiOnly,
                        (value) {
                          context
                              .read<SettingsBloc>()
                              .add(UpdateSyncOnWiFiOnlyEvent(value));
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.cloud_upload),
                            label: const Text('Sync Now'),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Syncing sessions...'),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            const SizedBox(height: 24),

            // About Section
            _buildSectionHeader(context, 'About'),
            _buildSettingsTile(
              context,
              'Version',
              'App version 1.0.0',
              Icons.info,
              null,
            ),
            _buildSettingsTile(
              context,
              'Privacy Policy',
              'Read our privacy policy',
              Icons.privacy_tip,
              () {
                // TODO: Open privacy policy
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback? onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  void _showUnitSelection(BuildContext context, String currentUnit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Preferred Units'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Kilometers'),
              value: 'km',
              groupValue: currentUnit,
              onChanged: (value) {
                if (value != null) {
                  context.read<SettingsBloc>().add(UpdateUnitsEvent(value));
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Miles'),
              value: 'mi',
              groupValue: currentUnit,
              onChanged: (value) {
                if (value != null) {
                  context.read<SettingsBloc>().add(UpdateUnitsEvent(value));
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
