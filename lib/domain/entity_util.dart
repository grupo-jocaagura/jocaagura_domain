part of '../jocaagura_domain.dart';

/// An abstract base class for utility functions or helpers related to entities.
///
/// The [EntityUtil] class is designed to provide a foundation for utility
/// methods or helper functionalities that are associated with managing entities
/// in the application. It can be extended to include specific utilities that
/// streamline operations related to entities.
///
/// Example usage:
///
/// ```dart
/// class UserUtil extends EntityUtil {
///   const UserUtil();
///
///   String formatUserName(String firstName, String lastName) {
///     return '$firstName $lastName';
///   }
///
///   bool isValidEmail(String email) {
///     // Logic to validate an email address
///     return email.contains('@');
///   }
/// }
///
/// const userUtil = UserUtil();
/// print(userUtil.formatUserName('John', 'Doe')); // Outputs: John Doe
/// ```
///
/// This class provides a consistent structure for creating utilities,
/// ensuring reusability and better organization in the application.
abstract class EntityUtil {
  /// Default constructor for entity utilities.
  ///
  /// This ensures that any utility class extending this base class
  /// adheres to a standard structure.
  const EntityUtil();
}
