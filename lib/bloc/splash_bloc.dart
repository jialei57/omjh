import 'package:get/get.dart';
import 'package:omjh/bloc/bloc.dart';
import 'package:omjh/common/repository.dart';

class SplashBloc implements Bloc {
  final Repository _repository = Get.put(Repository());

  Future<int> getVersion() async {
    return await _repository.getVersion();
  }
  
  @override
  void dispose() {
    
  }
}
