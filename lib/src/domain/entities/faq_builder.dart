import 'package:webim/src/domain/entities/faq.dart';
import 'package:webim/src/domain/entities/faq_builder_error.dart';
import 'package:webim/src/presentation/faq_impl.dart';

/// Builder for FAQ. See Webim.swift FAQBuilder. accountName required.
class FAQBuilder {
  String? _accountName;
  String? _application;
  String? _departmentKey;
  String? _language;
  String? _baseUrl;

  FAQBuilder setAccountName(String accountName) {
    _accountName = accountName;
    return this;
  }

  FAQBuilder setApplication(String application) {
    _application = application;
    return this;
  }

  FAQBuilder setDepartmentKey(String departmentKey) {
    _departmentKey = departmentKey;
    return this;
  }

  FAQBuilder setLanguage(String language) {
    _language = language;
    return this;
  }

  /// Optional. If not set, derived as https://{accountName}.webim.ru (root, no /api/v1).
  FAQBuilder setBaseUrl(String baseUrl) {
    _baseUrl = baseUrl;
    return this;
  }

  /// Root base URL for FAQ (aligned with Swift: createServerURLStringBy, no /api/v1).
  String get _resolvedBaseUrl {
    if (_baseUrl != null && _baseUrl!.isNotEmpty) return _baseUrl!;
    final a = _accountName?.trim() ?? '';
    if (a.contains('://')) return a;
    return 'https://$a.webim.ru';
  }

  /// Builds FAQ. Throws FAQBuilderError.nilAccountName if accountName is empty.
  FAQ build() {
    final name = _accountName?.trim();
    if (name == null || name.isEmpty) {
      throw FAQBuilderError.nilAccountName;
    }
    return FAQImpl(
      baseUrl: _resolvedBaseUrl,
      application: _application,
      departmentKey: _departmentKey,
      language: _language,
    );
  }
}
