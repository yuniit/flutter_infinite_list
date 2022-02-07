import 'package:bloc/bloc.dart';

class PostBlocObserver extends BlocObserver {
  @override
  void onTransition(Bloc bloc, Transition transition) {
    print('transition $transition');

    super.onTransition(bloc, transition);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print('error $error');

    super.onError(bloc, error, stackTrace);
  }
}
