import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:webim/src/domain/entities/message.dart';
import 'package:webim/src/domain/entities/session.dart';

import 'package:webim/src/data/datasources/api_client.dart';
import 'package:webim/src/data/repositories/faq_repository_impl.dart';
import 'package:webim/src/data/repositories/file_repository_impl.dart';
import 'package:webim/src/data/repositories/message_repository_impl.dart';
import 'package:webim/src/data/repositories/session_repository_impl.dart';
import 'package:webim/src/data/repositories/survey_repository_impl.dart';
import 'package:webim/src/domain/entities/faq_category.dart';
import 'package:webim/src/domain/entities/survey_answer.dart';
import 'package:webim/src/domain/usecases/create_session.dart';
import 'package:webim/src/domain/usecases/destroy_session.dart';
import 'package:webim/src/domain/usecases/fetch_faq.dart';
import 'package:webim/src/domain/usecases/fetch_history.dart';
import 'package:webim/src/domain/usecases/listen_messages.dart';
import 'package:webim/src/domain/usecases/refresh_token.dart';
import 'package:webim/src/domain/usecases/send_message.dart';
import 'package:webim/src/domain/usecases/submit_survey.dart';
import 'package:webim/src/domain/usecases/upload_file.dart';

final GetIt getIt = GetIt.asNewInstance();

class WebimSdk {
  final String baseUrl;
  final String wsBaseUrl;

  WebimSdk({required this.baseUrl, required this.wsBaseUrl}) {
    _registerDependencies();
  }

  void _registerDependencies() {
    getIt.registerLazySingleton<ApiClient>(() => ApiClient(baseUrl: baseUrl));
    getIt.registerLazySingleton<SessionRepositoryImpl>(
      () => SessionRepositoryImpl(getIt<ApiClient>()),
    );
    getIt.registerLazySingleton<MessageRepositoryImpl>(
      () => MessageRepositoryImpl(getIt<ApiClient>(), wsBaseUrl),
    );
    getIt.registerLazySingleton<FileRepositoryImpl>(
      () => FileRepositoryImpl(getIt<ApiClient>()),
    );
    getIt.registerLazySingleton<FAQRepositoryImpl>(
      () => FAQRepositoryImpl(getIt<ApiClient>()),
    );
    getIt.registerLazySingleton<SurveyRepositoryImpl>(
      () => SurveyRepositoryImpl(getIt<ApiClient>()),
    );

    getIt.registerFactory<CreateSession>(
      () => CreateSession(getIt<SessionRepositoryImpl>()),
    );
    getIt.registerFactory<RefreshToken>(
      () => RefreshToken(getIt<SessionRepositoryImpl>()),
    );
    getIt.registerFactory<DestroySession>(
      () => DestroySession(getIt<SessionRepositoryImpl>()),
    );
    getIt.registerFactory<SendMessage>(
      () => SendMessage(getIt<MessageRepositoryImpl>()),
    );
    getIt.registerFactory<FetchHistory>(
      () => FetchHistory(getIt<MessageRepositoryImpl>()),
    );
    getIt.registerFactory<ListenMessages>(
      () => ListenMessages(getIt<MessageRepositoryImpl>()),
    );
    getIt.registerFactory<UploadFile>(
      () => UploadFile(getIt<FileRepositoryImpl>()),
    );
    getIt.registerFactory<FetchFAQ>(() => FetchFAQ(getIt<FAQRepositoryImpl>()));
  }

  Future<Session> createSession({
    required String visitorId,
    required String clientSideId,
  }) => getIt<CreateSession>().call(
    visitorId: visitorId,
    clientSideId: clientSideId,
  );

  Future<Session> refreshToken(String token) =>
      getIt<RefreshToken>().call(token: token);

  Future<void> destroySession(String sessionId) =>
      getIt<DestroySession>().call(sessionId: sessionId);

  Future<Message> sendMessage({
    required String sessionId,
    required String content,
    required String type,
  }) => getIt<SendMessage>().call(
    sessionId: sessionId,
    content: content,
    type: type,
  );

  Future<List<Message>> fetchHistory({
    required String sessionId,
    int? limit,
    DateTime? before,
    DateTime? since,
  }) => getIt<FetchHistory>().call(
    sessionId: sessionId,
    limit: limit,
    before: before,
    since: since,
  );

  Stream<Message> listenMessages(String sessionId) =>
      getIt<ListenMessages>().call(sessionId: sessionId);

  Future<String> uploadFile(File file, {Map<String, String>? metadata}) =>
      getIt<UploadFile>().call(file, metadata: metadata);

  Future<List<FAQCategory>> fetchFAQs() => getIt<FetchFAQ>().call();

  Future<void> submitSurvey({
    required String sessionId,
    required String surveyId,
    required List<SurveyAnswer> answers,
  }) => getIt<SubmitSurvey>().call(
    sessionId: sessionId,
    surveyId: surveyId,
    answers: answers,
  );
}
