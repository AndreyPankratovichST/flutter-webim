import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:example/main.dart';

void main() {
  group('WebimExampleApp', () {
    testWidgets('запускается и отображает заголовок и вкладки', (WidgetTester tester) async {
      await tester.pumpWidget(const WebimExampleApp());

      expect(find.text('Webim Example'), findsOneWidget);
      expect(find.text('Чат'), findsOneWidget);
      expect(find.text('FAQ'), findsOneWidget);
      expect(find.text('Лог'), findsOneWidget);
    });

    testWidgets('вкладка Чат: отображает блок подключения и состояние', (WidgetTester tester) async {
      await tester.pumpWidget(const WebimExampleApp());

      expect(find.text('Подключение'), findsOneWidget);
      expect(find.text('Account name'), findsOneWidget);
      expect(find.text('Location'), findsOneWidget);
      expect(find.text('Создать сессию'), findsOneWidget);
      expect(find.text('Состояние'), findsOneWidget);
      expect(find.textContaining('VisitSessionState:'), findsOneWidget);
      expect(find.textContaining('ChatState:'), findsOneWidget);
      expect(find.textContaining('Оператор:'), findsOneWidget);
      expect(find.text('Сообщения'), findsOneWidget);
      expect(find.text('Демо: Webim.parse(remoteNotification)'), findsOneWidget);
    });

    testWidgets('при пустом account name кнопка Создать сессию пишет в лог', (WidgetTester tester) async {
      await tester.pumpWidget(const WebimExampleApp());

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), '');
      await tester.enterText(textFields.at(1), '');
      await tester.tap(find.text('Создать сессию'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Лог'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Укажите account name и location'), findsOneWidget);
    });

    testWidgets('вкладка FAQ: отображает форму и кнопки', (WidgetTester tester) async {
      await tester.pumpWidget(const WebimExampleApp());

      await tester.tap(find.text('FAQ'));
      await tester.pumpAndSettle();

      expect(find.text('FAQ (база знаний)'), findsOneWidget);
      expect(find.text('Загрузить FAQ'), findsOneWidget);
      expect(find.text('Корневые категории'), findsOneWidget);
      expect(find.text('Поиск по FAQ'), findsOneWidget);
      expect(find.text('Искать'), findsOneWidget);
    });

    testWidgets('вкладка Лог отображается без ошибок', (WidgetTester tester) async {
      await tester.pumpWidget(const WebimExampleApp());

      await tester.tap(find.text('Лог'));
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('кнопка Демо Webim.parse не вызывает падения', (WidgetTester tester) async {
      await tester.pumpWidget(const WebimExampleApp());

      await tester.tap(find.text('Демо: Webim.parse(remoteNotification)'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Лог'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Webim.isWebim:'), findsOneWidget);
    });
  });
}
