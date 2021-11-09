import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:walton_video_conference/video_conference_interface.dart';

import 'TextFormBuilder.dart';

final userRef = FirebaseFirestore.instance.collection("users");

class UserInterface extends StatefulWidget {
  @override
  _UserInterfaceState createState() => _UserInterfaceState();
}

class _UserInterfaceState extends State<UserInterface> {
  bool isAdmin = false;
  final auth = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();

  adminChange(bool value) {
    setState(() {
      isAdmin = value;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    // createUser();
    print(auth.uid);
    super.initState();
  }

  createUser() async {
    try {
      final userExists = await userRef.doc(auth.uid).get();
      if(userExists.exists){
        userRef.doc(auth.uid).update({
          "User id": auth.uid,
          "userName": mobileController.text,
          "isAdmin": isAdmin,
        });
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => VideoConference()));
      }
      else {
        userRef.doc(auth.uid).set({
          "User id": auth.uid,
          "userName": mobileController.text,
          "isAdmin": isAdmin,
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "Your data has been saved!",
            textAlign: TextAlign.center,
          )));
      Timer(Duration(seconds: 2), (){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => VideoConference()));
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        "Some error occurred, please try again",
        textAlign: TextAlign.center,
      )));
    }
  }

  final mobileController = TextEditingController();
  final roomText2 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormBuilder(
                validateFunction: (value) {
                  if (value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
                controller: roomText2,
                prefix: Feather.user,
                hintText: "User name",
                textInputAction: TextInputAction.next,
              ),
              TextFormBuilder(
                validateFunction: (value) {
                  if (value.isEmpty) {
                    return 'Please provide your mobile number';
                  }
                  return null;
                },
                controller: mobileController,
                prefix: Feather.phone,
                textInputType: TextInputType.phone,
                hintText: "mobile number",
                textInputAction: TextInputAction.next,
              ),

              SizedBox(
                height: 20.0,
              ),
              CheckboxListTile(
                value: isAdmin,
                onChanged: adminChange,
                title: Text("Are you admin?"),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      createUser();
                    }
                  },
                  child: Text("Submit"))
            ],
          ),
        ),
      ),
    );
  }
}
