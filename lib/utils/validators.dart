// text validators
bool validateEmail(String v) {
  return RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
      .hasMatch(v);
}

bool validatePassword(String v) {
  return RegExp(r"^\S{8,128}$").hasMatch(v);
}

bool validateFullName(String v) {
  return RegExp(r"^[\w\s]{2,64}$").hasMatch(v);
}

// fields validators
String emailFieldValidator(String v) {
  if (v.isEmpty) return "Please enter your email";
  if (!validateEmail(v)) return "Please type a valid email";
}

String passwordFieldValidator(String v) {
  if (v.isEmpty) return "Please enter your password";
  if (!validatePassword(v)) return "Please type a valid password";
}

String fullNameFieldValidator(String v) {
  if (v.isEmpty) return "Please enter your full name";
  if (!validateFullName(v)) return "Please type a valid full name";
}
