import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

import 'home.dart';

class AuthGate extends StatelessWidget {
 const AuthGate({super.key});

 @override
 Widget build(BuildContext context) {
   return StreamBuilder<User?>(
     stream: FirebaseAuth.instance.authStateChanges(),
     builder: (context, snapshot) {
       if (!snapshot.hasData) {
         return SignInScreen(
            providers: [
              EmailAuthProvider(),
            ],
            showAuthActionSwitch: false,
            headerBuilder: (context, constraints, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset('assets/2a0ad195769368b1.gif'),
                ),
              );
            },
            subtitleBuilder: (context, action) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 18.0),
                child: Text('Welcome to FlutterFire, please sign in!'),
              );
            },
            oauthButtonVariant: OAuthButtonVariant.icon,
            footerBuilder: (context, action) {
              return const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  'By signing in, you agree to our terms and conditions.',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            },
            sideBuilder: (context, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset('assets/2a0ad195769368b1.gif'),
                ),
              );
            },
         );
       }
       return const HomeScreen();
     },
   );
 }
}
