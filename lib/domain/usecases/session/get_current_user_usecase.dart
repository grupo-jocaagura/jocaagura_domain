part of '../../../../jocaagura_domain.dart';

/// Returns the currently authenticated user from the repository.
///
/// ⚠️ Implementation note:
/// The usecase should **not** take parameters and should return
/// `Future<Either<ErrorItem, UserModel>>`.
/// Current implementation signature differs; align it with the contract below.
///
/// Expected:
/// ```dart
/// class GetCurrentUserUsecase {
///   const GetCurrentUserUsecase(this._repository);
///   final RepositoryAuth _repository;
///
///   Future<Either<ErrorItem, UserModel>> call() {
///     return _repository.getCurrentUser();
///   }
/// }
/// ```
///
/// Example:
/// ```dart
/// void main() async {
///   final RepositoryAuth repo = MyAuthRepository();
///   final GetCurrentUserUsecase usecase = GetCurrentUserUsecase(repo);
///
///   final result = await usecase();
///   result.fold(
///     (e) => print('no current user: ${e.message}'),
///     (u) => print('current user: ${u.email}'),
///   );
/// }
/// ```
class GetCurrentUserUsecase {
  const GetCurrentUserUsecase(this._repository);
  final RepositoryAuth _repository;

  Future<Either<ErrorItem, UserModel>> call() {
    return _repository.getCurrentUser();
  }
}
