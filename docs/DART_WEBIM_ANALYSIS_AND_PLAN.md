# Сравнительный анализ Webim Swift SDK и Dart-плагина. План доработки

## 1. Анализ архитектуры Swift SDK (docs/WebimMobileSDK/)

### 1.1 Точка входа и создание сессии

- **Webim**: `newSessionBuilder()`, `newFAQBuilder()`, `parse(remoteNotification:visitorId:)`, `isWebim(remoteNotification:)`.
- **SessionBuilder**: устанавливает accountName, location, appVersion, pageTitle, deviceToken, requestHeader, prechat, visitorFields / providedAuthorizationToken, localHistoryStoragingEnabled, visitorDataClearingEnabled, baseUrl (не используется напрямую — URL строится через **InternalUtils.createServerURLStringBy(accountName)**), mobileChatInstance, fatalErrorHandler, notFatalErrorHandler, webimLogger, remoteNotificationSystem, multivisitorSection, onlineStatusRequestFrequencyInMillis, webimAlert.
- **Создание сессии (WebimSessionImpl.newInstanceWith)**:
  - Сессия **не создаётся** через отдельный вызов типа POST /session/create.
  - Используется **Keychain** (WMKeychainWrapper): по ключу `ru.webim.WebimClientSDKiOS.visitor.{visitorName}.{mobileChatInstance}` хранятся visitor (JSON string), session_id, page_id, auth_token, history_db_name, read_before_timestamp и др.
  - При первом запуске (нет данных в Keychain) эти поля заполняются **пустыми/nil**; затем строится **WebimClient** с DeltaRequestLoop, у которого sessionID, visitorJSONString, authorizationData изначально nil.
  - При **resume()** запускается DeltaRequestLoop.**run()**: в цикле вызывается **requestInitialization()** (GET **/l/v/m/init** с query: device-id, event=init, location, platform=ios, respond-immediately=true, since=0, title, опционально app-version, push-token, visit-session-id, visitor, visitor-ext, provided_auth_token, prechat).
  - Ответ init содержит **fullUpdate** с полями: **visitSessionId**, **authToken**, **pageId**, visitor, state, chat, departments, hintsEnabled, historyRevision, onlineStatus и др.
  - **SessionParametersListener.onSessionParametersChanged** сохраняет visitSessionId, pageId, authToken, visitor в Keychain.
  - Дальнейшие запросы **delta** и **action** используют уже **AuthorizationData(pageID, authorizationToken)** из fullUpdate.

Итог: в Swift нет эндпоинта «создать сессию»; сессия появляется после первого успешного **GET /l/v/m/init** и сохранения fullUpdate в Keychain. Идентификация запросов — **page-id** и **auth-token** (в query или в body), а не Bearer в заголовке.

### 1.2 URL сервера

- **InternalUtils.createServerURLStringBy(accountName)**:
  - Если в accountName есть `://`, возвращается accountName (без завершающего `/`).
  - Иначе: `"https://\(accountName).webim.ru"` (первый домен из списка domains).
- Базовый URL без суффикса `/api/v1`; пути вида `/l/v/m/init`, `/l/v/m/delta`, `/l/v/m/action` и т.д. добавляются к этому baseURL.

### 1.3 Delta (обновления чата)

- **DeltaRequestLoop**:
  - **run()**: если `authorizationData != nil && since != "0"` — вызывается **requestDelta()**, иначе — **requestAccountConfig()** и **requestInitialization()**.
  - **requestDelta()**: GET **baseURL + "/l/v/m/delta"** с query: **since**, **ts** (текущее время в мс), **page-id**, **auth-token**.
  - Ответ: JSON с полями revision, fullUpdate и/или deltaList. При fullUpdate вызывается **DeltaCallback.process(fullUpdate)**; при deltaList — **process(deltaList)** с разбором по типам (chat, chatMessage, visitSessionState, departmentList, survey, unreadByVisitor и т.д.).
- **SessionParametersListener** при первом init обновляет authorizationData в DeltaRequestLoop и ActionRequestLoop (через SessionParametersListenerWrapper), чтобы следующие delta/action шли уже с page-id и auth-token.

