import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:login_flutter/features/admin/presentation/bloc/song_bloc.dart';
import 'package:login_flutter/features/admin/presentation/bloc/song_event.dart';

import '../widgets/custom_bottom_nav.dart';
import '../widgets/discover_app_bar.dart';
import '../widgets/discover_tab_bar.dart';
import '../widgets/mini_player.dart';
import 'tabs/suggestions_tab.dart';
import 'tabs/your_audio_tab.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    context.read<SongBloc>().add(LoadSongsEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const DiscoverAppBar(),
            DiscoverTabBar(tabController: _tabController),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  const SuggestionsTab(),
                  const Center(child: Text("Yêu thích")),
                  const Center(child: Text("Gần đây")),
                  const YourAudioTab(),
                ],
              ),
            ),
            // Bottom padding to ensure list content is not hidden behind the custom bottom nav
            const SizedBox(height: 140), 
          ],
        ),
      ),
      bottomSheet: Container(
        color: Colors.transparent,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: MiniPlayer(),
                ),
                const SizedBox(height: 8), // Gap between player and nav
                const CustomBottomNav(),
                // Padding for safe area bottom if needed
                Container(
                  color: Colors.white,
                  height: MediaQuery.of(context).padding.bottom,
                ),
              ],
            ),
            // Floating Action Button
            Positioned(
              bottom: 30 + MediaQuery.of(context).padding.bottom, // roughly top edge of BottomNav
              child: Container(
                padding: const EdgeInsets.all(4), // White border effect
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
