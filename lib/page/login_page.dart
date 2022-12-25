import 'package:flutter/material.dart';
import 'package:omjh/common/theme_style.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 100.0),
              child: Center(
                child: SizedBox(
                    width: 200,
                    height: 150,
                    child: Image.asset('assets/image/ic_logo.png')),
              ),
            ),
            const Padding(
              padding:
                  EdgeInsets.only(left: 20.0, right: 20.0, top: 40, bottom: 0),
              child: TextField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'User Name',
                    hintText: 'User Name'),
              ),
            ),
            const Padding(
              padding:
                  EdgeInsets.only(left: 20.0, right: 20.0, top: 15, bottom: 0),
              //padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    hintText: 'Enter secure password'),
              ),
            ),
            Container(
              height: 50,
              width: 250,
              margin: const EdgeInsets.only(top: 30),
              decoration: BoxDecoration(
                  color: ThemeStyle.bgColor, borderRadius: BorderRadius.circular(20)),
              child: TextButton(
                onPressed: () {
                  // Navigator.push(
                  //     context, MaterialPageRoute(builder: (_) => HomePage()));
                },
                child: const Text(
                  'Login',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            const Text('New User? Create Account')
          ],
        ),
      ),
    );
  }
}
