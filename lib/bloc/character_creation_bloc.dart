import 'package:omjh/bloc/bloc.dart';
import 'package:omjh/common/repository.dart';
import 'package:get/get.dart';
import 'package:omjh/common/shared.dart';
import 'package:omjh/entity/character.dart';

class CharacterCreationBloc extends Bloc {
  final Repository _repository = Get.put(Repository());
  final Shared shared = Get.put(Shared());
  String sex = '';
  String name = '';
  @override
  void dispose() {}

  Future<bool> createCharacter() async {
    Map<String, dynamic> status = {};
    status['age'] = 14;
    Character char = Character(null, name, sex, 1, status, null);
    bool success = await _repository.createCharacter(char);
    if (!success) {
      return false;
    }

    shared.characters = await _repository.getCharacters() ?? [];
    await shared.setChar(shared.characters.length - 1);
    shared.quests = await _repository.getQuests(shared.currentCharacter!.id!) ?? [];
    return true;
  }
}
