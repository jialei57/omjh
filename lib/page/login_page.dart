import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omjh/bloc/login_bloc.dart';
import 'package:omjh/common/theme_style.dart';
import 'package:omjh/main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final LoginBloc _bloc = LoginBloc();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool validate() {
    final form = _formKey.currentState;
    return (form?.validate() == true);
  }

  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.only(top: 100.0),
      child: Center(
        child: SizedBox(
            width: 200,
            height: 150,
            child: Image.asset('assets/image/ic_logo.png')),
      ),
    );
  }

  Widget _buildUserNameField() {
    return Padding(
      padding:
          const EdgeInsets.only(left: 20.0, right: 20.0, top: 40, bottom: 0),
      child: TextFormField(
        decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: 'user_name'.tr,
            hintText: 'user_name'.tr),
        validator: (value) => (value == null || value.isEmpty)
            ? 'user_name_cannot_empty'.tr
            : null,
        controller: _usernameController,
      ),
    );
  }

  Widget _buildPasswordField() {
    return Padding(
      padding:
          const EdgeInsets.only(left: 20.0, right: 20.0, top: 15, bottom: 0),
      child: TextFormField(
        obscureText: true,
        decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: 'password'.tr,
            hintText: 'password'.tr),
        validator: (value) => (value == null || value.isEmpty)
            ? 'password_cannot_empty'.tr
            : null,
        controller: _passwordController,
      ),
    );
  }

  void login() async {
    final token = await _bloc.authendicate(
        _usernameController.text, _passwordController.text);
    if (token != null && token.isNotEmpty) {
      Get.offAll(() => const SplashPage());
    }
  }

  Widget _buildLoginButton() {
    return Container(
      margin: const EdgeInsets.only(top: 30, bottom: 50),
      width: 250,
      height: 50,
      child: OutlinedButton(
          style: OutlinedButton.styleFrom(
              backgroundColor: ThemeStyle.bgColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18))),
          onPressed: () {
            if (validate()) {
              login();
            }
          },
          child: Text(
            'login'.tr,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontFamily: 'NanFengXingShu'),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildLogo(),
            Form(
              key: _formKey,
              child: Column(children: [
                _buildUserNameField(),
                _buildPasswordField(),
              ]),
            ),
            _buildLoginButton(),
            Text('register_new'.tr)
          ],
        ),
      ),
    );
  }
}
