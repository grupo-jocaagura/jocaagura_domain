part of '../../jocaagura_domain.dart';

/// Enum representing the fields of a dental condition in the [DentalConditionModel].
///
/// Each value corresponds to a specific property of the [DentalConditionModel].
enum DentalConditionEnum {
  /// Unique identifier for the dental condition.
  id,

  /// Identifier for the specific tooth or dental region affected.
  dentalId,

  /// Region of the tooth affected by the condition.
  dentalRegion,

  /// Specific condition diagnosed in the dental region.
  condition,

  /// Date and time when the condition was recorded.
  dateTimeOfRecord,
}

/// Enum representing the various regions of a tooth.
///
/// This enum defines all possible regions of a tooth, including an option `none`
/// for cases where the region does not match any predefined value.
enum DentalRegionEnum {
  /// The masticatory surface of posterior teeth.
  occlusal,

  /// The surface of teeth facing cheeks and lips.
  vestibular,

  /// The surface of a tooth closest to the midline of the dental arch.
  mesial,

  /// The surface of a tooth farthest from the midline of the dental arch.
  distal,

  /// The surface of upper teeth facing the palate.
  palatal,

  /// The surface of teeth facing the tongue.
  lingual,

  /// The surface of teeth near the cheeks.
  buccal,

  /// The surface of teeth near the lips.
  labial,

  /// The cutting edge of anterior teeth.
  incisal,

  /// Related to the gums.
  gingival,

  /// Related to the supporting structures of the teeth.
  periodontal,

  /// Related to the upper jaw.
  maxillary,

  /// Related to the lower jaw.
  mandibular,

  /// Default value for unspecified or unmatched regions.
  none,
}

/// Enum representing various conditions of a tooth.
///
/// This structured representation helps define and manage tooth conditions.
enum ToothConditionEnum {
  /// The tooth is in good health.
  healthy,

  /// The tooth has a cavity.
  cavity,

  /// The tooth has been filled.
  filled,

  /// The tooth is missing.
  missing,

  /// The tooth is broken.
  broken,

  /// The tooth is sensitive.
  sensitive,

  /// The tooth is impacted.
  impacted,

  /// The tooth is decayed.
  decayed,

  /// The tooth has undergone root canal treatment.
  rootCanal,

  /// The tooth has a crown.
  crown,

  /// The tooth needs to be extracted.
  extractionNeeded,

  /// The tooth has orthodontic issues.
  orthodonticIssue,

  /// Default value for unspecified or unmatched conditions.
  none,
}

/// Enum representing unique identifiers for dental quadrants.
///
/// Each value corresponds to a specific tooth within a quadrant.
enum DentalIDEnum {
  /// Quadrant 1 (Upper right)
  q11,
  q12,
  q13,
  q14,
  q15,
  q16,
  q17,
  q18,

  /// Quadrant 2 (Upper left)
  q21,
  q22,
  q23,
  q24,
  q25,
  q26,
  q27,
  q28,

  /// Quadrant 3 (Lower left)
  q31,
  q32,
  q33,
  q34,
  q35,
  q36,
  q37,
  q38,

  /// Quadrant 4 (Lower right)
  q41,
  q42,
  q43,
  q44,
  q45,
  q46,
  q47,
  q48,
}

/// Extension for [DentalIDEnum] to retrieve numerical IDs for dental quadrants.
extension DentalIDExtension on DentalIDEnum {
  /// Returns the numeric ID of a dental quadrant.
  int get id {
    switch (this) {
      case DentalIDEnum.q11:
        return 11;
      case DentalIDEnum.q12:
        return 12;
      case DentalIDEnum.q13:
        return 13;
      case DentalIDEnum.q14:
        return 14;
      case DentalIDEnum.q15:
        return 15;
      case DentalIDEnum.q16:
        return 16;
      case DentalIDEnum.q17:
        return 17;
      case DentalIDEnum.q18:
        return 18;
      case DentalIDEnum.q21:
        return 21;
      case DentalIDEnum.q22:
        return 22;
      case DentalIDEnum.q23:
        return 23;
      case DentalIDEnum.q24:
        return 24;
      case DentalIDEnum.q25:
        return 25;
      case DentalIDEnum.q26:
        return 26;
      case DentalIDEnum.q27:
        return 27;
      case DentalIDEnum.q28:
        return 28;
      case DentalIDEnum.q31:
        return 31;
      case DentalIDEnum.q32:
        return 32;
      case DentalIDEnum.q33:
        return 33;
      case DentalIDEnum.q34:
        return 34;
      case DentalIDEnum.q35:
        return 35;
      case DentalIDEnum.q36:
        return 36;
      case DentalIDEnum.q37:
        return 37;
      case DentalIDEnum.q38:
        return 38;
      case DentalIDEnum.q41:
        return 41;
      case DentalIDEnum.q42:
        return 42;
      case DentalIDEnum.q43:
        return 43;
      case DentalIDEnum.q44:
        return 44;
      case DentalIDEnum.q45:
        return 45;
      case DentalIDEnum.q46:
        return 46;
      case DentalIDEnum.q47:
        return 47;
      case DentalIDEnum.q48:
        return 48;
    }
  }
}

