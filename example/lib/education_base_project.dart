import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  // ------------------------------
  // Minimal end-to-end demo
  // ------------------------------
  const ModelCategory science =
      ModelCategory(category: 'sci', description: 'Science');

  final CompetencyStandard std = CompetencyStandard(
    id: 'STD-SCI-001',
    label: 'Understands the composition of water molecules.',
    area: science,
    cineLevel: 2,
    // Example
    code: 'SCI.WAT.001',
    version: 1,
    isActive: true,
    createdAtMs: DateTime.now().millisecondsSinceEpoch,
    updatedAtMs: DateTime.now().millisecondsSinceEpoch,
    authorId: 'teacher:ana',
  );

  final LearningGoal goal = LearningGoal(
    id: 'GOAL-SCI-001',
    standardId: std.id,
    label: 'Identify elements in common molecules.',
    code: 'SCI.WAT.GOAL.1',
    version: 1,
    isActive: true,
    createdAtMs: nowMs(),
    updatedAtMs: nowMs(),
    authorId: 'teacher:ana',
  );

  final PerformanceIndicator ind = PerformanceIndicator(
    id: 'IND-SCI-001',
    goalId: goal.id,
    label: 'Recognizes that water is H2O (two hydrogens and one oxygen).',
    level: PerformanceLevel.basic,
    code: 'SCI.WAT.IND.1',
    version: 1,
    isActive: true,
    createdAtMs: nowMs(),
    updatedAtMs: nowMs(),
    authorId: 'teacher:ana',
  );

  final AchievementTriple link = AchievementTriple(
    competencyId: std.id,
    learningGoalId: goal.id,
    performanceIndicatorId: ind.id,
  );

  final LearningItem item = LearningItem(
    id: '',
    // can be empty; implementers may assign UUID during persistence
    label: 'La molécula de agua se compone de dos átomos de…',
    correctAnswer: 'Hidrógeno y oxígeno',
    wrongAnswers: <String>[
      'Carbono y nitrógeno',
      'Sodio y cloro',
      'Helio y neón',
    ],
    explanation:
        'El agua (H2O) está formada por dos átomos de hidrógeno y uno de oxígeno.',
    attributes: <ModelAttribute<dynamic>>[
      const ModelAttribute<String>(name: 'youtubeId', value: 'dQw4w9WgXcQ'),
    ],
    achievements: <AchievementTriple>[link],
    cineLevel: 2,
    estimatedTimeMinutes: 2,
    category: science,
    state: ContentState.published,
    version: 1,
    isActive: true,
    createdAtMs: nowMs(),
    updatedAtMs: nowMs(),
    authorId: 'teacher:ana',
  );

  // Roundtrip: toMap → fromMap
  final Map<String, dynamic> map = item.toMap();
  final LearningItem item2 = LearningItem.fromMap(map);
  assert(item == item2);

  // JSON roundtrip
  final String jsonStr = jsonEncode(item.toJson());
  final LearningItem item3 =
      LearningItem.fromJson(Utils.mapFromDynamic(jsonStr));
  assert(item3 == item);

  // Assessment grouping
  final Assessment quiz = Assessment(
    id: 'QZ-1',
    title: 'Molecules – Quick Check',
    items: <LearningItem>[item],
    shuffleItems: true,
    shuffleOptions: true,
    timeLimitMinutes: 5,
    passScore: 1,
    version: 1,
    isActive: true,
    createdAtMs: nowMs(),
    updatedAtMs: nowMs(),
    authorId: 'teacher:ana',
  );

  // Print some evidence
  debugPrint('Item JSON: $jsonStr');
  debugPrint('Quiz items count: ${quiz.items.length}');
}

int nowMs() => DateTime.now().millisecondsSinceEpoch;

/// Represents who performs or manages the learning content.
///
/// Typical roles are **teacher**, **student**, and **parent**.
///
/// ### Example
/// ```dart
/// final ActorRole role = ActorRole.teacher;
/// ```
enum ActorRole { teacher, student, parent }

