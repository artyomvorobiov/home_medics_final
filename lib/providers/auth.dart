import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _lifeTime;
  String _userId;
  Timer _authenticationTimer;

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_lifeTime != null &&
        _lifeTime.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyDhG65EZrA7Eh6FCalyRYOR5_S8He9L_lc';
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(
          {
            'email': email,
            'password': password + '123456',
            'returnSecureToken': true,
          },
        ),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null &&
          responseData['error']['message'] != 'INVALID_EMAIL') {
        // print("ERRRRRRRR $responseData['error']['message']");
        throw HttpException(responseData['error']['message']);
      }
      // print("RESPONSE$responseData");
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      // expiresIn - время валидности токена
      _lifeTime = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      );
      // после устанавления времени валидности токена в вызывемом методе запускаем таймер, по истечении которого мы авторазлогиниваемся
      // _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': _token,
          'userId': _userId,
          'expiryDate': _lifeTime.toIso8601String(),
        },
      );

      // заносим в память данные
      prefs.setString('userData', userData);
    } catch (error) {
      // print("JFKJFOIKJFO");
      throw error;
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }

    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _lifeTime = expiryDate;
    notifyListeners();
    // _autoLogout();
    return true;
  }

  // в этом методе мы удаляем данные из памяти устройства и убираем таймер
  Future<void> logout() async {
    _token = null;
    _userId = null;
    _lifeTime = null;
    if (_authenticationTimer != null) {
      _authenticationTimer.cancel();
      _authenticationTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  // в этом методе мы устанавливаем таймер, который будет вызывать метод logout через определенное время
  // void _autoLogout() {
  //   if (_authenticationTimer != null) {
  //     _authenticationTimer.cancel();
  //   }
  //   final timeToExpiry = _lifeTime.difference(DateTime.now()).inSeconds;
  //   _authenticationTimer = Timer(Duration(seconds: timeToExpiry), logout);
  // }
}
