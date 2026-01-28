import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpDialog extends StatelessWidget {
  const HelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Aide & Manuel d\'utilisation',
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
          future: rootBundle.loadString('USER_MANUAL_FR.md'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Erreur lors du chargement de l\'aide : ${snapshot.error}',
                ),
              );
            }
            return Markdown(
              data: snapshot.data ?? 'Aucun contenu trouvé.',
              onTapLink: (text, href, title) {
                if (href != null) {
                  launchUrl(Uri.parse(href));
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
      ),
    );
  }
}
