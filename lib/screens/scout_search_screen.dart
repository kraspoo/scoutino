import 'package:flutter/material.dart';

import '../app_state.dart';
import '../main.dart';

class _Player {
  final String name;
  final int age;
  final String position;
  final String city;
  final int? score;
  final bool isMe;
  const _Player(this.name, this.age, this.position, this.city, this.score,
      {this.isMe = false});
}

class ScoutSearchScreen extends StatefulWidget {
  const ScoutSearchScreen({super.key});

  @override
  State<ScoutSearchScreen> createState() => _ScoutSearchScreenState();
}

class _ScoutSearchScreenState extends State<ScoutSearchScreen> {
  static const List<_Player> samples = [
    _Player('عمر خالد', 14, 'جناح', 'الإسكندرية', 81),
    _Player('مازن سمير', 12, 'وسط', 'الجيزة', 78),
    _Player('كريم حسن', 15, 'مدافع', 'المنصورة', 76),
    _Player('زياد محمود', 13, 'حارس', 'أسيوط', 74),
    _Player('آدم طارق', 14, 'مهاجم', 'القاهرة', 72),
  ];

  static const List<String> positions = [
    'الكل', 'مهاجم', 'جناح', 'وسط', 'مدافع', 'حارس'
  ];

  final AppState state = AppState.instance;
  String selected = 'الكل';
  String query = '';
  bool favoritesOnly = false;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final me = state.profile;
        final all = <_Player>[
          _Player(me.name, me.age, me.position, me.city, state.overall,
              isMe: true),
          ...samples,
        ];

        final filtered = all.where((p) {
          final posOk = selected == 'الكل' || p.position == selected;
          final qOk =
              query.isEmpty || p.name.contains(query) || p.city.contains(query);
          final favOk = !favoritesOnly || state.favorites.contains(p.name);
          return posOk && qOk && favOk;
        }).toList()
          ..sort((a, b) => (b.score ?? -1).compareTo(a.score ?? -1));

        return Scaffold(
          appBar: AppBar(title: const Text('بحث الكشاف')),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  onChanged: (v) => setState(() => query = v.trim()),
                  decoration: InputDecoration(
                    hintText: 'ابحث بالاسم أو المدينة',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),
              ),
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8),
                      child: FilterChip(
                        avatar: const Icon(Icons.star, size: 18),
                        label: const Text('المفضلة'),
                        selected: favoritesOnly,
                        onSelected: (v) => setState(() => favoritesOnly = v),
                      ),
                    ),
                    ...positions.map(
                      (p) => Padding(
                        padding: const EdgeInsetsDirectional.only(end: 8),
                        child: ChoiceChip(
                          label: Text(p),
                          selected: selected == p,
                          selectedColor: kGreen.withAlpha(77),
                          onSelected: (_) => setState(() => selected = p),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('مفيش لاعبين مطابقين'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: filtered.length,
                        itemBuilder: (c, i) {
                          final p = filtered[i];
                          final fav = state.favorites.contains(p.name);
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: p.isMe ? kGreen : kNavy,
                                child: const Icon(Icons.person,
                                    color: Colors.white),
                              ),
                              title: Text(
                                p.isMe ? '${p.name} (أنا)' : p.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                  '${p.position} • ${p.age} سنة • ${p.city}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: p.score == null
                                          ? Colors.grey
                                          : kGreen,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      p.score == null ? '--' : '${p.score}',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'مفضلة',
                                    icon: Icon(
                                      fav ? Icons.star : Icons.star_border,
                                      color: fav ? Colors.amber : Colors.grey,
                                    ),
                                    onPressed: () =>
                                        state.toggleFavorite(p.name),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
