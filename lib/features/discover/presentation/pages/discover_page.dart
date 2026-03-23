import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:login_flutter/features/admin/presentation/bloc/song_bloc.dart';
import 'package:login_flutter/features/admin/presentation/bloc/song_event.dart';

import '../widgets/discover_app_bar.dart';
import '../widgets/discover_tab_bar.dart';
import 'tabs/suggestions_tab.dart';
import 'tabs/your_audio_tab.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: DiscoverContent(),
    );
  }
}

class DiscoverContent extends StatefulWidget {
  const DiscoverContent({super.key});

  @override
  State<DiscoverContent> createState() => _DiscoverContentState();
}

class _DiscoverContentState extends State<DiscoverContent>
    with SingleTickerProviderStateMixin {
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
    return SafeArea(
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
                const Center(child: Text('Yêu thích')),
                const Center(child: Text('Gần đây')),
                const YourAudioTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
