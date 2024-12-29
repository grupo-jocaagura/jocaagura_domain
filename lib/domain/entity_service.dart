part of '../jocaagura_domain.dart';

/// An abstract base class representing a service for managing entities.
///
/// This class is intended to serve as a foundation for creating services
/// that handle operations related to specific entities in the application.
/// It can be extended to include methods for managing the lifecycle,
/// persistence, or any other business logic specific to an entity.
///
/// Example usage:
///
/// ```dart
/// class UserService extends EntityService {
///   void createUser(User user) {
///     // Logic to create a new user
///   }
///
///   void deleteUser(String userId) {
///     // Logic to delete a user by ID
///   }
/// }
///
/// const userService = UserService();
/// ```
///
/// This abstract class enforces a standard structure for entity services,
/// promoting consistency and reusability across the application.
abstract class EntityService {
  /// Default constructor for an entity service.
  ///
  /// This constructor ensures that any service extending this class
  /// will inherit its contract.
  const EntityService();
}
