part of '../../jocaagura_domain.dart';

/// Represents a main menu item in an application.
///
/// This model is designed to encapsulate the properties of a main menu item,
/// including the icon to display, the action to perform when the menu item is clicked,
/// a label to describe the menu item, and an optional description for additional context.
///
/// Example of using [ModelMainMenuModel] in a practical application:
///
/// ```dart
/// void main() {
///   var menuItem = ModelMainMenuModel(
///     iconData: Icons.home,
///     onPressed: () {
///       print('Home pressed');
///     },
///     label: 'Home',
///     description: 'Go to the home screen',
///   );
///
///   print('Menu Label: ${menuItem.label}');
///   print('Description: ${menuItem.description}');
///   menuItem.onPressed();
/// }
/// ```
///
/// This class can be used to build dynamic and interactive menus in Flutter applications.
class ModelMainMenuModel extends Model {
  /// Constructs a new [ModelMainMenuModel] with the given [iconData], [onPressed],
  /// [label], and an optional [description].
  ///
  /// The [description] field defaults to an empty string if not provided.
  const ModelMainMenuModel({
    required this.iconData,
    required this.onPressed,
    required this.label,
    this.description = '',
  });

  /// The icon to display for the menu item.
  final IconData iconData;

  /// The action to execute when the menu item is pressed.
  final void Function() onPressed;

  /// The label that describes the menu item.
  final String label;

  /// An optional description providing additional context for the menu item.
  final String description;

  /// Creates a copy of this [ModelMainMenuModel] with optional new values.
  ///
  /// This method allows immutability while supporting modifications to the model.
  @override
  ModelMainMenuModel copyWith({
    IconData? iconData,
    void Function()? onPressed,
    String? label,
    String? description,
  }) {
    return ModelMainMenuModel(
      iconData: iconData ?? this.iconData,
      onPressed: onPressed ?? this.onPressed,
      label: label ?? this.label,
      description: description ?? this.description,
    );
  }

  /// Determines if two [ModelMainMenuModel] instances are equal.
  ///
  /// Two instances are considered equal if their [iconData], [label], and [description] fields are the same.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelMainMenuModel &&
          runtimeType == other.runtimeType &&
          iconData == other.iconData &&
          label == other.label &&
          description == other.description &&
          hashCode == other.hashCode;

  /// Returns the hash code for this [ModelMainMenuModel].
  ///
  /// The hash code is generated using the lowercase version of the [label] field to ensure case-insensitive comparison.
  @override
  int get hashCode => label.toLowerCase().hashCode;

  /// Converts this [ModelMainMenuModel] into a JSON map.
  ///
  /// Note: The [toJson] method currently returns an empty map as serialization is not implemented for this class.
  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{};
  }
}
