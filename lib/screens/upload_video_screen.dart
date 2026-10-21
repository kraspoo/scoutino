import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../app_state.dart';
import '../main.dart';
import 'ai_result_screen.dart';

class UploadVideoScreen extends StatefulWidget {
  const UploadVideoScreen({super.key});

  @override
  State<UploadVideoScreen> createState() => _UploadVideoScreenState();
}

class _UploadVideoScreenState extends State<UploadVideoScreen> {
  final AppState state = AppState.instance;
  int current = 0;

  @override
  void initState() {
    super.initState();
    final i = state.videoPaths.indexWhere((p) => p == null);
    current = i == -1 ? 0 : i;
  }

  Future<void> record() async {
    try {
      final video = await ImagePicker().pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(seconds: 15),
      );
      if (video == null || !mounted) return;
      state.recordVideo(current, video.path);
      final next = state.videoPaths.indexWhere((p) => p == null);
      if (next == -1) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AIResultScreen()),
        );
      } else {
        setState(() => current = next);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر فتح الكاميرا، تأكد من الصلاحيات')),
      );
    }
  }

  void _reset() {
    state.resetVideos();
    setState(() => current = 0);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final total = AppState.skillSteps.length;
        return Scaffold(
          appBar: AppBar(
            title: const Text('رفع فيديو المهارات'),
            actions: [
              IconButton(
                tooltip: 'ابدأ من الأول',
                icon: const Icon(Icons.refresh),
                onPressed: state.videosDone == 0 ? null : _reset,
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: state.videosDone / total,
                  color: kGreen,
                  minHeight: 8,
                ),
                const SizedBox(height: 10),
                Text(
                  'الخطوة ${current + 1} من $total : ${AppState.skillSteps[current]}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                const Text('اضغط على أي مربع عشان تعيد تسجيله',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: total,
                  itemBuilder: (c, i) {
                    final done = state.videoPaths[i] != null;
                    return GestureDetector(
                      onTap: () => setState(() => current = i),
                      child: Container(
                        decoration: BoxDecoration(
                          color: i == current
                              ? kGreen.withAlpha(51)
                              : Colors.white,
                          border: Border.all(
                            color: done ? kGreen : Colors.grey.shade300,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              done ? Icons.check_circle : Icons.videocam,
                              color: done ? kGreen : Colors.grey,
                              size: 40,
                            ),
                            const SizedBox(height: 8),
                            Text(AppState.skillSteps[i],
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGreen,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: record,
                    icon: const Icon(Icons.videocam, color: Colors.white),
                    label: Text(
                      'سجل الآن - ${AppState.skillSteps[current]}',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
