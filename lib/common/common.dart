import '../entity/npc.dart';

class Common {
  static const String authendicationToken = 'authendication_token';
  static const String currentCharacterIndex = 'current_character_index';
  static const String baseIP = '127.0.0.1:3000';
  // static const String baseIP = '192.168.1.131:3000';
  // static const String baseIP = '101.127.158.77:3000';

  static const int initAge = 14;
  static const int initStr = 5;
  static const int initAgi = 5;
  static const int initCon = 5;
  static const int initSpi = 5;

  static String getIconForNpc(Npc npc) {
    switch (npc.name) {
      case '鸡':
        return 'ic_chicken.png';
      case '狼':
        return 'ic_wolf.png';
      case '野猪':
        return 'ic_boar.png';
      default:
        return 'ic_not_found.png';
    }
  }
}
