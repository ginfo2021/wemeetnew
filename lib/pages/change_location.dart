import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';
import 'package:wemeet/components/wide_button.dart';

import 'package:wemeet/models/app.dart';
import 'package:wemeet/models/user.dart';

import 'package:wemeet/services/user.dart';

import 'package:wemeet/pages/place_picker.dart';
import 'package:wemeet/components/loader.dart';
import 'package:wemeet/utils/colors.dart';

import 'package:wemeet/utils/toast.dart';
import 'package:wemeet/utils/errors.dart';

class ChangeLocationPage extends StatefulWidget {

  final AppModel model;
  const ChangeLocationPage({Key key, this.model}) : super(key: key);

  @override
  _ChangeLocationPageState createState() => _ChangeLocationPageState();
}

class _ChangeLocationPageState extends State<ChangeLocationPage> {

  Map location = {
    "latitude": 0,
    "longitude": 0,
    "state": "State",
    "country": "Country",
    "address": "-"
  };

  Location loc = Location();
  LocationData locationData;

  AppModel model;
  UserModel user;

  @override
  void initState() { 
    super.initState();
    
    model = widget.model;
    user = model.user;

    getLocal([user.latitude, user.longitude]);
    // getLocal([6.6448708, 3.3643317]);

    getLocation();

  }

  void getLocation() async {
    loc.getLocation().then((data) {
      setState(() {
        locationData = data;        
      });
    });
  }

  void getLocal(List val) async {
    if(val.contains(null) || val.contains(0.0)){
      return;
    }

    try {
      Coordinates coord = Coordinates(val.first, val.last);
      List<Address> addrs = await Geocoder.local.findAddressesFromCoordinates(coord);

      if(addrs.isEmpty) {
        return;
      }

      Address addr = addrs.first;

      setState(() {
        location = {
          "latitude": addr.coordinates.latitude,
          "longitude": addr.coordinates.longitude,
          "state": addr.adminArea,
          "country": addr.countryName,
          "address": addr.addressLine
        };        
      });

    } catch (e) {
      WeMeetToast.toast(kTranslateError(e), true);
    }

  }

  void updateLocation() async {
    WeMeetLoader.showLoadingModal(context);
    
    Map data = {
      "latitude": location["latitude"],
      "longitude": location["longitude"]
    };

    try {
      var res = await UserService.postUpdateLocation(data);
      WeMeetToast.toast(res["message"] ?? "User location updated successfully");
      model.addUserMap(data);
    } catch (e) {
      WeMeetToast.toast(kTranslateError(e), true);
    } finally {
      if(Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  void pickLocation() async  {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => LocationPickerModalPage(
        onSelected: (place) {
          setState(() {
            location = {
              "latitude": place.location.latitude,
              "longitude": place.location.longitude,
              "address": place.address,
              "state": "",
              "country": ""
            };         
          });
          
          // pop page
          if(Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        },
      ),
      fullscreenDialog: true
    ));
  }

  void useLocation() async {
    WeMeetLoader.showLoadingModal(context);

    try {
      if(locationData == null) {
        await getLocation();
      }

      await getLocal([locationData.latitude, locationData.longitude]);

    } catch (e) {
      WeMeetToast.toast(kTranslateError(e), true);
    } finally {
      if(Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  Widget _tile(String title, String subtitle) {
    return Container(
      color: Colors.white,
      child: ListTile(
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13.0,
            height: 1.6
          )
        ),
      ),
    );
  }

  Widget buildBody() {
    return ListView(
      children: [
        Text(
          "Set Your Location",
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w500
          ),
        ),
        SizedBox(height: 10.0),
        _tile("Place", location["address"] ?? "-"),
        _tile("State", location["state"] ?? "-"),
        _tile("Country", location["country"] ?? "-"),
        SizedBox(height: 40.0),
        WWideButton(
          title: "Use Custom Location",
          onTap: pickLocation,
          color: AppColors.yellowColor.withOpacity(0.3),
          textColor: AppColors.color1,
        ),
        SizedBox(height: 20.0),
        WWideButton(
          title: "Use My Location",
          onTap: useLocation,
          color: Colors.greenAccent.withOpacity(0.3),
          textColor: Colors.green,
        ),
        SizedBox(height: 20.0),
        WWideButton(
          title: "Update",
          onTap: updateLocation,
        ),
      ],
      padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
      physics: ClampingScrollPhysics(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff5f5f5),
      appBar: AppBar(
        title: Text("Change Location"),
      ),
      body: buildBody(),
    );
  }
}