import 'package:flutter/material.dart';

import '../app_state.dart';
import '../main.dart';

class PlayerProfileScreen extends StatelessWidget {
  const PlayerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final p = state.profile;
        final overall = state.overall;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Scoutino - سكاوتينو'),
            actions: [
              IconButton(
                tooltip: 'تعديل البروفايل',
                icon: const Icon(Icons.edit),
                onPressed: () => _openEdit(context),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 8),
              const Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: kNavy,
                  child: Icon(Icons.sports_soccer, size: 50, color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  '${p.name} - ${p.age} سنة - ${p.position}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                children: [
                  Chip(label: Text(p.city)),
                  Chip(label: Text('قدم ${p.foot}')),
                  Chip(label: Text(overall == null ? 'لسه متقيمش' : '$overall/100')),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'فيديوهات المهارات (${state.videosDone}/${state.videoPaths.length})',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      for (var i = 0; i < AppState.skillSteps.length; i++)
                        ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            state.videoPaths[i] != null
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: state.videoPaths[i] != null ? kGreen : Colors.grey,
                          ),
                          title: Text(AppState.skillSteps[i]),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGreen,
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: () => _openEdit(context),
                icon: const Icon(Icons.edit, color: Colors.white),
                label: const Text('تعديل بياناتي',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openEdit(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _EditProfileSheet(),
    );
  }
}

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet();

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController nameC;
  late final TextEditingController ageC;
  late final TextEditingController cityC;
  late String position;
  late String foot;

  @override
  void initState() {
    super.initState();
    final p = AppState.instance.profile;
    nameC = TextEditingController(text: p.name);
    ageC = TextEditingController(text: '${p.age}');
    cityC = TextEditingController(text: p.city);
    position = p.position;
    foot = p.foot;
  }

  @override
  void dispose() {
    nameC.dispose();
    ageC.dispose();
    cityC.dispose();
    super.dispose();
  }

  void _save() {
    final old = AppState.instance.profile;
    final age = (int.tryParse(ageC.text.trim()) ?? old.age).clamp(6, 20).toInt();
    AppState.instance.updateProfile(PlayerProfile(
      name: nameC.text.trim().isEmpty ? old.name : nameC.text.trim(),
      age: age,
      position: position,
      city: cityC.text.trim().isEmpty ? old.city : cityC.text.trim(),
      foot: foot,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('بياناتي',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            TextField(
              controller: nameC,
              decoration: const InputDecoration(
                  labelText: 'الاسم', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ageC,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'السن', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: cityC,
              decoration: const InputDecoration(
                  labelText: 'المدينة', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: position,
              decoration: const InputDecoration(
                  labelText: 'المركز', border: OutlineInputBorder()),
              items: AppState.positions
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => position = v ?? position),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: foot,
              decoration: const InputDecoration(
                  labelText: 'القدم', border: OutlineInputBorder()),
              items: AppState.feet
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => foot = v ?? foot),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kGreen,
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: _save,
              child: const Text('حفظ', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
