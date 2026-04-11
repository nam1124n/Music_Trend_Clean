import 'package:flutter/material.dart';
import 'package:login_flutter/l10n/app_localizations.dart';

class GenreScreen extends StatelessWidget {
  const GenreScreen({super.key});

  static const List<_GenreItem> _genres = [
    _GenreItem(name: 'Pop', icon: Icons.graphic_eq_rounded),
    _GenreItem(name: 'Ballad', icon: Icons.music_note_rounded),
    _GenreItem(name: 'Lo-fi', icon: Icons.nightlight_round),
    _GenreItem(name: 'Acoustic', icon: Icons.piano_rounded),
    _GenreItem(name: 'EDM', icon: Icons.bolt_rounded),
    _GenreItem(name: 'Rap', icon: Icons.mic_rounded),
    _GenreItem(name: 'Jazz', icon: Icons.album_rounded),
    _GenreItem(name: 'Rock', icon: Icons.audiotrack_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: Text(
          l10n.genreLabel,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.genreScreenTitle,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.genreScreenSubtitle,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  itemCount: _genres.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.28,
                  ),
                  itemBuilder: (context, index) {
                    final genre = _genres[index];

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3E8FF),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              genre.icon,
                              color: const Color(0xFF8C52FF),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            genre.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenreItem {
  const _GenreItem({required this.name, required this.icon});

  final String name;
  final IconData icon;
}
