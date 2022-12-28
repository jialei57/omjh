import 'package:get/get.dart';
import 'package:omjh/bloc/bloc.dart';
import 'package:omjh/common/repository.dart';
import 'package:omjh/entity/character.dart';

class SplashBloc implements Bloc {
  final Repository _repository = Get.put(Repository());

  Future<int> getVersion() async {
    return await _repository.getVersion();
  }

  Future<List<Character>?> getCharacters() async {
    return await _repository.getCharacters();
  }
  
  @override
  void dispose() {
    
  }
}
