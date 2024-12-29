import 'package:jocaagura_domain/jocaagura_domain.dart';

class MockEntityBloc extends EntityBloc {
  bool isDisposed = false;

  @override
  void dispose() {
    isDisposed = true;
  }
}
