import 'package:flutter/material.dart';

class SuggestionsTab extends StatelessWidget {
  const SuggestionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text(
              "Thịnh hành",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          // Horizontal list
          SizedBox(
            height: 160,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildTrendingCard(
                  title: "Cyberpunk Beats",
                  subtitle: "Curated by SoundWave",
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF8C52FF), Color(0xFFF43F5E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                const SizedBox(width: 12),
                _buildTrendingCard(
                  title: "Midnight Acoustics",
                  subtitle: "Acoustic chill",
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E1B4B), Color(0xFF4C1D95)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Dành cho bạn",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  "Xem tất cả",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8C52FF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Vertical list
          _buildForYouList(),
        ],
      ),
    );
  }

  Widget _buildTrendingCard({
    required String title,
    required String subtitle,
    required Gradient gradient,
  }) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: gradient,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForYouList() {
    final items = [
      {
        'title': 'Electric Dreams',
        'subtitle': 'Synthesize',
        'time': '3:42',
        'color': const Color(0xFFEF4444),
        'icon': Icons.bookmark_border,
      },
      {
        'title': 'Golden Hour',
        'subtitle': 'Luna Ray',
        'time': '4:15',
        'color': const Color(0xFF10B981),
        'icon': Icons.bookmark,
        'iconColor': const Color(0xFF8C52FF),
      },
      {
        'title': 'Slow Burn',
        'subtitle': 'The Echoes',
        'time': '2:58',
        'color': const Color(0xFFD97706),
        'icon': Icons.bookmark_border,
      },
      {
        'title': 'After Dark',
        'subtitle': 'Midnight Pulse',
        'time': '5:20',
        'color': const Color(0xFFEAB308),
        'icon': Icons.bookmark_border,
      },
      {
        'title': 'Starlight Serenade',
        'subtitle': 'Sound Studio • 0:45',
        'isMusicSub': true,
        'desc': 'Đã nghe 5 phút trước',
        'color': const Color(0xFFA855F7), // slightly different purple
        'icon': Icons.bookmark_border,
      },
      {
        'title': 'Neon Pulse (Remix)',
        'subtitle': 'DJ Vortex • 1:12',
        'isMusicSub': true,
        'desc': 'Đã nghe 12 phút trước',
        'color': const Color(0xFF0F172A),
        'icon': Icons.bookmark,
        'iconColor': const Color(0xFF8C52FF),
      },
      {
        'title': 'Acoustic Dreams',
        'subtitle': 'Luna Ray • 2:30',
        'isMusicSub': true,
        'desc': 'Đã nghe 45 phút trước',
        'color': const Color(0xFF1E293B),
        'icon': Icons.bookmark_border,
      },
      {
        'title': 'City Rain Lo-Fi',
        'subtitle': 'Chill Beats • 3:15',
        'isMusicSub': true,
        'desc': 'Đã nghe 2 giờ trước',
        'color': const Color(0xFFFACC15),
        'icon': Icons.bookmark_border,
      },
    ];

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        final hasDesc = item.containsKey('desc');
        final isMusicSub = item['isMusicSub'] == true;

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
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: item['color'] as Color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.music_note, color: Colors.white54, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (isMusicSub)
                      Row(
                        children: [
                          const Icon(Icons.music_note, size: 14, color: Color(0xFF8C52FF)),
                          const SizedBox(width: 4),
                          Text(
                            item['subtitle'] as String,
                            style: const TextStyle(
                              color: Color(0xFF8C52FF),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        item['subtitle'] as String,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                        ),
                      ),
                    if (hasDesc) ...[
                      const SizedBox(height: 4),
                      Text(
                        item['desc'] as String,
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 12,
                        ),
                      ),
                    ]
                  ],
                ),
              ),
              if (item.containsKey('time'))
                Text(
                  item['time'] as String,
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                ),
              const SizedBox(width: 12),
              Icon(
                item['icon'] as IconData,
                color: item.containsKey('iconColor')
                    ? item['iconColor'] as Color
                    : Colors.grey.shade300,
                size: 24,
              ),
            ],
          ),
        );
      },
    );
  }
}