/// Default instance of [DentalConditionModel] used as a placeholder or for testing.
///
/// Provides predefined values for all fields.
final DentalConditionModel dentalConditionModelDefault = DentalConditionModel(
  id: 'xxiv',
  dentalId: 11,
  dentalRegion: DentalRegionEnum.gingival,
  condition: ToothConditionEnum.healthy,
  dateTimeOfRecord: DateTime(2024, 07, 24),
);

/// Represents a dental condition record within an application that manages dental health data.
///
/// This model encapsulates detailed information about a specific dental condition observed in a patient,
/// including the region of the tooth affected, the specific condition, and the time the observation was made.
///
/// Example of using [DentalConditionModel] in a practical application:
///
/// ```dart
/// void main() {
///   var dentalCondition = DentalConditionModel(
///     id: '001',
///     dentalId: 11,  // Representing tooth number 11
///     dentalRegion: DentalRegionEnum.incisal,
///     condition: ToothConditionEnum.cavity,
///     dateTimeOfRecord: DateTime.now(),
///   );
///
///   print('Dental Condition ID: ${dentalCondition.id}');
///   print('Tooth ID: ${dentalCondition.dentalId}');
///   print('Region: ${dentalCondition.dentalRegion}');
///   print('Condition: ${dentalCondition.condition}');
///   print('Recorded on: ${dentalCondition.dateTimeOfRecord}');
/// }
/// ```
class DentalConditionModel extends Model {
  /// Constructs a new instance with the provided [id], [dentalId], [dentalRegion],
  /// [condition], and [dateTimeOfRecord].
  const DentalConditionModel({
    required this.id,
    required this.dentalId,
    required this.dentalRegion,
    required this.condition,
    required this.dateTimeOfRecord,
  });

  /// Deserializes a JSON map into an instance of [DentalConditionModel].
  factory DentalConditionModel.fromJson(Map<String, dynamic> json) {
    return DentalConditionModel(
      id: Utils.getStringFromDynamic(json[DentalConditionEnum.id.name]),
      dentalId: getDentalIDAsInt(
        Utils.getStringFromDynamic(json[DentalConditionEnum.dentalId.name]),
      ),
      dentalRegion: getDentalRegionFromString(
        Utils.getStringFromDynamic(
          json[DentalConditionEnum.dentalRegion.name],
        ),
      ),
      condition: getToothConditionFromString(
        Utils.getStringFromDynamic(json[DentalConditionEnum.condition.name]),
      ),
      dateTimeOfRecord: DateUtils.dateTimeFromDynamic(
        json[DentalConditionEnum.dateTimeOfRecord.name],
      ),
    );
  }

  /// A unique identifier for the dental condition record.
  final String id;

  /// The specific ID of the tooth or dental region affected.
  final int dentalId;

  /// The region of the tooth affected by the condition.
  final DentalRegionEnum dentalRegion;

  /// The specific condition diagnosed in the dental region.
  final ToothConditionEnum condition;

  /// The date and time when the condition was recorded.
  final DateTime dateTimeOfRecord;

  /// Creates a copy of this [DentalConditionModel] with optional new values.
  @override
  DentalConditionModel copyWith({
    String? id,
    ToothConditionEnum? condition,
    DentalRegionEnum? dentalRegion,
    int? dentalId,
    DateTime? dateTimeOfRecord,
  }) {
    return DentalConditionModel(
      id: id ?? this.id,
      dentalId: dentalId ?? this.dentalId,
      dentalRegion: dentalRegion ?? this.dentalRegion,
      condition: condition ?? this.condition,
      dateTimeOfRecord: dateTimeOfRecord ?? this.dateTimeOfRecord,
    );
  }

