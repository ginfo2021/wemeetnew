import 'package:wemeet/utils/api.dart';

class AuthService {
  static Future postLogin(dynamic body) =>
      api.post("backend-service/v1/auth/login", data: body, token: false);

  static Future postRegister(dynamic body) =>
      api.post("backend-service/v1/auth/signup", data: body, token: false);

  static Future postSocialSignup(dynamic body) =>
      api.post("backend-service/v1/auth/signup", data: body, token: false);

  static Future getForgotPassword(String email) =>
      api.get("backend-service/v1/auth/accounts/forgot-password?email=$email");

  static Future getVerifyToken(String email, String token) => api.get(
      "backend-service/v1/auth/accounts/verify-password-token?email=$email&token=$token");

  static Future postResetPassword(dynamic body) =>
      api.post("backend-service/v1/auth/accounts/reset-password", data: body);

  static Future postChangedPassword(dynamic body) =>
      api.post("backend-service/v1/auth/change-password", data: body);

  static Future postResendEmailToken() =>
      api.post("backend-service/v1/auth/resend-email");

  static Future postVerifyEmail(String token) =>
      api.post("backend-service/v1/auth/verify/email?token=$token");

  static Future postSelfDelete() =>
      api.post("backend-service/v1/auth/self-delete");
}
