import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:login_flutter/domain/entities/song_entity.dart';
import 'package:login_flutter/l10n/app_localizations.dart';
import 'package:login_flutter/ui/screen/audio/providers/audio_player_provider.dart';
import 'package:login_flutter/ui/screen/discover/providers/favorites_provider.dart';
import 'package:login_flutter/ui/screen/discover/providers/recents_provider.dart';

class GenreScreen extends ConsumerStatefulWidget {
  const GenreScreen({super.key});

  @override
  ConsumerState<GenreScreen> createState() => _GenreScreenState();
}

class _GenreScreenState extends ConsumerState<GenreScreen> {
  static const List<int> _years = [2025, 2024, 2023, 2022];
  static const Color _purple = Color(0xFF7B43F3);
  static const Color _purpleDark = Color(0xFF4C1D95);
  static const Color _background = Color(0xFFF7F2FF);

  int _selectedYear = _years.first;
  bool _didSelectYear = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isVietnamese = Localizations.localeOf(context).languageCode == 'vi';
    final favoriteSongs = ref.watch(favoriteNotifierProvider);
    final playerState = ref.watch(audioPlayerNotifierProvider);
    final songsByYear = _groupSongsByYear(favoriteSongs);
    final autoSelectedYear = _preferredYear(songsByYear);
    final selectedYear = _didSelectYear ? _selectedYear : autoSelectedYear;
    final selectedSongs = songsByYear[selectedYear] ?? const <SongEntity>[];
    final yearsWithMemories = _years
        .where((year) => (songsByYear[year] ?? const []).isNotEmpty)
        .length;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.92),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          l10n.genreLabel,
          style: const TextStyle(
            color: Color(0xFF1F1147),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8F4FF), Color(0xFFF4EEFF), Color(0xFFFDFBFF)],
          ),
        ),
        child: Stack(
          children: [
            const Positioned(
              top: -80,
              right: -20,
              child: _GlowOrb(
                size: 210,
                color: Color(0xFFD8C1FF),
                opacity: 0.5,
              ),
            ),
            const Positioned(
              top: 160,
              left: -50,
              child: _GlowOrb(
                size: 170,
                color: Color(0xFFEADBFF),
                opacity: 0.55,
              ),
            ),
            SafeArea(
              top: false,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                children: [
                  _HeaderCard(
                    title: l10n.genreScreenTitle,
                    subtitle: l10n.genreScreenSubtitle,
                    selectedYear: selectedYear,
                    totalSongs: favoriteSongs.length,
                    yearsWithMemories: yearsWithMemories,
                    isVietnamese: isVietnamese,
                  ),
                  const SizedBox(height: 22),
                  _buildYearTabs(selectedYear),
                  const SizedBox(height: 20),
                  _SectionHeader(
                    title: _yearListTitle(selectedYear, isVietnamese),
                    subtitle: _yearListSubtitle(
                      selectedYear: selectedYear,
                      songCount: selectedSongs.length,
                      hasFavorites: favoriteSongs.isNotEmpty,
                      isVietnamese: isVietnamese,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (selectedSongs.isEmpty)
                    _EmptyStateCard(
                      title: _emptyStateTitle(
                        hasFavorites: favoriteSongs.isNotEmpty,
                        selectedYear: selectedYear,
                        isVietnamese: isVietnamese,
                      ),
                      subtitle: _emptyStateSubtitle(
                        hasFavorites: favoriteSongs.isNotEmpty,
                        isVietnamese: isVietnamese,
                      ),
                    )
                  else
                    ...selectedSongs.map(
                      (song) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _SongMemoryCard(
                          song: song,
                          note: _memoryNote(song, isVietnamese),
                          isPlaying:
                              playerState.currentSong?.id == song.id &&
                              playerState.isPlaying,
                          isLoading:
                              playerState.currentSong?.id == song.id &&
                              playerState.isLoading,
                          onPlayPressed: () => _handlePlayAction(
                            song: song,
                            playlist: selectedSongs,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearTabs(int selectedYear) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _years.map((year) {
          final isSelected = year == selectedYear;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedYear = year;
                  _didSelectYear = true;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _purple
                      : Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : const Color(0xFFE8DDFB),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? _purple.withValues(alpha: 0.26)
                          : const Color(0xFF2B145F).withValues(alpha: 0.04),
                      blurRadius: isSelected ? 24 : 16,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Text(
                  '$year',
                  style: TextStyle(
                    color: isSelected ? Colors.white : _purpleDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _handlePlayAction({
    required SongEntity song,
    required List<SongEntity> playlist,
  }) async {
    final playerState = ref.read(audioPlayerNotifierProvider);
    final playerNotifier = ref.read(audioPlayerNotifierProvider.notifier);

    if (playerState.currentSong?.id == song.id) {
      if (playerState.isPlaying) {
        playerNotifier.pause();
      } else {
        playerNotifier.resume();
      }
      return;
    }

    await playerNotifier.playSong(song, playlist: playlist);
    await ref.read(recentNotifierProvider.notifier).addRecent(song);
  }

  Map<int, List<SongEntity>> _groupSongsByYear(List<SongEntity> songs) {
    final grouped = {for (final year in _years) year: <SongEntity>[]};

    for (final song in songs) {
      final year = _bucketYearFor(song);
      grouped[year]!.add(song);
    }

    return grouped;
  }

  int _preferredYear(Map<int, List<SongEntity>> songsByYear) {
    for (final year in _years) {
      if ((songsByYear[year] ?? const []).isNotEmpty) {
        return year;
      }
    }

    return _years.first;
  }

  int _bucketYearFor(SongEntity song) {
    final savedYear = song.savedAt?.year;
    if (savedYear != null && _years.contains(savedYear)) {
      return savedYear;
    }

    // Keep legacy or newer records visible inside the archive even when
    // they do not expose one of the fixed design years.
    return _years.first;
  }

  String _yearListTitle(int year, bool isVietnamese) {
    return isVietnamese ? 'Đã lưu trong $year' : 'Saved in $year';
  }

  String _yearListSubtitle({
    required int selectedYear,
    required int songCount,
    required bool hasFavorites,
    required bool isVietnamese,
  }) {
    if (!hasFavorites) {
      return isVietnamese
          ? 'Những bài bạn thả tim sẽ xuất hiện ở đây theo từng năm.'
          : 'Songs you save will appear here, grouped by year.';
    }

    if (songCount == 0) {
      return isVietnamese
          ? 'Năm $selectedYear hiện chưa có bài hát nào được lưu.'
          : 'No songs are saved in $selectedYear yet.';
    }

    return isVietnamese
        ? '$songCount bài hát được giữ lại như một cột mốc nghe nhạc.'
        : '$songCount songs kept as snapshots from that year.';
  }

  String _emptyStateTitle({
    required bool hasFavorites,
    required int selectedYear,
    required bool isVietnamese,
  }) {
    if (!hasFavorites) {
      return isVietnamese
          ? 'Chưa có kỷ niệm âm nhạc nào'
          : 'No music memories yet';
    }

    return isVietnamese
        ? 'Năm $selectedYear vẫn đang trống'
        : '$selectedYear is still empty';
  }

  String _emptyStateSubtitle({
    required bool hasFavorites,
    required bool isVietnamese,
  }) {
    if (!hasFavorites) {
      return isVietnamese
          ? 'Lưu bài hát bạn thích để tự tạo một archive nghe lại theo từng năm.'
          : 'Save the songs you love to start building a year-by-year archive.';
    }

    return isVietnamese
        ? 'Thử chuyển sang một năm khác để mở lại những bài hát bạn đã giữ.'
        : 'Try another year tab to revisit the songs you have kept.';
  }

  String _memoryNote(SongEntity song, bool isVietnamese) {
    final tags = song.semanticTags.map((tag) => tag.toLowerCase()).toList();

    if (tags.any(
      (tag) =>
          tag.contains('chill') ||
          tag.contains('lo-fi') ||
          tag.contains('lofi') ||
          tag.contains('acoustic'),
    )) {
      return isVietnamese
          ? 'Giai điệu giữ mọi thứ dịu xuống vừa đủ.'
          : 'The track that kept everything calm enough.';
    }

    if (tags.any(
      (tag) =>
          tag.contains('sad') || tag.contains('buon') || tag.contains('ballad'),
    )) {
      return isVietnamese
          ? 'Một bài hát thường quay lại vào những đêm yên hơn.'
          : 'A song that kept coming back on quieter nights.';
    }

    if (song.energyLevel >= 4 ||
        tags.any(
          (tag) =>
              tag.contains('edm') ||
              tag.contains('rock') ||
              tag.contains('rap') ||
              tag.contains('dance'),
        )) {
      return isVietnamese
          ? 'Bản nhạc kéo tâm trạng lên ngay từ vài giây đầu.'
          : 'The one that lifted the mood in just a few seconds.';
    }

    return isVietnamese
        ? 'Một ca khúc bạn đã giữ lại cho rất nhiều lần nghe sau đó.'
        : 'A song you kept around for many listens after that.';
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.title,
    required this.subtitle,
    required this.selectedYear,
    required this.totalSongs,
    required this.yearsWithMemories,
    required this.isVietnamese,
  });

  final String title;
  final String subtitle;
  final int selectedYear;
  final int totalSongs;
  final int yearsWithMemories;
  final bool isVietnamese;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6F3AF2), Color(0xFF9A76FF)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6F3AF2).withValues(alpha: 0.24),
            blurRadius: 34,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
                child: Text(
                  '$selectedYear',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _StatChip(
                label: isVietnamese ? 'Bài đã lưu' : 'Saved songs',
                value: '$totalSongs',
              ),
              _StatChip(
                label: isVietnamese ? 'Năm có kỷ niệm' : 'Active years',
                value: '$yearsWithMemories/4',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.76),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F1147),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            height: 1.5,
            color: Color(0xFF6E5A9A),
          ),
        ),
      ],
    );
  }
}

class _SongMemoryCard extends StatelessWidget {
  const _SongMemoryCard({
    required this.song,
    required this.note,
    required this.isPlaying,
    required this.isLoading,
    required this.onPlayPressed,
  });

  final SongEntity song;
  final String note;
  final bool isPlaying;
  final bool isLoading;
  final VoidCallback onPlayPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8DDFB)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF220B52).withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          _Artwork(imageUrl: song.imageUrl),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF23124F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  song.artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF7B43F3),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  note,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: Color(0xFF7B6B9A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPlayPressed,
              customBorder: const CircleBorder(),
              child: Ink(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isPlaying
                      ? const Color(0xFF5B21B6)
                      : const Color(0xFFF1E8FF),
                ),
                child: Center(
                  child: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF7B43F3),
                          ),
                        )
                      : Icon(
                          isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          size: 26,
                          color: isPlaying
                              ? Colors.white
                              : const Color(0xFF7B43F3),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Artwork extends StatelessWidget {
  const _Artwork({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6F3AF2), Color(0xFFC4A6FF)],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl.isNotEmpty
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const _ArtworkPlaceholder(),
            )
          : const _ArtworkPlaceholder(),
    );
  }
}

class _ArtworkPlaceholder extends StatelessWidget {
  const _ArtworkPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(Icons.music_note_rounded, size: 28, color: Colors.white),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8DDFB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF3EAFF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              color: Color(0xFF7B43F3),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF23124F),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Color(0xFF6E5A9A),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.size,
    required this.color,
    required this.opacity,
  });

  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: opacity),
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}
