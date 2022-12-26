import 'package:get/get.dart';

class AppTranslation extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': {
          'jianghu': 'Jiang Hu',
          'character': 'Chracter',
          'bag': 'Bag',
          'skill': 'Skill',
          'user_name': 'User Name',
          'user_name_cannot_empty': 'User name cannot be empty',
          'password': 'Password',
          'password_cannot_empty': 'User name cannot be empty',
          'login': 'Loign',
          'submit': 'Submit',
          'input_dialog': 'Please input dialog',
        },
        'zh_CN': {
          'jianghu': '江湖',
          'character': '人物',
          'bag': '背包',
          'skill': '武功',
          'user_name': '用户名',
          'user_name_cannot_empty': '用户名不能为空',
          'password': '密码',
          'password_cannot_empty': '密码不能为空',
          'login': '登录',
          'submit': '发送',
          'input_dialog': '请输入对话',
        }
      };
}
