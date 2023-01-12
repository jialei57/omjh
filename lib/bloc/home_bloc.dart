// import 'dart:async';

// import 'package:get/get.dart';
// import 'package:omjh/bloc/bloc.dart';
// import 'package:omjh/common/action_cable_helper.dart';
// import 'package:omjh/common/repository.dart';
// import 'package:omjh/common/shared.dart';

// class HomeBloc extends Bloc {
//   final Repository _repository = Get.put(Repository());
//   final shared = Get.put(Shared());
//   final actionCableHelper = Get.put(ActionCableHelper());

//   @override
//   void dispose() {}

//   void _heartBeat() {
//     Timer.periodic(const Duration(minutes: 3), (timer) {
//       _repository.updateCharacter(shared.currentCharacter!);
//     });
//   }
// }
