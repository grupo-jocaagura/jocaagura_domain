import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('constructor', () {
    test(
      'Given translations '
      'When model is created without fallbackLanguage '
      'Then fallbackLanguage is undetermined',
      () {
        // Arrange
        final Map<ModelLanguage, String> translations = <ModelLanguage, String>{
          ModelLanguage.spanishColombia: 'Hola',
        };

        // Act
        final ModelLocalizedText model = ModelLocalizedText(
          translations: translations,
        );

        // Assert
        expect(
          model.fallbackLanguage,
          ModelLanguage.undetermined,
        );
      },
    );

    test(
      'Given translations and fallbackLanguage '
      'When model is created '
      'Then values are preserved',
      () {
        // Arrange
        final Map<ModelLanguage, String> translations = <ModelLanguage, String>{
          ModelLanguage.spanishColombia: 'Hola',
          ModelLanguage.englishUnitedStates: 'Hello',
        };

        // Act
        final ModelLocalizedText model = ModelLocalizedText(
          translations: translations,
          fallbackLanguage: ModelLanguage.spanishColombia,
        );

        // Assert
        expect(
          model.translations,
          <ModelLanguage, String>{
            ModelLanguage.spanishColombia: 'Hola',
            ModelLanguage.englishUnitedStates: 'Hello',
          },
        );
        expect(
          model.fallbackLanguage,
          ModelLanguage.spanishColombia,
        );
      },
    );

    test(
      'Given mutable translations '
      'When model is created and input map changes '
      'Then model translations remain unchanged',
      () {
        // Arrange
        final Map<ModelLanguage, String> translations = <ModelLanguage, String>{
          ModelLanguage.spanishColombia: 'Hola',
        };

        final ModelLocalizedText model = ModelLocalizedText(
          translations: translations,
        );

        // Act
        translations[ModelLanguage.spanishColombia] = 'Modificado';
        translations[ModelLanguage.englishUnitedStates] = 'Hello';

        // Assert
        expect(
          model.translations,
          <ModelLanguage, String>{
            ModelLanguage.spanishColombia: 'Hola',
          },
        );
      },
    );

    test(
      'Given a created model '
      'When translations map is mutated '
      'Then mutation throws UnsupportedError',
      () {
        // Arrange
        final ModelLocalizedText model = ModelLocalizedText(
          translations: <ModelLanguage, String>{
            ModelLanguage.spanishColombia: 'Hola',
          },
        );

        // Act
        void mutateTranslations() {
          model.translations[ModelLanguage.englishUnitedStates] = 'Hello';
        }

        // Assert
        expect(
          mutateTranslations,
          throwsUnsupportedError,
        );
      },
    );

    test(
      'Given empty translations '
      'When model is created '
      'Then empty map is preserved',
      () {
        // Act
        final ModelLocalizedText model = ModelLocalizedText(
          translations: const <ModelLanguage, String>{},
        );

        // Assert
        expect(model.translations, isEmpty);
        expect(
          model.fallbackLanguage,
          ModelLanguage.undetermined,
        );
      },
    );
  });

  group('equality', () {
    test(
      'Given the same instance '
      'When equality is evaluated '
      'Then it is equal to itself',
      () {
        // Arrange
        final ModelLocalizedText model = ModelLocalizedText(
          translations: <ModelLanguage, String>{
            ModelLanguage.spanishColombia: 'Hola',
          },
        );

        // Act
        final bool result = model == model;

        // Assert
        expect(result, isTrue);
      },
    );

    test(
      'Given different instances with same values '
      'When equality is evaluated '
      'Then they are equal',
      () {
        // Arrange
        final ModelLocalizedText first = ModelLocalizedText(
          translations: <ModelLanguage, String>{
            ModelLanguage.spanishColombia: 'Hola',
            ModelLanguage.englishUnitedStates: 'Hello',
          },
          fallbackLanguage: ModelLanguage.spanishColombia,
        );

        final ModelLocalizedText second = ModelLocalizedText(
          translations: <ModelLanguage, String>{
            ModelLanguage.spanishColombia: 'Hola',
            ModelLanguage.englishUnitedStates: 'Hello',
          },
          fallbackLanguage: ModelLanguage.spanishColombia,
        );

        // Act & Assert
        expect(first, equals(second));
      },
    );

    test(
      'Given translations inserted in different order '
      'When equality is evaluated '
      'Then models are equal',
      () {
        // Arrange
        final ModelLocalizedText first = ModelLocalizedText(
          translations: <ModelLanguage, String>{
            ModelLanguage.spanishColombia: 'Hola',
            ModelLanguage.englishUnitedStates: 'Hello',
          },
        );

        final ModelLocalizedText second = ModelLocalizedText(
          translations: <ModelLanguage, String>{
            ModelLanguage.englishUnitedStates: 'Hello',
            ModelLanguage.spanishColombia: 'Hola',
          },
        );

        // Act & Assert
        expect(first, equals(second));
      },
    );

    test(
      'Given different fallback languages '
      'When equality is evaluated '
      'Then models are not equal',
      () {
        // Arrange
        final ModelLocalizedText first = ModelLocalizedText(
          translations: <ModelLanguage, String>{
            ModelLanguage.spanishColombia: 'Hola',
          },
          fallbackLanguage: ModelLanguage.spanishColombia,
        );

        final ModelLocalizedText second = ModelLocalizedText(
          translations: <ModelLanguage, String>{
            ModelLanguage.spanishColombia: 'Hola',
          },
          fallbackLanguage: ModelLanguage.englishUnitedStates,
        );

        // Act & Assert
        expect(first, isNot(equals(second)));
      },
    );

    test(
      'Given different translation map lengths '
      'When equality is evaluated '
      'Then models are not equal',
      () {
        // Arrange
        final ModelLocalizedText first = ModelLocalizedText(
          translations: <ModelLanguage, String>{
            ModelLanguage.spanishColombia: 'Hola',
          },
        );

        final ModelLocalizedText second = ModelLocalizedText(
          translations: <ModelLanguage, String>{
            ModelLanguage.spanishColombia: 'Hola',
            ModelLanguage.englishUnitedStates: 'Hello',
          },
        );

        // Act & Assert
        expect(first, isNot(equals(second)));
      },
    );

    test(
      'Given same translation count but different languages '
      'When equality is evaluated '
      'Then models are not equal',
      () {
        // Arrange
        final ModelLocalizedText first = ModelLocalizedText(
          translations: <ModelLanguage, String>{
            ModelLanguage.spanishColombia: 'Hola',
          },
        );

        final ModelLocalizedText second = ModelLocalizedText(
          translations: <ModelLanguage, String>{
            ModelLanguage.spanishMexico: 'Hola',
          },
        );

        // Act & Assert
        expect(first, isNot(equals(second)));
      },
    );

    test(
      'Given same languages but different text '
      'When equality is evaluated '
      'Then models are not equal',
      () {
        // Arrange
        final ModelLocalizedText first = ModelLocalizedText(
          translations: <ModelLanguage, String>{
            ModelLanguage.spanishColombia: 'Hola',
          },
        );

        final ModelLocalizedText second = ModelLocalizedText(
          translations: <ModelLanguage, String>{
            ModelLanguage.spanishColombia: 'Buenos días',
          },
        );

        // Act & Assert
        expect(first, isNot(equals(second)));
      },
    );

    test(
      'Given equal models '
      'When hashCode is evaluated '
      'Then hashCodes are equal',
      () {
        // Arrange
        final ModelLocalizedText first = ModelLocalizedText(
          translations: <ModelLanguage, String>{
            ModelLanguage.spanishColombia: 'Hola',
            ModelLanguage.englishUnitedStates: 'Hello',
          },
          fallbackLanguage: ModelLanguage.spanishColombia,
        );

        final ModelLocalizedText second = ModelLocalizedText(
          translations: <ModelLanguage, String>{
            ModelLanguage.spanishColombia: 'Hola',
            ModelLanguage.englishUnitedStates: 'Hello',
          },
          fallbackLanguage: ModelLanguage.spanishColombia,
        );

        // Act & Assert
        expect(first.hashCode, second.hashCode);
      },
    );

    test(
      'Given equal translations inserted in different order '
      'When hashCode is evaluated '
      'Then hashCodes are equal',
      () {
        // Arrange
        final ModelLocalizedText first = ModelLocalizedText(
          translations: <ModelLanguage, String>{
            ModelLanguage.spanishColombia: 'Hola',
            ModelLanguage.englishUnitedStates: 'Hello',
          },
        );

        final ModelLocalizedText second = ModelLocalizedText(
          translations: <ModelLanguage, String>{
            ModelLanguage.englishUnitedStates: 'Hello',
            ModelLanguage.spanishColombia: 'Hola',
          },
        );

        // Act & Assert
        expect(first.hashCode, second.hashCode);
      },
    );
  });

  group('fromJson', () {
    test(
      'Given valid JSON '
      'When model is deserialized '
      'Then translations and fallback are created',
      () {
        // Arrange
        final Map<String, dynamic> json = <String, dynamic>{
          ModelLocalizedText.translationsKey: <Map<String, dynamic>>[
            <String, dynamic>{
              ModelLocalizedText.languageKey: <String, dynamic>{
                ModelLanguage.languageCodeKey: 'es',
                ModelLanguage.scriptCodeKey: '',
                ModelLanguage.regionCodeKey: 'CO',
              },
              ModelLocalizedText.textKey: 'Hola',
            },
            <String, dynamic>{
              ModelLocalizedText.languageKey: <String, dynamic>{
                ModelLanguage.languageCodeKey: 'en',
                ModelLanguage.scriptCodeKey: '',
                ModelLanguage.regionCodeKey: 'US',
              },
              ModelLocalizedText.textKey: 'Hello',
            },
          ],
          ModelLocalizedText.fallbackLanguageKey: <String, dynamic>{
            ModelLanguage.languageCodeKey: 'es',
            ModelLanguage.scriptCodeKey: '',
            ModelLanguage.regionCodeKey: 'CO',
          },
        };

        // Act
        final ModelLocalizedText model = ModelLocalizedText.fromJson(json);

        // Assert
        expect(
          model.translations,
          <ModelLanguage, String>{
            ModelLanguage.spanishColombia: 'Hola',
            ModelLanguage.englishUnitedStates: 'Hello',
          },
        );
        expect(
          model.fallbackLanguage,
          ModelLanguage.spanishColombia,
        );
      },
    );

    test(
      'Given language values with inconsistent casing and whitespace '
      'When model is deserialized '
      'Then languages are normalized by ModelLanguage',
      () {
        // Arrange
        final Map<String, dynamic> json = <String, dynamic>{
          ModelLocalizedText.translationsKey: <Map<String, dynamic>>[
            <String, dynamic>{
              ModelLocalizedText.languageKey: <String, dynamic>{
                ModelLanguage.languageCodeKey: ' ES ',
                ModelLanguage.scriptCodeKey: ' ',
                ModelLanguage.regionCodeKey: ' co ',
              },
              ModelLocalizedText.textKey: 'Hola',
            },
          ],
          ModelLocalizedText.fallbackLanguageKey: <String, dynamic>{
            ModelLanguage.languageCodeKey: ' EN ',
            ModelLanguage.scriptCodeKey: '',
            ModelLanguage.regionCodeKey: ' us ',
          },
        };

        // Act
        final ModelLocalizedText model = ModelLocalizedText.fromJson(json);

        // Assert
        expect(
          model.translations,
          <ModelLanguage, String>{
            ModelLanguage.spanishColombia: 'Hola',
          },
        );
        expect(
          model.fallbackLanguage,
          ModelLanguage.englishUnitedStates,
        );
      },
    );

    test(
      'Given script language values '
      'When model is deserialized '
      'Then script normalization is delegated to ModelLanguage',
      () {
        // Arrange
        final Map<String, dynamic> json = <String, dynamic>{
          ModelLocalizedText.translationsKey: <Map<String, dynamic>>[
            <String, dynamic>{
              ModelLocalizedText.languageKey: <String, dynamic>{
                ModelLanguage.languageCodeKey: 'ZH',
                ModelLanguage.scriptCodeKey: 'hANT',
                ModelLanguage.regionCodeKey: 'tw',
              },
              ModelLocalizedText.textKey: '你好',
            },
          ],
        };

        // Act
        final ModelLocalizedText model = ModelLocalizedText.fromJson(json);

        // Assert
        expect(
          model.translations,
          <ModelLanguage, String>{
            ModelLanguage.chineseTaiwan: '你好',
          },
        );
      },
    );

    test(
      'Given missing translations '
      'When model is deserialized '
      'Then translations are empty',
      () {
        // Act
        final ModelLocalizedText model = ModelLocalizedText.fromJson(
          const <String, dynamic>{},
        );

        // Assert
        expect(model.translations, isEmpty);
      },
    );

    test(
      'Given null translations '
      'When model is deserialized '
      'Then translations are empty',
      () {
        // Act
        final ModelLocalizedText model = ModelLocalizedText.fromJson(
          const <String, dynamic>{
            ModelLocalizedText.translationsKey: null,
          },
        );

        // Assert
        expect(model.translations, isEmpty);
      },
    );

    test(
      'Given invalid non-list translations '
      'When model is deserialized '
      'Then translations are empty',
      () {
        // Act
        final ModelLocalizedText model = ModelLocalizedText.fromJson(
          const <String, dynamic>{
            ModelLocalizedText.translationsKey: 'invalid',
          },
        );

        // Assert
        expect(model.translations, isEmpty);
      },
    );

    test(
      'Given non-map entries inside translations '
      'When model is deserialized '
      'Then invalid entries are ignored',
      () {
        // Arrange
        final Map<String, dynamic> json = <String, dynamic>{
          ModelLocalizedText.translationsKey: <dynamic>[
            'invalid',
            null,
            42,
            <String, dynamic>{
              ModelLocalizedText.languageKey: <String, dynamic>{
                ModelLanguage.languageCodeKey: 'es',
                ModelLanguage.regionCodeKey: 'CO',
              },
              ModelLocalizedText.textKey: 'Hola',
            },
          ],
        };

        // Act
        final ModelLocalizedText model = ModelLocalizedText.fromJson(json);

        // Assert
        expect(
          model.translations,
          <ModelLanguage, String>{
            ModelLanguage.spanishColombia: 'Hola',
          },
        );
      },
    );

    test(
      'Given translation with missing language '
      'When model is deserialized '
      'Then language becomes undetermined',
      () {
        // Arrange
        final Map<String, dynamic> json = <String, dynamic>{
          ModelLocalizedText.translationsKey: <Map<String, dynamic>>[
            <String, dynamic>{
              ModelLocalizedText.textKey: 'Unknown text',
            },
          ],
        };

        // Act
        final ModelLocalizedText model = ModelLocalizedText.fromJson(json);

        // Assert
        expect(
          model.translations,
          <ModelLanguage, String>{
            ModelLanguage.undetermined: 'Unknown text',
          },
        );
      },
    );

    test(
      'Given translation with null language '
      'When model is deserialized '
      'Then language becomes undetermined',
      () {
        // Arrange
        final Map<String, dynamic> json = <String, dynamic>{
          ModelLocalizedText.translationsKey: <Map<String, dynamic>>[
            <String, dynamic>{
              ModelLocalizedText.languageKey: null,
              ModelLocalizedText.textKey: 'Unknown text',
            },
          ],
        };

        // Act
        final ModelLocalizedText model = ModelLocalizedText.fromJson(json);

        // Assert
        expect(
          model.translations,
          <ModelLanguage, String>{
            ModelLanguage.undetermined: 'Unknown text',
          },
        );
      },
    );

    test(
      'Given translation with empty language code '
      'When model is deserialized '
      'Then language becomes undetermined',
      () {
        // Arrange
        final Map<String, dynamic> json = <String, dynamic>{
          ModelLocalizedText.translationsKey: <Map<String, dynamic>>[
            <String, dynamic>{
              ModelLocalizedText.languageKey: <String, dynamic>{
                ModelLanguage.languageCodeKey: '',
              },
              ModelLocalizedText.textKey: 'Unknown text',
            },
          ],
        };

        // Act
        final ModelLocalizedText model = ModelLocalizedText.fromJson(json);

        // Assert
        expect(
          model.translations,
          <ModelLanguage, String>{
            ModelLanguage.undetermined: 'Unknown text',
          },
        );
      },
    );

    test(
      'Given translation with whitespace language code '
      'When model is deserialized '
      'Then language becomes undetermined',
      () {
        // Arrange
        final Map<String, dynamic> json = <String, dynamic>{
          ModelLocalizedText.translationsKey: <Map<String, dynamic>>[
            <String, dynamic>{
              ModelLocalizedText.languageKey: <String, dynamic>{
                ModelLanguage.languageCodeKey: '   ',
              },
              ModelLocalizedText.textKey: 'Unknown text',
            },
          ],
        };

        // Act
        final ModelLocalizedText model = ModelLocalizedText.fromJson(json);

        // Assert
        expect(
          model.translations,
          <ModelLanguage, String>{
            ModelLanguage.undetermined: 'Unknown text',
          },
        );
      },
    );

    test(
      'Given missing translation text '
      'When model is deserialized '
      'Then text becomes empty string',
      () {
        // Arrange
        final Map<String, dynamic> json = <String, dynamic>{
          ModelLocalizedText.translationsKey: <Map<String, dynamic>>[
            <String, dynamic>{
              ModelLocalizedText.languageKey: <String, dynamic>{
                ModelLanguage.languageCodeKey: 'es',
                ModelLanguage.regionCodeKey: 'CO',
              },
            },
          ],
        };

        // Act
        final ModelLocalizedText model = ModelLocalizedText.fromJson(json);

        // Assert
        expect(
          model.translations[ModelLanguage.spanishColombia],
          '',
        );
      },
    );

    test(
      'Given null translation text '
      'When model is deserialized '
      'Then text becomes empty string',
      () {
        // Arrange
        final Map<String, dynamic> json = <String, dynamic>{
          ModelLocalizedText.translationsKey: <Map<String, dynamic>>[
            <String, dynamic>{
              ModelLocalizedText.languageKey: <String, dynamic>{
                ModelLanguage.languageCodeKey: 'es',
                ModelLanguage.regionCodeKey: 'CO',
              },
              ModelLocalizedText.textKey: null,
            },
          ],
        };

        // Act
        final ModelLocalizedText model = ModelLocalizedText.fromJson(json);

        // Assert
        expect(
          model.translations[ModelLanguage.spanishColombia],
          '',
        );
      },
    );

    test(
      'Given non-string translation text '
      'When model is deserialized '
      'Then text is converted to String',
      () {
        // Arrange
        final Map<String, dynamic> json = <String, dynamic>{
          ModelLocalizedText.translationsKey: <Map<String, dynamic>>[
            <String, dynamic>{
              ModelLocalizedText.languageKey: <String, dynamic>{
                ModelLanguage.languageCodeKey: 'es',
                ModelLanguage.regionCodeKey: 'CO',
              },
              ModelLocalizedText.textKey: 42,
            },
          ],
        };

        // Act
        final ModelLocalizedText model = ModelLocalizedText.fromJson(json);

        // Assert
        expect(
          model.translations[ModelLanguage.spanishColombia],
          '42',
        );
      },
    );

    test(
      'Given missing fallbackLanguage '
      'When model is deserialized '
      'Then fallbackLanguage becomes undetermined',
      () {
        // Act
        final ModelLocalizedText model = ModelLocalizedText.fromJson(
          const <String, dynamic>{},
        );

        // Assert
        expect(
          model.fallbackLanguage,
          ModelLanguage.undetermined,
        );
      },
    );

    test(
      'Given null fallbackLanguage '
      'When model is deserialized '
      'Then fallbackLanguage becomes undetermined',
      () {
        // Act
        final ModelLocalizedText model = ModelLocalizedText.fromJson(
          const <String, dynamic>{
            ModelLocalizedText.fallbackLanguageKey: null,
          },
        );

        // Assert
        expect(
          model.fallbackLanguage,
          ModelLanguage.undetermined,
        );
      },
    );

    test(
      'Given invalid fallbackLanguage '
      'When model is deserialized '
      'Then fallbackLanguage becomes undetermined',
      () {
        // Act
        final ModelLocalizedText model = ModelLocalizedText.fromJson(
          const <String, dynamic>{
            ModelLocalizedText.fallbackLanguageKey: 'invalid',
          },
        );

        // Assert
        expect(
          model.fallbackLanguage,
          ModelLanguage.undetermined,
        );
      },
    );

    test(
      'Given duplicate translations resolving to same language '
      'When model is deserialized '
      'Then last translation wins',
      () {
        // Arrange
        final Map<String, dynamic> json = <String, dynamic>{
          ModelLocalizedText.translationsKey: <Map<String, dynamic>>[
            <String, dynamic>{
              ModelLocalizedText.languageKey: <String, dynamic>{
                ModelLanguage.languageCodeKey: 'ES',
                ModelLanguage.regionCodeKey: 'co',
              },
              ModelLocalizedText.textKey: 'Primero',
            },
            <String, dynamic>{
              ModelLocalizedText.languageKey: <String, dynamic>{
                ModelLanguage.languageCodeKey: 'es',
                ModelLanguage.regionCodeKey: 'CO',
              },
              ModelLocalizedText.textKey: 'Último',
            },
          ],
        };

        // Act
        final ModelLocalizedText model = ModelLocalizedText.fromJson(json);

        // Assert
        expect(model.translations.length, 1);
        expect(
          model.translations[ModelLanguage.spanishColombia],
          'Último',
        );
      },
    );

    test(
      'Given multiple entries resolving to undetermined '
      'When model is deserialized '
      'Then last undetermined translation wins',
      () {
        // Arrange
        final Map<String, dynamic> json = <String, dynamic>{
          ModelLocalizedText.translationsKey: <Map<String, dynamic>>[
            <String, dynamic>{
              ModelLocalizedText.textKey: 'Primero',
            },
            <String, dynamic>{
              ModelLocalizedText.languageKey: <String, dynamic>{
                ModelLanguage.languageCodeKey: '   ',
              },
              ModelLocalizedText.textKey: 'Último',
            },
          ],
        };

        // Act
        final ModelLocalizedText model = ModelLocalizedText.fromJson(json);

        // Assert
        expect(model.translations.length, 1);
        expect(
          model.translations[ModelLanguage.undetermined],
          'Último',
        );
      },
    );

    test(
      'Given source JSON '
      'When model is deserialized '
      'Then input map remains untouched',
      () {
        // Arrange
        final Map<String, dynamic> language = <String, dynamic>{
          ModelLanguage.languageCodeKey: 'ES',
          ModelLanguage.scriptCodeKey: '',
          ModelLanguage.regionCodeKey: 'co',
        };

        final Map<String, dynamic> translation = <String, dynamic>{
          ModelLocalizedText.languageKey: language,
          ModelLocalizedText.textKey: 'Hola',
        };

        final List<Map<String, dynamic>> translations = <Map<String, dynamic>>[
          translation,
        ];

        final Map<String, dynamic> json = <String, dynamic>{
          ModelLocalizedText.translationsKey: translations,
          ModelLocalizedText.fallbackLanguageKey: language,
        };

        // Act
        ModelLocalizedText.fromJson(json);

        // Assert
        expect(
          language,
          <String, dynamic>{
            ModelLanguage.languageCodeKey: 'ES',
            ModelLanguage.scriptCodeKey: '',
            ModelLanguage.regionCodeKey: 'co',
          },
        );

        expect(
          translation,
          <String, dynamic>{
            ModelLocalizedText.languageKey: language,
            ModelLocalizedText.textKey: 'Hola',
          },
        );

        expect(
          translations,
          <Map<String, dynamic>>[
            translation,
          ],
        );
      },
    );
  });

  group('JSON keys', () {
    test(
      'Given ModelLocalizedText serialization contract '
      'When static keys are read '
      'Then keys remain deterministic',
      () {
        expect(
          ModelLocalizedText.translationsKey,
          'translations',
        );
        expect(
          ModelLocalizedText.fallbackLanguageKey,
          'fallbackLanguage',
        );
        expect(
          ModelLocalizedText.languageKey,
          'language',
        );
        expect(
          ModelLocalizedText.textKey,
          'text',
        );
      },
    );
  });

  group('toJson', () {
    test('supports JSON round trip', () {
      final ModelLocalizedText original = ModelLocalizedText(
        translations: <ModelLanguage, String>{
          ModelLanguage.spanishColombia: 'Hola',
          ModelLanguage.englishUnitedStates: 'Hello',
          ModelLanguage.portugueseBrazil: 'Olá',
        },
        fallbackLanguage: ModelLanguage.spanishColombia,
      );

      final Map<String, dynamic> json = original.toJson();

      final ModelLocalizedText restored = ModelLocalizedText.fromJson(json);

      expect(restored, original);
      expect(restored.hashCode, original.hashCode);
    });
    test('serializes translations in deterministic canonical order', () {
      final ModelLocalizedText model = ModelLocalizedText(
        translations: <ModelLanguage, String>{
          ModelLanguage.spanishColombia: 'Hola',
          ModelLanguage.portugueseBrazil: 'Olá',
          ModelLanguage.englishUnitedStates: 'Hello',
        },
      );

      final Map<String, dynamic> json = model.toJson();

      final List<Map<String, dynamic>> translations = Utils.listFromDynamic(
        json[ModelLocalizedText.translationsKey],
      );

      expect(
        translations
            .map(
              (Map<String, dynamic> entry) => ModelLanguage.fromJson(
                Utils.mapFromDynamic(
                  entry[ModelLocalizedText.languageKey],
                ),
              ).canonicalTag,
            )
            .toList(),
        <String>[
          'en-US',
          'es-CO',
          'pt-BR',
        ],
      );
    });
    test(
        'equal models serialize to equivalent JSON regardless of insertion order',
        () {
      final ModelLocalizedText first = ModelLocalizedText(
        translations: <ModelLanguage, String>{
          ModelLanguage.spanishColombia: 'Hola',
          ModelLanguage.englishUnitedStates: 'Hello',
        },
      );

      final ModelLocalizedText second = ModelLocalizedText(
        translations: <ModelLanguage, String>{
          ModelLanguage.englishUnitedStates: 'Hello',
          ModelLanguage.spanishColombia: 'Hola',
        },
      );

      expect(first, second);
      expect(
        Utils.deepEqualsMap(
          first.toJson(),
          second.toJson(),
        ),
        isTrue,
      );
    });
  });
}
