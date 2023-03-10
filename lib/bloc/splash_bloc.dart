import 'package:get/get.dart';
import 'package:omjh/bloc/bloc.dart';
import 'package:omjh/common/repository.dart';
import 'package:omjh/entity/character.dart';
import 'package:omjh/entity/quantified_item.dart';
import 'package:omjh/entity/quest.dart';

class SplashBloc implements Bloc {
  final Repository _repository = Get.put(Repository());

  Future<int> getVersion() async {
    return await _repository.getVersion();
  }

  Future<List<Character>?> getCharacters() async {
    return await _repository.getCharacters();
  }

  Future<List<Quest>?> getQuests(int charId) async {
    return await _repository.getQuests(charId);
  }

  Future<List<QuantifiedItem>?> getItems(int charId) async {
    return await _repository.getItems(charId);
  }

  Future<bool> getMap() async {
    return await _repository.getMapFile();
  }

  @override
  void dispose() {}
}
