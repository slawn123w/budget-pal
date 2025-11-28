import 'package:flutter/material.dart';
import '../models/user.dart';


class AuthProvider with ChangeNotifier {
  Appuser? _user;
  Appuser? get user => _user;
  bool get isauthenticated => _user != null;

  void login(String email, String pass) {
    // TODO: Implement login logic
  }
}