/// Publication state of any content entity.
///
/// ### Example
/// ```dart
/// final ContentState s = ContentState.published;
/// ```
enum ContentState { draft, published, archived }

/// Performance level aligned with common MEN usage.
///
/// The typical levels in Colombia are: **low**, **basic**, **high**, **superior**.
/// Use the one that fits your institutional rubric.
///
/// ### Example
/// ```dart
/// final PerformanceLevel lvl = PerformanceLevel.basic;
/// ```
enum PerformanceLevel { low, basic, high, superior }

// ---------------------------------------------------------------------------
// Standards → Goals → Performance Indicators
// ---------------------------------------------------------------------------

/// Learning goal that refines a [CompetencyStandard].
///
/// ### Example
/// ```dart
/// final LearningGoal g = LearningGoal(
///   id: 'GOAL-1',
///   standardId: 'STD-1',
///   label: 'Classify matter by composition',
///   code: 'SCI.MAT.G1',
///   version: 1,
///   isActive: true,
///   createdAtMs: nowMs(),
///   updatedAtMs: nowMs(),
///   authorId: 'teacher:ana',
/// );
/// ```
class LearningGoal {
  const LearningGoal({
    required this.id,
    required this.standardId,
    required this.label,
    required this.code,
    required this.version,
    required this.isActive,
    required this.createdAtMs,
    required this.updatedAtMs,
    required this.authorId,
  });

  factory LearningGoal.fromMap(Map<String, dynamic> map) => LearningGoal(
        id: (map['id'] ?? '') as String,
        standardId: (map['standardId'] ?? '') as String,
        label: (map['label'] ?? '') as String,
        code: (map['code'] ?? '') as String,
        version: (map['version'] ?? 1) as int,
        isActive: (map['isActive'] ?? true) as bool,
        createdAtMs: (map['createdAtMs'] ?? 0) as int,
        updatedAtMs: (map['updatedAtMs'] ?? 0) as int,
        authorId: (map['authorId'] ?? '') as String,
      );

  factory LearningGoal.fromJson(Map<String, dynamic> json) =>
      LearningGoal.fromMap(json);

  final String id;
  final String standardId;
  final String label;
  final String code;
  final int version;
  final bool isActive;
  final int createdAtMs;
  final int updatedAtMs;
  final String authorId;

  LearningGoal copyWith({
    String? id,
    String? standardId,
    String? label,
    String? code,
    int? version,
    bool? isActive,
    int? createdAtMs,
    int? updatedAtMs,
    String? authorId,
  }) =>
      LearningGoal(
        id: id ?? this.id,
        standardId: standardId ?? this.standardId,
        label: label ?? this.label,
        code: code ?? this.code,
        version: version ?? this.version,
        isActive: isActive ?? this.isActive,
        createdAtMs: createdAtMs ?? this.createdAtMs,
        updatedAtMs: updatedAtMs ?? this.updatedAtMs,
        authorId: authorId ?? this.authorId,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'standardId': standardId,
        'label': label,
        'code': code,
        'version': version,
        'isActive': isActive,
        'createdAtMs': createdAtMs,
        'updatedAtMs': updatedAtMs,
        'authorId': authorId,
      };

  Map<String, dynamic> toJson() => toMap();

  @override
  int get hashCode => Object.hash(
        id,
        standardId,
        label,
        code,
        version,
        isActive,
        createdAtMs,
        updatedAtMs,
        authorId,
      );

  @override
  bool operator ==(Object other) =>
      other is LearningGoal &&
      other.id == id &&
      other.standardId == standardId &&
      other.label == label &&
      other.code == code &&
      other.version == version &&
      other.isActive == isActive &&
      other.createdAtMs == createdAtMs &&
      other.updatedAtMs == updatedAtMs &&
      other.authorId == authorId;

  @override
  String toString() => 'LearningGoal(' + id + ', ' + code + ')';
}

