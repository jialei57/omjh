import 'package:omjh/bloc/bloc.dart';
import 'package:omjh/common/repository.dart';

class LoginBloc implements Bloc {
  final Repository _repository = Repository();

  Future<String?> authendicate(String username, String password) async {
    final token = await _repository.authenticate(username, password);
    return token;
  }

  @override
  void dispose() {}
}
