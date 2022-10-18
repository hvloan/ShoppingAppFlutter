import 'package:carousel_indicator/carousel_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_social_button/flutter_social_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../controller/bottom_nav_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _fireStoreInstance = FirebaseFirestore.instance;
  var policyAndTerms = "";
  var _dotPosition = 0;
  var _isCheck = false;
  List listCarousel = [];

  getDataCarousel() async {
    CollectionReference reference = _fireStoreInstance.collection('splashScreen');
    reference.snapshots().listen((querySnapshot) {
      for (var change in querySnapshot.docChanges) {
        listCarousel.add(
          {
            "imgUrl": change.doc["imgUrl"],
            "subText": change.doc["subText"],
          }
        );
      }
    });
  }

  getDataPrivacyAndTerms() async {
    QuerySnapshot querySnapshot =
        await _fireStoreInstance.collection('policyAndTerms').get();
    setState(() {
      policyAndTerms = querySnapshot.docs[0]["policyAndTerms"] as String;
    });
    return querySnapshot.docs;
  }

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.blue;
    }
    return Colors.black;
  }

  googleSignInMethod() async {
    final GoogleSignInAccount? googleUser =
        await GoogleSignIn(scopes: <String>['email']).signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return await FirebaseAuth.instance.signInWithCredential(credential).then(
        (value) => Navigator.push(context,
            CupertinoPageRoute(builder: (_) => const BottomNavController())));
  }

  showToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 5,
      backgroundColor: Colors.redAccent,
    );
  }

  @override
  void initState() {
    getDataCarousel();
    getDataPrivacyAndTerms();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              flex: 7,
              child: CarouselSlider(
                items: listCarousel.map(
                  (e) {
                    return Container(
                      margin: const EdgeInsets.only(
                          left: 10, right: 10, bottom: 10, top: 50),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image.network(
                            e['imgUrl'],
                            alignment: Alignment.center,
                            width: double.maxFinite,
                            height: 250,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 20.0,
                                horizontal: 20.0,
                              ),
                              child: Text(
                                e['subText'],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          CarouselIndicator(
                            count: listCarousel.length,
                            index: _dotPosition,
                            color: Colors.black26,
                            activeColor: Colors.black,
                            cornerRadius: 10.0,
                            width: 10.0,
                            height: 10.0,
                          )
                        ],
                      ),
                    );
                  },
                ).toList(),
                options: CarouselOptions(
                  autoPlay: true,
                  viewportFraction: 1,
                  enlargeCenterPage: true,
                  aspectRatio: 1.0,
                  enlargeStrategy: CenterPageEnlargeStrategy.height,
                  onPageChanged: (val, carouselPageChangedReason) {
                    setState(() {
                      _dotPosition = val;
                    });
                  },
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25.0),
                    topRight: Radius.circular(25.0),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Checkbox(
                          checkColor: Colors.white,
                          fillColor: MaterialStateColor.resolveWith(getColor),
                          value: _isCheck,
                          onChanged: (bool? value) {
                            setState(() {
                              _isCheck = value!;
                            });
                          },
                        ),
                        RichText(
                          text: const TextSpan(
                            text: 'I agree with ',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                  text: 'Policy',
                                  style: TextStyle(
                                      color: Colors.indigo,
                                      fontWeight: FontWeight.bold)),
                              TextSpan(text: ' and '),
                              TextSpan(
                                  text: 'Terms',
                                  style: TextStyle(
                                      color: Colors.indigo,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )
                      ],
                    ),
                    FlutterSocialButton(
                      buttonType: ButtonType.google,
                      iconColor: Colors.white,
                      onTap: () {
                        if (_isCheck == true) {
                          googleSignInMethod();
                        } else {
                          showToast('Please read and accept policy & terms to continue!');
                        }
                      },
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