/// Performance indicator (most atomic) that belongs to a [LearningGoal].
///
/// ### Example
/// ```dart
/// final PerformanceIndicator ind = PerformanceIndicator(
///   id: 'IND-1', goalId: 'GOAL-1', label: 'Recognizes H2O',
///   level: PerformanceLevel.basic,
///   code: 'SCI.WAT.IND.1',
///   version: 1, isActive: true,
///   createdAtMs: nowMs(), updatedAtMs: nowMs(),
///   authorId: 'teacher:ana',
/// );
/// ```
class PerformanceIndicator {
  const PerformanceIndicator({
    required this.id,
    required this.goalId,
    required this.label,
    required this.level,
    required this.code,
    required this.version,
    required this.isActive,
    required this.createdAtMs,
    required this.updatedAtMs,
    required this.authorId,
  });

  factory PerformanceIndicator.fromMap(Map<String, dynamic> map) =>
      PerformanceIndicator(
        id: (map['id'] ?? '') as String,
        goalId: (map['goalId'] ?? '') as String,
        label: (map['label'] ?? '') as String,
        level: _parsePerformanceLevel(map['level']),
        code: (map['code'] ?? '') as String,
        version: (map['version'] ?? 1) as int,
        isActive: (map['isActive'] ?? true) as bool,
        createdAtMs: (map['createdAtMs'] ?? 0) as int,
        updatedAtMs: (map['updatedAtMs'] ?? 0) as int,
        authorId: (map['authorId'] ?? '') as String,
      );

  factory PerformanceIndicator.fromJson(Map<String, dynamic> json) =>
      PerformanceIndicator.fromMap(json);

  final String id;
  final String goalId;
  final String label;
  final PerformanceLevel level;
  final String code;
  final int version;
  final bool isActive;
  final int createdAtMs;
  final int updatedAtMs;
  final String authorId;

  PerformanceIndicator copyWith({
    String? id,
    String? goalId,
    String? label,
    PerformanceLevel? level,
    String? code,
    int? version,
    bool? isActive,
    int? createdAtMs,
    int? updatedAtMs,
    String? authorId,
  }) =>
      PerformanceIndicator(
        id: id ?? this.id,
        goalId: goalId ?? this.goalId,
        label: label ?? this.label,
        level: level ?? this.level,
        code: code ?? this.code,
        version: version ?? this.version,
        isActive: isActive ?? this.isActive,
        createdAtMs: createdAtMs ?? this.createdAtMs,
        updatedAtMs: updatedAtMs ?? this.updatedAtMs,
        authorId: authorId ?? this.authorId,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'goalId': goalId,
        'label': label,
        'level': level.name,
        'code': code,
        'version': version,
        'isActive': isActive,
        'createdAtMs': createdAtMs,
        'updatedAtMs': updatedAtMs,
        'authorId': authorId,
      };

  Map<String, dynamic> toJson() => toMap();

  @override
  int get hashCode => Object.hash(
        id,
        goalId,
        label,
        level,
        code,
        version,
        isActive,
        createdAtMs,
        updatedAtMs,
        authorId,
      );

  @override
  bool operator ==(Object other) =>
      other is PerformanceIndicator &&
      other.id == id &&
      other.goalId == goalId &&
      other.label == label &&
      other.level == level &&
      other.code == code &&
      other.version == version &&
      other.isActive == isActive &&
      other.createdAtMs == createdAtMs &&
      other.updatedAtMs == updatedAtMs &&
      other.authorId == authorId;

  @override
  String toString() => 'PerformanceIndicator(' + id + ', ' + code + ')';
}

PerformanceLevel _parsePerformanceLevel(dynamic raw) {
  final String s = (raw ?? '').toString();
  for (final PerformanceLevel v in PerformanceLevel.values) {
    if (v.name == s) return v;
  }
  return PerformanceLevel.basic; // fallback
}

/// A triple reference that connects Standard → Goal → Indicator.
///
/// Ensures consistent pairing of the three levels when linking to items.
///
/// ### Example
/// ```dart
/// final AchievementTriple link = AchievementTriple(
///   competencyId: 'STD-1',
///   learningGoalId: 'GOAL-1',
///   performanceIndicatorId: 'IND-1',
/// );
/// ```
class AchievementTriple {
  const AchievementTriple({
    required this.competencyId,
    required this.learningGoalId,
    required this.performanceIndicatorId,
  });

