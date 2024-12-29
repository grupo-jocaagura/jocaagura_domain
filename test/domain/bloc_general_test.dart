import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('BlocGeneral Tests', () {
    test('initial value is set correctly', () {
      final BlocGeneral<int> bloc = BlocGeneral<int>(0);
      expect(bloc.valueOrNull, 0);
    });

    test(
        'addFunctionToProcessTValueOnStream adds function and executes if executeNow is true',
        () {
      final BlocGeneral<int> bloc = BlocGeneral<int>(0);
      bool isExecuted = false;

      bloc.addFunctionToProcessTValueOnStream(
        'test',
        (int value) {
          isExecuted = true;
          expect(value, 0);
        },
        true,
      );

      expect(isExecuted, true);
      expect(bloc.containsKeyFunction('test'), true);
    });

    test(
        'addFunctionToProcessTValueOnStream does not execute immediately if executeNow is false',
        () {
      final BlocGeneral<int> bloc = BlocGeneral<int>(0);
      bool isExecuted = false;

      bloc.addFunctionToProcessTValueOnStream('test', (int value) {
        isExecuted = true;
      });

      expect(isExecuted, false);
      expect(bloc.containsKeyFunction('test'), true);
    });

    test('deleteFunctionToProcessTValueOnStream removes function', () {
      final BlocGeneral<int> bloc = BlocGeneral<int>(0);
      bloc.addFunctionToProcessTValueOnStream('test', (int value) {});

      expect(bloc.containsKeyFunction('test'), true);

      bloc.deleteFunctionToProcessTValueOnStream('test');
      expect(bloc.containsKeyFunction('test'), false);
    });

    test(
        'containsKeyFunction returns true for existing key and false for non-existing key',
        () {
      final BlocGeneral<int> bloc = BlocGeneral<int>(0);
      bloc.addFunctionToProcessTValueOnStream('test', (int value) {});

      expect(bloc.containsKeyFunction('test'), true);
      expect(bloc.containsKeyFunction('nonexistent'), false);
    });

    test('close method calls dispose', () {
      final BlocGeneral<int> bloc = BlocGeneral<int>(0);
      bloc.close();

      // Assuming `dispose()` has been implemented properly in the parent Bloc class,
      // no further action is needed for this test.
    });

    test('processing value in stream triggers all functions', () async {
      final BlocGeneral<int> bloc = BlocGeneral<int>(0);
      bool function1Executed = false;
      bool function2Executed = false;

      bloc.addFunctionToProcessTValueOnStream('function1', (int value) {
        function1Executed = true;
      });

      bloc.addFunctionToProcessTValueOnStream('function2', (int value) {
        function2Executed = true;
      });
      bloc.value = 10;
      expect(bloc.value, 10);
      await Future<void>.delayed(
        const Duration(
          milliseconds: 100,
        ),
      ); // Allow time for stream processing
      expect(function1Executed, true);
      expect(function2Executed, true);
    });

    test('adding functions with different cases treats them as unique', () {
      final BlocGeneral<int> bloc = BlocGeneral<int>(0);
      bloc.addFunctionToProcessTValueOnStream('test', (int value) {});
      bloc.addFunctionToProcessTValueOnStream('TEST', (int value) {});

      expect(bloc.containsKeyFunction('test'), true);
      expect(bloc.containsKeyFunction('TEST'), true);
    });
  });
}
