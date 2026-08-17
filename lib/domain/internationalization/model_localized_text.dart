part of '../../jocaagura_domain.dart';

/// Represents text translated into one or more languages.
///
/// [translations] contains the available localized values indexed by
/// [ModelLanguage].
///
/// [fallbackLanguage] identifies the preferred fallback language when one has
/// been explicitly declared. [ModelLanguage.undetermined] represents the
/// absence of a specific fallback.
///
/// The provided translations are defensively copied into an unmodifiable map,
/// preventing external mutations from changing the model after construction.
///
/// Example:
///
/// ```dart
/// void main() {
///   final ModelLocalizedText text = ModelLocalizedText(
///     translations: <ModelLanguage, String>{
///       ModelLanguage.spanishColombia: 'Hola',
///       ModelLanguage.englishUnitedStates: 'Hello',
///     },
///     fallbackLanguage: ModelLanguage.spanishColombia,
///   );
///
///   assert(
///     text.translations[ModelLanguage.spanishColombia] == 'Hola',
///   );
/// }
/// ```
@immutable
class ModelLocalizedText {
  /// Creates localized text from the provided [translations].
  ///
  /// The input map is defensively copied and exposed as an unmodifiable map.
  ///
  /// [fallbackLanguage] defaults to [ModelLanguage.undetermined], meaning that
  /// no explicit fallback language has been declared.
  ModelLocalizedText({
    required Map<ModelLanguage, String> translations,
    this.fallbackLanguage = ModelLanguage.undetermined,
  }) : translations = Map<ModelLanguage, String>.unmodifiable(translations);

  /// Creates a [ModelLocalizedText] from a JSON map.
  ///
  /// Invalid or missing external values are normalized deterministically:
  ///
  /// - Missing or invalid `translations` become an empty map.
  /// - Missing or invalid translation languages become
  ///   [ModelLanguage.undetermined].
  /// - Missing or `null` translation text becomes an empty string.
  /// - Missing or invalid `fallbackLanguage` becomes
  ///   [ModelLanguage.undetermined].
  /// - Language normalization is delegated to [ModelLanguage.fromJson].
  ///
  /// When multiple translation entries resolve to the same [ModelLanguage],
  /// the last entry wins.
  ///
  /// Example:
  ///
  /// ```dart
  /// void main() {
  ///   final ModelLocalizedText text = ModelLocalizedText.fromJson(
  ///     <String, dynamic>{
  ///       'translations': <Map<String, dynamic>>[
  ///         <String, dynamic>{
  ///           'language': <String, dynamic>{
  ///             'languageCode': 'ES',
  ///             'regionCode': 'co',
  ///           },
  ///           'text': 'Hola',
  ///         },
  ///       ],
  ///       'fallbackLanguage': <String, dynamic>{
  ///         'languageCode': 'es',
  ///         'regionCode': 'CO',
  ///       },
  ///     },
  ///   );
  ///
  ///   assert(
  ///     text.translations[ModelLanguage.spanishColombia] == 'Hola',
  ///   );
  ///   assert(
  ///     text.fallbackLanguage == ModelLanguage.spanishColombia,
  ///   );
  /// }
  /// ```
  factory ModelLocalizedText.fromJson(Map<String, dynamic> json) {
    final List<Map<String, dynamic>> rawTranslations =
        Utils.listFromDynamic(json[translationsKey]);

    final Map<ModelLanguage, String> translations = <ModelLanguage, String>{};

    for (final Map<String, dynamic> rawTranslation in rawTranslations) {
      final ModelLanguage language = ModelLanguage.fromJson(
        Utils.mapFromDynamic(
          rawTranslation[languageKey],
        ),
      );

      final String text = Utils.getStringFromDynamic(
        rawTranslation[textKey],
      );

      translations[language] = text;
    }

    final ModelLanguage fallbackLanguage = ModelLanguage.fromJson(
      Utils.mapFromDynamic(
        json[fallbackLanguageKey],
      ),
    );

    return ModelLocalizedText(
      translations: translations,
      fallbackLanguage: fallbackLanguage,
    );
  }

  /// Available translations indexed by language.
  final Map<ModelLanguage, String> translations;

  /// Preferred fallback language.
  ///
  /// [ModelLanguage.undetermined] means that no explicit fallback has been
  /// declared.
  final ModelLanguage fallbackLanguage;

  /// JSON key for [translations].
  static const String translationsKey = 'translations';

  /// JSON key for [fallbackLanguage].
  static const String fallbackLanguageKey = 'fallbackLanguage';

  /// JSON key for the language of a translation entry.
  static const String languageKey = 'language';

  /// JSON key for the localized text of a translation entry.
  static const String textKey = 'text';
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ModelLocalizedText &&
            fallbackLanguage == other.fallbackLanguage &&
            _translationsAreEqual(
              translations,
              other.translations,
            );
  }

  @override
  int get hashCode {
    final Iterable<int> translationHashes = translations.entries.map(
      (MapEntry<ModelLanguage, String> entry) {
        return Object.hash(
          entry.key,
          entry.value,
        );
      },
    );

    return Object.hash(
      fallbackLanguage,
      Object.hashAllUnordered(translationHashes),
    );
  }

  static bool _translationsAreEqual(
    Map<ModelLanguage, String> first,
    Map<ModelLanguage, String> second,
  ) {
    if (identical(first, second)) {
      return true;
    }

    if (first.length != second.length) {
      return false;
    }

    for (final MapEntry<ModelLanguage, String> entry in first.entries) {
      if (!second.containsKey(entry.key) || second[entry.key] != entry.value) {
        return false;
      }
    }

    return true;
  }

  /// Converts this localized text into a deterministic JSON map.
  ///
  /// Translation entries are sorted by [ModelLanguage.canonicalTag] before
  /// serialization. This guarantees that equivalent models produce the same
  /// JSON structure regardless of the original insertion order.
  ///
  /// Each language is serialized using [ModelLanguage.toJson].
  ///
  /// Example:
  ///
  /// ```dart
  /// void main() {
  ///   final ModelLocalizedText text = ModelLocalizedText(
  ///     translations: <ModelLanguage, String>{
  ///       ModelLanguage.spanishColombia: 'Hola',
  ///       ModelLanguage.englishUnitedStates: 'Hello',
  ///     },
  ///     fallbackLanguage: ModelLanguage.spanishColombia,
  ///   );
  ///
  ///   final Map<String, dynamic> json = text.toJson();
  ///
  ///   assert(json[ModelLocalizedText.translationsKey] is List<dynamic>);
  ///   assert(
  ///     json[ModelLocalizedText.fallbackLanguageKey]
  ///         is Map<String, dynamic>,
  ///   );
  /// }
  /// ```
  Map<String, dynamic> toJson() {
    final List<MapEntry<ModelLanguage, String>> sortedEntries =
        translations.entries.toList()
          ..sort(
            (
              MapEntry<ModelLanguage, String> first,
              MapEntry<ModelLanguage, String> second,
            ) {
              return first.key.canonicalTag.compareTo(
                second.key.canonicalTag,
              );
            },
          );

    return <String, dynamic>{
      translationsKey: sortedEntries
          .map(
            (MapEntry<ModelLanguage, String> entry) => <String, dynamic>{
              languageKey: entry.key.toJson(),
              textKey: entry.value,
            },
          )
          .toList(growable: false),
      fallbackLanguageKey: fallbackLanguage.toJson(),
    };
  }
}
