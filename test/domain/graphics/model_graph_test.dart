import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('ModelGraph.fromJson (lenient strings)', () {
    test(
        'Given non-string titles When fromJson Then stringifies and maps empty to null',
        () {
      // Arrange
      final Map<String, dynamic> json = <String, dynamic>{
        ModelGraphEnum.xAxis.name: <String, dynamic>{
          GraphAxisSpecEnum.title.name: 'X',
          GraphAxisSpecEnum.min.name: 0,
          GraphAxisSpecEnum.max.name: 10,
        },
        ModelGraphEnum.yAxis.name: <String, dynamic>{
          GraphAxisSpecEnum.title.name: 'Y',
          GraphAxisSpecEnum.min.name: 0,
          GraphAxisSpecEnum.max.name: 100,
        },
        ModelGraphEnum.points.name: <Map<String, dynamic>>[
          <String, dynamic>{
            'label': 'A',
            'vector': <String, dynamic>{'dx': 1, 'dy': 10},
          }
        ],
        ModelGraphEnum.title.name: 123, // -> '123'
        ModelGraphEnum.subtitle.name: '', // -> null
        ModelGraphEnum.description.name: true, // -> 'true'
      };

      // Act
      final ModelGraph g = ModelGraph.fromJson(json);

      // Assert
      expect(g.title, '123');
      expect(g.subtitle, isEmpty);
      expect(g.description, 'true');
      expect(g.points.single.label, 'A');
      expect(g.points.single.vector.dx, 1.0);
      expect(g.points.single.vector.dy, 10.0);
    });

    test(
        'Given noisy points list When fromJson Then ignores non-map entries upstream',
        () {
      // Arrange: Utils.listFromDynamic ignora elementos no-mapa
      final List<dynamic> noisy = <dynamic>[
        <String, dynamic>{
          'label': 'A',
          'vector': <String, dynamic>{'dx': 1, 'dy': 2},
        },
        'noise',
        123,
        null,
      ];

      final Map<String, dynamic> json = <String, dynamic>{
        ModelGraphEnum.xAxis.name: <String, dynamic>{
          GraphAxisSpecEnum.title.name: 'X',
          GraphAxisSpecEnum.min.name: 0,
          GraphAxisSpecEnum.max.name: 10,
        },
        ModelGraphEnum.yAxis.name: <String, dynamic>{
          GraphAxisSpecEnum.title.name: 'Y',
          GraphAxisSpecEnum.min.name: 0,
          GraphAxisSpecEnum.max.name: 100,
        },
        ModelGraphEnum.points.name: noisy,
      };

      // Act
      final ModelGraph g = ModelGraph.fromJson(json);

      // Assert
      expect(g.points.length, 1);
      expect(g.points.first.label, 'A');
    });
  });

  group('ModelGraph immutability & equality', () {
    test('Given constructed graph When mutating points Then it is unmodifiable',
        () {
      // Arrange
      final ModelGraph g = ModelGraph(
        xAxis: const GraphAxisSpec(title: 'X', min: 0, max: 2),
        yAxis: const GraphAxisSpec(title: 'Y', min: 0, max: 2),
        points: const <ModelPoint>[
          ModelPoint(label: 'p1', vector: ModelVector(1, 1)),
        ],
      );

      // Act & Assert
      expect(
        () => g.points
            .add(const ModelPoint(label: 'p2', vector: ModelVector(2, 2))),
        throwsUnsupportedError,
      );
    });

    test('Given two identical graphs When comparing Then == and hashCode match',
        () {
      // Arrange
      final ModelGraph a = ModelGraph(
        xAxis: const GraphAxisSpec(title: 'X', min: 0, max: 2),
        yAxis: const GraphAxisSpec(title: 'Y', min: 0, max: 2),
        points: const <ModelPoint>[
          ModelPoint(label: 'p1', vector: ModelVector(1, 1)),
          ModelPoint(label: 'p2', vector: ModelVector(2, 2)),
        ],
        title: 'T',
        subtitle: 'S',
        description: 'D',
      );

      final ModelGraph b = ModelGraph(
        xAxis: const GraphAxisSpec(title: 'X', min: 0, max: 2),
        yAxis: const GraphAxisSpec(title: 'Y', min: 0, max: 2),
        points: const <ModelPoint>[
          ModelPoint(label: 'p1', vector: ModelVector(1, 1)),
          ModelPoint(label: 'p2', vector: ModelVector(2, 2)),
        ],
        title: 'T',
        subtitle: 'S',
        description: 'D',
      );

      // Assert
      expect(a == b, isTrue);
      expect(a.hashCode, b.hashCode);
    });

    test('Given copyWith When overriding Then points remain unmodifiable', () {
      // Arrange
      final ModelGraph g1 = ModelGraph(
        xAxis: const GraphAxisSpec(title: 'X', min: 0, max: 1),
        yAxis: const GraphAxisSpec(title: 'Y', min: 0, max: 1),
        points: const <ModelPoint>[
          ModelPoint(label: 'p1', vector: ModelVector(1, 1)),
        ],
      );

      final List<ModelPoint> newPts = <ModelPoint>[
        const ModelPoint(label: 'p2', vector: ModelVector(2, 2)),
      ];

      // Act
      final ModelGraph g2 = g1.copyWith(points: newPts);

      // Assert
      expect(
        () => g2.points
            .add(const ModelPoint(label: 'x', vector: ModelVector.zero)),
        throwsUnsupportedError,
      );
      expect(g2.points.length, 1);
      expect(g2.points.first.label, 'p2');
    });
  });

  group('ModelGraph.fromTable', () {
    test('Given rows When fromTable Then builds points and axis ranges', () {
      // Arrange
      final List<Map<String, Object?>> rows = <Map<String, Object?>>[
        <String, Object?>{'label': 'A', 'value': 10},
        <String, Object?>{'label': 'B', 'value': 5},
        <String, Object?>{'label': 'C', 'value': 20},
      ];

      // Act
      final ModelGraph g = ModelGraph.fromTable(
        rows,
        xLabelKey: 'label',
        yValueKey: 'value',
        xTitle: 'Idx',
        yTitle: 'Val',
      );

      // Assert
      expect(g.xAxis.title, 'Idx');
      expect(g.yAxis.title, 'Val');
      expect(
        g.points.map((ModelPoint p) => p.label).toList(),
        <String>['A', 'B', 'C'],
      );
      expect(
        g.points.map((ModelPoint p) => p.vector.dx).toList(),
        <double>[1, 2, 3],
      );
      expect(
        g.points.map((ModelPoint p) => p.vector.dy).toList(),
        <double>[10, 5, 20],
      );
      expect(g.xAxis.min, 1);
      expect(g.xAxis.max, 3);
      expect(g.yAxis.min, 5);
      expect(g.yAxis.max, 20);
    });

    test('Given custom xFrom When fromTable Then uses mapping for X', () {
      // Arrange
      final List<Map<String, Object?>> rows = <Map<String, Object?>>[
        <String, Object?>{'label': 'A', 'value': 10},
        <String, Object?>{'label': 'B', 'value': 5},
      ];

      // Act
      final ModelGraph g = ModelGraph.fromTable(
        rows,
        xLabelKey: 'label',
        yValueKey: 'value',
        xFrom: (int i, Map<String, Object?> r) => (i * 10).toDouble(), // 0, 10
      );

      // Assert
      expect(g.points.first.vector.dx, 0);
      expect(g.points.last.vector.dx, 10);
      expect(g.xAxis.min, 0);
      expect(g.xAxis.max, 10);
    });

    test(
        'Given empty rows When fromTable Then axis ranges are 0..0 and points empty',
        () {
      // Arrange
      final List<Map<String, Object?>> rows = <Map<String, Object?>>[];

      // Act
      final ModelGraph g = ModelGraph.fromTable(
        rows,
        xLabelKey: 'label',
        yValueKey: 'value',
      );

      // Assert
      expect(g.points, isEmpty);
      expect(g.xAxis.min, 0);
      expect(g.xAxis.max, 0);
      expect(g.yAxis.min, 0);
      expect(g.yAxis.max, 0);
    });
  });
  group('ModelGraph JSON round-trip', () {
    test(
        'Given a complete graph When toJson→fromJson Then preserves value equality',
        () {
      // Arrange
      final ModelGraph original = ModelGraph(
        xAxis: const GraphAxisSpec(title: 'X', min: 1.0, max: 12.0),
        yAxis: const GraphAxisSpec(title: 'Y', min: 0.0, max: 100.0),
        points: const <ModelPoint>[
          ModelPoint(label: 'Enero', vector: ModelVector(1.0, 10.0)),
          ModelPoint(label: 'Febrero', vector: ModelVector(2.0, 20.0)),
        ],
        title: 'Ventas',
        subtitle: 'Q1',
        description: 'Serie mensual',
      );

      // Act
      final Map<String, dynamic> json = original.toJson();
      final ModelGraph round = ModelGraph.fromJson(json);

      // Assert
      expect(round, original);
      expect(round.points, isA<List<ModelPoint>>());
      expect(
        () => round.points
            .add(const ModelPoint(label: 'X', vector: ModelVector.zero)),
        throwsUnsupportedError,
      ); // sigue siendo unmodifiable tras el round-trip
    });

    test('Given optional titles as null When toJson→fromJson Then remain null',
        () {
      // Arrange
      final ModelGraph original = ModelGraph(
        xAxis: const GraphAxisSpec(title: 'X', min: 0.0, max: 2.0),
        yAxis: const GraphAxisSpec(title: 'Y', min: 0.0, max: 2.0),
        points: const <ModelPoint>[
          ModelPoint(label: 'p1', vector: ModelVector(1.0, 1.0)),
        ],
      );

      // Act
      final ModelGraph round = ModelGraph.fromJson(original.toJson());

      // Assert
      expect(round.title, isEmpty);
      expect(round.subtitle, isEmpty);
      expect(round.description, isEmpty);
      expect(round, original);
    });

    test(
        'Given empty-string titles in JSON When fromJson Then map to null and round-trip stable',
        () {
      // Arrange: simulamos un JSON externo con strings vacíos
      final Map<String, dynamic> json = <String, dynamic>{
        ModelGraphEnum.xAxis.name:
            const GraphAxisSpec(title: 'X', min: 0, max: 1).toJson(),
        ModelGraphEnum.yAxis.name:
            const GraphAxisSpec(title: 'Y', min: 0, max: 1).toJson(),
        ModelGraphEnum.points.name: <Map<String, dynamic>>[
          const ModelPoint(label: 'p', vector: ModelVector(1.0, 1.0)).toJson(),
        ],
        ModelGraphEnum.title.name: '',
        ModelGraphEnum.subtitle.name: '',
        ModelGraphEnum.description.name: '',
      };

      // Act
      final ModelGraph parsed = ModelGraph.fromJson(json);
      final ModelGraph round = ModelGraph.fromJson(parsed.toJson());

      // Assert
      expect(parsed.title, isEmpty);
      expect(parsed.subtitle, isEmpty);
      expect(parsed.description, isEmpty);
      expect(round, parsed);
    });
  });
}