  /// Serializes this [DentalConditionModel] into a JSON map.
  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      DentalConditionEnum.id.name: id,
      DentalConditionEnum.dentalId.name: dentalId,
      DentalConditionEnum.dentalRegion.name: dentalRegion.name,
      DentalConditionEnum.condition.name: condition.name,
      DentalConditionEnum.dateTimeOfRecord.name:
          DateUtils.dateTimeToString(dateTimeOfRecord),
    };
  }

  /// Converts a string into a [DentalRegionEnum].
  static DentalRegionEnum getDentalRegionFromString(String region) {
    switch (region.toLowerCase()) {
      case 'occlusal':
        return DentalRegionEnum.occlusal;
      case 'vestibular':
        return DentalRegionEnum.vestibular;
      case 'mesial':
        return DentalRegionEnum.mesial;
      case 'distal':
        return DentalRegionEnum.distal;
      case 'palatal':
        return DentalRegionEnum.palatal;
      case 'lingual':
        return DentalRegionEnum.lingual;
      case 'buccal':
        return DentalRegionEnum.buccal;
      case 'labial':
        return DentalRegionEnum.labial;
      case 'incisal':
        return DentalRegionEnum.incisal;
      case 'gingival':
        return DentalRegionEnum.gingival;
      case 'periodontal':
        return DentalRegionEnum.periodontal;
      case 'maxillary':
        return DentalRegionEnum.maxillary;
      case 'mandibular':
        return DentalRegionEnum.mandibular;
      default:
        return DentalRegionEnum.none;
    }
  }

  /// Converts a string into a [ToothConditionEnum].
  static ToothConditionEnum getToothConditionFromString(String condition) {
    switch (condition.toLowerCase()) {
      case 'healthy':
        return ToothConditionEnum.healthy;
      case 'cavity':
        return ToothConditionEnum.cavity;
      case 'filled':
        return ToothConditionEnum.filled;
      case 'missing':
        return ToothConditionEnum.missing;
      case 'broken':
        return ToothConditionEnum.broken;
      case 'sensitive':
        return ToothConditionEnum.sensitive;
      case 'impacted':
        return ToothConditionEnum.impacted;
      case 'decayed':
        return ToothConditionEnum.decayed;
      case 'root canal':
        return ToothConditionEnum.rootCanal;
      case 'crown':
        return ToothConditionEnum.crown;
      case 'extraction needed':
        return ToothConditionEnum.extractionNeeded;
      case 'orthodontic issue':
        return ToothConditionEnum.orthodonticIssue;
      default:
        return ToothConditionEnum.none;
    }
  }

  /// Converts a string into a [DentalIDEnum].
  static DentalIDEnum getDentalIDFromString(String id) {
    switch (id.toLowerCase()) {
      case '11':
        return DentalIDEnum.q11;
      case '12':
        return DentalIDEnum.q12;
      case '13':
        return DentalIDEnum.q13;
      case '14':
        return DentalIDEnum.q14;
      case '15':
        return DentalIDEnum.q15;
      case '16':
        return DentalIDEnum.q16;
      case '17':
        return DentalIDEnum.q17;
      case '18':
        return DentalIDEnum.q18;
      case '21':
        return DentalIDEnum.q21;
      case '22':
        return DentalIDEnum.q22;
      case '23':
        return DentalIDEnum.q23;
      case '24':
        return DentalIDEnum.q24;
      case '25':
        return DentalIDEnum.q25;
      case '26':
        return DentalIDEnum.q26;
      case '27':
        return DentalIDEnum.q27;
      case '28':
        return DentalIDEnum.q28;
      case '31':
        return DentalIDEnum.q31;
      case '32':
        return DentalIDEnum.q32;
      case '33':
        return DentalIDEnum.q33;
      case '34':
        return DentalIDEnum.q34;
      case '35':
        return DentalIDEnum.q35;
      case '36':
        return DentalIDEnum.q36;
      case '37':
        return DentalIDEnum.q37;
      case '38':
        return DentalIDEnum.q38;
      case '41':
        return DentalIDEnum.q41;
      case '42':
        return DentalIDEnum.q42;
      case '43':
        return DentalIDEnum.q43;
      case '44':
        return DentalIDEnum.q44;
      case '45':
        return DentalIDEnum.q45;
      case '46':
        return DentalIDEnum.q46;
      case '47':
        return DentalIDEnum.q47;
      case '48':
        return DentalIDEnum.q48;
      default:
        return DentalIDEnum.q11;
    }
  }

  /// Converts a dental ID string into its integer representation.
  static int getDentalIDAsInt(String id) => getDentalIDFromString(id).id;

  /// Determines if two [DentalConditionModel] instances are equal.
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is DentalConditionModel &&
            runtimeType == other.runtimeType &&
            hashCode == other.hashCode;
  }

  /// Returns the hash code for this [DentalConditionModel].
  @override
  int get hashCode => Object.hash(
        id,
        dentalRegion,
        condition,
        dateTimeOfRecord,
        dentalId,
      );
}
