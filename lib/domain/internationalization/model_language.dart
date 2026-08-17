part of '../../jocaagura_domain.dart';

/// Creates a language configuration.
///
/// [languageCode] must not be empty and should use a valid language code
/// such as `es`, `en`, or `pt`.
///
/// [scriptCode] optionally identifies the writing system, such as `Hans`
/// or `Hant`.
///
/// [regionCode] optionally identifies a region, such as `CO`, `US`,
/// or `BR`.
///
/// Usage recommendation:
///
/// Prefer [fromJson] when creating a language from external or untrusted data,
/// because it normalizes the input and falls back to [undeterminedCode] when
/// `languageCode` is missing or empty.
///
/// When using this constructor directly, provide a non-empty [languageCode].
/// The constructor uses an assertion to detect empty values during development,
/// but assertions are not guaranteed to run in production builds.
///
/// Use [undetermined] explicitly when no language can be determined.
/// Example:
///
/// ```dart
/// const ModelLanguage language = ModelLanguage.spanishColombia;
///
/// const ModelLanguage equivalent = ModelLanguage(
///   languageCode: 'es',
///   regionCode: 'CO',
/// );
///
/// void main() {
///   assert(language == equivalent);
///   assert(language.languageCode == 'es');
///   assert(language.regionCode == 'CO');
/// }
/// ```
@immutable
class ModelLanguage {
  /// Creates a language configuration.
  ///
  /// [languageCode] must not be empty and should use a valid language code
  /// such as `es`, `en`, or `pt`.
  ///
  /// [scriptCode] optionally identifies the writing system, such as `Hans`
  /// or `Hant`.
  ///
  /// [regionCode] optionally identifies a region, such as `CO`, `US`,
  /// or `BR`.
  /// Usage recommendation:
  ///
  /// Prefer [fromJson] when creating a language from external or untrusted data,
  /// because it normalizes the input and falls back to [undeterminedCode] when
  /// `languageCode` is missing or empty.
  ///
  /// When using this constructor directly, provide a non-empty [languageCode].
  /// The constructor uses an assertion to detect empty values during development,
  /// but assertions are not guaranteed to run in production builds.
  ///
  /// Use [undetermined] explicitly when no language can be determined.
  const ModelLanguage({
    required this.languageCode,
    this.scriptCode = '',
    this.regionCode = '',
  }) : assert(languageCode != '');

  /// Creates a [ModelLanguage] from a JSON map.
  ///
  /// External values are normalized before entering the domain:
  ///
  /// - `languageCode` is trimmed and converted to lowercase.
  /// - `scriptCode` is trimmed and normalized to title case.
  /// - `regionCode` is trimmed and converted to uppercase.
  /// - An empty or missing `languageCode` falls back to [undeterminedCode].
  ///
  /// Example:
  ///
  /// ```dart
  /// void main() {
  ///   final ModelLanguage language = ModelLanguage.fromJson(
  ///     <String, dynamic>{
  ///       'languageCode': 'ES',
  ///       'scriptCode': '',
  ///       'regionCode': 'co',
  ///     },
  ///   );
  ///
  ///   assert(language == ModelLanguage.spanishColombia);
  /// }
  /// ```
  factory ModelLanguage.fromJson(Map<String, dynamic> json) {
    final String rawLanguageCode =
        Utils.getStringFromDynamic(json[languageCodeKey]).trim();

    final String rawScriptCode =
        Utils.getStringFromDynamic(json[scriptCodeKey]).trim();

    final String rawRegionCode =
        Utils.getStringFromDynamic(json[regionCodeKey]).trim();

    return ModelLanguage(
      languageCode: rawLanguageCode.isEmpty
          ? undeterminedCode
          : rawLanguageCode.toLowerCase(),
      scriptCode: _normalizeScriptCode(rawScriptCode),
      regionCode: rawRegionCode.toUpperCase(),
    );
  }

  /// JSON key for [languageCode].
  static const String languageCodeKey = 'languageCode';

  /// JSON key for [scriptCode].
  static const String scriptCodeKey = 'scriptCode';

  /// JSON key for [regionCode].
  static const String regionCodeKey = 'regionCode';

  /// Language code used when the language cannot be determined.
  static const String undeterminedCode = 'und';

  /// Undetermined language.
  static const ModelLanguage undetermined = ModelLanguage(
    languageCode: undeterminedCode,
  );

  /// Spanish used in Colombia.
  static const ModelLanguage spanishColombia = ModelLanguage(
    languageCode: 'es',
    regionCode: 'CO',
  );

  /// Spanish used in Mexico.
  static const ModelLanguage spanishMexico = ModelLanguage(
    languageCode: 'es',
    regionCode: 'MX',
  );

  /// Spanish used in Spain.
  static const ModelLanguage spanishSpain = ModelLanguage(
    languageCode: 'es',
    regionCode: 'ES',
  );

  /// Spanish used in Argentina.
  static const ModelLanguage spanishArgentina = ModelLanguage(
    languageCode: 'es',
    regionCode: 'AR',
  );

  /// Spanish used in Chile.
  static const ModelLanguage spanishChile = ModelLanguage(
    languageCode: 'es',
    regionCode: 'CL',
  );

