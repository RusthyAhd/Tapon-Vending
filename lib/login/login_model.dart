class LoginModel {
  String emailOrMobile;
  String password;
  bool rememberMe;

  LoginModel({required this.emailOrMobile, required this.password, this.rememberMe = false});
}
