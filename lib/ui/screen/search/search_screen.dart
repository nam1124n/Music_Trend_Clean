import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:login_flutter/domain/entities/song_entity.dart';
import 'package:login_flutter/ui/screen/admin/bloc/song_bloc.dart';
import 'package:login_flutter/ui/screen/admin/bloc/song_state.dart';
import 'package:login_flutter/ui/screen/audio/cubit/audio_player_cubit.dart';
import 'package:login_flutter/ui/screen/discover/bloc/recent_cubit.dart';
import 'package:login_flutter/ui/screen/search/cubit/search_cubit.dart';
import 'package:login_flutter/ui/screen/search/cubit/search_state.dart';
import 'package:login_flutter/ui/screen/search/widgets/search_infor_card.dart';
import 'package:login_flutter/ui/screen/search/widgets/search_result_title.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
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
      context.read<SearchCubit>().search(query: value, songs: songs);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SongBloc, SongState>(
      builder: (context, songState) {
        final songs = songState is SongLoaded
            ? songState.songs
            : <SongEntity>[];

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
                Expanded(
                  child: BlocBuilder<SearchCubit, SearchState>(
                    builder: (context, searchState) {
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
                                child: Center(
                                  child: Text('Khong tim thay bai hat phu hop'),
                                ),
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
                                separatorBuilder: (_, _) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final song = searchState.results[index];
                                  return SearchResultTile(
                                    song: song,
                                    onTap: () {
                                      context.read<AudioPlayerCubit>().playSong(
                                        song,
                                        playlist: searchState.results,
                                      );
                                      context.read<RecentCubit>().addRecent(
                                        song,
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      }

                      return const Center(
                        child: Text('Nhap cau tim kiem de AI phan tich'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
