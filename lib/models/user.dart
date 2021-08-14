import 'package:date_format/date_format.dart';
import 'package:wemeet/utils/converters.dart';

class UserModel {
  final int id;
  String email;
  String firstName;
  String lastName;
  String bio;
  String gender;
  int dob;
  String workStatus = "";
  List genderPreference;
  String type;
  int age;
  bool hideLocation;
  bool hideProfile;
  bool emailVerified;
  String phone;
  bool phoneVerified;
  bool active;
  bool suspended;
  String profileImage;
  int minAge;
  int maxAge;
  int distanceInKm;
  int swipeRadius;
  List additionalImages;
  double longitude;
  double latitude;
  int createdAt;

  Map data;

  UserModel({
    this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.bio,
    this.gender,
    this.dob,
    this.workStatus,
    this.genderPreference,
    this.type, 
    this.age,
    this.hideLocation,
    this.hideProfile,
    this.emailVerified,
    this.phone,
    this.phoneVerified,
    this.active,
    this.suspended,
    this.profileImage,
    this.minAge,
    this.maxAge,
    this.distanceInKm,
    this.additionalImages,
    this.swipeRadius,
    this.latitude,
    this.longitude,
    this.createdAt,

    this.data
  });

  factory UserModel.fromMap(Map res) {
    return UserModel(
      id: ensureInt(res["id"]),
      email: res["email"] ?? "",
      phone: res["phone"] ?? "",
      firstName: res["firstName"] ?? "",
      lastName: res["lastName"] ?? "",
      bio: res["bio"] ?? "",
      gender: res["gender"] ?? "",
      dob: ensureInt(res["dateOfBirth"]),
      workStatus: res["workStatus"] ?? "",
      genderPreference: res["genderPreference"] ?? [],
      type: res["type"],
      age: ensureInt(res["age"]),
      hideLocation: res["hideLocation"] ?? false,
      hideProfile: res["hideProfile"] ?? false,
      emailVerified: res["emailVerified"] ?? false,
      phoneVerified: res["phoneVerified"] ?? false,
      active: res["active"] ?? false,
      profileImage: res["profileImage"],
      suspended: res["suspended"] ?? false,
      minAge: ensureInt(res["minAge"]),
      maxAge: ensureInt(res["maxAge"]),
      createdAt: ensureInt(res["dateCreated"]),
      distanceInKm: ensureInt(res["distanceInKm"]) ?? 1,
      additionalImages: res["additionalImages"] ?? [],
      swipeRadius: ensureInt(res["swipeRadius"]),
      latitude: ensureDouble(res["latitude"]),
      longitude: ensureDouble(res["longitude"]),
      
      data: res
    );
  }

  String get fullName {
    return "$firstName $lastName".trim();
  }

  String get dobF {
    return formatDate(DateTime.fromMillisecondsSinceEpoch(dob ?? 10000), [dd, " ", MM, ", ", yyyy]);
  }

  String get createdF {
    if(createdAt == 0) {
      return "-";
    }
    return formatDate(DateTime.fromMillisecondsSinceEpoch(createdAt), [dd, " ", MM, ", ", yyyy]);
  }

  String get ageF {
    if(dob < 10000) {
      return "";
    }

    Duration dur = Duration(milliseconds: DateTime.now().millisecondsSinceEpoch - DateTime.fromMillisecondsSinceEpoch(dob).millisecondsSinceEpoch);

    return "${(dur.inDays ~/ 360)}";
  }

  Map toMap() {
    Map entry = {
      "id": id,
      "email": email,
      "phone": phone,
      "firstName": firstName,
      "lastName": lastName,
      "bio": bio,
      "gender": gender,
      "dateOfBirth": dob,
      "workStatus": workStatus,
      "genderPreference": genderPreference,
      "type": type,
      "distanceInKm": distanceInKm,
      "minAge": minAge,
      "maxAge": maxAge,
      "swipeRadius": swipeRadius,
      "hideLocation": hideLocation,
      "hideProfile": hideProfile,
      "longitude": 18.720183,
      "latitude": -33.832253,
    };

    return entry;
  }
}
