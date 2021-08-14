import 'package:wemeet/utils/api.dart';

class SubscriptionService {
  
  static Future getPlans() => api.get("backend-service/v1/payment/plans");

  static Future getVerifyUpgrade(String ref) => api.get("backend-service/v1/payment/verify?reference=$ref");

  static Future postUpgrade(dynamic data) => api.post("backend-service/v1/payment/upgrade", data: data);

}