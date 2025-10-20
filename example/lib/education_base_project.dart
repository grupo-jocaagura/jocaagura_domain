import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  // ------------------------------
  // Minimal end-to-end demo
  // ------------------------------
  const ModelCategory science =
      ModelCategory(category: 'sci', description: 'Science');

  const ModelCompetencyStandard std = ModelCompetencyStandard(
    id: 'STD-SCI-001',
    label: 'Understands the composition of water molecules.',
    area: science,
    cineLevel: 2,
    // Example
    code: 'SCI.WAT.001',
  );

  const ModelLearningGoal goal = ModelLearningGoal(
    id: 'GOAL-SCI-001',
    standard: std,
    label: 'Identify elements in common molecules.',
    code: 'SCI.WAT.GOAL.1',
  );

  const ModelPerformanceIndicator ind = ModelPerformanceIndicator(
    id: 'IND-SCI-001',
    modelLearningGoal: goal,
    label: 'Recognizes that water is H2O (two hydrogens and one oxygen).',
    level: PerformanceLevel.basic,
    code: 'SCI.WAT.IND.1',
  );

  final ModelLearningItem item = ModelLearningItem(
    id: '',
    label: 'La molécula de agua se compone de dos átomos de…',
    correctAnswer: 'Hidrógeno y oxígeno',
    wrongAnswerOne: 'Carbono y nitrógeno',
    wrongAnswerTwo: 'Sodio y cloro',
    wrongAnswerThree: 'Helio y neón',
    explanation:
        'El agua (H2O) está formada por dos átomos de hidrógeno y uno de oxígeno.',
    attributes: const <ModelAttribute<dynamic>>[
      ModelAttribute<String>(name: 'youtubeId', value: 'dQw4w9WgXcQ'),
    ],
    achievementOne: ind,
    cineLevel: 2,
    estimatedTimeForAnswer: ModelLearningItem.defaultETA,
    category: science,
  );

  final Map<String, dynamic> map = item.toJson();
  final ModelLearningItem item2 = ModelLearningItem.fromJson(map);
  assert(item == item2);

  // JSON roundtrip
  final String jsonStr = jsonEncode(item.toJson());
  final ModelLearningItem item3 =
      ModelLearningItem.fromJson(Utils.mapFromDynamic(jsonStr));
  assert(item3 == item);

  // Assessment grouping
  final ModelAssessment quiz = ModelAssessment(
    id: 'QZ-1',
    title: 'Molecules – Quick Check',
    items: <ModelLearningItem>[item],
    shuffleItems: true,
    shuffleOptions: true,
    passScore: 1,
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

// ---------------------------------------------------------------------------
// Standards → Goals → Performance Indicators
// ---------------------------------------------------------------------------
