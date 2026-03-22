part of 'home_screen.dart';

class _TopHeader extends StatelessWidget {
  const _TopHeader({
    required this.userName,
    required this.unreadNotifications,
    required this.searchController,
    required this.searching,
    required this.suggestions,
    required this.onLogoTap,
    required this.onSearchChanged,
    required this.onSelectSuggestion,
    required this.onProfileMenuTap,
  });

  final String userName;
  final int unreadNotifications;
  final TextEditingController searchController;
  final bool searching;
  final List<HomeSearchSuggestion> suggestions;
  final VoidCallback onLogoTap;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<HomeSearchSuggestion> onSelectSuggestion;
  final ValueChanged<String> onProfileMenuTap;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final compact = width < 720;

    return Material(
      color: const Color(0xFF0D0F14),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Row(
              children: [
                InkWell(
                  onTap: onLogoTap,
                  borderRadius: BorderRadius.circular(10),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Text('Readify', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Tìm sách và bài viết...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: searching
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                            )
                          : null,
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded)),
                    if (unreadNotifications > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(999)),
                          child: Text(
                            unreadNotifications > 99 ? '99+' : '$unreadNotifications',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                  ],
                ),
                PopupMenuButton<String>(
                  onSelected: onProfileMenuTap,
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'profile', child: Text('Trang cá nhân')),
                    PopupMenuItem(value: 'logout', child: Text('Đăng xuất')),
                  ],
                  child: Row(
                    children: [
                      const CircleAvatar(radius: 14, child: Icon(Icons.person, size: 18)),
                      if (!compact) ...[
                        const SizedBox(width: 6),
                        Text(userName, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (suggestions.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              constraints: const BoxConstraints(maxHeight: 280),
              decoration: BoxDecoration(
                color: const Color(0xFF12151E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final item = suggestions[index];
                  return ListTile(
                    onTap: () => onSelectSuggestion(item),
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      child: Icon(item.type == 'book' ? Icons.menu_book : Icons.article, size: 16),
                    ),
                    title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(item.subtitle ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                  );
                },
                separatorBuilder: (context, index) => Divider(height: 1, color: Colors.white.withValues(alpha: 0.06)),
                itemCount: suggestions.length,
              ),
            ),
        ],
      ),
    );
  }
}

class _DesktopTabBar extends StatelessWidget {
  const _DesktopTabBar({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    const tabs = ['Trang chủ', 'Sách', 'Blog', 'Yêu thích', 'Cá nhân'];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Wrap(
        spacing: 8,
        children: List.generate(
          tabs.length,
          (index) => ChoiceChip(
            label: Text(tabs[index]),
            selected: currentIndex == index,
            onSelected: (_) => onTap(index),
          ),
        ),
      ),
    );
  }
}
