import 'package:flutter/material.dart';
import 'package:campus_connect_app_login/loginstack/layerone.dart';
import 'package:campus_connect_app_login/loginstack/layertwo.dart';
import 'package:campus_connect_app_login/loginstack/layerthree.dart';

void main() {
  runApp(MaterialApp(
    title: 'Campus Connect',
    theme: ThemeData(
      fontFamily: 'Poppins',
    ),
    debugShowCheckedModeBanner: false,
    home: LoginPage(),
  ));
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/primaryBg.png'),
              fit: BoxFit.cover,
            )),
        child: Stack(
          children: <Widget>[
            Positioned(
                top: 120,
                left: 30,
                child: Container(
                  child: Text(
                    'Login',
                    style: TextStyle(
                        fontSize: 68,
                        fontFamily: 'Poppins-Medium',
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                )),
            Positioned(top: 210, right: 0, bottom: 0, child: LayerOne()),
            Positioned(top: 238, right: 0, bottom: 28, child: LayerTwo()),
            Positioned(top: 240, right: 0, bottom: 38, child: LayerThree()),
          ],
        ),
      ),
    );
  }
}