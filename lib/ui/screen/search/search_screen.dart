import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:login_flutter/domain/entities/song_entity.dart';
import 'package:login_flutter/ui/screen/admin/providers/song_provider.dart';
import 'package:login_flutter/ui/screen/admin/providers/song_state.dart';
import 'package:login_flutter/ui/screen/audio/providers/audio_player_provider.dart';
import 'package:login_flutter/ui/screen/discover/providers/recents_provider.dart';
import 'package:login_flutter/ui/screen/search/providers/search_provider.dart';
import 'package:login_flutter/ui/screen/search/providers/search_state.dart';
import 'package:login_flutter/ui/screen/search/widgets/search_info_card.dart';
import 'package:login_flutter/ui/screen/search/widgets/search_result_tile.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value, List<SongEntity> songs) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      ref
          .read(searchNotifierProvider.notifier)
          .search(query: value, songs: songs);
    });
  }

  @override
  Widget build(BuildContext context) {
    final songState = ref.watch(songNotifierProvider);
    final searchState = ref.watch(searchNotifierProvider);
    final songs = songState is SongLoaded ? songState.songs : <SongEntity>[];

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              onChanged: (value) => _onQueryChanged(value, songs),
              decoration: InputDecoration(
                hintText: 'Tim bai hat, ca si, mood...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildContent(searchState, songState)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(SearchState searchState, SongState songState) {
    if (songState is SongLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (songState is SongError) {
      return Center(child: Text(songState.message));
    }

    if (searchState is SearchLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (searchState is SearchError) {
      return Center(child: Text(searchState.message));
    }

    if (searchState is SearchLoaded) {
      if (searchState.results.isEmpty) {
        return Column(
          children: [
            SearchInfoCard(plan: searchState.plan),
            const SizedBox(height: 16),
            const Expanded(
              child: Center(child: Text('Khong tim thay bai hat phu hop')),
            ),
          ],
        );
      }

      return Column(
        children: [
          SearchInfoCard(plan: searchState.plan),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: searchState.results.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final song = searchState.results[index];
                return SearchResultTile(
                  song: song,
                  onTap: () {
                    ref
                        .read(audioPlayerNotifierProvider.notifier)
                        .playSong(song, playlist: searchState.results);
                    ref.read(recentNotifierProvider.notifier).addRecent(song);
                  },
                );
              },
            ),
          ),
        ],
      );
    }

    return const Center(child: Text('Nhap cau tim kiem de AI phan tich'));
  }
}
