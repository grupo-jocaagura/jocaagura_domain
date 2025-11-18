part of 'package:jocaagura_domain/jocaagura_domain.dart';

extension StateHttpRequestLifecycleX on StateHttpRequest {
  /// Maps this [StateHttpRequest] to a high-level lifecycle bucket.
  HttpRequestLifecycleEnum get lifecycle {
    final StateHttpRequest state = this;
    if (state is StateHttpRequestCreated) {
      return HttpRequestLifecycleEnum.created;
    }
    if (state is StateHttpRequestRunning) {
      return HttpRequestLifecycleEnum.running;
    }
    if (state is StateHttpRequestSuccess) {
      return HttpRequestLifecycleEnum.succeeded;
    }
    if (state is StateHttpRequestFailure) {
      return HttpRequestLifecycleEnum.failed;
    }
    if (state is StateHttpRequestCancelled) {
      return HttpRequestLifecycleEnum.cancelled;
    }
    return HttpRequestLifecycleEnum.failed;
  }
}
