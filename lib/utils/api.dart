import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http_parser/src/media_type.dart';
import 'package:http/http.dart' as http;

import 'package:geocoder/geocoder.dart' show Coordinates;

import 'package:wemeet/config.dart';
import 'package:wemeet/providers/data.dart';

import 'package:wemeet/models/place.dart';

class WeMeetAPI {

  String _baseUrl = WeMeetConfig.baseUrl;
  String _mapsKey = WeMeetConfig.mapsKey;
  HttpClient _httpClient = new HttpClient();
  DataProvider _dP = DataProvider();

  // Get the url
  String _getUrl(String endpoint){
    endpoint = endpoint.replaceAll("//", "/");

    if(endpoint.startsWith("/")){
      endpoint = endpoint.substring(1);
    }

    if (endpoint.endsWith("/")){
      endpoint = endpoint.substring(0, endpoint.length - 1);
    }
    return "$_baseUrl$endpoint";
  }

  // Compose the query data
  String composeQuery(Map data){
    if(data == null) return "";
    var params = [];
    data.forEach((key, value){
      String v = "$value";
      params.add("$key=${Uri.encodeComponent(v)}");
    });
    return params.join("&");
  }

  // Do GET request
  Future get(String endpoint, {Map query, bool token = true, String reqToken}) async {

    String url =
        _getUrl(endpoint) + ((query != null) ? "?" + composeQuery(query) : "");

    Uri uri = Uri.parse(url);
    print("GET: " + uri.toString());

    var request = await _httpClient.openUrl("GET", uri);
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json; charset=utf-8');
    if(token){
      request.headers.set(HttpHeaders.authorizationHeader, "Bearer ${reqToken ?? _dP.token}");
    }
    
    var response = await request.close();
    var responseBody = await response.transform(utf8.decoder).join();
    var dataResponse = await jsonDecode(responseBody);

    if(response.statusCode >= 300){
      throw dataResponse;
    }

    return dataResponse;
  }

  // Do POST request
  Future post(String endpoint, {dynamic data, bool token = true, String reqToken}) async{

    String u = _getUrl(endpoint);
    Uri uri = Uri.parse(u);
    print("POST: " + uri.toString());
    
    var request = await _httpClient.postUrl(uri);
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json; charset=utf-8');
    if(token){
      request.headers.set(HttpHeaders.authorizationHeader, "Bearer ${reqToken ?? _dP.token}");
    }
    if(data != null){
      request.write(jsonEncode(data));
    }
    var response = await request.close();
    var responseBody = await response.transform(utf8.decoder).join();
    var dataResponse = await jsonDecode(responseBody);

    print(responseBody.runtimeType);

    if(response.statusCode >= 300){
      throw dataResponse;
    }

    return dataResponse;
  }

  // Do Put request
  Future put(String endpoint, {dynamic data, bool token = true, String reqToken}) async {

    String u = _getUrl(endpoint);
    Uri uri = Uri.parse(u);
    print("PUT: " + uri.toString());

    var request = await _httpClient.putUrl(uri);
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json; charset=utf-8');
    if(token){
      request.headers.set(HttpHeaders.authorizationHeader, "Bearer ${reqToken ??_dP.token}");
    }
    if(data != null){
      request.write(jsonEncode(data));
    }
    var response = await request.close();
    var responseBody = await response.transform(utf8.decoder).join();
    var dataResponse = await jsonDecode(responseBody);

    if(response.statusCode >= 300){
      throw dataResponse;
    }

    return dataResponse;
  }

  // Do DELETE request
  Future delete(String endpoint, {dynamic data, bool token = true, String reqToken}) async {

    String u = _getUrl(endpoint);
    Uri uri = Uri.parse(u);
    print("DELETE: " + uri.toString());

    var request = await _httpClient.deleteUrl(uri);
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json; charset=utf-8');
    if(token){
      request.headers.set(HttpHeaders.authorizationHeader, "Bearer ${reqToken ?? _dP.token}");
    }
    if(data != null){
      request.write(jsonEncode(data));
    }
    var response = await request.close();
    var responseBody = await response.transform(utf8.decoder).join();
    var dataResponse = await jsonDecode(responseBody);

    if(response.statusCode >= 300){
      throw dataResponse;
    }

    return dataResponse;
  }

  // Upload a file
  Future upload(String endpoint, String filePath, String imageType) async {
    String u = _getUrl(endpoint);
    Uri uri = Uri.parse(u);
    print("UPLOAD: " + uri.toString());

    String ext = filePath.split(".").last;

    var request = http.MultipartRequest('POST', uri);
    request.headers.addAll({
      "Authorization": 'Bearer ' + _dP.token,
      "accept": "application/json",
      "Content-Type": 'multipart/form-data'
    });
    request.files.add(
      await http.MultipartFile.fromPath(
        "file", 
        filePath,
        contentType: MediaType('image', ext)
      )
    );
    request.fields['imageType'] = imageType;
    var response = await request.send();
    final res = await http.Response.fromStream(response);
    var responseBody = utf8.decode(res.bodyBytes);
    var dataResponse = await jsonDecode(responseBody);

    if(response.statusCode >= 300){
      throw dataResponse;
    }
    return dataResponse;
  }

  // Get Autocomplete predictions
  Future<List<PlacePrediction>> getPredictions(Coordinates location, String query) async{
    String url ="https://maps.googleapis.com/maps/api/place/autocomplete/json?location=${location?.latitude},${location?.longitude}&radius=10000&input=$query&key=$_mapsKey";

    var client = new http.Client();
    var res = await client.get(url);
    await client.close();

    var resBody = await jsonDecode(res.body);

    if(res.statusCode >= 300){
      throw resBody;
    }

    List preds = resBody["predictions"];
    return preds.map((x) => PlacePrediction.fromMap(x)).toList();
  }

  // Get placemark from predictions
  Future<Placemark> getPlace(String placeId) async{
    String url = "https://maps.googleapis.com/maps/api/place/details/json?&placeid=$placeId&key=$_mapsKey";
    print(url);
    var client = new http.Client();
    var res = await client.get(url);
    await client.close();

    var resBody = await jsonDecode(res.body);

    if(res.statusCode >= 300){
      throw resBody;
    }
    return Placemark.fromMap(resBody);
  }

} 

WeMeetAPI api = WeMeetAPI();