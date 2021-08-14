import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';

import 'package:wemeet/models/app.dart';

import 'package:wemeet/components/checkbox_field.dart';
import 'package:wemeet/components/loader.dart';
import 'package:wemeet/components/text_field.dart';
import 'package:wemeet/components/wide_button.dart';
import 'package:wemeet/providers/data.dart';
import 'package:wemeet/services/auth.dart';

import 'package:wemeet/utils/colors.dart';
import 'package:wemeet/utils/converters.dart';
import 'package:wemeet/utils/svg_content.dart';
import 'package:wemeet/utils/url.dart';
import 'package:wemeet/utils/toast.dart';
import 'package:wemeet/utils/validators.dart';
import 'package:wemeet/utils/errors.dart';
//import 'package:wemeet/models/social_signin.dart';

class RegisterPage extends StatefulWidget {
  final AppModel model;

  const RegisterPage({Key key, this.model}) : super(key: key);
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  DataProvider _dataProvider = DataProvider();

  TextEditingController _fullNameC = TextEditingController();
  TextEditingController _phoneC = TextEditingController();
  TextEditingController _emailC = TextEditingController();
  TextEditingController _passwordC = TextEditingController();
  TextEditingController dobC = TextEditingController();

  FocusNode _phoneNode = FocusNode();
  FocusNode _emailNode = FocusNode();
  FocusNode _passwordNode = FocusNode();

  bool checked = true;
  bool isLoading = false;

  @override
  void dispose() {
    _fullNameC.dispose();
    _phoneC?.dispose();
    _emailC.dispose();
    _passwordC.dispose();
    dobC.dispose();
    _phoneNode?.dispose();
    _emailNode.dispose();
    _passwordNode.dispose();
    super.dispose();
  }

