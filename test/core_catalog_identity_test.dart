import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';
import 'package:jocaagura_domain_core/jocaagura_domain_models.dart' as core;

void main() {
  test(
    'the historical facade exposes canonical model types across families',
    () {
      final Map<Type, Type> types = <Type, Type>{
        UserModel: core.UserModel,
        AddressModel: core.AddressModel,
        PersonModel: core.PersonModel,
        ModelAcl: core.ModelAcl,
        ModelAiMessage: core.ModelAiMessage,
        ModelDocDocument: core.ModelDocDocument,
        ModelGroup: core.ModelGroup,
        ModelSheetBook: core.ModelSheetBook,
        ModelVehicle: core.ModelVehicle,
        ModelVector: core.ModelVector,
        ScreenSizeConfig: core.ScreenSizeConfig,
        ReadParams: core.ReadParams,
      WriteParams<Model>: core.WriteParams<core.Model>,
        DeleteManyParams: core.DeleteManyParams,
      };
      for (final MapEntry<Type, Type> pair in types.entries) {
        expect(identical(pair.key, pair.value), isTrue, reason: '${pair.key}');
      }
      expect(identical(defaultErrorItem, core.defaultErrorItem), isTrue);
    expect(identical(defaultModelVector, core.defaultModelVector), isTrue);
      expect(identical(ModelMainMenuModel, core.ModelMainMenuModel), isFalse);
    },
  );
}
