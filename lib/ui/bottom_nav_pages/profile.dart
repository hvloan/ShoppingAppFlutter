import 'package:e_commerce_app/ui/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final auth = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    var userName = auth?.displayName;
    var userEmail = auth?.email;
    var userPhotoUrl = auth?.photoURL;
    var userPhoneNumber = auth?.phoneNumber;
    userPhoneNumber ??= "+84";
    print(auth);
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(left: 16, top: 10, right: 16),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: ListView(
            children: [
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                          border: Border.all(
                              width: 4,
                              color: Theme.of(context).scaffoldBackgroundColor),
                          boxShadow: [
                            BoxShadow(
                                spreadRadius: 2,
                                blurRadius: 10,
                                color: Colors.black.withOpacity(0.1),
                                offset: const Offset(0, 10))
                          ],
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(
                                userPhotoUrl!,
                              ))),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: 4,
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                          color: Colors.deepOrangeAccent,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 35,
              ),
              buildTextField("Full Name", userName!, false),
              buildTextField("E-mail", userEmail!, false),
              buildTextField("Phone number", userPhoneNumber, true),
              const SizedBox(
                height: 35,
              ),
              Container(
                margin: const EdgeInsets.only(left: 8, right: 8),
                width: MediaQuery.of(context).size.width,
                height: 56,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.logout_sharp),
                  onPressed: () => {signOut()},
                  style: ElevatedButton.styleFrom(
                    primary: Colors.deepOrange,
                    elevation: 3,
                  ),
                  label: const Text(
                    "Logout",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String labelText, String placeholder, bool isNumber) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextField(
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(bottom: 3),
          labelText: labelText,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintText: placeholder,
          hintStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        keyboardType: isNumber ? TextInputType.number : null,
        enabled: isNumber ? true : false,
        onSubmitted: (phoneNumber) {
          // auth?.updatePhoneNumber(
          //     // PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);
          // );
        },
      ),
    );
  }

  Future<void> signOut() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      if (!kIsWeb) {
        await googleSignIn.signOut();
        Navigator.push(context, CupertinoPageRoute(builder: (_) => const LoginScreen()));
      }
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print(e);
    }
  }
}
