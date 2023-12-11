import 'package:get/get.dart';
import 'package:omjh/bloc/bloc.dart';
import 'package:omjh/common/repository.dart';
import 'package:omjh/common/shared.dart';

class ItemsBloc extends Bloc {
  final Repository _repository = Get.put(Repository());
  final shared = Get.put(Shared());

  @override
  void dispose() {}

  List<String> infoMessages = <String>[].obs;

  Future equip(int iid) async {
    return await _repository.equip(shared.currentCharacter!.id!, iid);
  }

  Future takeOff(String type) async {
    return await _repository.takeOff(shared.currentCharacter!.id!, type);
  }
}
