import 'package:flutter/material.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:ionicons/ionicons.dart';
import 'package:strings/strings.dart' as strings;
import 'package:flutter_paystack/flutter_paystack.dart';
import 'dart:async';

import 'package:wemeet/components/loader.dart';
import 'package:wemeet/components/error.dart';

import 'package:wemeet/models/app.dart';
import 'package:wemeet/models/user.dart';
import 'package:wemeet/models/plan.dart';
import 'package:wemeet/providers/data.dart';

import 'package:wemeet/services/subscription.dart';
import 'package:wemeet/services/user.dart';
import 'package:wemeet/utils/colors.dart';

import 'package:wemeet/utils/errors.dart';
import 'package:wemeet/utils/toast.dart';

import 'package:wemeet/config.dart';

class SubscriptionPage extends StatefulWidget {
  @override
  _SubscriptionPageState createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {

  bool isLoading = false;
  String errorText;
  int currentPage = 0;
  PageController _controller = PageController(initialPage: 0, viewportFraction: 0.8);
  List<PlanModel> plans = [];

  DataProvider _dataProvider = DataProvider();

  StreamSubscription<String> reloadStream;

  AppModel model;
  UserModel user;

  @override
  void initState() { 
    super.initState();

    PaystackPlugin.initialize(
        publicKey: WeMeetConfig.payStackPublickKey);
    
    reloadStream = _dataProvider.onReloadPage.listen((val){
      if(!mounted || !val.split(",").contains("subscription")) {
        return;
      }

      fetchPlans();
    });
    
    fetchPlans();
  }

  void fetchPlans() async {
    setState(() {
      isLoading = true;   
      errorText = null;   
    });

    try {
      var res = await SubscriptionService.getPlans();
      List data = res["data"] as List;
      setState(() {
        plans = data.map((e) => PlanModel.fromMap(e)).toList();        
      });
    } catch (e) {
      setState(() {
        errorText = kTranslateError(e);
      });
      WeMeetToast.toast(errorText, true);
    } finally {
      setState(() {
        isLoading = false;        
      });
    }
  }

  void chargeCard(int amount, String accessCode, String ref) async {
    Charge charge = Charge()
      ..amount = amount
      ..accessCode = accessCode
      ..email = user.email;

    CheckoutResponse response = await PaystackPlugin.checkout(
      context,
      charge: charge,
    );

    print(response);

    if(response.reference == null) {
      throw response.message;
    }

    var verify = await  SubscriptionService.getVerifyUpgrade(ref);

    print(verify);

  }

  void getProfile() {
    UserService.getProfile().then((res){
      model.setUserMap(res["data"]);

      DataProvider().reloadPage("match, home");
    });
  }

  void upgradePlan(PlanModel plan) async {

    WeMeetLoader.showLoadingModal(context);

    Map data = {
      "amount": plan.amount,
      "plan_code": plan.code,
      "email": user.email
    };

    try {
      var res = await SubscriptionService.postUpgrade(data);
      Map resData = res["data"];
      print(resData);
      await chargeCard(plan.amount, resData["access_code"], resData["reference"]);
    } catch (e) {
      print(e);
      WeMeetToast.toast(kTranslateError(e), true);
    } finally {
      if(Navigator.canPop(context)) {
        Navigator.pop(context);
      }

    }

  }

  Widget _keyVal(String key, String val) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            key,
            style: TextStyle(
              fontWeight: FontWeight.w600
            ),
          ),
          Text(
            val
          )
        ],
      ),
    );
  }

  Widget buildItem(PlanModel plan, int index) {
    bool active = user?.type == plan.name;
    return Container(
      height: 300.0,
      margin: EdgeInsets.only(right: 15.0),
      child: Stack(
        children: [
          Positioned.fill(
            top: 10.0,
            left: 0.0,
            right: 0.0,
            child: Container(
              margin: EdgeInsets.only(right: 10.0),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: active ? Colors.greenAccent : Colors.grey,
                  width: active ? 3.0 : 1.0
                )
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Color(0xfff5f5f5)
                    ),
                    child: Text(
                      strings.capitalize(plan.name.toLowerCase()) + " Plan",
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w700
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Text.rich(
                    TextSpan(
                      text: "NGN ${(plan.amount ~/ 100)}",
                      children: <TextSpan>[
                        TextSpan(
                          text: " / ${plan.period}",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 15.0
                          )
                        )
                      ],
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16.0
                      )
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10.0),
                  _keyVal("Swipes", "${plan.limit.swipeText}"),
                  Divider(height: 20.0, indent: 20, endIndent: 20.0,),
                  _keyVal("Messages", "${plan.limit.messageText}"),
                  Divider(height: 20.0, indent: 20, endIndent: 20.0,),
                  _keyVal("Location Update", "${plan.limit.locationText}"),
                  SizedBox(height: 50.0),
                  if(!["FREE", user.type].contains(plan.name)) Container(
                    margin: EdgeInsets.symmetric(horizontal: 20.0),
                    child: ElevatedButton(
                      onPressed: (){
                        upgradePlan(plan);
                      },
                      child: Text("Upgrade Plan"),
                    ),
                  )
                ],
              ),
            ),
          ),
          if(user.type == plan.name) Positioned(
            top: 0.0,
            right: 0.0,
            child: Icon(Icons.check_circle, color: Colors.green, size: 30.0,),
          ),
        ],
      ),
    );
  }

  Widget buildBody() {

    if(isLoading) {
      return WeMeetLoader.showBusyLoader();
    }

    if(errorText != null) {
      return WErrorComponent(text: errorText, callback: fetchPlans,);
    }

    if(plans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(FeatherIcons.alertCircle, color: AppColors.color1, size: 60.0),
            SizedBox(height: 10.0),
            Text(
              "Something wierd is going on.\nThere are no plans to show",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      margin: EdgeInsets.only(top: 30.0),
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      height: 400.0,
      child: PageView.builder(
        controller: _controller,
        itemBuilder: (context, index) {
          return buildItem(plans[index], index);
        },
        itemCount: plans.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Navigator.pop(context);
    return ScopedModelDescendant<AppModel>(
      builder: (context, child, m) {
        model = m;
        user = model.user;

        return Scaffold(
          appBar: AppBar(
            title: Text("Subscription"),
            centerTitle: false,
            actions: [
              IconButton(
                onPressed: fetchPlans,
                icon: Icon(Ionicons.refresh_outline),
              )
            ],
          ),
          body: buildBody(),
        );
      },
    );        
  }
}