import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../app_state.dart';
import '../main.dart';

class AIResultScreen extends StatelessWidget {
  const AIResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final scores = state.scores;
        final overall = state.overall;

        if (scores == null || overall == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('نتيجة التحليل')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.analytics_outlined,
                        size: 64, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text(
                      'سجّل الـ ${AppState.skillSteps.length} فيديوهات من تبويب "رفع فيديو" وهتظهرلك النتيجة هنا.\n(تم تسجيل ${state.videosDone})',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final entries = scores.entries.toList();
        return Scaffold(
          appBar: AppBar(title: const Text('نتيجة التحليل')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration:
                      const BoxDecoration(shape: BoxShape.circle, color: kGreen),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('$overall',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold)),
                      const Text('التقييم العام',
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text('* تقييم تجريبي - تحليل الذكاء الاصطناعي الحقيقي لسه هيتربط',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 260,
                child: RadarChart(
                  RadarChartData(
                    radarShape: RadarShape.polygon,
                    tickCount: 4,
                    ticksTextStyle: const TextStyle(color: Colors.transparent),
                    tickBorderData: BorderSide(color: Colors.grey.shade300),
                    gridBorderData: BorderSide(color: Colors.grey.shade300),
                    radarBorderData: const BorderSide(color: Colors.transparent),
                    titleTextStyle: const TextStyle(fontSize: 12, color: kNavy),
                    getTitle: (index, angle) =>
                        RadarChartTitle(text: entries[index].key),
                    dataSets: [
                      RadarDataSet(
                        fillColor: kGreen.withAlpha(77),
                        borderColor: kGreen,
                        entryRadius: 3,
                        borderWidth: 2,
                        dataEntries: entries
                            .map((e) => RadarEntry(value: e.value))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 110,
                        child: Text(e.key,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: e.value / 100,
                          color: kGreen,
                          backgroundColor: Colors.grey.shade300,
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${e.value.round()}'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