  factory AchievementTriple.fromMap(Map<String, dynamic> map) =>
      AchievementTriple(
        competencyId: (map['competencyId'] ?? '') as String,
        learningGoalId: (map['learningGoalId'] ?? '') as String,
        performanceIndicatorId: (map['performanceIndicatorId'] ?? '') as String,
      );

  factory AchievementTriple.fromJson(Map<String, dynamic> json) =>
      AchievementTriple.fromMap(json);

  final String competencyId;
  final String learningGoalId;
  final String performanceIndicatorId;

  AchievementTriple copyWith({
    String? competencyId,
    String? learningGoalId,
    String? performanceIndicatorId,
  }) =>
      AchievementTriple(
        competencyId: competencyId ?? this.competencyId,
        learningGoalId: learningGoalId ?? this.learningGoalId,
        performanceIndicatorId:
            performanceIndicatorId ?? this.performanceIndicatorId,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'competencyId': competencyId,
        'learningGoalId': learningGoalId,
        'performanceIndicatorId': performanceIndicatorId,
      };

  Map<String, dynamic> toJson() => toMap();

  @override
  int get hashCode =>
      Object.hash(competencyId, learningGoalId, performanceIndicatorId);

  @override
  bool operator ==(Object other) =>
      other is AchievementTriple &&
      other.competencyId == competencyId &&
      other.learningGoalId == learningGoalId &&
      other.performanceIndicatorId == performanceIndicatorId;

  @override
  String toString() =>
      'AchievementTriple(' +
      competencyId +
      '>' +
      learningGoalId +
      '>' +
      performanceIndicatorId +
      ')';
}

// ---------------------------------------------------------------------------
// LearningItem (atomic activity)
// ---------------------------------------------------------------------------
/// Atomic multiple-choice learning item with **one correct** and **three wrong** answers.
///
/// It is linked to 1..3 [AchievementTriple] to support precise profiling against
/// standards/goals/indicators. The item also supports optional `attributes` such as
/// YouTube video IDs.
///
/// ### Example
/// ```dart
/// final LearningItem item = LearningItem(
///   id: '',
///   label: 'La molécula de agua se compone de dos átomos de…',
///   correctAnswer: 'Hidrógeno y oxígeno',
///   wrongAnswers: <String>['Carbono y nitrógeno', 'Sodio y cloro', 'Helio y neón'],
///   explanation: 'El agua (H2O) está formada por dos átomos de hidrógeno y uno de oxígeno.',
///   attributes: <ModelAttribute<dynamic>>[
///     ModelAttribute<String>(key: 'youtubeId', value: 'dQw4w9WgXcQ'),
///   ],
///   achievements: <AchievementTriple>[...],
///   cineLevel: 2,
///   estimatedTimeMinutes: 2,
///   category: ModelCategory(id: 'sci', name: 'Science'),
///   state: ContentState.published,
///   version: 1, isActive: true,
///   createdAtMs: nowMs(), updatedAtMs: nowMs(),
///   authorId: 'teacher:ana',
/// );
/// ```
class LearningItem {
  LearningItem({
    required this.id,
    required this.label,
    required this.correctAnswer,
    required List<String> wrongAnswers,
    required this.explanation,
    required List<ModelAttribute<dynamic>> attributes,
    required List<AchievementTriple> achievements,
    required this.cineLevel,
    required this.estimatedTimeMinutes,
    required this.category,
    required this.state,
    required this.version,
    required this.isActive,
    required this.createdAtMs,
    required this.updatedAtMs,
    required this.authorId,
  })  : wrongAnswers = List<String>.unmodifiable(wrongAnswers),
        attributes = List<ModelAttribute<dynamic>>.unmodifiable(attributes),
        achievements = List<AchievementTriple>.unmodifiable(achievements) {
    if (wrongAnswers.length != 3) {
      throw ArgumentError('wrongAnswers must have exactly 3 items');
    }
    if (achievements.isEmpty || achievements.length > 3) {
      throw ArgumentError('achievements must be between 1 and 3');
    }
    if (cineLevel < 0 || cineLevel > 11) {
      throw ArgumentError('cineLevel must be in 0..11');
    }
  }

