class Common {
  static const String authendicationToken = 'authendication_token';
  static const String currentCharacterIndex = 'current_character_index';
  static const String baseIP = '192.168.1.131:3000';
  // static const String baseIP = '101.127.158.77:3000';

  static const int initAge = 14;
  static const int initStr = 5;
  static const int initAgi = 5;
  static const int initCon = 5;
  static const int initSpi = 5;

  static String getIconForNpc(int id) {
    switch (id) {
      case 3:
        return 'ic_chicken.png';
      default:
        return 'ic_not_found.png';
    }
  }
}
