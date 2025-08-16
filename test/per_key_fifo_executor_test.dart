import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('PerKeyFifoExecutor — single key serialization', () {
    test('FIFO order for same key', () async {
      final PerKeyFifoExecutor<String> exec = PerKeyFifoExecutor<String>();
      final List<int> log = <int>[];

      Future<void> enqueue(int i, int delayMs) {
        return exec.withLock<void>('k', () async {
          await Future<void>.delayed(Duration(milliseconds: delayMs));
          log.add(i);
        });
      }

      // Enqueue out-of-order delays to stress FIFO
      await Future.wait(<Future<void>>[
        enqueue(0, 30),
        enqueue(1, 10),
        enqueue(2, 5),
        enqueue(3, 0),
      ]);

      expect(log, <int>[0, 1, 2, 3]); // FIFO by enqueue order, not by delay
    });

    test('Propagates return values', () async {
      final PerKeyFifoExecutor<String> exec = PerKeyFifoExecutor<String>();

      final int result = await exec.withLock<int>('k', () async {
        await Future<void>.delayed(const Duration(milliseconds: 5));
        return 42;
      });

      expect(result, 42);
    });

    test('Propagates async exceptions and continues the queue', () async {
      final PerKeyFifoExecutor<String> exec = PerKeyFifoExecutor<String>();
      final List<String> log = <String>[];

      // First action throws.
      expectLater(
        exec.withLock<void>('k', () async {
          await Future<void>.delayed(const Duration(milliseconds: 5));
          log.add('A-start');
          throw StateError('boom');
        }),
        throwsA(isA<StateError>()),
      );

      // Next action must still run.
      await exec.withLock<void>('k', () async {
        log.add('B-run');
      });

      expect(log, containsAllInOrder(<String>['A-start', 'B-run']));
    });

    test('Propagates sync exceptions and continues the queue', () async {
      final PerKeyFifoExecutor<String> exec = PerKeyFifoExecutor<String>();
      final List<String> log = <String>[];

      expectLater(
        exec.withLock<void>('k', () {
          log.add('C-start');
          throw ArgumentError('nope');
        }),
        throwsA(isA<ArgumentError>()),
      );

      await exec.withLock<void>('k', () async {
        log.add('D-run');
      });

      expect(log, containsAllInOrder(<String>['C-start', 'D-run']));
    });

    test('No double-run: each enqueued action runs exactly once', () async {
      final PerKeyFifoExecutor<String> exec = PerKeyFifoExecutor<String>();
      int count = 0;

      Future<void> unit() => exec.withLock<void>('k', () async {
            count++;
          });

      await Future.wait(<Future<void>>[
        unit(),
        unit(),
        unit(),
        unit(),
        unit(),
      ]);

      expect(count, 5);
    });
  });

  group('PerKeyFifoExecutor — multi-key parallelism', () {
    test('Different keys do not block each other', () async {
      final PerKeyFifoExecutor<String> exec = PerKeyFifoExecutor<String>();
      final List<String> order = <String>[];

      final Future<void> a = exec.withLock<void>('k1', () async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        order.add('A');
      });

      final Future<void> b = exec.withLock<void>('k2', () async {
        // Should complete earlier than A.
        await Future<void>.delayed(const Duration(milliseconds: 5));
        order.add('B');
      });

      await Future.wait(<Future<void>>[a, b]);
      expect(order, <String>['B', 'A']);
    });

    test('High interleaving: preserves per-key FIFO across many keys',
        () async {
      final PerKeyFifoExecutor<int> exec = PerKeyFifoExecutor<int>();
      final Map<int, int> lastSeen = <int, int>{};

      Future<void> enqueue(int key, int seq) async {
        await exec.withLock<void>(key, () async {
          final int prev = lastSeen[key] ?? -1;
          // Must see strictly increasing sequence per key.
          expect(seq, greaterThan(prev));
          lastSeen[key] = seq;
        });
      }

      final List<Future<void>> futures = <Future<void>>[];
      for (int k = 0; k < 10; k++) {
        for (int i = 0; i < 10; i++) {
          futures.add(enqueue(k, i));
        }
      }
      await Future.wait(futures);

      // Each key should have lastSeen == 9
      for (int k = 0; k < 10; k++) {
        expect(lastSeen[k], 9);
      }
    });
  });

  group('PerKeyFifoExecutor — dispose semantics', () {
    test('dispose() does not cancel in-flight action', () async {
      final PerKeyFifoExecutor<String> exec = PerKeyFifoExecutor<String>();
      bool ran = false;

      final Future<void> longRun = exec.withLock<void>('k', () async {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        ran = true;
      });

      exec.dispose(); // Should not cancel longRun.

      await longRun;
      expect(ran, isTrue);
    });

    test('After dispose(), new actions are not chained (may overlap)',
        () async {
      final PerKeyFifoExecutor<String> exec = PerKeyFifoExecutor<String>();
      final Completer<void> startedA = Completer<void>();
      final Completer<void> finishedA = Completer<void>();
      final Completer<void> finishedB = Completer<void>();

      // Start a long action A.
      // ignore: unawaited_futures
      exec.withLock<void>('k', () async {
        startedA.complete();
        await Future<void>.delayed(const Duration(milliseconds: 40));
        finishedA.complete();
      });

      await startedA.future;
      exec.dispose();

      // Schedule B after dispose — it must NOT wait for A.
      // ignore: unawaited_futures
      exec.withLock<void>('k', () async {
        // If B were chained, finishedB would happen after finishedA.
        finishedB.complete();
      });

      // B should complete before A.
      await finishedB.future;
      expect(finishedA.isCompleted, isFalse);

      // Let A finish to avoid dangling futures in the test.
      await finishedA.future;
    });

    test('Idempotent dispose()', () {
      final PerKeyFifoExecutor<String> exec = PerKeyFifoExecutor<String>();
      exec.dispose();
      exec.dispose();
      exec.dispose();
      // No throws means OK.
    });
  });

  group('PerKeyFifoExecutor — edge cases', () {
    test('Nested withLock on different keys inside action', () async {
      final PerKeyFifoExecutor<String> exec = PerKeyFifoExecutor<String>();
      final List<String> log = <String>[];

      await exec.withLock<void>('k1', () async {
        log.add('outer-start');
        await exec.withLock<void>('k2', () async {
          log.add('inner-run');
        });
        log.add('outer-end');
      });

      expect(log, <String>['outer-start', 'inner-run', 'outer-end']);
    });

    test(
      'Nested withLock on the SAME key (not supported) — document behavior',
      () async {
        // We intentionally skip this to avoid deadlock:
        // calling withLock('k') inside withLock('k') is not supported.
        expect(true, isTrue, reason: 'Behavior documented as unsupported.');
      },
      skip: true,
    );

    test('Stress: 100 sequential actions on one key', () async {
      final PerKeyFifoExecutor<String> exec = PerKeyFifoExecutor<String>();
      int sum = 0;
      for (int i = 0; i < 100; i++) {
        // ignore: await_only_futures
        await exec.withLock<void>('k', () async {
          sum += i;
        });
      }
      expect(sum, 4950);
    });

    test('Stress: burst on 10 keys x 50 actions', () async {
      final PerKeyFifoExecutor<int> exec = PerKeyFifoExecutor<int>();
      final Map<int, int> counts = <int, int>{};
      final List<Future<void>> futs = <Future<void>>[];

      for (int k = 0; k < 10; k++) {
        counts[k] = 0;
        for (int i = 0; i < 50; i++) {
          futs.add(
            exec.withLock<void>(k, () async {
              counts[k] = (counts[k] ?? 0) + 1;
            }),
          );
        }
      }

      await Future.wait(futs);
      for (int k = 0; k < 10; k++) {
        expect(counts[k], 50);
      }
    });
  });
}
