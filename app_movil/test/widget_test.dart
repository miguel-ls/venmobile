// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.
import 'package:app_movil/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';

// Mock http client
class MockClient extends Mock implements http.Client {}

void main() {
  group('LoginScreen', () {
    testWidgets('shows loading indicator and then displays captcha question',
        (WidgetTester tester) async {
      final client = MockClient();

      // Mock the API call to return a fake captcha question
      when(client.get(Uri.parse('http://localhost/api.php/captcha')))
          .thenAnswer((_) async => http.Response(
                '{"question":"2 + 3 = ?"}',
                200,
                headers: {
                  'content-type': 'application/json; charset=utf-8',
                  'set-cookie': 'PHPSESSID=12345'
                },
              ));

      await tester.pumpWidget(MaterialApp(home: LoginScreen()));

      // Verify that the loading indicator is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for the API call to complete
      await tester.pumpAndSettle();

      // Verify that the captcha question is displayed
      expect(find.text('2 + 3 = ?'), findsOneWidget);
    });
  });
}