  factory LearningItem.fromMap(Map<String, dynamic> map) => LearningItem(
        id: (map['id'] ?? '') as String,
        label: (map['label'] ?? '') as String,
        correctAnswer: (map['correctAnswer'] ?? '') as String,
        wrongAnswers: List<String>.from(
          ((map['wrongAnswers'] ?? <dynamic>[]) as List)
              .map((e) => e.toString()),
        ),
        explanation: (map['explanation'] ?? '') as String,
        attributes: ModelAttribute.listFromDynamicShallow(map['attributes']),
        achievements: List<Map<String, dynamic>>.from(
          Utils.listFromDynamic(map['achievements']),
        ).map(AchievementTriple.fromMap).toList(),
        cineLevel: (map['cineLevel'] ?? 0) as int,
        estimatedTimeMinutes: (map['estimatedTimeMinutes'] ?? 0) as int,
        category:
            ModelCategory.fromJson(map['category'] as Map<String, dynamic>),
        state: _parseContentState(map['state']),
        version: (map['version'] ?? 1) as int,
        isActive: (map['isActive'] ?? true) as bool,
        createdAtMs: (map['createdAtMs'] ?? 0) as int,
        updatedAtMs: (map['updatedAtMs'] ?? 0) as int,
        authorId: (map['authorId'] ?? '') as String,
      );

  factory LearningItem.fromJson(Map<String, dynamic> json) =>
      LearningItem.fromMap(json);

  final String id; // may start empty; persistence layer can assign UUID
  final String label;
  final String correctAnswer;
  final List<String> wrongAnswers; // exactly 3
  final String explanation;
  final List<ModelAttribute<dynamic>> attributes; // e.g., youtubeId
  final List<AchievementTriple> achievements; // 1..3
  final int cineLevel; // 0..11
  final int estimatedTimeMinutes; // UX hint for planners
  final ModelCategory category;
  final ContentState state;
  final int version;
  final bool isActive;
  final int createdAtMs;
  final int updatedAtMs;
  final String authorId;

  List<String> optionsShuffled([int? seed]) {
    final List<String> opts = <String>[correctAnswer, ...wrongAnswers];
    // Simple deterministic shuffle if seed provided
    if (seed == null) {
      opts.shuffle();
      return opts;
    }
    final List<String> result = List<String>.from(opts);
    int s = seed;
    for (int i = result.length - 1; i > 0; i--) {
      s = (s * 1103515245 + 12345) & 0x7fffffff;
      final int j = s % (i + 1);
      final String tmp = result[i];
      result[i] = result[j];
      result[j] = tmp;
    }
    return result;
  }

  LearningItem copyWith({
    String? id,
    String? label,
    String? correctAnswer,
    List<String>? wrongAnswers,
    String? explanation,
    List<ModelAttribute<dynamic>>? attributes,
    List<AchievementTriple>? achievements,
    int? cineLevel,
    int? estimatedTimeMinutes,
    ModelCategory? category,
    ContentState? state,
    int? version,
    bool? isActive,
    int? createdAtMs,
    int? updatedAtMs,
    String? authorId,
  }) =>
      LearningItem(
        id: id ?? this.id,
        label: label ?? this.label,
        correctAnswer: correctAnswer ?? this.correctAnswer,
        wrongAnswers: wrongAnswers ?? this.wrongAnswers,
        explanation: explanation ?? this.explanation,
        attributes: attributes ?? this.attributes,
        achievements: achievements ?? this.achievements,
        cineLevel: cineLevel ?? this.cineLevel,
        estimatedTimeMinutes: estimatedTimeMinutes ?? this.estimatedTimeMinutes,
        category: category ?? this.category,
        state: state ?? this.state,
        version: version ?? this.version,
        isActive: isActive ?? this.isActive,
        createdAtMs: createdAtMs ?? this.createdAtMs,
        updatedAtMs: updatedAtMs ?? this.updatedAtMs,
        authorId: authorId ?? this.authorId,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'label': label,
        'correctAnswer': correctAnswer,
        'wrongAnswers': List<String>.from(wrongAnswers),
        'explanation': explanation,
        'attributes':
            attributes.map((ModelAttribute<dynamic> e) => e.toJson()).toList(),
        'achievements': achievements.map((a) => a.toMap()).toList(),
        'cineLevel': cineLevel,
        'estimatedTimeMinutes': estimatedTimeMinutes,
        'category': category.toJson(),
        'state': state.name,
        'version': version,
        'isActive': isActive,
        'createdAtMs': createdAtMs,
        'updatedAtMs': updatedAtMs,
        'authorId': authorId,
      };

