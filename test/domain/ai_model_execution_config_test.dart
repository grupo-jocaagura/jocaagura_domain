import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('ModelAiExecutionConfig', () {
    const ModelAiExecutionConfig config = ModelAiExecutionConfig(
      temperature: 0,
      topP: 0.95,
      topK: 40,
      maxOutputTokens: 512,
      seed: 7,
      stopSequences: <String>['</json>'],
      deterministicPreferred: true,
    );

    test(
      'Given a canonical config When toJson and fromJson Then preserves the contract',
      () {
        final Map<String, dynamic> json = config.toJson();
        final ModelAiExecutionConfig roundtrip =
            ModelAiExecutionConfig.fromJson(json);

        expect(roundtrip, config);
        expect(roundtrip.toJson(), config.toJson());
      },
    );

    test(
      'Given canonical JSON When fromJson and toJson Then preserves JSON roundtrip',
      () {
        final Map<String, dynamic> json = <String, dynamic>{
          ModelAiExecutionConfigEnum.temperature.name: 0,
          ModelAiExecutionConfigEnum.topP.name: 0.95,
          ModelAiExecutionConfigEnum.topK.name: 40,
          ModelAiExecutionConfigEnum.maxOutputTokens.name: 512,
          ModelAiExecutionConfigEnum.seed.name: 7,
          ModelAiExecutionConfigEnum.stopSequences.name: <String>['</json>'],
          ModelAiExecutionConfigEnum.deterministicPreferred.name: true,
        };

        final ModelAiExecutionConfig parsed =
            ModelAiExecutionConfig.fromJson(json);

        expect(parsed.toJson(), json);
      },
    );

    test(
      'Given a config When copyWith overrides fields Then returns updated copy',
      () {
        final ModelAiExecutionConfig copy = config.copyWith(
          maxOutputTokens: 256,
          stopSequences: <String>['END'],
          deterministicPreferred: false,
        );

        expect(copy.maxOutputTokens, 256);
        expect(copy.stopSequences, <String>['END']);
        expect(copy.deterministicPreferred, false);
        expect(copy, isNot(config));
      },
    );
  });
}
