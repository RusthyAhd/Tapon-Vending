class SignupModel {
  String name;
  String email;
  String mobile;
  String password;
  bool agreeToTerms;

  SignupModel({required this.name,required this.email,required this.mobile, required this.password, this.agreeToTerms = false});
}
