import 'package:flutter/material.dart';
import 'package:omjh/bloc/login_bloc.dart';
import 'package:omjh/common/theme_style.dart';

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
        decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'User Name',
            hintText: 'User Name'),
        validator: (value) => (value == null || value.isEmpty)
            ? 'User name can not be empty'
            : null,
        controller: _usernameController,
      ),
    );
  }

  Widget _buildPasswordField() {
    return Padding(
      padding:
          const EdgeInsets.only(left: 20.0, right: 20.0, top: 15, bottom: 0),
      //padding: EdgeInsets.symmetric(horizontal: 15),
      child: TextFormField(
        obscureText: true,
        decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Password',
            hintText: 'Enter secure password'),
        validator: (value) => (value == null || value.isEmpty)
            ? 'Password can not be empty'
            : null,
        controller: _passwordController,
      ),
    );
  }

  Widget _buildLoginButton() {
    return Container(
      height: 50,
      width: 250,
      margin: const EdgeInsets.only(top: 30, bottom: 50),
      decoration: BoxDecoration(
          color: ThemeStyle.bgColor, borderRadius: BorderRadius.circular(20)),
      child: TextButton(
        onPressed: () {
          if (validate()) {
            _bloc
                .authendicate(
                    _usernameController.text, _passwordController.text)
                .then((token) => {if (token != null && token.isNotEmpty) {}});
          }
        },
        child: const Text(
          'Login',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
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
            const Text('New User? Create Account')
          ],
        ),
      ),
    );
  }
}
