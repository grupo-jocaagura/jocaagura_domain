part of '../../jocaagura_domain.dart';

/// Abstract service for WebSocket-based NoSQL database operations.
///
/// This service handles JSON-like data interchange. For typed models,
/// implementers can use a generic type `T` and map between `T` and
/// `Map<String, dynamic>`.
///
/// Example:
/// ```dart
/// final ServiceWsDatabase<Map<String, dynamic>> db = FakeServiceWsDatabase();
/// await db.saveDocument(
///   collection: 'users',
///   docId: 'u1',
///   document: {'name': 'Alice', 'age': 30},
/// );
/// final userData = await db.readDocument(
///   collection: 'users',
///   docId: 'u1',
/// );
/// print(userData); // {name: Alice, age: 30}
/// ```
///
/// If you want to work with typed models:
/// ```dart
/// class User {
///   final String name;
///   final int age;
///   User(this.name, this.age);
///
///   Map<String, dynamic> toJson() => {'name': name, 'age': age};
///   static User fromJson(Map<String, dynamic> json) =>
///       User(json['name'], json['age'] as int);
/// }
///
/// final db = FakeServiceWsDatabase<User>(
///   toMap: (user) => user.toJson(),
///   fromMap: (json) => User.fromJson(json),
/// );
/// ```
@Deprecated('Use ServiceWsDb. Map at Repository/Gateway layer.')
abstract class ServiceWsDatabase<T> {
  /// Writes or replaces a document in the specified [collection] with ID [docId].
  ///
  /// Throws [ArgumentError] if [collection] or [docId] is empty.
  Future<void> saveDocument({
    required String collection,
    required String docId,
    required T document,
  });

  /// Reads a single document from the specified [collection] by [docId].
  ///
  /// Returns the document of type `T`, or throws [StateError] if the document
  /// does not exist.
  ///
  /// Throws [ArgumentError] if [collection] or [docId] is empty.
  Future<T> readDocument({
    required String collection,
    required String docId,
  });

  /// Streams real-time updates of a single document.
  ///
  /// Throws [ArgumentError] if [collection] or [docId] is empty.
  Stream<T> documentStream({
    required String collection,
    required String docId,
  });

  /// Streams real-time updates of all documents in the specified [collection].
  ///
  /// Throws [ArgumentError] if [collection] is empty.
  Stream<List<T>> collectionStream({
    required String collection,
  });

  /// Deletes a single document from the specified [collection] by [docId].
  ///
  /// Throws [ArgumentError] if [collection] or [docId] is empty.
  Future<void> deleteDocument({
    required String collection,
    required String docId,
  });

  /// Disposes any internal controllers or streams.
  ///
  /// Call this when the database is no longer needed to avoid memory leaks.
  void dispose();
}
