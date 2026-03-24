import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:login_flutter/ui/screen/audio/cubit/audio_player_cubit.dart';
import 'package:login_flutter/ui/screen/audio/cubit/audio_player_state.dart';
import 'package:login_flutter/ui/screen/discover/discover_screen.dart';
import 'package:login_flutter/ui/screen/discover/widgets/custom_bottom_nav.dart';
import 'package:login_flutter/ui/screen/discover/widgets/mini_player.dart';
import 'package:login_flutter/ui/screen/profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _onTabChanged(int index) {
    if (_currentIndex == index) {
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          DiscoverContent(),
          _PlaceholderTab(
            icon: Icons.search_rounded,
            title: 'Tìm kiếm',
            description: 'Khu vực tìm kiếm sẽ hiển thị tại đây.',
          ),
          _PlaceholderTab(
            icon: Icons.favorite_rounded,
            title: 'Đã thích',
            description: 'Danh sách bài hát yêu thích sẽ hiển thị tại đây.',
          ),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _HomeBottomBar(
        currentIndex: _currentIndex,
        onTabChanged: _onTabChanged,
      ),
    );
  }
}

class _HomeBottomBar extends StatelessWidget {
  const _HomeBottomBar({
    required this.currentIndex,
    required this.onTabChanged,
  });

  final int currentIndex;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
      builder: (context, state) {
        final bool hasCurrentSong = state.currentSong != null;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasCurrentSong)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: MiniPlayer(),
              ),
            if (hasCurrentSong) const SizedBox(height: 8),
            Container(
              color: Colors.white,
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: 84,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        top: 19,
                        child: CustomBottomNav(
                          currentIndex: currentIndex,
                          onTap: onTabChanged,
                        ),
                      ),
                      const Positioned(top: 0, child: _CreateButton()),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CreateButton extends StatelessWidget {
  const _CreateButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: Container(
        width: 56,
        height: 56,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF8C52FF),
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE4FF),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Icon(icon, size: 36, color: const Color(0xFF8C52FF)),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
