import 'dart:convert';

import 'package:http/http.dart';

abstract class AsyncHttpRequest<T> {
  final Client _client;
  final String _requestUrl;

  AsyncHttpRequest(this._client, this._requestUrl);

  Map<String, dynamic> _convertData(T data);

  performPutRequest(
      String uid, String parentRef, String locationRef, T data) async {
    if (uid != null) {
      var dataMap = <String, dynamic>{"parentRef": parentRef};
      if (data != null) {
        dataMap["data"] = _convertData(data);
      }
      final headers = {
        "Authorization": uid,
        "Content-Type": "application/json"
      };
      final url = _requestUrl + "/" + Uri.encodeComponent(locationRef);
      print("request: $url");
      final response =
          await _client.put(url, headers: headers, body: json.encode(dataMap));
      print("status: ${response.statusCode}");
      if (response.statusCode >= 200 && response.statusCode < 399) {
        return true;
      } else {
        throw Exception("Error ${response.statusCode}");
      }
    } else {
      throw Exception("User not logged in");
    }
  }
  performPostRequest(
      String uid, String parentRef, String locationRef, T data) async {
    if (uid != null) {
      var dataMap = <String, dynamic>{"parentRef": parentRef};
      if (data != null) {
        dataMap["data"] = _convertData(data);
      }
      final headers = {
        "Authorization": uid,
        "Content-Type": "application/json"
      };
      final url = _requestUrl + "/" + Uri.encodeComponent(locationRef);
      print("request: $url");
      final response =
          await _client.post(url, headers: headers, body: json.encode(dataMap));
      print("status: ${response.statusCode}");
      if (response.statusCode >= 200 && response.statusCode < 399) {
        return true;
      } else {
        throw Exception("Error ${response.statusCode}");
      }
    } else {
      throw Exception("User not logged in");
    }
  }
}

class Invitation {
  String email;
  String employeePath;
  String locationPath;

  Invitation(this.email, this.employeePath, this.locationPath);

  Map<String, dynamic> toMap() {
    Map<String, dynamic> result = {};
    result["email"] = email;
    result["employeePath"] = employeePath;
    result["locationPath"] = locationPath;
    return result;
  }
}

class InvitationRequest extends AsyncHttpRequest<Invitation> {
  InvitationRequest(Client client)
      : super(client,
            'https://us-central1-blaulichtplaner.cloudfunctions.net');

  @override
  Map<String, Object> _convertData(Invitation data) {
    return data.toMap();
  }
}

class RegistrationRequest extends AsyncHttpRequest<Map<String, dynamic>> {
  RegistrationRequest(Client client)
      : super(client,
            'https://us-central1-blaulichtplaner.cloudfunctions.net');

  @override
  Map<String, dynamic> _convertData(Map<String, dynamic> data) {
    return data;
  }
}
