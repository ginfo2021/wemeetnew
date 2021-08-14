import 'package:url_launcher/url_launcher.dart';

void openURL(String url) async {

  print(url);

  if(url == null) throw "Unable to launch";


  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}