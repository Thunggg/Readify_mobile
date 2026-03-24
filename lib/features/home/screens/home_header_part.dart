part of 'home_screen.dart';

class _TopHeader extends StatelessWidget {
  const _TopHeader({
    required this.userName,
    required this.unreadNotifications,
    required this.searchController,
    required this.searching,
    required this.suggestions,
    required this.onLogoTap,
    required this.onSearchTap,
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
  final VoidCallback onSearchTap;
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
                    onSubmitted: (_) => onSearchTap(),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Search books...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.open_in_new),
                        onPressed: onSearchTap,
                        tooltip: 'Open filter page',
                      ),
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
                    PopupMenuItem(value: 'profile', child: Text('Profile')),
                    PopupMenuItem(value: 'logout', child: Text('Log out')),
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
          if (searching)
            const LinearProgressIndicator(minHeight: 2),
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
    const tabs = ['Home', 'Blog', 'Cart', 'Account'];
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