### 1.4 Actions (действия посетителя)

- **WebimActionsImpl** + **ActionRequestLoop**:
  - Все действия — POST (или GET для истории) на **baseURL + "/l/v/m/action"** (или /l/v/m/upload, /l/v/file-delete, /l/v/m/history, /l/v/m/search-messages и т.д.).
  - **createUrlRequest(request, withAuthData: true)** добавляет к телу (или query) запроса поля **page-id** и **auth-token** из **AuthorizationData**.
  - Авторизация — **только в теле/query** (form-urlencoded), не в заголовке Authorization.
  - Примеры: chat.start, chat.close, chat.message, chat.visitor_typing, chat.delete_message, rate_operator, upload file и т.д.

### 1.5 История сообщений

- **getHistory** (WebimActionsImpl): GET **baseURL + "/l/v/m/history"** с query: **since** (или **before-ts**), плюс **page-id** и **auth-token** (добавляются в createUrlRequest).
- Ответ разбирается в HistoryBeforeResponse / HistorySinceResponse; сообщения маппятся через HistoryMessageMapper и складываются в MessageHolder / SQLiteHistoryStorage.

### 1.6 MessageHolder и MessageTracker

- **MessageHolder** хранит текущий чат и историю; получает обновления из DeltaCallback (fullUpdate/deltaList) и из RemoteHistoryProvider (getHistory).
- **MessageTrackerImpl** выдаёт сообщения из MessageHolder (getLastMessages, getNextMessages, getAllMessages, resetTo).

### 1.7 FAQ

- **FAQImpl**: FAQClient с **FAQRequestLoop** (без авторизации сессии).
- Пути (FAQActions.ServerPathSuffix):  
  - категории: **/webim/api/v1/faq/category** (GET, query: application, platform, language, departmentKey);  
  - категория по id: **/services/faq/v1/category** (GET, categoryId, userid);  
  - item: **/services/faq/v1/item** (itemId, userid);  
  - structure: **/services/faq/v1/structure** (categoryId);  
  - search: **/services/faq/v1/search** (categoryId, query, limit);  
  - like/dislike: **/services/faq/v1/like**, **/services/faq/v1/dislike**;  
  - track: **/services/faq/v1/track**.
- BaseURL для FAQ — тот же **createServerURLStringBy(accountName)** (без /api/v1).

### 1.8 Прочее в Swift

- **destroy session**: вызов сервера + очистка Keychain по userDefaultsKey.
- **changeLocation**: в DeltaRequestLoop сбрасываются authorizationData и since, вызывается requestInitialization() с новой location.
- **setDeviceToken**: обновляется в DeltaRequestLoop; при следующем init уйдёт push-token.
- **AccessError**: invalidThread (проверка потока создания сессии), invalidSession (после destroy).
- Локальное хранилище истории: SQLite (SQLiteHistoryStorage) или MemoryHistoryStorage; readBeforeTimestamp, historyRevision, historyEnded в Keychain.

---

## 2. Анализ текущей архитектуры Dart-плагина (lib/)

### 2.1 Точка входа и создание сессии

- **Webim**: newSessionBuilder(), newFAQBuilder(), parse(remoteNotification, visitorId:), isWebim(remoteNotification) — соответствуют Swift.
- **SessionBuilder**: accountName, location, appVersion, pageTitle, deviceToken, requestHeader, prechat, visitorFieldsJsonString / providedAuthorizationToken, isLocalHistoryStoragingEnabled, isVisitorDataClearingEnabled, baseUrl, wsBaseUrl, mobileChatInstance, fatalErrorHandler, notFatalErrorHandler, webimLogger, remoteNotificationSystem, multivisitorSection, onlineStatusRequestFrequencyInMillis, webimAlert.
- **_resolvedBaseUrl**: если baseUrl не задан и accountName не URL — `https://{accountName}.webim.ru/api/v1`; если accountName уже URL — `{accountName}/api/v1`. То есть Dart **всегда** добавляет суффикс **/api/v1** к baseURL.
- **Создание сессии (WebimSessionImpl.build)**:
  - Вызывается **SessionRepositoryImpl.create(visitorId: 'anonymous', clientSideId: generateClientSideID())**.
  - **create()** выполняет **POST /session/create** с телом { visitorId, clientSideId }.
  - Эндпоинт **POST /session/create** в официальном бэкенде Webim **отсутствует**; сервер возвращает 404.
  - Из ответа ожидаются sessionId и token; сущность **Session** содержит только **sessionId** и **token** (и опционально visitorId, clientSideId). Поле **pageId** отсутствует.
  - После create() в ApiClient устанавливается **setAuthorizationToken(session.token)** — дальше все запросы идут с заголовком **Authorization: Bearer {token}**.

