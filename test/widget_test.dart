import 'package:flutter_test/flutter_test.dart';
import 'package:spin_wheel_picker/main.dart';

void main() {
  testWidgets('spin_wheel_picker smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SpinWheelPickerApp());

    expect(find.byType(SpinWheelPickerApp), findsOneWidget);
  });
}
