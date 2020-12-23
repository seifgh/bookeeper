import 'package:bookeeper/data_providers/web_api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  String type;
  Map<String, dynamic> data;
  FormatedApiResponse initUserApiResponse;

  bool isAuthenticated() => type == "auth";
  bool isGuest() => type == "guest";

  Future<User> initialize() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    type = sharedPrefs.getString("userType");

    if (isAuthenticated()) {
      // get user data from api
      final res = await webApi.getUser();
      initUserApiResponse = res;
      if (res.isSuccessful)
        data = res.body;
      else if (res.statusCode == 403) type = null;
    }
    return this;
  }

  Future<User> update(String newType, [Map<String, dynamic> newData]) async {
    final sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.setString("userType", newType);
    type = newType;
    if (!isAuthenticated()) {
      data = null;
    } else if (newData != null) {
      data = newData;
    }
  }
}

final user = User();
