import 'package:flutter/material.dart';
import 'package:webim/webim.dart';

void main() {
  runApp(const WebimExampleApp());
}

class WebimExampleApp extends StatelessWidget {
  const WebimExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Webim Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const _HomeScreen(),
    );
  }
}

class _HomeScreen extends StatefulWidget {
  const _HomeScreen();

  @override
  State<_HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<_HomeScreen> {
  final _accountNameController = TextEditingController(text: 'demo');
  final _locationController = TextEditingController(text: 'mobile');
  final _messageController = TextEditingController();
  final _faqAccountController = TextEditingController(text: 'demo');
  final _faqSearchController = TextEditingController();
  final _logController = ScrollController();

  WebimSession? _session;
  MessageStream? _stream;
  MessageTracker? _tracker;
  FAQ? _faq;

  final List<Message> _messages = [];
  final List<String> _logLines = [];
  String _visitState = '—';
  String _chatState = '—';
  String _operatorName = '—';
  List<FAQCategory> _faqCategories = [];
  List<FAQSearchItem> _faqSearchResults = [];
  bool _loading = false;
  bool _faqLoading = false;

  @override
  void dispose() {
    _accountNameController.dispose();
    _locationController.dispose();
    _messageController.dispose();
    _faqAccountController.dispose();
    _faqSearchController.dispose();
    _logController.dispose();
    _session?.destroy();
    _faq?.destroy();
    super.dispose();
  }

  void _log(String msg) {
    setState(() {
      _logLines.insert(0, '${DateTime.now().toString().substring(11, 19)} $msg');
      if (_logLines.length > 100) _logLines.removeLast();
    });
  }

  /// Создаёт сессию по протоколу Webim: GET /l/v/m/init, затем delta/action с page-id и auth-token.
  /// По умолчанию сессия сохраняется в Drift (webim_sessions.db). Путь можно задать через setStoragePath().
  Future<void> _createAndResumeSession() async {
    final accountName = _accountNameController.text.trim();
    final location = _locationController.text.trim();
    if (accountName.isEmpty || location.isEmpty) {
      _log('Укажите account name и location');
      return;
    }
    setState(() => _loading = true);
    try {
      final builder = Webim.newSessionBuilder()
        ..setAccountName(accountName)
        ..setLocation(location)
        ..setWebimLogger((m) => _log('SDK: $m'))
        ..setFatalErrorHandler((e) => _log('Fatal: $e'))
        ..setNotFatalErrorHandler((e) => _log('NotFatal: $e'));

      final session = await builder.build();
      final stream = session.getStream();

      stream.setVisitSessionStateListener(_VisitStateListenerImpl(
        onState: (s) => setState(() => _visitState = s.toString()),
      ));
      stream.setChatStateListener(_ChatStateListenerImpl(
        onState: (s) => setState(() => _chatState = s.toString()),
      ));
      stream.setCurrentOperatorChangeListener(_CurrentOperatorListenerImpl(
        onOperator: (op) => setState(() => _operatorName = op?.name ?? '—'),
      ));

      _session?.destroy();
      _session = session;
      _stream = stream;
      _tracker = stream.newMessageTracker(_ExampleMessageListener(
        onMessagesChanged: () => setState(() {}),
        messages: _messages,
      ));
      _messages.clear();

      session.resume();
      setState(() {
        _visitState = stream.getVisitSessionState().toString();
        _chatState = stream.getChatState().toString();
        _operatorName = stream.getCurrentOperator()?.name ?? '—';
      });

      _tracker!.getLastMessages(50, (list) {
        if (mounted) {
          setState(() => _messages
            ..clear()
            ..addAll(list));
        }
      });

      _log('Сессия создана и возобновлена');
    } on SessionBuilderError catch (e) {
      _log('SessionBuilderError: $e');
    } on WebimApiException catch (e) {
      _log('Сервер вернул ошибку: HTTP ${e.statusCode ?? "?"} — ${e.message}');
    } catch (e, st) {
      _log('Ошибка: $e');
      debugPrintStack(stackTrace: st);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _pauseSession() {
    _session?.pause();
    _log('Сессия приостановлена');
    setState(() {});
  }

  void _resumeSession() {
    _session?.resume();
    _log('Сессия возобновлена');
    setState(() {});
  }

  void _destroySession() {
    _session?.destroy();
    _session = null;
    _stream = null;
    _tracker = null;
    _messages.clear();
    setState(() {
      _visitState = '—';
      _chatState = '—';
      _operatorName = '—';
    });
    _log('Сессия завершена');
  }

  Future<void> _startChat() async {
    final stream = _stream;
    if (stream == null) return;
    try {
      stream.startChat(forceStart: true);
      _log('startChat() вызван');
      setState(() => _chatState = stream.getChatState().toString());
    } catch (e) {
      _log('startChat error: $e');
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _stream == null) return;
    _messageController.clear();
    try {
      final id = await _stream!.send(text);
      _log('Сообщение отправлено: $id');
      _tracker?.getLastMessages(50, (list) {
        if (mounted) {
          setState(() {
            _messages
              ..clear()
              ..addAll(list);
          });
        }
      });
    } on WebimApiException catch (e) {
      _log('WebimApiException: ${e.message}');
    } catch (e) {
      _log('Ошибка отправки: $e');
    }
    setState(() {});
  }

  Future<void> _loadFaq() async {
    final accountName = _faqAccountController.text.trim();
    if (accountName.isEmpty) {
      _log('FAQ: укажите account name');
      return;
    }
    setState(() => _faqLoading = true);
    try {
      _faq?.destroy();
      final faq = Webim.newFAQBuilder()
        ..setAccountName(accountName);
      final built = faq.build();
      _faq = built;
      built.resume();
      final categories = await built.getRootCategories();
      if (mounted) {
        setState(() {
          _faqCategories = categories;
          _faqLoading = false;
        });
        _log('FAQ: загружено категорий: ${categories.length}');
      }
    } on FAQBuilderError catch (e) {
      _log('FAQBuilderError: $e');
      if (mounted) setState(() => _faqLoading = false);
    } catch (e) {
      _log('FAQ error: $e');
      if (mounted) setState(() => _faqLoading = false);
    }
  }

  Future<void> _searchFaq() async {
    final query = _faqSearchController.text.trim();
    if (query.isEmpty || _faq == null) return;
    setState(() => _faqLoading = true);
    try {
      final results = await _faq!.search(query, limitOfItems: 20);
      if (mounted) {
        setState(() {
          _faqSearchResults = results;
          _faqLoading = false;
        });
        _log('FAQ search: найдено ${results.length}');
      }
    } catch (e) {
      _log('FAQ search error: $e');
      if (mounted) setState(() => _faqLoading = false);
    }
  }

  void _demoParseNotification() {
    final userInfo = <String, dynamic>{
      'webim': true,
      'type': 'operator_message',
      'params': ['chat_id', 'visitor_id'],
    };
    final isWebim = Webim.isWebim(userInfo);
    final parsed = Webim.parse(userInfo, visitorId: 'visitor_id');
    _log('Webim.isWebim: $isWebim, parse: ${parsed != null}');
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Webim Example'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Чат', icon: Icon(Icons.chat)),
              Tab(text: 'FAQ', icon: Icon(Icons.help_outline)),
              Tab(text: 'Лог', icon: Icon(Icons.list)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildChatTab(),
            _buildFaqTab(),
            _buildLogTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildChatTab() {
    final hasSession = _session != null;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Подключение', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _accountNameController,
            decoration: const InputDecoration(
              labelText: 'Account name',
              border: OutlineInputBorder(),
            ),
            enabled: !hasSession,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _locationController,
            decoration: const InputDecoration(
              labelText: 'Location',
              border: OutlineInputBorder(),
            ),
            enabled: !hasSession,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (!hasSession)
                FilledButton(
                  onPressed: _loading ? null : _createAndResumeSession,
                  child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Создать сессию'),
                )
              else ...[
                FilledButton.tonal(onPressed: _resumeSession, child: const Text('Resume')),
                FilledButton.tonal(onPressed: _pauseSession, child: const Text('Pause')),
                OutlinedButton(onPressed: _destroySession, child: const Text('Destroy')),
              ],
            ],
          ),
          const SizedBox(height: 16),
          const Text('Состояние', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('VisitSessionState: $_visitState'),
          Text('ChatState: $_chatState'),
          Text('Оператор: $_operatorName'),
          if (hasSession && _stream != null) ...[
            const SizedBox(height: 8),
            OutlinedButton(onPressed: _startChat, child: const Text('Начать чат (forceStart)')),
          ],
          const SizedBox(height: 16),
          const Text('Сообщения', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (hasSession && _tracker != null)
            OutlinedButton(
              onPressed: () {
                _tracker!.getLastMessages(50, (list) {
                  if (mounted) {
                    setState(() {
                      _messages
                        ..clear()
                        ..addAll(list);
                    });
                  }
                });
              },
              child: const Text('Обновить историю'),
            ),
          const SizedBox(height: 8),
          ..._messages.map((m) => ListTile(
            title: Text(m.senderName.isNotEmpty ? m.senderName : 'ID: ${m.id}'),
            subtitle: Text(m.text.isEmpty ? '(нет текста)' : m.text),
            trailing: Text(m.sendStatus.toString().split('.').last),
          )),
          const SizedBox(height: 16),
          if (hasSession) ...[
            const Text('Отправить сообщение', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Текст сообщения',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(onPressed: _sendMessage, child: const Text('Отправить')),
              ],
            ),
          ],
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: _demoParseNotification,
            child: const Text('Демо: Webim.parse(remoteNotification)'),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('FAQ (база знаний)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _faqAccountController,
            decoration: const InputDecoration(
              labelText: 'Account name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _faqLoading ? null : _loadFaq,
            child: _faqLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Загрузить FAQ'),
          ),
          const SizedBox(height: 16),
          const Text('Корневые категории', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          ..._faqCategories.map((c) => ListTile(
            title: Text(c.title),
            subtitle: Text('id: ${c.id}'),
          )),
          const SizedBox(height: 16),
          const Text('Поиск по FAQ', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _faqSearchController,
                  decoration: const InputDecoration(
                    hintText: 'Запрос',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _searchFaq(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(onPressed: _faq == null ? null : _searchFaq, child: const Text('Искать')),
            ],
          ),
          const SizedBox(height: 8),
          ..._faqSearchResults.map((r) => ListTile(
            title: Text(r.title),
            subtitle: Text(r.id),
          )),
        ],
      ),
    );
  }

  Widget _buildLogTab() {
    return ListView.builder(
      controller: _logController,
      padding: const EdgeInsets.all(8),
      itemCount: _logLines.length,
      itemBuilder: (context, i) => SelectableText(_logLines[i], style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
    );
  }
}

class _ExampleMessageListener implements MessageListener {
  _ExampleMessageListener({
    required this.onMessagesChanged,
    required this.messages,
  });

  final VoidCallback onMessagesChanged;
  final List<Message> messages;

  @override
  void added(Message newMessage, [Message? after]) {
    if (messages.any((m) => m.id == newMessage.id)) return;
    final insertIndex = after == null
        ? 0
        : () {
            final idx = messages.indexWhere((m) => m.id == after.id);
            return idx < 0 ? messages.length : idx + 1;
          }();
    messages.insert(insertIndex.clamp(0, messages.length), newMessage);
    onMessagesChanged();
  }

  @override
  void removed(Message message) {
    messages.removeWhere((m) => m.id == message.id);
    onMessagesChanged();
  }

  @override
  void removedAllMessages() {
    messages.clear();
    onMessagesChanged();
  }

  @override
  void changed(Message oldVersion, Message newVersion) {
    final i = messages.indexWhere((m) => m.id == oldVersion.id);
    if (i >= 0) {
      messages[i] = newVersion;
      onMessagesChanged();
    }
  }
}

class _VisitStateListenerImpl implements VisitSessionStateListener {
  _VisitStateListenerImpl({required this.onState});
  final void Function(VisitSessionState state) onState;

  @override
  void changed(VisitSessionState previous, VisitSessionState newState) => onState(newState);
}

class _ChatStateListenerImpl implements ChatStateListener {
  _ChatStateListenerImpl({required this.onState});
  final void Function(ChatState state) onState;

  @override
  void changed(ChatState previous, ChatState newState) => onState(newState);
}

class _CurrentOperatorListenerImpl implements CurrentOperatorChangeListener {
  _CurrentOperatorListenerImpl({required this.onOperator});
  final void Function(Operator? operator) onOperator;

  @override
  void changed(Operator? previousOperator, Operator? newOperator) => onOperator(newOperator);
}
