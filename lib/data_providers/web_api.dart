import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

// web server api configs and routers
const _SERVER_IP = "https://bookeeper-api.herokuapp.com";

class FormatedApiResponse {
  int statusCode;
  bool isSuccessful, hasServerError, hasNetworkError;
  dynamic body;
  FormatedApiResponse(http.Response res) {
    statusCode = res.statusCode;
    // case  empty response ( 204 : no Content)
    if (statusCode != 204) body = json.decode(res.body);
    isSuccessful = res.statusCode >= 200 && res.statusCode < 300;
    hasServerError = res.statusCode >= 500;
    hasNetworkError = false;
  }
  FormatedApiResponse.fromNetworkError() {
    isSuccessful = false;
    hasServerError = false;
    hasNetworkError = true;
  }
}

class WebApi {
  String _authToken;

  Future updateAuthToken(String newAuthToken) async {
    _authToken = newAuthToken;
    final secureStorage = FlutterSecureStorage();
    await secureStorage.write(key: "authToken", value: _authToken);
  }

  Future<FormatedApiResponse> signUp(
    String fullName,
    String email,
    String password, [
    File image,
  ]) async {
    try {
      final req = new http.MultipartRequest(
          "POST", Uri.parse("$_SERVER_IP/user/signup"));
      req.fields
          .addAll({'fullName': fullName, 'email': email, 'password': password});
      if (image != null) {
        req.files.add(http.MultipartFile(
          'image',
          image.readAsBytes().asStream(),
          image.lengthSync(),
          filename: basename(image.path),
        ));
      }
      req.headers.addAll({"Content-type": "multipart/form-data"});
      final res =
          FormatedApiResponse(await http.Response.fromStream(await req.send()));
      if (res.isSuccessful) {
        updateAuthToken(res.body["authToken"]);
      }
      return res;
    } on SocketException catch (_) {
      return FormatedApiResponse.fromNetworkError();
    }
  }

  Future<FormatedApiResponse> signIn(String email, String password) async {
    try {
      final res = FormatedApiResponse(await http.post("$_SERVER_IP/user/signin",
          body: {'email': email, 'password': password}));

      if (res.isSuccessful) {
        updateAuthToken(res.body["authToken"]);
      }
      return res;
    } on SocketException catch (_) {
      return FormatedApiResponse.fromNetworkError();
    }
  }

  Future<FormatedApiResponse> getUser() async {
    final secureStorage = FlutterSecureStorage();
    _authToken = await secureStorage.read(key: "authToken");
    try {
      return FormatedApiResponse(await http.get("$_SERVER_IP/user/",
          headers: {HttpHeaders.authorizationHeader: _authToken}));
    } on SocketException catch (_) {
      return FormatedApiResponse.fromNetworkError();
    }
  }

  // bookmarks lists

  Future<FormatedApiResponse> getBookmarksLists() async {
    try {
      return FormatedApiResponse(await http.get("$_SERVER_IP/bookmarks-list/",
          headers: {HttpHeaders.authorizationHeader: _authToken}));
    } on SocketException catch (_) {
      return FormatedApiResponse.fromNetworkError();
    }
  }

  Future<FormatedApiResponse> addBookmarksList(String title) async {
    try {
      return FormatedApiResponse(await http.post("$_SERVER_IP/bookmarks-list/",
          body: {"title": title},
          headers: {HttpHeaders.authorizationHeader: _authToken}));
    } on SocketException catch (_) {
      return FormatedApiResponse.fromNetworkError();
    }
  }

  Future<FormatedApiResponse> deleteBookmarksList(String listId) async {
    try {
      return FormatedApiResponse(await http.delete(
          "$_SERVER_IP/bookmarks-list/$listId",
          headers: {HttpHeaders.authorizationHeader: _authToken}));
    } on SocketException catch (_) {
      return FormatedApiResponse.fromNetworkError();
    }
  }

  Future<FormatedApiResponse> updateBookmarksList(
      String listId, String newTitle) async {
    try {
      return FormatedApiResponse(await http.put(
          "$_SERVER_IP/bookmarks-list/$listId",
          body: {"title": newTitle},
          headers: {HttpHeaders.authorizationHeader: _authToken}));
    } on SocketException catch (_) {
      return FormatedApiResponse.fromNetworkError();
    }
  }

  // bookmarks
  Future<FormatedApiResponse> getBookmarks(String listId) async {
    try {
      return FormatedApiResponse(await http.get("$_SERVER_IP/bookmark/$listId",
          headers: {HttpHeaders.authorizationHeader: _authToken}));
    } on SocketException catch (_) {
      return FormatedApiResponse.fromNetworkError();
    }
  }

  Future<FormatedApiResponse> addBookmark(
      String listId, String title, String content) async {
    try {
      return FormatedApiResponse(await http.post("$_SERVER_IP/bookmark/$listId",
          body: {"title": title, "content": content},
          headers: {HttpHeaders.authorizationHeader: _authToken}));
    } on SocketException catch (_) {
      return FormatedApiResponse.fromNetworkError();
    }
  }

  Future<FormatedApiResponse> deleteBookmark(String id) async {
    try {
      return FormatedApiResponse(await http.delete("$_SERVER_IP/bookmark/$id",
          headers: {HttpHeaders.authorizationHeader: _authToken}));
    } on SocketException catch (_) {
      return FormatedApiResponse.fromNetworkError();
    }
  }

  Future<FormatedApiResponse> updateBookmark(
      String id, String newTitle, String newContent) async {
    try {
      return FormatedApiResponse(await http.put("$_SERVER_IP/bookmark/$id",
          body: {"title": newTitle, "content": newContent},
          headers: {HttpHeaders.authorizationHeader: _authToken}));
    } on SocketException catch (_) {
      return FormatedApiResponse.fromNetworkError();
    }
  }
}

final webApi = WebApi();
