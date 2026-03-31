import 'package:flutter/material.dart';

class DiscoverTabBar extends StatelessWidget {
  final TabController tabController;

  const DiscoverTabBar({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TabBar(
        controller: tabController,
        isScrollable: true,
        labelColor: const Color(0xFF8C52FF),
        unselectedLabelColor: Colors.grey.shade600,
        indicatorColor: const Color(0xFF8C52FF),
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.grey.shade200,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        tabAlignment: TabAlignment.start,
        tabs: const [
          Tab(text: "Gợi ý"),
          Tab(text: "Yêu thích"),
          Tab(text: "Gần đây"),
          Tab(text: "Âm thanh của bạn"),
        ],
      ),
    );
  }
}