  Map<String, dynamic> toJson() => toMap();

  @override
  int get hashCode => Object.hash(
        id,
        label,
        correctAnswer,
        _deepHash(wrongAnswers),
        explanation,
        _deepHash(attributes),
        _deepHash(achievements),
        cineLevel,
        estimatedTimeMinutes,
        category,
        state,
        version,
        isActive,
        createdAtMs,
        updatedAtMs,
        authorId,
      );

  @override
  bool operator ==(Object other) =>
      other is LearningItem &&
      other.id == id &&
      other.label == label &&
      other.correctAnswer == correctAnswer &&
      _deepEquals(other.wrongAnswers, wrongAnswers) &&
      other.explanation == explanation &&
      _deepEquals(other.attributes, attributes) &&
      _deepEquals(other.achievements, achievements) &&
      other.cineLevel == cineLevel &&
      other.estimatedTimeMinutes == estimatedTimeMinutes &&
      other.category == category &&
      other.state == state &&
      other.version == version &&
      other.isActive == isActive &&
      other.createdAtMs == createdAtMs &&
      other.updatedAtMs == updatedAtMs &&
      other.authorId == authorId;

  @override
  String toString() => 'LearningItem(' + label + ')';
}

ContentState _parseContentState(dynamic raw) {
  final String s = (raw ?? '').toString();
  for (final ContentState v in ContentState.values) {
    if (v.name == s) return v;
  }
  return ContentState.draft;
}

// ---------------------------------------------------------------------------
// Assessment (basic grouping)
// ---------------------------------------------------------------------------
/// A basic assessment (quiz) that groups [LearningItem]s and provides
/// simple delivery parameters (time limit, shuffle).
///
/// ### Example
/// ```dart
/// final Assessment a = Assessment(
///   id: 'QZ-1', title: 'Quick Check', items: <LearningItem>[item],
///   shuffleItems: true, shuffleOptions: true, timeLimitMinutes: 5,
///   passScore: 3, version: 1, isActive: true,
///   createdAtMs: nowMs(), updatedAtMs: nowMs(), authorId: 'teacher:ana',
/// );
/// ```
class Assessment {
  Assessment({
    required this.id,
    required this.title,
    required List<LearningItem> items,
    required this.shuffleItems,
    required this.shuffleOptions,
    required this.timeLimitMinutes,
    required this.passScore,
    required this.version,
    required this.isActive,
    required this.createdAtMs,
    required this.updatedAtMs,
    required this.authorId,
  }) : items = List<LearningItem>.unmodifiable(items);

  factory Assessment.fromMap(Map<String, dynamic> map) => Assessment(
        id: (map['id'] ?? '') as String,
        title: (map['title'] ?? '') as String,
        items: Utils.listFromDynamic(
          map['items'],
        ).map(LearningItem.fromMap).toList(),
        shuffleItems: (map['shuffleItems'] ?? true) as bool,
        shuffleOptions: (map['shuffleOptions'] ?? true) as bool,
        timeLimitMinutes: (map['timeLimitMinutes'] ?? 0) as int,
        passScore: (map['passScore'] ?? 0) as int,
        version: (map['version'] ?? 1) as int,
        isActive: (map['isActive'] ?? true) as bool,
        createdAtMs: (map['createdAtMs'] ?? 0) as int,
        updatedAtMs: (map['updatedAtMs'] ?? 0) as int,
        authorId: (map['authorId'] ?? '') as String,
      );

