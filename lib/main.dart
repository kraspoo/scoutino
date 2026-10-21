import 'package:flutter/material.dart';

import 'app_state.dart';
import 'screens/ai_result_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/scout_search_screen.dart';
import 'screens/upload_video_screen.dart';

const kNavy = Color(0xFF0A192F);
const kGreen = Color(0xFF00A651);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppState.instance.load();
  runApp(const ScoutinoApp());
}

class ScoutinoApp extends StatelessWidget {
  const ScoutinoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scoutino',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: kNavy,
        colorScheme: ColorScheme.fromSeed(seedColor: kGreen),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: kNavy,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: const HomeTabs(),
    );
  }
}

class HomeTabs extends StatefulWidget {
  const HomeTabs({super.key});

  @override
  State<HomeTabs> createState() => _HomeTabsState();
}

class _HomeTabsState extends State<HomeTabs> {
  int idx = 0;

  final List<Widget> pages = const [
    PlayerProfileScreen(),
    UploadVideoScreen(),
    AIResultScreen(),
    ScoutSearchScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: idx, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: idx,
        onTap: (i) => setState(() => idx = i),
        selectedItemColor: kGreen,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'بروفايلي'),
          BottomNavigationBarItem(icon: Icon(Icons.videocam), label: 'رفع فيديو'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'نتيجتي'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'بحث الكشاف'),
        ],
      ),
    );
  }
}
