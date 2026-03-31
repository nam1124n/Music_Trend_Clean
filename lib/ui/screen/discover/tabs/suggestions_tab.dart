import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:login_flutter/domain/entities/song_entity.dart';
import 'package:login_flutter/domain/entities/trending_song_entity.dart';
import 'package:login_flutter/ui/screen/admin/providers/song_provider.dart';
import 'package:login_flutter/ui/screen/admin/providers/song_state.dart';
import 'package:login_flutter/ui/screen/audio/providers/audio_player_provider.dart';
import 'package:login_flutter/ui/screen/discover/providers/favorites_provider.dart';
import 'package:login_flutter/ui/screen/discover/providers/recents_provider.dart';

class SuggestionsTab extends ConsumerWidget {
  const SuggestionsTab({super.key});

  static const List<List<Color>> _trendingPalettes = [
    [Color(0xFF0F172A), Color(0xFF8C52FF), Color(0xFFF43F5E)],
    [Color(0xFF1E1B4B), Color(0xFF4C1D95)],
    [Color(0xFF1F2937), Color(0xFF0EA5E9)],
    [Color(0xFF14532D), Color(0xFF10B981)],
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(songNotifierProvider);

    if (state is SongError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            state.message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      );
    }

    if (state is SongLoaded) {
      if (state.songs.isEmpty) {
        return _buildEmptyState();
      }

      return _buildContent(context, ref, state.songs);
    }

    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF8C52FF)),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<SongEntity> songs,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text(
              'Thịnh hành',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          _buildTrendingSection(ref),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dành cho bạn',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Từ Firestore',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8C52FF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          _buildForYouList(songs),
        ],
      ),
    );
  }

  Widget _buildTrendingSection(WidgetRef ref) {
    final getWeeklyTrendingSongsUseCase = ref.watch(
      getWeeklyTrendingSongsUseCaseProvider,
    );

    return StreamBuilder<List<TrendingSongEntity>>(
      stream: getWeeklyTrendingSongsUseCase(limit: 4),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const SizedBox(
            height: 160,
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFF8C52FF)),
            ),
          );
        }

        final trendingSongs = snapshot.data ?? const <TrendingSongEntity>[];

        if (trendingSongs.isEmpty) {
          return Container(
            height: 160,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.local_fire_department_outlined,
                  size: 32,
                  color: Color(0xFF8C52FF),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Chưa có đủ lượt nghe để xếp hạng tuần này',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Top 4 sẽ tự cập nhật khi người dùng nghe đủ thời lượng.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          );
        }

        return SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: trendingSongs.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final trendingSong = trendingSongs[index];
              final colors =
                  _trendingPalettes[index % _trendingPalettes.length];

              return _buildTrendingCard(
                trendingSong: trendingSong,
                colors: colors,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTrendingCard({
    required TrendingSongEntity trendingSong,
    required List<Color> colors,
  }) {
    final song = trendingSong.song;

    return Container(
      width: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (song.imageUrl.isNotEmpty)
            Image.network(
              song.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.12),
                  Colors.black.withValues(alpha: 0.6),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTrendingStats(trendingSong),
                const Spacer(),
                Text(
                  song.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  song.artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingStats(TrendingSongEntity trendingSong) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildStatChip(
          icon: Icons.people_alt_outlined,
          label: '${_formatCount(trendingSong.uniqueUserCount)} người nghe',
        ),
        _buildStatChip(
          icon: Icons.headphones_outlined,
          label: '${_formatCount(trendingSong.totalPlayCount)} lượt nghe',
        ),
      ],
    );
  }

  Widget _buildStatChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(value % 1000000 == 0 ? 0 : 1)}M';
    }

    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1)}k';
    }

    return value.toString();
  }

  Widget _buildForYouList(List<SongEntity> songs) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: songs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final song = songs[index];
        final cardColor =
            _trendingPalettes[index % _trendingPalettes.length].first;

        return Consumer(
          builder: (context, ref, _) {
            final favoriteSongs = ref.watch(favoriteNotifierProvider);
            final playerState = ref.watch(audioPlayerNotifierProvider);
            final isFavorite = favoriteSongs.any((s) => s.id == song.id);
            final isPlayingThisSong =
                playerState.currentSong?.id == song.id && playerState.isPlaying;
            final isLoadingThisSong =
                playerState.currentSong?.id == song.id && playerState.isLoading;

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade100, width: 1),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: song.imageUrl.isNotEmpty
                        ? Image.network(
                            song.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.music_note,
                              color: Colors.white54,
                              size: 28,
                            ),
                          )
                        : const Icon(
                            Icons.music_note,
                            color: Colors.white54,
                            size: 28,
                          ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.music_note,
                              size: 14,
                              color: Color(0xFF8C52FF),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                song.artist,
                                style: const TextStyle(
                                  color: Color(0xFF8C52FF),
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Audio tu Firestore',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      ref
                          .read(favoriteNotifierProvider.notifier)
                          .toggleFavorite(song);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite
                            ? const Color(0xFFF43F5E)
                            : Colors.grey.shade400,
                        size: 24,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (isPlayingThisSong) {
                        ref.read(audioPlayerNotifierProvider.notifier).pause();
                      } else if (playerState.currentSong?.id == song.id) {
                        ref.read(audioPlayerNotifierProvider.notifier).resume();
                      } else {
                        ref
                            .read(audioPlayerNotifierProvider.notifier)
                            .playSong(song, playlist: songs);
                        ref
                            .read(recentNotifierProvider.notifier)
                            .addRecent(song);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: isLoadingThisSong
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF8C52FF),
                              ),
                            )
                          : Icon(
                              isPlayingThisSong
                                  ? Icons.pause_circle_outline
                                  : Icons.play_circle_outline,
                              color: isPlayingThisSong
                                  ? const Color(0xFF8C52FF)
                                  : Colors.grey.shade400,
                              size: 28,
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFF3E8FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.library_music_outlined,
                size: 56,
                color: Color(0xFF8C52FF),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Chua co du lieu bai hat',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Them bai hat trong Firestore hoac tu trang admin de giao dien nay hien du lieu that.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
