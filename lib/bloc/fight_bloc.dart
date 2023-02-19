import 'package:get/get.dart';
import 'package:omjh/bloc/bloc.dart';
import 'package:omjh/common/repository.dart';
import 'package:omjh/common/shared.dart';
import 'package:omjh/entity/reward.dart';

class FightBloc extends Bloc {
  final Repository _repository = Get.put(Repository());
  final shared = Get.put(Shared());

  @override
  void dispose() {}

  List<String> infoMessages = <String>[].obs;

  Future<Reward?> killedNpc(List<int> nids) async {
    return await _repository.killedNpc(shared.currentCharacter!.id!, nids);
  }
}
