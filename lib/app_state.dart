import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlayerProfile {
  final String name;
  final int age;
  final String position;
  final String city;
  final String foot;

  const PlayerProfile({
    required this.name,
    required this.age,
    required this.position,
    required this.city,
    required this.foot,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'age': age,
        'position': position,
        'city': city,
        'foot': foot,
      };

  factory PlayerProfile.fromJson(Map<String, dynamic> j) => PlayerProfile(
        name: j['name'] as String,
        age: j['age'] as int,
        position: j['position'] as String,
        city: j['city'] as String,
        foot: j['foot'] as String,
      );
}

/// حالة التطبيق المشتركة + الحفظ المحلي على الجهاز.
class AppState extends ChangeNotifier {
  AppState._();
  static final AppState instance = AppState._();

  static const List<String> skillSteps = [
    'جري بالكرة 15ث',
    'مراوغة 15ث',
    'تسديد 15ث',
    'السرعة 15ث',
  ];
  static const List<String> positions = [
    'مهاجم',
    'جناح',
    'وسط',
    'مدافع',
    'حارس',
  ];
  static const List<String> feet = ['يمين', 'يسار', 'الاتنين'];

  PlayerProfile profile = const PlayerProfile(
    name: 'لاعب جديد',
    age: 13,
    position: 'مهاجم',
    city: 'القاهرة',
    foot: 'يمين',
  );
  List<String?> videoPaths = List<String?>.filled(4, null);
  Map<String, double>? scores;
  Set<String> favorites = <String>{};
  SharedPreferences? _prefs;

  int get videosDone => videoPaths.where((p) => p != null).length;

  int? get overall {
    final s = scores;
    if (s == null || s.isEmpty) return null;
    return (s.values.reduce((a, b) => a + b) / s.length).round();
  }

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    _prefs = p;

    final pj = p.getString('profile');
    if (pj != null) {
      try {
        profile = PlayerProfile.fromJson(jsonDecode(pj) as Map<String, dynamic>);
      } catch (_) {}
    }

    final vj = p.getStringList('videos');
    if (vj != null && vj.length == 4) {
      videoPaths = vj.map((e) => e.isEmpty ? null : e).toList();
    }

    final sj = p.getString('scores');
    if (sj != null) {
      try {
        final m = jsonDecode(sj) as Map<String, dynamic>;
        scores = m.map((k, v) => MapEntry(k, (v as num).toDouble()));
      } catch (_) {}
    }

    favorites = (p.getStringList('favorites') ?? <String>[]).toSet();
    notifyListeners();
  }

  void updateProfile(PlayerProfile p) {
    profile = p;
    notifyListeners();
    _save();
  }

  void recordVideo(int step, String path) {
    videoPaths[step] = path;
    if (videosDone == videoPaths.length) {
      _computeScores();
    }
    notifyListeners();
    _save();
  }

  void resetVideos() {
    videoPaths = List<String?>.filled(4, null);
    scores = null;
    notifyListeners();
    _save();
  }

  void toggleFavorite(String name) {
    if (!favorites.add(name)) favorites.remove(name);
    notifyListeners();
    _save();
  }

  /// تقييم تجريبي: أرقام ثابتة مشتقة من الفيديوهات المسجلة.
  /// لما نربط نموذج ذكاء اصطناعي حقيقي بنستبدل الدالة دي.
  void _computeScores() {
    var seed = 17;
    for (final path in videoPaths) {
      if (path == null) continue;
      var len = path.hashCode;
      try {
        len = File(path).lengthSync();
      } catch (_) {}
      seed = (seed * 31 + len) & 0x7fffffff;
    }
    final r = Random(seed);
    double v() => (65 + r.nextInt(31)).toDouble();
    scores = {
      'السرعة': v(),
      'المراوغة': v(),
      'التسديد': v(),
      'التحكم بالكرة': v(),
      'التحمل': v(),
    };
  }

  Future<void> _save() async {
    final p = _prefs;
    if (p == null) return;
    await p.setString('profile', jsonEncode(profile.toJson()));
    await p.setStringList('videos', videoPaths.map((e) => e ?? '').toList());
    final s = scores;
    if (s == null) {
      await p.remove('scores');
    } else {
      await p.setString('scores', jsonEncode(s));
    }
    await p.setStringList('favorites', favorites.toList());
  }
}
