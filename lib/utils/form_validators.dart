String? nameValidator(String? value) {
  if (value!.isEmpty) {
    return "Please enter your name";
  }
  return null;
}

String? emailValidator(String? value) {
  String pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = RegExp(pattern);
  if (value!.isEmpty) {
    return "Please enter a email";
  } else if (!regex.hasMatch(value)) {
    return 'Email format is invalid';
  }
  return null;
}

String? phoneValidator(String? value) {
  if (value!.isEmpty) {
    return "Please enter a phone number";
  }
  if (value.length != 10) {
    return "Phone number is invalid";
  }
  return null;
}

String? passwordValidator(String? value) {
  if (value!.isEmpty) {
    return "Please enter a password";
  }
  return null;
}

String? countryValidator(String? value) {
  if (value!.isEmpty) {
    return "Mention your country";
  }
  return null;
}

String? fieldValidator(String? value) {
  if (value!.isEmpty) {
    return "Field is required";
  }
  return null;
}

String? swiftCodeValidator(String? value) {
  if (value!.isEmpty) {
    return "Field is required";
  }
  if (value.length != 8) {
    return "Invalid code";
  }
  return null;
}

String? commentsValidator(String? value) {
  if (value!.isEmpty) {
    return "Comment is empty!";
  }
  if (value.length < 5) {
    return "Comment is too short!";
  }
  return null;
}
