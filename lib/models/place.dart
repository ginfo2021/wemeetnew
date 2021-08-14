import 'package:geocoder/geocoder.dart' show Coordinates;

class Placemark {
  final String shortName;
  final String placeName;
  final String address;
  final String town;
  final String countryCode;
  final String countryName;
  final String state;
  
  final Map data;
  final Coordinates location;

  Placemark({
    this.shortName, 
    this.placeName, 
    this.address, 
    this.town, 
    this.location,
    this.countryName,
    this.countryCode,
    this.state,
    this.data
  });

  factory Placemark.fromMap(Map res){
    Map loc = res['result']["geometry"]["location"];
    return Placemark(
      // shortName: res['result']["address_components"][2]["short_name"],
      shortName: Placemark.getName(res['result']["address_components"], 2),
      // state: res['result']["address_components"][1]["short_name"],
      state: Placemark.getName(res['result']["address_components"], 1),
      placeName: res['result']["name"],
      countryName: Placemark.getCountry(res['result']["address_components"])["long_name"],
      countryCode: Placemark.getCountry(res['result']["address_components"])["short_name"],
      address: res['result']["formatted_address"],
      // town: res['result']["address_components"][3]["short_name"],
      town: Placemark.getName(res['result']["address_components"], 3),
      location: Coordinates(loc["lat"], loc["lng"]),
      data: res
    );
  }

  static Map getCountry(List val){
    return val.last;
  }

  static String getName(List val, int index) {
    if(val.isEmpty || (val.length - 1) < index) {
      return "";
    }

    return val[index]["short_name"];
  }
}

class PlacePrediction {

  final String placeId;
  final String description;
  final Map data;

  PlacePrediction({this.placeId, this.description, this.data});

  factory PlacePrediction.fromMap(Map res){
    return PlacePrediction(
      placeId: res["place_id"],
      description: res["description"],
      data: res
    );
  }
}