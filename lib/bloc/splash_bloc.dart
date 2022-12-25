import 'package:omjh/bloc/bloc.dart';
import 'package:omjh/common/repository.dart';

class SplashBloc implements Bloc {
  final Repository _repository = Repository();

  getVersion() async {
    await _repository.getVersion();
  }
  
  @override
  void dispose() {
    
  }
}
