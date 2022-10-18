import 'dart:async';

import 'package:e_commerce_app/const/app_colors.dart';
import 'package:e_commerce_app/controller/bottom_nav_controller.dart';
import 'package:e_commerce_app/ui/bottom_nav_pages/home.dart';
import 'package:e_commerce_app/ui/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  User? firebaseUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    Timer(
        const Duration(seconds: 5),
        () => {
              if (firebaseUser?.email != null)
                {
                  Navigator.push(context,
                      CupertinoPageRoute(builder: (_) => const BottomNavController()))
                }
              else
                {
                  Navigator.push(context,
                      CupertinoPageRoute(builder: (_) => const LoginScreen()))
                }
            });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepOrange,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "E-Commerce",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 44.sp),
              ),
              SizedBox(
                height: 20.h,
              ),
              const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 5.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
