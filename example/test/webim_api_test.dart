import 'package:flutter_test/flutter_test.dart';
import 'package:webim/webim.dart';

void main() {
  group('Webim.isWebim', () {
    test('возвращает false для пустой карты', () {
      expect(Webim.isWebim({}), false);
    });

    test('возвращает false если webim не true', () {
      expect(Webim.isWebim({'webim': false}), false);
      expect(Webim.isWebim({'webim': 1}), false);
      expect(Webim.isWebim({'webim': 'true'}), false);
    });

    test('возвращает true если webim: true', () {
      expect(Webim.isWebim({'webim': true}), true);
      expect(Webim.isWebim({'webim': true, 'other': 1}), true);
    });
  });

  group('Webim.parse', () {
    test('возвращает null для пустой карты', () {
      expect(Webim.parse({}), isNull);
    });

    test('возвращает null при отсутствии aps.alert', () {
      expect(Webim.parse({'webim': true}), isNull);
      expect(Webim.parse({'webim': true, 'aps': {}}), isNull);
      expect(Webim.parse({'webim': true, 'aps': {'alert': 'not map'}}), isNull);
    });

    test('возвращает уведомление при валидном userInfo без visitorId', () {
      final userInfo = {
        'webim': true,
        'aps': {
          'alert': {
            'loc-key': 'P.OM',
            'event': 'add',
            'loc-args': ['chatId', 'msgId'],
          },
        },
      };
      final result = Webim.parse(userInfo);
      expect(result, isNotNull);
      expect(result!.type, NotificationType.operatorMessage);
      expect(result.parameters, ['chatId', 'msgId']);
    });

    test('с visitorId: возвращает уведомление если parameters содержат visitorId', () {
      final userInfo = {
        'webim': true,
        'aps': {
          'alert': {
            'loc-key': 'P.OM',
            'event': 'add',
            'loc-args': ['chatId', 'msgId', 'my_visitor_id'],
          },
        },
      };
      final result = Webim.parse(userInfo, visitorId: 'my_visitor_id');
      expect(result, isNotNull);
      expect(result!.type, NotificationType.operatorMessage);
      expect(result.parameters[2], 'my_visitor_id');
    });

    test('с visitorId: возвращает null если visitorId не совпадает', () {
      final userInfo = {
        'webim': true,
        'aps': {
          'alert': {
            'loc-key': 'P.OM',
            'event': 'add',
            'loc-args': ['chatId', 'msgId', 'other_visitor'],
          },
        },
      };
      final result = Webim.parse(userInfo, visitorId: 'my_visitor_id');
      expect(result, isNull);
    });

    test('парсит тип operatorAccepted (index 1)', () {
      final userInfo = {
        'webim': true,
        'aps': {
          'alert': {
            'loc-key': 'P.OA',
            'event': 'add',
            'loc-args': ['chatId', 'my_visitor_id'],
          },
        },
      };
      final result = Webim.parse(userInfo, visitorId: 'my_visitor_id');
      expect(result, isNotNull);
      expect(result!.type, NotificationType.operatorAccepted);
      expect(result.parameters[1], 'my_visitor_id');
    });
  });
}
