import 'dart:convert';
import 'dart:ui';
import 'package:erthquake_app/models/earthquake_model.dart';
import 'package:erthquake_app/utils/helper_function.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as gc;

class AppDataProvider with ChangeNotifier{

  final baseUrl = Uri.parse("https://earthquake.usgs.gov/fdsnws/event/1/query?");

  Map<String,dynamic> queryParams = {

  };

  double _maxRadiusKm = 500;
  double _latitude = 0.0, _longitude = 0.0;
  String _startTime = "", _endTime = "";
  String _orderBy = "time";
  String? _currentCity;
  final double _maxRadiusKmThreshold = 20001.6;
  bool _shouldUseLocation = false;
  EarthquakeModel? earthquakeModel;
  String _minmagnitude = "4";


  String get minmagnitude => _minmagnitude;

  double get maxRadiusKm => _maxRadiusKm;

  double get latitude => _latitude;

  get longitude => _longitude;

  String get startTime => _startTime;

  get endTime => _endTime;

  String get orderBy => _orderBy;

  String? get currentCity => _currentCity;

  double get maxRadiusKmThreshold => _maxRadiusKmThreshold;

  bool get shouldUseLocation => _shouldUseLocation;

  bool get hasDataLoaded => earthquakeModel != null;

  void setOrder(String value){
    _orderBy = value;
    notifyListeners();
    _setQueryParams();
    getEarthquakeData();
  }

  _setQueryParams(){
    queryParams["format"] = "geojson";
    queryParams["starttime"] = _startTime;
    queryParams["endtime"] = _endTime;
    queryParams["minmagnitude"] = _minmagnitude;
    queryParams["orderby"] = _orderBy;
    queryParams["limit"] = "500";
    queryParams["latitude"] = "$_latitude";
    queryParams["longitude"] = "$_longitude";
    queryParams["maxradiuskm"] = "$_maxRadiusKm";
  }

  init(){
    _startTime = getFormattedDateTime(DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch);
    _endTime = getFormattedDateTime(DateTime.now().millisecondsSinceEpoch);
    _maxRadiusKm = maxRadiusKmThreshold;
    _setQueryParams();
    getEarthquakeData();
  }

  Color getAlertColor(String color){
    return switch(color){
      "green" => Colors.green,
      "yellow" => Colors.yellow,
      "orange" => Colors.orange,
      _ => Colors.red,
    };
  }

  Future<void> getEarthquakeData()async{
    final uri = Uri.https(baseUrl.authority, baseUrl.path, queryParams);
    try{
      final response = await http.get(uri);
      if(response.statusCode == 200);
      final json = jsonDecode(response.body);
      earthquakeModel = EarthquakeModel.fromJson(json);
      print("Total Data is == ${earthquakeModel!.features!.length}");
      notifyListeners();
    }catch(error){
      print(error.toString());
    }
  }

  void setStartTime(String date) {
    _startTime = date;
    _setQueryParams();
    notifyListeners();
  }

  void setEndTime(String date) {
    _endTime = date;
    _setQueryParams();
    notifyListeners();
    }
  void setMagnitude(String value){
    _minmagnitude = value;
    _setQueryParams();
    notifyListeners();
  }

  Future<void> setLocation(bool value) async {
    _shouldUseLocation = value;
    notifyListeners();
    if(value){
      final position = await _determinePosition();
      _latitude = position.latitude;
      _longitude = position.longitude;
      await _getCurrnetCity();
      _maxRadiusKm = 500;
      _setQueryParams();
      getEarthquakeData();
    }else{
      _latitude = 0.0;
      _longitude = 0.0;
      _maxRadiusKm = _maxRadiusKmThreshold;
      _currentCity = null;
      _setQueryParams();
      getEarthquakeData();

    }
  }


  Future<void> _getCurrnetCity() async {
    try{
     final placeMarkList = await gc.placemarkFromCoordinates(_latitude,_longitude);
     if(placeMarkList.isNotEmpty){
       final placemark = placeMarkList.first;
       _currentCity = placemark.locality;
       notifyListeners();
     }
    }catch(error){
      print(error);
    }
  }


  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}