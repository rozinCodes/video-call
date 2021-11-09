import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:jitsi_meet/feature_flag/feature_flag.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:jitsi_meet/jitsi_meeting_listener.dart';
import 'package:jitsi_meet/room_name_constraint.dart';
import 'package:jitsi_meet/room_name_constraint_type.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:walton_video_conference/register.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:walton_video_conference/user_interface.dart';


import 'TextFormBuilder.dart';

class VideoConference extends StatefulWidget {
  @override
  _VideoConferenceState createState() => _VideoConferenceState();
}

class _VideoConferenceState extends State<VideoConference> {
  final serverText = TextEditingController();
  final roomText = TextEditingController(text: "walton video conference");
  final subjectText = TextEditingController(text: "");
  final nameText = TextEditingController(text: "test");
  final emailText = TextEditingController(text: "");
  var isAudioOnly = true;
  var isAudioMuted = true;
  var isVideoMuted = true;
  final _formKey = GlobalKey<FormState>();
  final auth = FirebaseAuth.instance;


  @override
  void initState() {
    super.initState();
    JitsiMeet.addListener(JitsiMeetingListener(
        onConferenceWillJoin: _onConferenceWillJoin,
        onConferenceJoined: _onConferenceJoined,
        onConferenceTerminated: _onConferenceTerminated,
        onPictureInPictureWillEnter: _onPictureInPictureWillEnter,
        onPictureInPictureTerminated: _onPictureInPictureTerminated,
        onError: _onError));
  }

  @override
  void dispose() {
    super.dispose();
    JitsiMeet.removeAllListeners();
  }

