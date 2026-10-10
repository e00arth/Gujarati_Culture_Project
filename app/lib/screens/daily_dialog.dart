import 'package:flutter/material.dart';

import '../data/strings.dart';
import '../services/daily.dart';
import '../services/settings_store.dart';

/// Turns the kehvat of the day on or off and sets its time.
class DailyDialog extends StatelessWidget {
  const DailyDialog({super.key, required this.daily, required this.settings});

  final DailyKehvat daily;
  final SettingsStore settings;

  @override
  Widget build(BuildContext context) {
    final strings = Strings.of(settings.language);
    final store = daily.store;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) => AlertDialog(
        title: Text(strings.daily),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: Text(strings.dailySend),
              value: store.on,
              onChanged: (on) async {
                if (!on) {
                  store.on = false;
                } else if (!await daily.turnOn() && context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(strings.dailyBlocked)));
                }
              },
            ),
            ListTile(
              enabled: store.on,
              leading: const Icon(Icons.schedule),
              title: Text(strings.dailyTime),
              trailing: Text(
                TimeOfDay(
                  hour: store.minute ~/ 60,
                  minute: store.minute % 60,
                ).format(context),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(
                    hour: store.minute ~/ 60,
                    minute: store.minute % 60,
                  ),
                );
                if (picked != null) {
                  store.minute = picked.hour * 60 + picked.minute;
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
          ),
        ],
      ),
    );
  }
}
