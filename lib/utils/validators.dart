// RegExp _phone = new RegExp(r"^[1-9]{10,14}");
// RegExp _phone = new RegExp(r"^[+#*\(\)\[\]]*([0-9][ ext+-pw#*\(\)\[\]]*){6,45}$");

class PhoneValidator{
  static String validate(String value) {

    // RegExp _phone = new RegExp(r"^+?[0-9]{11,14}$");
    RegExp _phone = new RegExp(r"^[+#*\(\)\[\]]*([0-9][ ext+-pw#*\(\)\[\]]*){11,45}$");

    if(value.isEmpty) {
      return  "Enter phone number" ;
    }

    if(value.length < 11) {
      return  'Phone number should be at least 11 digits' ;
    }

    if(!_phone.hasMatch(value)){
      return "Please enter a valid Phone no e.g +2348023453467";
    }

    return null;
  } 
}

class EmailValidator{

  static String validate(String val){

    RegExp _email = new RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\/[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?");

    if(val.isEmpty){
      return "Email cannot be empty";
    }

    if(!_email.hasMatch(val.toLowerCase())){
      return "Please enter a valid email";
    }

    return null;
  }
    
}

class PasswordValidator {
  
  static String validate(String value) {
    if(value.isEmpty) {
      return  'Password  can not be empty' ;
    }
    if(value.length < 6) {
      return  'Password should be at least 6 characters' ;
    }
    return null;
  }
}

class ConfirmPasswordValidator {
  
  static String validate(String value, String val) {
    if(value.isEmpty) {
      return  'Password can not be empty';
    }
    if(value != val) {
      return  'Passwords do not match';
    }
    return null;
  }
}

class NotEmptyValidator {
  
  static String validate(String value, [String name, String mssg]) {
    if(value.isEmpty) {
      if(name == null && mssg == null) {
        return  "Field can not be empty";
      } else if(name != null) {
        return  "$name can not be empty";
      } else if(mssg != null) {
        return mssg;
      }
      return  "Field must be completed";
    }
    return null;
  }

  static String validateWithMessage(String value, String message) {
    if(value.isEmpty) {
      return  message;
    }
    return null;
  }
}

class NameValidator{

  static String validate(String value){

    if(value.isEmpty){
      return 'Full names can not be empty';
    }

    List l = value.trim().split(" ");
    
    if(l.length < 2){
      return "Please enter your full names";
    }

    return null;
  }
}

class DateValidator{

  static String validate(String val){

    RegExp _email = new RegExp(r"^(19|20)\d\d[- /.](0[1-9]|1[012])[- /.](0[1-9]|[12][0-9]|3[01])$");

    if(val.isEmpty){
      return "Enter date";
    }

    // if(DateTime.tryParse(val) == null){
    //   return "Invalid date. 1990-01-01";
    // }

    if(!_email.hasMatch(val.toLowerCase())){
      return "Invalid date. 1990-01-01";
    }

    return null;
  }
    
}
