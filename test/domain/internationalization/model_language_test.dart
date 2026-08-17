import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('ModelLanguage constructor', () {
    test(
      'Given only languageCode When constructed Then optional codes default to empty strings',
      () {
        const ModelLanguage language = ModelLanguage(
          languageCode: 'es',
        );

        expect(language.languageCode, 'es');
        expect(language.scriptCode, '');
        expect(language.regionCode, '');
      },
    );

    test(
      'Given all canonical codes When constructed Then values are preserved',
      () {
        const ModelLanguage language = ModelLanguage.chineseTaiwan;

        expect(language.languageCode, 'zh');
        expect(language.scriptCode, 'Hant');
        expect(language.regionCode, 'TW');
      },
    );

    test(
      'Given an empty languageCode When constructed Then assertion fails',
      () {
        expect(
          () => ModelLanguage(languageCode: ''),
          throwsA(isA<AssertionError>()),
        );
      },
    );
  });

  group('ModelLanguage serialization contract', () {
    test(
      'Given serialization constants When inspected Then JSON keys remain stable',
      () {
        expect(ModelLanguage.languageCodeKey, 'languageCode');
        expect(ModelLanguage.scriptCodeKey, 'scriptCode');
        expect(ModelLanguage.regionCodeKey, 'regionCode');
      },
    );

    test(
      'Given undeterminedCode When inspected Then it remains und',
      () {
        expect(ModelLanguage.undeterminedCode, 'und');
      },
    );

    test(
      'Given a language with all fields When toJson is called Then all fields are serialized',
      () {
        const ModelLanguage language = ModelLanguage.chineseTaiwan;

        final Map<String, dynamic> json = language.toJson();

        expect(
          json,
          <String, dynamic>{
            'languageCode': 'zh',
            'scriptCode': 'Hant',
            'regionCode': 'TW',
          },
        );
      },
    );

    test(
      'Given empty optional fields When toJson is called Then all keys are still included',
      () {
        const ModelLanguage language = ModelLanguage(
          languageCode: 'es',
        );

        final Map<String, dynamic> json = language.toJson();

        expect(
          json,
          <String, dynamic>{
            'languageCode': 'es',
            'scriptCode': '',
            'regionCode': '',
          },
        );
      },
    );

    test(
      'Given a serialized map When it is modified Then the language remains unchanged',
      () {
        const ModelLanguage language = ModelLanguage.spanishColombia;

        final Map<String, dynamic> json = language.toJson();

        json['languageCode'] = 'en';
        json['regionCode'] = 'US';

        expect(language, ModelLanguage.spanishColombia);

        final Map<String, dynamic> secondJson = language.toJson();

        expect(secondJson['languageCode'], 'es');
        expect(secondJson['regionCode'], 'CO');
      },
    );
  });

  group('ModelLanguage fromJson normalization', () {
    test(
      'Given mixed-case and padded codes When parsed Then values are canonicalized',
      () {
        final ModelLanguage language = ModelLanguage.fromJson(
          const <String, dynamic>{
            'languageCode': ' ES ',
            'scriptCode': ' hAnT ',
            'regionCode': ' co ',
          },
        );

        expect(language.languageCode, 'es');
        expect(language.scriptCode, 'Hant');
        expect(language.regionCode, 'CO');
      },
    );

    test(
      'Given an empty languageCode When parsed Then undetermined is used',
      () {
        final ModelLanguage language = ModelLanguage.fromJson(
          const <String, dynamic>{
            'languageCode': '',
          },
        );

        expect(language, ModelLanguage.undetermined);
      },
    );

    test(
      'Given a whitespace languageCode When parsed Then undetermined is used',
      () {
        final ModelLanguage language = ModelLanguage.fromJson(
          const <String, dynamic>{
            'languageCode': '   ',
            'scriptCode': '   ',
            'regionCode': '   ',
          },
        );

        expect(language, ModelLanguage.undetermined);
      },
    );

    test(
      'Given a missing languageCode When parsed Then undetermined is used',
      () {
        final ModelLanguage language = ModelLanguage.fromJson(
          const <String, dynamic>{},
        );

        expect(language, ModelLanguage.undetermined);
      },
    );

    test(
      'Given null JSON values When parsed Then nulls are normalized safely',
      () {
        final ModelLanguage language = ModelLanguage.fromJson(
          const <String, dynamic>{
            'languageCode': null,
            'scriptCode': null,
            'regionCode': null,
          },
        );

        expect(language, ModelLanguage.undetermined);
      },
    );

    test(
      'Given missing optional codes When parsed Then they remain empty',
      () {
        final ModelLanguage language = ModelLanguage.fromJson(
          const <String, dynamic>{
            'languageCode': 'EN',
          },
        );

        expect(language.languageCode, 'en');
        expect(language.scriptCode, '');
        expect(language.regionCode, '');
      },
    );

    test(
      'Given a mixed-case script When parsed Then it is normalized to title case',
      () {
        final ModelLanguage language = ModelLanguage.fromJson(
          const <String, dynamic>{
            'languageCode': 'zh',
            'scriptCode': 'hAnT',
          },
        );

        expect(language.scriptCode, 'Hant');
      },
    );

    test(
      'Given a one-character script When parsed Then normalization remains safe',
      () {
        final ModelLanguage language = ModelLanguage.fromJson(
          const <String, dynamic>{
            'languageCode': 'x',
            'scriptCode': 'h',
          },
        );

        expect(language.scriptCode, 'H');
      },
    );

    test(
      'Given an input JSON map When parsed Then the original map is not mutated',
      () {
        final Map<String, dynamic> json = <String, dynamic>{
          'languageCode': ' ES ',
          'scriptCode': ' hAnT ',
          'regionCode': ' co ',
        };

        final Map<String, dynamic> original = Map<String, dynamic>.from(json);

        ModelLanguage.fromJson(json);

        expect(json, original);
      },
    );
  });

  group('ModelLanguage JSON round trip', () {
    test(
      'Given a canonical language When serialized and parsed Then equality is preserved',
      () {
        const ModelLanguage original = ModelLanguage.chineseTaiwan;

        final Map<String, dynamic> json = original.toJson();
        final ModelLanguage restored = ModelLanguage.fromJson(json);

        expect(restored, original);
      },
    );

    test(
      'Given a predefined language When serialized and parsed Then its contract is preserved',
      () {
        const ModelLanguage original = ModelLanguage.spanishColombia;

        final ModelLanguage restored = ModelLanguage.fromJson(
          original.toJson(),
        );

        expect(restored, original);
      },
    );
  });

  group('ModelLanguage equality', () {
    test(
      'Given the same reference When compared Then equality uses the identity path',
      () {
        const ModelLanguage language = ModelLanguage.spanishColombia;

        const ModelLanguage sameReference = language;

        expect(identical(language, sameReference), isTrue);
        expect(language == sameReference, isTrue);
      },
    );

    test(
      'Given separate instances with equal fields When compared Then they are equal',
      () {
        const ModelLanguage first = ModelLanguage.spanishColombia;

        const ModelLanguage second = ModelLanguage.spanishColombia;

        expect(identical(first, second), isTrue);
        expect(first, second);
      },
    );

    test(
      'Given an object of another type When compared Then equality is false',
      () {
        const ModelLanguage language = ModelLanguage(
          languageCode: 'es',
        );

        // ignore: unrelated_type_equality_checks
        expect(language == 'es', isFalse);
      },
    );

    test(
      'Given different languageCodes When compared Then equality is false',
      () {
        const ModelLanguage first = ModelLanguage.spanishColombia;

        const ModelLanguage second = ModelLanguage(
          languageCode: 'en',
          regionCode: 'CO',
        );

        expect(first == second, isFalse);
      },
    );

    test(
      'Given different scriptCodes When compared Then equality is false',
      () {
        const ModelLanguage first = ModelLanguage.chineseChina;

        const ModelLanguage second = ModelLanguage(
          languageCode: 'zh',
          scriptCode: 'Hant',
          regionCode: 'CN',
        );

        expect(first == second, isFalse);
      },
    );

    test(
      'Given different regionCodes When compared Then equality is false',
      () {
        const ModelLanguage first = ModelLanguage.spanishColombia;

        const ModelLanguage second = ModelLanguage.spanishMexico;

        expect(first == second, isFalse);
      },
    );

    test(
      'Given equal instances When hashCode is calculated Then hashes are equal',
      () {
        const ModelLanguage first = ModelLanguage.chineseTaiwan;

        const ModelLanguage second = ModelLanguage.chineseTaiwan;

        expect(first, second);
        expect(first.hashCode, second.hashCode);
      },
    );
  });

  group('ModelLanguage predefined languages', () {
    final List<_LanguagePresetCase> cases = <_LanguagePresetCase>[
      const _LanguagePresetCase(
        name: 'undetermined',
        language: ModelLanguage.undetermined,
        languageCode: 'und',
        regionCode: '',
      ),
      const _LanguagePresetCase(
        name: 'spanishColombia',
        language: ModelLanguage.spanishColombia,
        languageCode: 'es',
        regionCode: 'CO',
      ),
      const _LanguagePresetCase(
        name: 'spanishMexico',
        language: ModelLanguage.spanishMexico,
        languageCode: 'es',
        regionCode: 'MX',
      ),
      const _LanguagePresetCase(
        name: 'spanishSpain',
        language: ModelLanguage.spanishSpain,
        languageCode: 'es',
        regionCode: 'ES',
      ),
      const _LanguagePresetCase(
        name: 'spanishArgentina',
        language: ModelLanguage.spanishArgentina,
        languageCode: 'es',
        regionCode: 'AR',
      ),
      const _LanguagePresetCase(
        name: 'spanishChile',
        language: ModelLanguage.spanishChile,
        languageCode: 'es',
        regionCode: 'CL',
      ),
      const _LanguagePresetCase(
        name: 'spanishPeru',
        language: ModelLanguage.spanishPeru,
        languageCode: 'es',
        regionCode: 'PE',
      ),
      const _LanguagePresetCase(
        name: 'englishUnitedStates',
        language: ModelLanguage.englishUnitedStates,
        languageCode: 'en',
        regionCode: 'US',
      ),
      const _LanguagePresetCase(
        name: 'englishUnitedKingdom',
        language: ModelLanguage.englishUnitedKingdom,
        languageCode: 'en',
        regionCode: 'GB',
      ),
      const _LanguagePresetCase(
        name: 'englishCanada',
        language: ModelLanguage.englishCanada,
        languageCode: 'en',
        regionCode: 'CA',
      ),
      const _LanguagePresetCase(
        name: 'englishAustralia',
        language: ModelLanguage.englishAustralia,
        languageCode: 'en',
        regionCode: 'AU',
      ),
      const _LanguagePresetCase(
        name: 'portugueseBrazil',
        language: ModelLanguage.portugueseBrazil,
        languageCode: 'pt',
        regionCode: 'BR',
      ),
      const _LanguagePresetCase(
        name: 'portuguesePortugal',
        language: ModelLanguage.portuguesePortugal,
        languageCode: 'pt',
        regionCode: 'PT',
      ),
      const _LanguagePresetCase(
        name: 'frenchFrance',
        language: ModelLanguage.frenchFrance,
        languageCode: 'fr',
        regionCode: 'FR',
      ),
      const _LanguagePresetCase(
        name: 'germanGermany',
        language: ModelLanguage.germanGermany,
        languageCode: 'de',
        regionCode: 'DE',
      ),
      const _LanguagePresetCase(
        name: 'italianItaly',
        language: ModelLanguage.italianItaly,
        languageCode: 'it',
        regionCode: 'IT',
      ),
      const _LanguagePresetCase(
        name: 'dutchNetherlands',
        language: ModelLanguage.dutchNetherlands,
        languageCode: 'nl',
        regionCode: 'NL',
      ),
      const _LanguagePresetCase(
        name: 'japaneseJapan',
        language: ModelLanguage.japaneseJapan,
        languageCode: 'ja',
        regionCode: 'JP',
      ),
      const _LanguagePresetCase(
        name: 'koreanSouthKorea',
        language: ModelLanguage.koreanSouthKorea,
        languageCode: 'ko',
        regionCode: 'KR',
      ),
      const _LanguagePresetCase(
        name: 'chineseChina',
        language: ModelLanguage.chineseChina,
        languageCode: 'zh',
        scriptCode: 'Hans',
        regionCode: 'CN',
      ),
      const _LanguagePresetCase(
        name: 'chineseTaiwan',
        language: ModelLanguage.chineseTaiwan,
        languageCode: 'zh',
        scriptCode: 'Hant',
        regionCode: 'TW',
      ),
      const _LanguagePresetCase(
        name: 'hindiIndia',
        language: ModelLanguage.hindiIndia,
        languageCode: 'hi',
        regionCode: 'IN',
      ),
      const _LanguagePresetCase(
        name: 'indonesianIndonesia',
        language: ModelLanguage.indonesianIndonesia,
        languageCode: 'id',
        regionCode: 'ID',
      ),
      const _LanguagePresetCase(
        name: 'turkishTurkey',
        language: ModelLanguage.turkishTurkey,
        languageCode: 'tr',
        regionCode: 'TR',
      ),
      const _LanguagePresetCase(
        name: 'polishPoland',
        language: ModelLanguage.polishPoland,
        languageCode: 'pl',
        regionCode: 'PL',
      ),
      const _LanguagePresetCase(
        name: 'swedishSweden',
        language: ModelLanguage.swedishSweden,
        languageCode: 'sv',
        regionCode: 'SE',
      ),
      const _LanguagePresetCase(
        name: 'norwegianNorway',
        language: ModelLanguage.norwegianNorway,
        languageCode: 'no',
        regionCode: 'NO',
      ),
    ];

    for (final _LanguagePresetCase testCase in cases) {
      test(
        'Given ${testCase.name} When inspected Then its canonical configuration is preserved',
        () {
          expect(
            testCase.language.languageCode,
            testCase.languageCode,
          );
          expect(
            testCase.language.scriptCode,
            testCase.scriptCode,
          );
          expect(
            testCase.language.regionCode,
            testCase.regionCode,
          );
        },
      );
    }
  });
  group('ModelLanguage canonicalTag', () {
    test(
      'Given only a languageCode When canonicalTag is read Then it returns the language code',
      () {
        const ModelLanguage language = ModelLanguage(
          languageCode: 'es',
        );

        expect(language.canonicalTag, 'es');
      },
    );

    test(
      'Given languageCode and regionCode When canonicalTag is read Then it returns language-region',
      () {
        const ModelLanguage language = ModelLanguage.spanishColombia;

        expect(language.canonicalTag, 'es-CO');
      },
    );

    test(
      'Given languageCode and scriptCode When canonicalTag is read Then it returns language-script',
      () {
        const ModelLanguage language = ModelLanguage(
          languageCode: 'zh',
          scriptCode: 'Hant',
        );

        expect(language.canonicalTag, 'zh-Hant');
      },
    );

    test(
      'Given languageCode scriptCode and regionCode When canonicalTag is read Then it returns the complete canonical tag',
      () {
        const ModelLanguage language = ModelLanguage.chineseTaiwan;

        expect(language.canonicalTag, 'zh-Hant-TW');
      },
    );

    test(
      'Given the undetermined language When canonicalTag is read Then it returns und',
      () {
        expect(
          ModelLanguage.undetermined.canonicalTag,
          ModelLanguage.undeterminedCode,
        );
      },
    );

    test(
      'Given a predefined language When canonicalTag is read Then it matches its canonical representation',
      () {
        expect(
          ModelLanguage.spanishColombia.canonicalTag,
          'es-CO',
        );

        expect(
          ModelLanguage.chineseChina.canonicalTag,
          'zh-Hans-CN',
        );
      },
    );
  });
  group('ModelLanguage canonicalTag', () {
    test(
      'Given only a languageCode When canonicalTag is read Then it returns the language code',
      () {
        const ModelLanguage language = ModelLanguage(
          languageCode: 'es',
        );

        expect(language.canonicalTag, 'es');
      },
    );

    test(
      'Given languageCode and regionCode When canonicalTag is read Then it returns language-region',
      () {
        const ModelLanguage language = ModelLanguage.spanishColombia;

        expect(language.canonicalTag, 'es-CO');
      },
    );

    test(
      'Given languageCode and scriptCode When canonicalTag is read Then it returns language-script',
      () {
        const ModelLanguage language = ModelLanguage(
          languageCode: 'zh',
          scriptCode: 'Hant',
        );

        expect(language.canonicalTag, 'zh-Hant');
      },
    );

    test(
      'Given languageCode scriptCode and regionCode When canonicalTag is read Then it returns the complete canonical tag',
      () {
        const ModelLanguage language = ModelLanguage.chineseTaiwan;

        expect(language.canonicalTag, 'zh-Hant-TW');
      },
    );

    test(
      'Given the undetermined language When canonicalTag is read Then it returns und',
      () {
        expect(
          ModelLanguage.undetermined.canonicalTag,
          ModelLanguage.undeterminedCode,
        );
      },
    );

    test(
      'Given a predefined language When canonicalTag is read Then it matches its canonical representation',
      () {
        expect(
          ModelLanguage.spanishColombia.canonicalTag,
          'es-CO',
        );

        expect(
          ModelLanguage.chineseChina.canonicalTag,
          'zh-Hans-CN',
        );
      },
    );
  });
}

class _LanguagePresetCase {
  const _LanguagePresetCase({
    required this.name,
    required this.language,
    required this.languageCode,
    required this.regionCode,
    this.scriptCode = '',
  });

  final String name;
  final ModelLanguage language;
  final String languageCode;
  final String scriptCode;
  final String regionCode;
}
