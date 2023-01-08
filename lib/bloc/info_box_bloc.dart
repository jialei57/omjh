import 'package:get/get.dart';
import 'package:omjh/bloc/bloc.dart';
import 'package:omjh/common/repository.dart';
import 'package:omjh/common/shared.dart';
import 'package:omjh/entity/character.dart';

class InfoBoxBloc implements Bloc {
  final Repository _repository = Get.put(Repository());
  final shared = Get.put(Shared());
  List<Character> players = <Character>[].obs;

  @override
  void dispose() {}

  Future updateCharacter() async {
    final Character char = shared.currentCharacter!;
    players = await _repository.updateCharacter(char);
  }
}
