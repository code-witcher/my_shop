import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_shop/models/http_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _userId;
  DateTime? _expiryDate;

  String? get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String? get userId {
    return _userId;
  }

  bool get isAuth {
    return token != null;
  }

  Future<void> addUser(
      String? email, String? password, String urlSegment) async {
    final url = Uri.parse('https://identitytoolkit.googleapis.com/v1/'
        'accounts:$urlSegment?key=AIzaSyCR8fhqoE9gvA6kDuL_wya5GCQ9Y80g6Lk');
    final response = await http.post(
      url,
      body: json.encode(
        {
          'email': email,
          'password': password,
          'returnSecureToken': true,
        },
      ),
    );
    final data = json.decode(response.body) as Map<String, dynamic>;
    if (data.containsKey('error')) {
      throw HttpException(data['error']['message']);
    }
    _token = data['idToken'];
    _userId = data['localId'];
    _expiryDate = DateTime.now().add(
      Duration(
        seconds: int.parse(data['expiresIn']),
      ),
    );
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();

    prefs.setString(
      'userData',
      json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate?.toIso8601String(),
      }),
    );
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final userData =
        json.decode(prefs.getString('userData')!) as Map<String, dynamic>;
    final expiry = DateTime.parse(userData['expiryDate']);
    if (expiry.isBefore(DateTime.now())) {
      return false;
    }
    _token = userData['token'];
    _userId = userData['userId'];
    _expiryDate = expiry;
    notifyListeners();

    return true;
  }

  Future<void> login(String? email, String? password) {
    return addUser(email, password, 'signInWithPassword');
  }

  Future<void> signup(String? email, String? password) {
    return addUser(email, password, 'signUp');
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
}
