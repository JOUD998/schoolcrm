import 'package:flutter/cupertino.dart';

class Auth extends ChangeNotifier {
  bool _authenticated = false;

  bool get authenticated => _authenticated;

  String? _userName; // Made userName nullable
  String? _role; // Made role nullable

  void login({required Map credentials}) {
    _authenticated = true;
    _role = "2";
    notifyListeners();
  }

  void setName(String userName) {
    _userName = userName;
  }

  String? getName() {
    return _userName;
  }

  String? getRole(String email) {
    switch (email) {
      case "parent@gmail.com":
        setName("Joud");
        notifyListeners();
        return "parent";
      case "parent1@gmail.com":
        setName("Hanady");
        notifyListeners();
        return "parent";
      case "parent2@gmail.com":
        setName("Ruba");
        notifyListeners();
        return "parent";
      case "driver@gmail.com":
        setName("أحمد ياسر");
        notifyListeners();
        return "driver";
      case "counselor@gmail.com":
        setName("Management");
        notifyListeners();
        return "counselor";
      default:
        return null;
    }
  }
}