Итог: Dart использует «кастомный» сценарий с POST /session/create и Bearer-токеном; это не совпадает с реальным API Webim (init + page-id/auth-token).

### 2.2 Delta

- **MessageRepositoryImpl.getDelta(sessionId, since)**: GET **/history/delta** с query **sessionId**, **since**.
  - В Swift delta — GET **/l/v/m/delta** с query **since**, **ts**, **page-id**, **auth-token** (без sessionId в query).
- В Dart путь и параметры не соответствуют Webim: используется другой контракт (из EndpointDoc), а не /l/v/m/delta.

### 2.3 Actions

- **ActionRepositoryImpl**: POST на **baseUrl + "/l/v/m/action"** через **ApiClient.postForm(fullUrl, body)**.
  - В body передаются только параметры действия (action, client-side-id, message и т.д.).
  - **page-id** и **auth-token** в тело не добавляются**; авторизация за счёт **Bearer token** в заголовке (из setAuthorizationToken).
  - Официальный бэкенд Webim ожидает авторизацию в **теле/query** (page-id, auth-token), а не в заголовке — возможны 401/403 или игнорирование запросов.

### 2.4 История сообщений

- **MessageRepositoryImpl.fetchHistory(sessionId, limit, before, since)**: GET **/message/history** с query sessionId, limit, before, since.
  - В Swift: GET **/l/v/m/history** с query **since** или **before-ts**, плюс **page-id** и **auth-token**.
- Путь и набор параметров в Dart не совпадают с /l/v/m/history.

### 2.5 Отправка сообщений и WebSocket

- **send**: через ActionRepositoryImpl.sendMessage (POST /l/v/m/action с action=chat.message) — логика близка к Swift, но без page-id/auth-token в body.
- **listen** (стрим сообщений): WebSocket на `wsBaseUrl/message/stream?sessionId=...`. В Swift реальный стрим может быть реализован через периодический delta; необходимо уточнить по документации/коду, используется ли в Swift тот же URL стрима.

### 2.6 MessageTracker

- **MessageTrackerImpl**: getLastMessages / getNextMessages / getAllMessages вызывают **MessageRepositoryImpl.fetchHistory** с sessionId и limit/before. Локального хранилища (SQLite) нет — только сетевые запросы. Соответственно, нет аналога readBeforeTimestamp/historyRevision в постоянном хранилище.

### 2.7 FAQ

- **FAQRepositoryImpl**: baseUrl в формате `https://{accountName}.webim.ru/api/v1`.
  - **getRootCategories / fetchAll**: GET **/faq/list** с опциональными query (departmentId, categoryId или app, lang, department-key).
  - **fetchById** (категория): GET **/faq/category** с query id.
  - В Swift корневые категории: GET **/webim/api/v1/faq/category** (полный путь от корня домена, т.е. baseURL без /api/v1 + /webim/api/v1/faq/category); item/category/structure/search — **/services/faq/v1/...**.
- В Dart пути упрощены до /faq/list и /faq/category относительно baseUrl = .../api/v1, что даёт другие полные URL и формат запросов по сравнению со Swift.

### 2.8 Session destroy, changeLocation, setDeviceToken

- **destroy**: DELETE /session/delete (без параметров в текущей реализации; в Swift вызывается отдельный механизм + очистка Keychain).
- **changeLocation**: заглушка (TODO).
- **setDeviceToken**: заглушка (TODO).

