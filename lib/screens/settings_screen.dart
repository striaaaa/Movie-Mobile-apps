import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/shared_prefs_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Movie Browser',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Flutter Mobile App for Tugas Besar',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Preferences',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                      return SwitchListTile(
                        title: const Text('Dark Mode'),
                        subtitle: const Text('Enable dark theme'),
                        value: themeProvider.isDarkTheme,
                        onChanged: (value) {
                          themeProvider.toggleTheme();
                        },
                        secondary: const Icon(Icons.dark_mode),
                      );
                    },
                  ),
                  const Divider(),
                  FutureBuilder<int?>(
                    future: SharedPrefsService.getLastViewedMovieId(),
                    builder: (context, snapshot) {
                      final lastViewedId = snapshot.data;
                      return ListTile(
                        leading: const Icon(Icons.history),
                        title: const Text('Last Viewed Movie'),
                        subtitle: Text(
                          lastViewedId != null
                              ? 'Movie ID: $lastViewedId'
                              : 'No recently viewed movies',
                        ),
                        trailing: lastViewedId != null
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () async {
                                  await SharedPrefsService.setLastViewedMovieId(
                                      0);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Cleared last viewed movie')),
                                    );
                                  }
                                },
                              )
                            : null,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.api),
                    title: const Text('API Source'),
                    subtitle: const Text('The Movie Database (TMDB)'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.code),
                    title: const Text('Developer'),
                    subtitle: const Text('Flutter - Tugas Besar Mobile'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