  /// Spanish used in Peru.
  static const ModelLanguage spanishPeru = ModelLanguage(
    languageCode: 'es',
    regionCode: 'PE',
  );

  /// English used in the United States.
  static const ModelLanguage englishUnitedStates = ModelLanguage(
    languageCode: 'en',
    regionCode: 'US',
  );

  /// English used in the United Kingdom.
  static const ModelLanguage englishUnitedKingdom = ModelLanguage(
    languageCode: 'en',
    regionCode: 'GB',
  );

  /// English used in Canada.
  static const ModelLanguage englishCanada = ModelLanguage(
    languageCode: 'en',
    regionCode: 'CA',
  );

  /// English used in Australia.
  static const ModelLanguage englishAustralia = ModelLanguage(
    languageCode: 'en',
    regionCode: 'AU',
  );

  /// Portuguese used in Brazil.
  static const ModelLanguage portugueseBrazil = ModelLanguage(
    languageCode: 'pt',
    regionCode: 'BR',
  );

  /// Portuguese used in Portugal.
  static const ModelLanguage portuguesePortugal = ModelLanguage(
    languageCode: 'pt',
    regionCode: 'PT',
  );

  /// French used in France.
  static const ModelLanguage frenchFrance = ModelLanguage(
    languageCode: 'fr',
    regionCode: 'FR',
  );

  /// German used in Germany.
  static const ModelLanguage germanGermany = ModelLanguage(
    languageCode: 'de',
    regionCode: 'DE',
  );

  /// Italian used in Italy.
  static const ModelLanguage italianItaly = ModelLanguage(
    languageCode: 'it',
    regionCode: 'IT',
  );

  /// Dutch used in the Netherlands.
  static const ModelLanguage dutchNetherlands = ModelLanguage(
    languageCode: 'nl',
    regionCode: 'NL',
  );

  /// Japanese used in Japan.
  static const ModelLanguage japaneseJapan = ModelLanguage(
    languageCode: 'ja',
    regionCode: 'JP',
  );

  /// Korean used in South Korea.
  static const ModelLanguage koreanSouthKorea = ModelLanguage(
    languageCode: 'ko',
    regionCode: 'KR',
  );

  /// Simplified Chinese used in China.
  static const ModelLanguage chineseChina = ModelLanguage(
    languageCode: 'zh',
    scriptCode: 'Hans',
    regionCode: 'CN',
  );

  /// Traditional Chinese used in Taiwan.
  static const ModelLanguage chineseTaiwan = ModelLanguage(
    languageCode: 'zh',
    scriptCode: 'Hant',
    regionCode: 'TW',
  );

  /// Hindi used in India.
  static const ModelLanguage hindiIndia = ModelLanguage(
    languageCode: 'hi',
    regionCode: 'IN',
  );

  /// Indonesian used in Indonesia.
  static const ModelLanguage indonesianIndonesia = ModelLanguage(
    languageCode: 'id',
    regionCode: 'ID',
  );

  /// Turkish used in Türkiye.
  static const ModelLanguage turkishTurkey = ModelLanguage(
    languageCode: 'tr',
    regionCode: 'TR',
  );

  /// Polish used in Poland.
  static const ModelLanguage polishPoland = ModelLanguage(
    languageCode: 'pl',
    regionCode: 'PL',
  );

  /// Swedish used in Sweden.
  static const ModelLanguage swedishSweden = ModelLanguage(
    languageCode: 'sv',
    regionCode: 'SE',
  );

  /// Norwegian used in Norway.
  static const ModelLanguage norwegianNorway = ModelLanguage(
    languageCode: 'no',
    regionCode: 'NO',
  );

  /// Language identifier.
  final String languageCode;

  /// Optional writing system identifier.
  final String scriptCode;

  /// Optional region identifier.
  final String regionCode;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ModelLanguage &&
            languageCode == other.languageCode &&
            scriptCode == other.scriptCode &&
            regionCode == other.regionCode;
  }

  @override
  int get hashCode => Object.hash(
        languageCode,
        scriptCode,
        regionCode,
      );

  /// Converts this language configuration into a JSON map.
  ///
  /// All fields are included to keep the serialized representation
  /// deterministic.
  ///
  /// Example:
  ///
  /// ```dart
  /// void main() {
  ///   final Map<String, dynamic> json =
  ///       ModelLanguage.spanishColombia.toJson();
  ///
  ///   assert(json['languageCode'] == 'es');
  ///   assert(json['scriptCode'] == '');
  ///   assert(json['regionCode'] == 'CO');
  /// }
  /// ```
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      languageCodeKey: languageCode,
      scriptCodeKey: scriptCode,
      regionCodeKey: regionCode,
    };
  }

  static String _normalizeScriptCode(String value) {
    if (value.isEmpty) {
      return '';
    }

    final String normalized = value.toLowerCase();

    return '${normalized[0].toUpperCase()}${normalized.substring(1)}';
  }

  String get canonicalTag {
    return <String>[
      languageCode,
      if (scriptCode.isNotEmpty) scriptCode,
      if (regionCode.isNotEmpty) regionCode,
    ].join('-');
  }
}