  logout() {
    auth.signOut();
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => UserRegister()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                icon: Icon(
                  Icons.logout,
                  color: Colors.white,
                ),
                onPressed: logout)
          ],
          title: const Text('Video Call'),
          centerTitle: true,
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      // SizedBox(
                      //   height: 24.0,
                      // ),
                      // // TextFormField(
                      // //   controller: serverText,
                      // //   decoration: InputDecoration(
                      // //       border: OutlineInputBorder(),
                      // //       labelText: "Server URL",
                      // //       hintText: "Hint: Leave empty for meet.jitsi.si"),
                      // // ),
                      // SizedBox(
                      //   height: 16.0,
                      // ),
                      // TextFormField(
                      //   validator: (value) {
                      //     if (value.isEmpty) {
                      //       return 'Please enter a meeting room name';
                      //     }
                      //     return null;
                      //   },
                      //   textAlign: TextAlign.center,
                      //   controller: roomText,
                      //   decoration: InputDecoration(
                      //     border: UnderlineInputBorder(),
                      //     labelText: "Room",
                      //   ),
                      // ),
                      // SizedBox(
                      //   height: 16.0,
                      // ),
                      // TextFormField(
                      //   textAlign: TextAlign.center,
                      //   controller: subjectText,
                      //   decoration: InputDecoration(
                      //     prefix: Icon(Feather.user),
                      //     border: UnderlineInputBorder(),
                      //     labelText: "Subject",
                      //   ),
                      // ),
                      // SizedBox(
                      //   height: 16.0,
                      // ),
                      // TextFormField(
                      //   validator: (value) {
                      //     if (value.isEmpty) {
                      //       return 'Please enter your Display name';
                      //     }
                      //     return null;
                      //   },
                      //   textAlign: TextAlign.center,
                      //   controller: nameText,
                      //   decoration: InputDecoration(
                      //     border: UnderlineInputBorder(),
                      //     labelText: "Display Name",
                      //   ),
                      // ),
                      // SizedBox(
                      //   height: 16.0,
                      // ),
                      // TextFormField(
                      //   textAlign: TextAlign.center,
                      //   controller: emailText,
                      //   decoration: InputDecoration(
                      //     border: UnderlineInputBorder(),
                      //     labelText: "Email",
                      //   ),
                      // ),
                      SizedBox(
                        height: 16.0,
                      ),

                      TextFormBuilder(
                        validateFunction: (value) {
                          if (value.isEmpty) {
                            return 'Please enter a meeting room name';
                          }
                          return null;
                        },
                        controller: roomText,
                        prefix: Feather.mail,
                        hintText: "Room name",
                        textInputAction: TextInputAction.next,
                      ),
                      SizedBox(
                        height: 16.0,
                      ),
                      TextFormBuilder(
                        controller: subjectText,
                        prefix: Feather.cast,
                        hintText: "Meeting subject",
                        textInputAction: TextInputAction.next,
                      ),
                      SizedBox(
                        height: 16.0,
                      ),
                      TextFormBuilder(
                        validateFunction: (value) {
                          if (value.isEmpty) {
                            return 'Please enter your username';
                          }
                          return null;
                        },
                        controller: nameText,
                        prefix: Feather.user,
                        hintText: "Display name",
                        textInputAction: TextInputAction.next,
                      ),
                      SizedBox(
                        height: 16.0,
                      ),
                      TextFormBuilder(
                        controller: emailText,
                        prefix: Feather.mail,
                        hintText: "E-mail",
                        textInputAction: TextInputAction.next,
                      ),
                      SizedBox(
                        height: 16.0,
                      ),
                      // CheckboxListTile(
                      //   title: Text("Audio Only"),
                      //   value: isAudioOnly,
                      //   onChanged: _onAudioOnlyChanged,
                      //     controlAffinity: ListTileControlAffinity.leading,
                      // ),
                      // SizedBox(
                      //   height: 16.0,
                      // ),
                      CheckboxListTile(
                        title: Text("Audio Muted"),
                        value: isAudioMuted,
                        secondary: Icon(Icons.volume_down),
                        onChanged: _onAudioMutedChanged,
                        controlAffinity: ListTileControlAffinity.platform,
                      ),
                      SizedBox(
                        height: 16.0,
                      ),
                      CheckboxListTile(
                        title: Text("Video Muted"),
                        value: isVideoMuted,
                        secondary: Icon(Icons.video_call),
                        onChanged: _onVideoMutedChanged,
                        controlAffinity: ListTileControlAffinity.platform,
                      ),
                      Divider(
                        height: 48.0,
                        thickness: 2.0,
                      ),
                      // SizedBox(
                      //   height: 64.0,
                      //   width: double.maxFinite,
                      // ),
                      // SizedBox(
                      //   height: 48.0,
                      // ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      _joinMeeting();
                    }
                  },
                  child: Text(
                    "Join Meeting",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(
                  height: 16.0,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: Colors.red),
                  child: Text("Delete my account", style: TextStyle(color: Colors.white),),
                  onPressed: deleteAccount,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  deleteAccount() async {
    try {
      await userRef.doc(auth.currentUser.uid).delete();
      auth.currentUser.delete();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Sorry to see you go")));
      Timer(Duration(seconds: 3), () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => UserRegister()));
      });
    }
    catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Some error occurred, please try again later")));
    }
  }

  _onAudioOnlyChanged(bool value) {
    setState(() {
      isAudioOnly = value;
    });
  }

  _onAudioMutedChanged(bool value) {
    setState(() {
      isAudioMuted = value;
    });
  }

  _onVideoMutedChanged(bool value) {
    setState(() {
      isVideoMuted = value;
    });
  }

  _joinMeeting() async {
    String serverUrl =
        serverText.text?.trim()?.isEmpty ?? "" ? null : serverText.text;

    try {
      // Enable or disable any feature flag here
      // If feature flag are not provided, default values will be used
      // Full list of feature flags (and defaults) available in the README
      FeatureFlag featureFlag = FeatureFlag();
      featureFlag.welcomePageEnabled = false;

      featureFlag.chatEnabled = false;
      featureFlag.recordingEnabled = false;
      featureFlag.iOSRecordingEnabled = false;
      featureFlag.liveStreamingEnabled = false;
      featureFlag.liveStreamingEnabled = false;
      // Here is an example, disabling features for each platform
      if (Platform.isAndroid) {
        // Disable ConnectionService usage on Android to avoid issues (see README)
        featureFlag.callIntegrationEnabled = false;
      } else if (Platform.isIOS) {
        // Disable PIP on iOS as it looks weird
        featureFlag.pipEnabled = false;
      }

      //uncomment to modify video resolution
      featureFlag.resolution = FeatureFlagVideoResolution.HD_RESOLUTION;

      // Define meetings options here
      var options = JitsiMeetingOptions()
        ..room = roomText.text
        ..serverURL = "https://kotha.waltonbd.com"
        ..subject = subjectText.text
        ..userDisplayName = nameText.text
        ..userEmail = emailText.text
        ..audioOnly = isAudioOnly
        ..audioMuted = isAudioMuted
        ..videoMuted = isVideoMuted
        ..featureFlag = featureFlag;

      debugPrint("JitsiMeetingOptions: $options");
      await JitsiMeet.joinMeeting(
        options,
        listener: JitsiMeetingListener(onConferenceWillJoin: ({message}) {
          debugPrint("${options.room} will join with message: $message");
        }, onConferenceJoined: ({message}) {
          debugPrint("${options.room} joined with message: $message");
        }, onConferenceTerminated: ({message}) {
          debugPrint("${options.room} terminated with message: $message");
        }, onPictureInPictureWillEnter: ({message}) {
          debugPrint("${options.room} entered PIP mode with message: $message");
        }, onPictureInPictureTerminated: ({message}) {
          debugPrint("${options.room} exited PIP mode with message: $message");
        }),
        // by default, plugin default constraints are used
        //roomNameConstraints: new Map(), // to disable all constraints
        //roomNameConstraints: customConstraints, // to use your own constraint(s)
      );
    } catch (error) {
      debugPrint("error: $error");
    }
  }

  static final Map<RoomNameConstraintType, RoomNameConstraint>
      customConstraints = {
    RoomNameConstraintType.MAX_LENGTH: new RoomNameConstraint((value) {
      return value.trim().length <= 50;
    }, "Maximum room name length should be 30."),
    RoomNameConstraintType.FORBIDDEN_CHARS: new RoomNameConstraint((value) {
      return RegExp(r"[$€£]+", caseSensitive: false, multiLine: false)
              .hasMatch(value) ==
          false;
    }, "Currencies characters aren't allowed in room names."),
  };

  void _onConferenceWillJoin({message}) {
    debugPrint("_onConferenceWillJoin broadcasted with message: $message");
  }

  void _onConferenceJoined({message}) {
    debugPrint("_onConferenceJoined broadcasted with message: $message");
  }

  void _onConferenceTerminated({message}) {
    debugPrint("_onConferenceTerminated broadcasted with message: $message");
  }

  void _onPictureInPictureWillEnter({message}) {
    debugPrint(
        "_onPictureInPictureWillEnter broadcasted with message: $message");
  }

  void _onPictureInPictureTerminated({message}) {
    debugPrint(
        "_onPictureInPictureTerminated broadcasted with message: $message");
  }

  _onError(error) {
    debugPrint("_onError broadcasted: $error");
  }
}
