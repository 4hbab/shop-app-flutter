import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token = '';
  DateTime _expiryDate = DateTime.now();
  String _userId = '';

  bool get isAuth {
    return token != '';
  }

  String get token {
    if (_expiryDate.isAfter(DateTime.now())) {
      return _token;
    }
    return '';
  }

  // Auth(this._token, this._expiryDate, this._userId);
  Future<void> _autheticate(
      String email, String password, String urlSegment) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyB41sR8ncKLiyXkmbaofKRywhr133SZqg8');
    try {
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      );
      notifyListeners();
    } catch (err) {
      rethrow;
    }

    // print(json.decode(response.body));
  }

  Future<void> signup(String email, String password) async {
    return _autheticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return _autheticate(email, password, 'signInWithPassword');
  }
}