---

## 3. Сводная таблица различий логики

| Аспект | Swift SDK | Dart плагин | Различие |
|--------|-----------|-------------|----------|
| Создание сессии | Нет POST create. Данные из Keychain; первый запрос — GET /l/v/m/init; из fullUpdate берутся visitSessionId, authToken, pageId, visitor и сохраняются. | POST /session/create (visitorId, clientSideId). Эндпоинт на бэкенде Webim отсутствует → 404. | Критическое: другой протокол и эндпоинты. |
| Идентификация запросов | page-id + auth-token в query или body (form). | Bearer token в заголовке Authorization; pageId не используется. | Критическое: бэкенд ожидает page-id/auth-token. |
| Сущность «сессия» | Фактически: sessionId (visitSessionId), pageId, authToken, visitor (из fullUpdate + Keychain). | Session: только sessionId и token. pageId нет. | Нет pageId в Dart. |
| Delta | GET /l/v/m/delta?since=&ts=&page-id=&auth-token=. | GET /history/delta?sessionId=&since=. | Разные путь и параметры. |
| History | GET /l/v/m/history?since= или before-ts= + page-id, auth-token. | GET /message/history?sessionId=, limit, before, since. | Разные путь и параметры. |
| Actions | POST /l/v/m/action (form) с полями action, ... и обязательно page-id, auth-token. | POST /l/v/m/action (form) с полями action, ...; авторизация только через Bearer. | В Dart в body не передаются page-id, auth-token. |
| Base URL | createServerURLStringBy(accountName) → без /api/v1 (например https://demo.webim.ru). Пути полные: /l/v/m/init, /l/v/m/delta. | baseUrl = .../api/v1; пути относительно него (например /history/delta). | Разная база и способ сборки URL. |
| Персистентность | Keychain: visitor, session_id, page_id, auth_token, history DB, readBeforeTimestamp и др. | Нет персистентности; сессия живёт только в памяти. | Нет восстановления сессии после перезапуска. |
| FAQ base/paths | baseURL без /api/v1; /webim/api/v1/faq/category, /services/faq/v1/... | baseUrl = .../api/v1; /faq/list, /faq/category. | Разные пути и, возможно, формат ответов. |
| changeLocation | Сброс authorizationData и since; повтор requestInitialization() с новой location. | Не реализовано (TODO). | Требуется доработка. |
| setDeviceToken | Обновление в DeltaRequestLoop; при следующем init уходит push-token. | Не реализовано (TODO). | Требуется доработка. |
| Destroy session | Вызов сервера + очистка Keychain. | DELETE /session/delete без тела. | Нужно уточнить реальный эндпоинт destroy в Webim и при необходимости — очистку локальных данных. |

---

## 4. План доработки Dart-плагина (приведение логики к Swift/Webim)

### Фаза 1: Сессия и авторизация (критично для работы с demo.webim.ru)

1. **Инициализация через GET /l/v/m/init (вместо POST /session/create)**  
   - Добавить в **SessionRepository** метод создания сессии через init (например `createViaInit`) с параметрами: location, deviceId, pageTitle, appVersion, deviceToken, prechat, visitorFieldsJsonString, providedAuthorizationToken, при необходимости visitSessionId и visitorJsonString (для повторного init при смене location или восстановлении).  
   - Реализация: GET `{baseUrl}/l/v/m/init` с query-параметрами по Swift (device-id, event=init, location, platform=web, respond-immediately=true, since=0, title, и опциональные).  
   - Заголовок: `x-webim-sdk-version` (как в Swift).  
   - Парсить ответ: при наличии поля `error` — выброс исключения; иначе из `fullUpdate` извлечь **visitSessionId**, **authToken**, **pageId**.

2. **Расширить сущность Session и использование pageId/token**  
   - В **Session** (или отдельный DTO после init) хранить: **sessionId** (visitSessionId), **token** (authToken), **pageId**.  
   - После успешного init передавать в ApiClient не только token, но и возможность подставлять **page-id** и **auth-token** в запросы (см. ниже).  
   - В **WebimSessionImpl.build()** вызывать новый метод init вместо create(); сохранять pageId в сессии/контексте, доступном репозиториям.

3. **Единый baseURL без обязательного /api/v1 для «action»-запросов**  
   - В Swift baseURL = `https://demo.webim.ru`; пути типа `/l/v/m/init`, `/l/v/m/action` — полные.  
   - В Dart либо задать **actionBaseUrl** без суффикса /api/v1 (например `https://demo.webim.ru`), либо явно формировать полные пути к /l/v/m/init, /l/v/m/delta, /l/v/m/action.  
   - Убедиться, что init и delta вызываются к одному и тому же «корню» (как в Swift), а не к .../api/v1/...

### Фаза 2: Delta и история (протокол Webim)

4. **Delta: путь и параметры**  
   - Заменить вызов GET /history/delta на GET **/l/v/m/delta** с query: **since**, **ts** (текущее время в мс), **page-id**, **auth-token**.  
   - Репозиторий (или отдельный DeltaClient) должен принимать pageId и token (из Session/контекста), а не только sessionId.  
   - Парсинг ответа оставить совместимым с текущим (revision, fullUpdate, deltaList); при необходимости привести имена полей к формату ответа Webim (как в DeltaResponse/FullUpdate в Swift).

5. **История сообщений**  
   - Заменить GET /message/history на GET **/l/v/m/history** с query: **since** (или **before-ts**), **page-id**, **auth-token**.  
   - Привести формат ответа к структуре, ожидаемой в Swift (HistorySinceResponse / HistoryBeforeResponse), и маппинг в **Message** — к полям сервера (ts_m, clientSideId, id и т.д.), чтобы MessageTracker и UI работали с теми же данными.

### Фаза 3: Actions (page-id и auth-token в теле)

6. **Авторизация в action-запросах**  
   - Для всех POST к /l/v/m/action (и при необходимости к upload, file-delete, search и т.д.) добавлять в **тело** (form-urlencoded) поля **page-id** и **auth-token** из текущей Session.  
   - Убрать зависимость действий от заголовка Authorization: Bearer (для этих эндпоинтов), либо оставить Bearer только для тех бэкендов, которые его явно поддерживают (если будет режим «custom backend»).  
   - **ActionRepositoryImpl** должен получать pageId и token (из WebimSessionImpl или ApiClient, настроенного на сессию) и подставлять их в каждый postForm.

7. **Проверка остальных action-эндпоинтов**  
   - Upload: /l/v/m/upload — в форме или query также передать page-id и auth-token, если так делает Swift.  
   - File delete: /l/v/file-delete — аналогично.  
   - Search: /l/v/m/search-messages — параметры и авторизация по образцу Swift.

### Фаза 4: Персистентность (опционально, по приоритету)

8. **Хранение сессии и visitor**  
   - Ввести абстракцию хранилища (аналог Keychain): например, flutter_secure_storage или shared_preferences для хранения после успешного init: visitSessionId, pageId, authToken, visitor (JSON string), mobileChatInstance.  
   - При следующем build() сессии: если в хранилище есть данные для данного accountName/location/mobileChatInstance — передавать visitSessionId и visitorJsonString в createViaInit для «восстановления» сессии вместо создания новой.  
   - Учитывать visitorDataClearingEnabled и смену accountName (очистка хранилища по аналогии со Swift).

9. **История (локальное кэширование)**  
   - По желанию: аналог SQLiteHistoryStorage / MemoryHistoryStorage (например, SQLite или только in-memory) для хранения прочитанной истории и readBeforeTimestamp, чтобы MessageTracker мог работать офлайн и быстрее. Это можно вынести во вторую очередь после стабилизации онлайн-сценария.

### Фаза 5: FAQ, destroy, changeLocation, setDeviceToken

10. **FAQ: base URL и пути**  
    - Привести baseURL FAQ к виду без /api/v1 (как в Swift), либо явно использовать пути Swift:  
      - список категорий: **/webim/api/v1/faq/category** с query application, platform, language, departmentKey;  
      - категория по id: **/services/faq/v1/category** (categoryId, userid);  
      - item: **/services/faq/v1/item**; structure: **/services/faq/v1/structure**; search: **/services/faq/v1/search**; like/dislike/track — соответствующие пути.  
    - Проверить форматы ответов (JSON) и маппинг в FAQCategory, FAQItem, FAQSearchItem, FAQStructure.

11. **Destroy session**  
    - Уточнить по документации/поведению Webim, есть ли отдельный вызов «удалить сессию» (например, действие или отдельный URL). Реализовать вызов при destroy(). При наличии персистентности (п. 8) — очищать локальное хранилище для данной сессии.

12. **changeLocation**  
    - Реализовать: сброс текущих authorizationData (pageId/token в памяти), вызов createViaInit с новой location (без visitSessionId/visitor при желании «новой» сессии в новой локации, или с ними — по логике Swift). После успешного init обновить Session и продолжить delta/actions с новыми page-id/auth-token.

13. **setDeviceToken**  
    - Сохранять deviceToken в контексте сессии; при следующем init (или при отдельном запросе, если такой есть в Webim) передавать push-token в параметрах init. Реализовать по аналогии с Swift (обновление в «DeltaRequestLoop» и передача в getInitializationParameterString).

### Фаза 6: Совпадение с Swift по контрактам и ошибкам

14. **Обработка ошибок init/delta**  
    - Обрабатывать ошибки из ответа init/delta (поле `error`): reinitializationRequired, providedAuthenticationTokenNotFound и т.д. — по списку WebimInternalError в Swift; при необходимости повтор init с задержкой или вызов listener для обновления providedAuthorizationToken.

15. **AccessError и поток**  
    - В Swift проверяется поток создания сессии (invalidThread). В Dart при необходимости ввести проверку (например, сохранение zone/isolate или явное указание в документации, что вызовы с одного и того же контекста). invalidSession — при уже вызванном destroy() — сохранить.

16. **Верификация по Swift**  
    - После каждой фазы сверять с протоколами и путями в docs/WebimMobileSDK/ (DeltaRequestLoop, WebimActionsImpl, FAQActions, InternalUtils.createServerURLStringBy и т.д.), а также запускать dart analyze и тесты.

---

## 6. Статус выполнения (обновлено)

- **Фазы 1–3**: выполнены (init, delta/history, actions с page-id/auth-token).
- **Legacy**: убраны create(visitorId, clientSideId), refresh(); только init.
- **Фаза 5**: FAQ пути, destroy без HTTP, changeLocation, setDeviceToken.
- **Фаза 6**: обработка ошибок init/delta (reinitializationRequired, internalError в WebimApiException), AccessError документирован, пути верифицированы.
- **Фаза 4.8**: персистентность сессии: абстракция SessionStorage, StoredSessionData, save/load после init, восстановление по visitSessionId/visitorJsonString, очистка при destroy(); MemorySessionStorage для тестов; п. 4.9 (локальная история) оставлен на вторую очередь.

---

## 5. Порядок выполнения (рекомендуемый)

1. **Фаза 1** (п. 1–3) — без неё работа с реальным Webim-сервером невозможна.  
2. **Фаза 2** (п. 4–5) — чтобы после init получать актуальное состояние чата и историю.  
3. **Фаза 3** (п. 6–7) — чтобы отправка сообщений и остальные действия проходили.  
4. **Фаза 5** (п. 10–13) — FAQ, destroy, changeLocation, setDeviceToken по мере необходимости.  
5. **Фаза 4** (п. 8–9) — персистентность и локальная история после стабилизации онлайн-потока.  
6. **Фаза 6** (п. 14–16) — доводка ошибок и соответствия Swift.

Документацию (README, пример, комментарии в коде) обновлять по мере внедрения фаз; после Фазы 1–3 в example можно указать, что плагин ориентирован на протокол Webim (init + page-id/auth-token) и при необходимости поддерживает кастомный бэкенд с POST /session/create и Bearer.
