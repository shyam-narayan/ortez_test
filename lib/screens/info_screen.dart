import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final features = [
      '• View, add, edit, and complete todos with an elegant UI',
      '• Themes has been used to design the application',
      '• Search todos by text or by user ID',
      '• Fetch todos from a live API (dummyjson.com)',
      '• Alternate to live API fetching, data fetching from dummy_data.json also included',
      '• Add new todos to a specific user',
      '• Edit todos and update their completion status',
      '• Offline support: previously loaded todos are available without internet',
      '• Data is cached locally using Hive',
      '• Responsive design',
      '• Error handling and user feedback with snackbars',
    ];
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'App Features',
          style: theme.textTheme.headlineLarge?.copyWith(
            fontFamily: GoogleFonts.dmSerifDisplay().fontFamily,
            fontWeight: FontWeight.w800,
            fontSize: 32,
            height: 1.1,
          ),
        ),
        toolbarHeight: 100,
        centerTitle: false,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  ...features.map(
                    (f) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '• ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              f.replaceFirst(
                                '• ',
                                '',
                              ), // Remove bullet from string
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white,
                                fontFamily:
                                    GoogleFonts.overpassMono().fontFamily,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 50,
              child: Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  '- Shyam. N',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white38,
                    fontFamily: GoogleFonts.overpassMono().fontFamily,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
