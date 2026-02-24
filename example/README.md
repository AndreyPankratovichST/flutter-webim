# Webim Example

Пример приложения, демонстрирующий работу с пакетом `webim` (Webim SDK для Flutter).

## Подключение пакета

Пакет подключён локально в `pubspec.yaml`:

```yaml
dependencies:
  webim:
    path: ../
```

Запуск из корня репозитория: `cd example && flutter run`.

## Функционал примера

- **Чат**
  - Создание сессии: `Webim.newSessionBuilder()` → `setAccountName`, `setLocation` → `build()` → `resume()`.
  - Состояние: VisitSessionState, ChatState, текущий оператор (слушатели и отображение).
  - Жизненный цикл: pause / resume / destroy.
  - Сообщения: `MessageStream.newMessageTracker(MessageListener)` → `getLastMessages`, отображение списка.
  - Отправка текста: `stream.send(text)`.
  - Начать чат: `stream.startChat(forceStart: true)`.
- **FAQ**
  - Создание FAQ: `Webim.newFAQBuilder()` → `setAccountName` → `build()` → `resume()`.
  - Корневые категории: `getRootCategories()`.
  - Поиск: `search(query, limitOfItems: 20)`.
- **Лог**
  - Лог событий SDK (logger, error handlers) и действий приложения.
- **Прочее**
  - Демо разбора push: `Webim.isWebim(userInfo)`, `Webim.parse(userInfo, visitorId: ...)`.

## Настройка

По умолчанию подставлены `account name: demo` и `location: mobile`. SDK создаёт сессию через **GET /l/v/m/init** (как в Swift) и работает с официальным стендом Webim (например, demo.webim.ru). При ошибках смотрите вкладку «Лог».
