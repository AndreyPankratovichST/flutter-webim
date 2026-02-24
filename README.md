<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# flutter-webim

Dart/Flutter клиент для [Webim](https://webim.ru/): чат, база знаний (FAQ), push-уведомления. Протокол совместим с официальным бэкендом Webim (инициализация через GET `/l/v/m/init`, авторизация через `page-id` и `auth-token` в запросах).

## Features

- **Сессия чата**: создание через GET `/l/v/m/init` (без POST `/session/create`), delta-обновления и история через `/l/v/m/delta` и `/l/v/m/history`, действия (отправка сообщений, старт чата и т.д.) через POST `/l/v/m/action` с `page-id` и `auth-token`.
- **Персистентность**: абстракция `SessionStorage` для сохранения сессии после перезапуска; реализация по умолчанию на Drift (SQLite) с возможностью задать путь через `SessionBuilder.setStoragePath()`; при смене аккаунта с `isVisitorDataClearingEnabled` выполняется очистка хранилища.
- **FAQ**: корневые категории, категория по id, пункты, структура, поиск, like/dislike (пути и контракты по образцу Swift SDK).
- **Жизненный цикл**: `pause()` / `resume()`, `destroy()` (в т.ч. с очисткой visitor data), `changeLocation()`, `setDeviceToken()` для push.
- **Ошибки**: обработка ответов init/delta (например `reinitializationRequired`), `AccessError`, `WebimApiException`.

## Getting started

Добавьте зависимость в `pubspec.yaml`:

```yaml
dependencies:
  webim:
    path: ../path/to/flutter-webim  # или версия с pub.dev
```

Импортируйте пакет:

```dart
import 'package:webim/webim.dart';
```

## Usage

### Session and chat

Сессия создаётся через `Webim.newSessionBuilder()`, затем `build()` и `resume()`. Плагин использует протокол Webim: первый запрос — GET `/l/v/m/init`; из ответа берутся `visitSessionId`, `pageId`, `authToken`; дальнейшие запросы delta и action идут с `page-id` и `auth-token`. Указывайте `accountName` (например `demo` для demo.webim.ru) и при необходимости `setBaseUrl()` для кастомного сервера.

По умолчанию используется встроенное хранилище сессии (Drift) с путём `webim_sessions.db`. **На iOS и Android** относительный путь часто недоступен для записи — задайте полный путь, например через `path_provider`: `setStoragePath('${(await getApplicationDocumentsDirectory()).path}/webim_sessions.db')`. Чтобы отключить сохранение, используйте `setLocalHistoryStoragingEnabled(false)`. При смене аккаунта и включённом `setVisitorDataClearingEnabled(true)` хранилище для предыдущего аккаунта очищается.

```dart
final builder = Webim.newSessionBuilder()
  ..setAccountName('demo')
  ..setLocation('mobile')
  ..setWebimLogger((m) => print('SDK: $m'));

// Опционально: путь к БД сессий (по умолчанию 'webim_sessions.db')
// builder.setStoragePath('/path/to/sessions.db');

final session = await builder.build(); // создаётся в паузе
session.resume();

final stream = session.getStream();
await stream.startChat();
final messageId = await stream.send('Hello');
final tracker = stream.newMessageTracker(myMessageListener);
```

### FAQ (knowledge base)

FAQ работает без чат-сессии. Вызовите `resume()` перед запросами категорий и пунктов:

```dart
final faq = Webim.newFAQBuilder()
  .setAccountName('demo')
  .build();
faq.resume();

final categories = await faq.getRootCategories();
final category = await faq.getCategory('category-id');
final item = await faq.getItem('item-id');
```

Для кастомной реализации персистентности реализуйте интерфейс `SessionStorage`; ключ последнего аккаунта для логики смены аккаунта — константа `kLastAccountStorageKey` (экспортируется из пакета вместе с `SessionStorage`).

## Additional information

- Полный разбор API и сравнение с Swift SDK: `docs/DART_WEBIM_ANALYSIS_AND_PLAN.md`.
- Документация эндпоинтов: `docs/EndpointDoc.md`, `docs/WebimMobileSDK/`.
- Некоторые функции (стикеры, опросы, статус виджета) требуют поддержки на стороне сервера.
