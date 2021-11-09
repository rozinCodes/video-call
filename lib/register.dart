import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walton_video_conference/user_interface.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
}

enum FormType { login, register }

class UserRegister extends StatefulWidget {
  @override
  _UserRegisterState createState() => _UserRegisterState();
}

class _UserRegisterState extends State<UserRegister> {
  @override
  void dispose() {
    super.dispose();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final formKey = GlobalKey<FormState>();
  bool loading = false;

  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  TextEditingController _retypePassword = TextEditingController();
  FormType _formType = FormType.login;
  var _fullPhoneNumber;
  bool numberIsValid = false;

  // void onInputChange(PhoneNumber number) {
  //   _fullPhoneNumber = number.phoneNumber;
  // }

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      try {
        if (_formType == FormType.login) {
          try {
            User user = (await _auth.signInWithEmailAndPassword(
                email: _email.text.trim(), password: _password.text.trim()))
                .user;
            setState(() {
              loading = true;
            });

            if (user.emailVerified) {
              setState(() {
                loading = true;
              });
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString('isUser', user.toString());
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => UserInterface()));
            } else {
              setState(() {
                loading = true;
              });
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => UserInterface()));
            }
          } on FirebaseAuthException catch (error) {
            setState(() {
              loading = false;
            });
            var _errors = error.message;
          }
        } else {
          setState(() {
            loading = true;
          });
          User user = (await _auth.createUserWithEmailAndPassword(
              email: _email.text.trim(), password: _password.text.trim()))
              .user;
          setState(() {
            loading = true;
          });
          // await UserProfile(uid: user.uid);
          if (user.emailVerified) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString('isUser', user.toString());
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => UserInterface()));
          } else {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => UserInterface()));
          }
        }
      } on PlatformException catch (e) {
        setState(() {
          loading = false;
        });
        print(e);
        if(e.message == ""){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("email already in use"),));
        }
      }
    }
  }

  void moveToRegister() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.register;
    });
  }

  void moveToLogin() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.login;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
        body: Container(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              // .stretch, //Used to stretch a button of its parent properties.
              children: buildInputs() + buildSubmitButtons(),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> buildInputs() {
    if (_formType == FormType.login) {
      return [
        TextFormField(
          keyboardType: TextInputType.emailAddress,
          controller: _email,
          autofocus: false,
          decoration: InputDecoration(
              labelText: "Email",
              suffixIcon: IconButton(
                icon: Icon(Icons.clear),
                onPressed: () => _email.clear(),
              )),
          validator: (String value) {
            if (value.isEmpty) {
              return "Email can\'t be empty";
            }
              return null;
          },
          onSaved: (value) => _email.text = value,
        ),
        TextFormField(
          controller: _password,
          decoration: InputDecoration(
            labelText: "Password",
            suffixIcon: IconButton(
              icon: Icon(Icons.clear),
              onPressed: () => _password.clear(),
            ),
          ),
          validator: (value) =>
          value.isEmpty ? "Password can\'t be empty" : null,
          onSaved: (value) => _password.text = value,
          obscureText: true,
        ),
      ];
    }
    if (_formType == FormType.register) {
      return [
        TextFormField(
            autofocus: false,
            controller: _email,
            decoration: InputDecoration(
              labelText: "Email",
              suffixIcon: IconButton(
                icon: Icon(Icons.clear),
                onPressed: () => _email.clear(),
              ),
            ),
            validator: (String value) =>
            value.isEmpty
                ? "Please enter a valid email"
                : null,
            onSaved: (String value) {
              _email.text = value;
            }),
        TextFormField(
          controller: _password,
          decoration: InputDecoration(
            labelText: "Password",
            suffixIcon: IconButton(
              icon: Icon(Icons.clear),
              onPressed: () => _password.clear(),
            ),
          ),
          validator: (String value) {
            if (value.isEmpty) {
              return 'Please Enter a Password';
            }
            return null;
          },
          onSaved: (value) => _password.text = value,
          obscureText: true,
        ),
        TextFormField(
          controller: _retypePassword,
          decoration: InputDecoration(
            labelText: "Password",
            suffixIcon: IconButton(
              icon: Icon(Icons.clear),
              onPressed: () => _retypePassword.clear(),
            ),
          ),
          validator: (String value) {
            if (value.isEmpty) {
              return 'Please re-enter password';
            }
            if (value != _password.text) {
              return "Password don't match";
            }
            return null;
          },
          onSaved: (value) => _retypePassword.text = value,
          obscureText: true,
        ),
      ];
    }
    return null;
  }

  List<Widget> buildSubmitButtons() {
    if (_formType == FormType.login) {
      return [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Container(
                // width: 200.0,
                height: 40.0,
                child: Material(
                  // borderRadius: BorderRadius.circular(40.0),
                  shadowColor: Colors.transparent,
                  color: Colors.transparent,
                  elevation: 7.0,
                  child: ElevatedButton(
                    child: Text("Slide to login", style: TextStyle(color: Colors.white),),
                    onPressed: validateAndSubmit,
                  ),
                ),
              ),
            ),
            ElevatedButton(
                child: Text(
                  "Create a new account",
                  style: TextStyle(fontSize: 15.0),
                ),
                onPressed: () {
                  moveToRegister();
                  _password.clear();
                  _retypePassword.clear();
                  _email.clear();
                }),
          ],
        ),
      ];
    }
    if (_formType == FormType.register) {
      return [
        SizedBox(height: MediaQuery.of(context).size.height / 35,),
        Container(
          width: MediaQuery.of(context).size.width / 1.5,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.blueAccent
          ),
          child: MaterialButton(
            child: Text(
              "Create an Account",
              style: TextStyle(fontSize: 20.0,color: Colors.white),
            ),
            onPressed: validateAndSubmit,
          ),
        ),
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child:  InkWell(
                    onTap: () {
                      moveToLogin();
                      _password.clear();
                      _retypePassword.clear();
                      _email.clear();
                    },
                    child: Text("Already have an account? Login",
                        style: TextStyle(
                          fontSize: 15.0,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          // decoration: TextDecoration.underline
                        )),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: InkWell(
                onTap: () {
                  _password.clear();
                  _retypePassword.clear();
                  _email.clear();
                },
                child: Text("prefer phone instead? click here",
                    style: TextStyle(
                      fontSize: 15.0,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      // decoration: TextDecoration.underline
                    )),
              ),
            )
          ],
        ),
      ];
    }
    return null;
  }
}