  factory Assessment.fromJson(Map<String, dynamic> json) =>
      Assessment.fromMap(json);

  final String id;
  final String title;
  final List<LearningItem> items;
  final bool shuffleItems;
  final bool shuffleOptions;
  final int timeLimitMinutes;
  final int passScore; // number of correct answers required
  final int version;
  final bool isActive;
  final int createdAtMs;
  final int updatedAtMs;
  final String authorId;

  Assessment copyWith({
    String? id,
    String? title,
    List<LearningItem>? items,
    bool? shuffleItems,
    bool? shuffleOptions,
    int? timeLimitMinutes,
    int? passScore,
    int? version,
    bool? isActive,
    int? createdAtMs,
    int? updatedAtMs,
    String? authorId,
  }) =>
      Assessment(
        id: id ?? this.id,
        title: title ?? this.title,
        items: items ?? this.items,
        shuffleItems: shuffleItems ?? this.shuffleItems,
        shuffleOptions: shuffleOptions ?? this.shuffleOptions,
        timeLimitMinutes: timeLimitMinutes ?? this.timeLimitMinutes,
        passScore: passScore ?? this.passScore,
        version: version ?? this.version,
        isActive: isActive ?? this.isActive,
        createdAtMs: createdAtMs ?? this.createdAtMs,
        updatedAtMs: updatedAtMs ?? this.updatedAtMs,
        authorId: authorId ?? this.authorId,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'title': title,
        'items': items.map((e) => e.toMap()).toList(),
        'shuffleItems': shuffleItems,
        'shuffleOptions': shuffleOptions,
        'timeLimitMinutes': timeLimitMinutes,
        'passScore': passScore,
        'version': version,
        'isActive': isActive,
        'createdAtMs': createdAtMs,
        'updatedAtMs': updatedAtMs,
        'authorId': authorId,
      };

  Map<String, dynamic> toJson() => toMap();

  @override
  int get hashCode => Object.hash(
        id,
        title,
        _deepHash(items),
        shuffleItems,
        shuffleOptions,
        timeLimitMinutes,
        passScore,
        version,
        isActive,
        createdAtMs,
        updatedAtMs,
        authorId,
      );

  @override
  bool operator ==(Object other) =>
      other is Assessment &&
      other.id == id &&
      other.title == title &&
      _deepEquals(other.items, items) &&
      other.shuffleItems == shuffleItems &&
      other.shuffleOptions == shuffleOptions &&
      other.timeLimitMinutes == timeLimitMinutes &&
      other.passScore == passScore &&
      other.version == version &&
      other.isActive == isActive &&
      other.createdAtMs == createdAtMs &&
      other.updatedAtMs == updatedAtMs &&
      other.authorId == authorId;

  @override
  String toString() =>
      'Assessment(' + id + ', items=' + items.length.toString() + ')';
}

// ---------------------------------------------------------------------------
// Simple deep equality helpers (no external packages)
// ---------------------------------------------------------------------------
bool _deepEquals(Object? a, Object? b) {
  if (a is List && b is List) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (!_deepEquals(a[i], b[i])) return false;
    }
    return true;
  }
  if (a is Map && b is Map) {
    if (a.length != b.length) return false;
    for (final Object? key in a.keys) {
      if (!b.containsKey(key) || !_deepEquals(a[key], b[key])) return false;
    }
    return true;
  }
  return a == b;
}

int _deepHash(Object? a) {
  if (a is List) {
    int h = 0;
    for (final Object? e in a) {
      h = 0x1fffffff & (h + _deepHash(e));
      h = 0x1fffffff & (h + ((0x0007ffff & h) << 10));
      h ^= (h >> 6);
    }
    h = 0x1fffffff & (h + ((0x03ffffff & h) << 3));
    h ^= (h >> 11);
    h = 0x1fffffff & (h + ((0x00003fff & h) << 15));
    return h;
  }
  if (a is Map) {
    int h = 0;
    for (final Object? k in a.keys) {
      h = h ^ _deepHash(k) ^ _deepHash(a[k]);
    }
    return h;
  }
  return a.hashCode;
}