  void doSubmit() async {
    WeMeetLoader.showLoadingModal(context);

    List<String> name = _fullNameC.text.split(" ");

    Map data = {
      "dateOfBirth": DateTime.parse(dobC.text).toIso8601String(),
      "deviceId": _dataProvider.deviceId,
      "email": _emailC.text,
      "firstName": name.first,
      "lastName": name.sublist(1).join(" "),
      "latitude": _dataProvider.location?.latitude ?? 0,
      "longitude": _dataProvider.location?.longitude ?? 0,
      "password": _passwordC.text,
      // "phone": _phoneC.text,
      "userName": _emailC.text
    };

    try {
      var res = await AuthService.postRegister(data);

      Map resData = res["data"] as Map;

      // set user
      widget.model.setUserMap(resData["user"]);
      // set user token
      widget.model.setToken(resData["tokenInfo"]["accessToken"]);

      WeMeetToast.toast(res["message"] ?? "Account registered successfully");
      formKey.currentState.reset();
      await Future.delayed(Duration(milliseconds: 500));
      Navigator.pushNamedAndRemoveUntil(context, "/activate", (route) => false);
    } catch (e) {
      print(e);
      WeMeetToast.toast(kTranslateError(e), true);
    } finally {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  void submit() {
    FocusScope.of(context).unfocus();
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      doSubmit();
    }
  }

  void openPage(String url) {
    openURL(url);
  }

  void pickDob() {
    FocusScope.of(context).requestFocus(FocusNode());

    DateTime current = DateTime.tryParse(dobC.text) ??
        DateTime.now().subtract(Duration(days: 365 * 18));

    int maxYear = DateTime.now().year - 18;
    DatePicker.showDatePicker(
      context,
      minDateTime: DateTime(1920),
      maxDateTime: DateTime(maxYear),
      initialDateTime: current,
      dateFormat: "dd-MMMM-yyyy",
      locale: DateTimePickerLocale.en_us,
      pickerTheme: DateTimePickerTheme(
          itemHeight: 40.0,
          confirm: Text(
            "Save",
            style: TextStyle(color: AppColors.color1),
          ),
          cancel: Text(
            "Cancel",
            style: TextStyle(color: Colors.red),
          )),
      pickerMode: DateTimePickerMode.date, // show TimePicker
      onConfirm: (date, l) {
        setState(() {
          dobC.text = toYMD(date);
        });
      },
    );
  }

  Widget buildForm() {
    return Form(
      key: formKey,
      child: ListView(
        children: [
          SizedBox(height: kToolbarHeight),
          Center(
            child: SvgPicture.string(WemeetSvgContent.logoYB),
          ),
          SizedBox(height: 30.0),
          /*Center(
            child: SignInPage(),
          ),
          SizedBox(height: 30.0),
          Text(
            "---------OR---------",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17.0),
          ),
          SizedBox(height: 30.0),*/
          Text(
            "Create your account",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17.0),
          ),
          SizedBox(height: 20.0),
          WeMeetTextField(
            // helperText: "Full Name",
            controller: _fullNameC,
            hintText: "First & Last Names",
            validator: NameValidator.validate,
            inputAction: TextInputAction.next,
            onFieldSubmitted: (val) {
              FocusScope.of(context).requestFocus(_emailNode);
            },
          ),
          // SizedBox(height: 20.0),
          // WeMeetTextField(
          //   // helperText: "Phone Number",
          //   controller: _phoneC,
          //   focusNode: _phoneNode,
          //   hintText: "Phone Number",
          //   keyboardType: TextInputType.phone,
          //   validator: PhoneValidator.validate,
          //   onFieldSubmitted: (val) {
          //     FocusScope.of(context).requestFocus(_emailNode);
          //   },
          // ),
          SizedBox(height: 20.0),
          WeMeetTextField(
            // helperText: "Email Address",
            controller: _emailC,
            focusNode: _emailNode,
            hintText: "Email Address",
            keyboardType: TextInputType.emailAddress,
            validator: EmailValidator.validate,
            inputAction: TextInputAction.next,
            onFieldSubmitted: (val) {
              FocusScope.of(context).requestFocus(_passwordNode);
            },
          ),
          SizedBox(height: 20.0),
          WeMeetTextField(
            helperColor: Colors.grey,
            hintText: "Date of Birth",
            controller: dobC,
            enabled: false,
            onFieldTapped: pickDob,
            validator: (val) => NotEmptyValidator.validateWithMessage(
                val, "Please select your date of birth"),
          ),
          SizedBox(height: 20.0),
          WeMeetTextField(
            // helperText: "Password",
            controller: _passwordC,
            focusNode: _passwordNode,
            hintText: "Password",
            isPassword: true,
            showPasswordToggle: true,
            validator: PasswordValidator.validate,
            onFieldSubmitted: (val) {
              submit();
            },
          ),
          SizedBox(height: 20.0),
          CheckboxFormField(
            initialValue: checked,
            onSaved: (val) {
              setState(() {
                checked = val;
              });
            },
            validator: (val) => val
                ? null
                : "You must agree to the terms before you may proceed",
            title: Text.rich(
              TextSpan(text: "I agree to the ", children: [
                TextSpan(
                    text: "Terms of Use",
                    style: TextStyle(decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        openURL("https://wemeet.africa/terms-of-use.html");
                      }),
                TextSpan(text: " and "),
                TextSpan(
                    text: "Privacy Policy.",
                    style: TextStyle(decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        openURL("https://wemeet.africa/privacy-policy.html");
                      })
              ]),
              style: TextStyle(fontSize: 13.0),
            ),
            padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 5.0),
          ),
          SizedBox(height: 20.0),
          WWideButton(
            title: "Done",
            onTap: submit,
          ),
          SizedBox(height: 30.0),
          Text.rich(
            TextSpan(text: "Already have an account? ", children: [
              TextSpan(
                  text: "Sign in.",
                  style: TextStyle(decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.of(context).pushReplacementNamed("/login");
                    }),
            ]),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.0),
          ),
          SizedBox(height: 15.0),
        ],
        padding: EdgeInsets.symmetric(horizontal: 30.0),
        physics: ClampingScrollPhysics(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.color3,
      body: SafeArea(
        child: Container(color: AppColors.color3, child: buildForm()),
      ),
    );
  }
}
