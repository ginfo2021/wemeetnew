import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'dart:async';


import 'package:wemeet/models/place.dart';

import 'package:wemeet/utils/api.dart';
import 'package:wemeet/utils/constants.dart';
import 'package:wemeet/utils/errors.dart';
import 'package:wemeet/utils/toast.dart';

class LocationPickerModalPage extends StatefulWidget {

  final Placemark place;
  final ValueChanged<Placemark> onSelected;
  const LocationPickerModalPage({Key key, this.place, this.onSelected}) : super(key: key);

  @override
  _LocationPickerModalPageState createState() => _LocationPickerModalPageState();
}

class _LocationPickerModalPageState extends State<LocationPickerModalPage> {

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  bool notNull(Object o) => o != null;
  bool isLoading = false;
  bool canSearch = false;
  String address;

  Placemark place;
  List<PlacePrediction> places = [];

  String query = "";


  List<String> results = [];

  TextEditingController _searchC;
  Timer _debounce;

  @override
  void initState() { 
    super.initState();
    
    place = widget.place;
    canSearch = place == null;
    _searchC = TextEditingController(text: place?.placeName);

    created();
  }

  @override
  void dispose(){
    _searchC?.dispose();
    super.dispose();
  }

  void created() async{
    if(!mounted){
      return;
    }

    if(canSearch){
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {

      List<PlacePrediction> res = await api.getPredictions(place.location, place?.placeName);

      setState(() {
        places = res;
      });

    } catch(e, stack){
      print("Stacktrace: $stack");
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void doSearch(String val) async{

    if(!mounted){
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      List<PlacePrediction> res = await api.getPredictions(place?.location, val);
      setState(() {
        places = res;
      });
    } catch(e, stack){
      print(e);
      print("Stacktrace: $stack");
      WeMeetToast.toast(kTranslateError(e));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void search(String query){
    if(query.length <= 4){
      return;
    }

    String val = query;
    //Delay Api call by a second
    bool active = _debounce?.isActive ?? false;
    if (active) {
      _debounce.cancel();
    } 
    _debounce = Timer(const Duration(milliseconds: 1000), () {
      doSearch(val);
    });
  }

  void getPlace(String placeId) async {
    
    if(!mounted){
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      Placemark res = await api.getPlace(placeId);
      widget.onSelected(res);
    } catch(e, stack){
      print("Stacktrace: $stack");
      WeMeetToast.toast(kTranslateError(e));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String smallText(String val) {
    if(val == null || val.isEmpty) {
      return "";
    }

    List n = val.split(",");
    if(n.isEmpty) {
      return "";
    }

    return n.last.trim();
  }

  Widget buildItem(PlacePrediction item){
    return ListTile(
      leading: Icon(Ionicons.location_outline),
      title: Text(
        item.description,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 15.0
        ),
      ),
      subtitle: Text(
        smallText(item.description),
        style: TextStyle(
          fontSize: 13.0
        ),
      ),
      onTap: isLoading ? null : (){
        getPlace(item.placeId);
      },
    );
  }

  Widget buildBody(){
    return ListView.separated(
      itemCount: places.length,
      itemBuilder: (context, index){
        return buildItem(places[index]);
      },
      separatorBuilder: (context, index) {
        return Divider(
          indent: 55.0, 
          color: Colors.black.withOpacity(0.03),
        );
      },
      padding: EdgeInsets.symmetric(vertical: 10.0),
    );
  }

  Widget buildAppBar() {
    return AppBar(
      title: Text("Enter Address"),
      bottom: PreferredSize(
        child: Container(
          child: Column(
            children: [
              Container(
                width: wemeetScreenWidth(context) * 0.95,
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10.0)
                ),
                child: Row(
                  children: [
                    Icon(Ionicons.search_outline, color: Colors.black12,),
                    SizedBox(width: 10.0),
                    Expanded(
                      child: TextField(
                        controller: _searchC,
                        onChanged: search,
                        autocorrect: false,
                        decoration: InputDecoration.collapsed(
                          hintText: "Enter address",
                          filled: false
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.0),
              if(isLoading) SizedBox(height: 2.0, child: LinearProgressIndicator())
            ].where(notNull).toList(),
          ),
        ),
        preferredSize: Size.fromHeight(60.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: buildBody(),
    );
  }
}