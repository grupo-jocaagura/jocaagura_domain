part of '../../../jocaagura_domain.dart';

abstract class UseCase<T, P> {
  Future<T> call(P params);
}
