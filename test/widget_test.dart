import 'package:flutter_test/flutter_test.dart';
import 'package:scoutino/app_state.dart';
import 'package:scoutino/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('التطبيق بيفتح وبيعرض التبويبات', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await AppState.instance.load();
    await tester.pumpWidget(const ScoutinoApp());

    expect(find.text('بروفايلي'), findsOneWidget);
    expect(find.text('رفع فيديو'), findsOneWidget);
    expect(find.text('نتيجتي'), findsOneWidget);
    expect(find.text('بحث الكشاف'), findsOneWidget);
  });
}
