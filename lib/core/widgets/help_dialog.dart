import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:aeroclim/l10n/app_localizations.dart';

class HelpDialog extends StatelessWidget {
  const HelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final String languageCode = Localizations.localeOf(
      context,
    ).languageCode.toUpperCase();
    final String manualFileName = 'USER_MANUAL_$languageCode.md';

    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.helpAndUserManual,
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
        ),
        body: FutureBuilder<String>(
          future: rootBundle.loadString(manualFileName).catchError((error) {
            // Fallback to English if the specific language file is not found
            return rootBundle.loadString('USER_MANUAL_EN.md');
          }),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('${l10n.errorLoadingHelp}${snapshot.error}'),
              );
            }
            return Markdown(
              data: snapshot.data ?? l10n.noContentFound,
              onTapLink: (text, href, title) {
                if (href != null) {
                  launchUrl(Uri.parse(href), mode: LaunchMode.platformDefault);
                }
              },
              styleSheet: MarkdownStyleSheet(
                h1: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
                h2: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.8),
                ),
                p: const TextStyle(fontSize: 16, height: 1.5),
                listBullet: const TextStyle(fontSize: 16),
              ),
            );
          },
        ),
        persistentFooterButtons: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.copyUrlIfLinksDoNotWork,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SelectableText(
                  'https://github.com/jean-anton/aeroclim',
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
