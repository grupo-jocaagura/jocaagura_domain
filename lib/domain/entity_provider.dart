part of '../jocaagura_domain.dart';

/// An abstract class representing a generic entity provider.
///
/// This class serves as a base for defining providers that manage entities
/// within the application. It is intended to be extended or implemented
/// by concrete classes that handle specific types of entities.
///
/// Example usage:
///
/// ```dart
/// class UserProvider extends EntityProvider {
///   final List<User> users = [];
///
///   void addUser(User user) {
///     users.add(user);
///   }
///
///   User? getUserById(String id) {
///     return users.firstWhere((user) => user.id == id, orElse: () => null);
///   }
/// }
/// ```
abstract class EntityProvider {
  /// A constant constructor for [EntityProvider].
  ///
  /// This allows [EntityProvider] to be extended by other classes
  /// while maintaining immutability where possible.
  const EntityProvider();
}
