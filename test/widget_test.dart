import 'package:flutter_test/flutter_test.dart';
import 'package:mseva_punjab/main.dart';

void main() {
  testWidgets('starting screen renders its primary actions', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Welcome to mSeva app'), findsOneWidget);
    expect(find.text('Citizen'), findsOneWidget);
    expect(find.text('Employee'), findsOneWidget);
  });
}
