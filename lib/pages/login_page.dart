import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:salvavidas/provider/auth_provider.dart';
import 'package:sign_in_button/sign_in_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.signInWithGoogle().then((value) {
      if (authProvider.isAuth) {
        context.go('/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(132, 26, 30, 1),
                Color.fromRGBO(136, 39, 39, 1),
                Color.fromRGBO(183, 14, 33, 1),
                Color.fromRGBO(216, 3, 25, 1),
                Color.fromRGBO(228, 0, 26, 1)
              ]),
        ),
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              fit: BoxFit.cover,
              'assets/icons/logo-out-bg.png',
              width: screenWidth / 2,
            ),
            const SizedBox(
              height: 5,
            ),
            const Text(
              "Salvavidas",
              style: TextStyle(
                fontSize: 30,
                color: Colors.white,
                fontFamily: 'Comfortaa',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SignInButton(
              Buttons.google,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              text: "Iniciar sesión con Google",
              padding: const EdgeInsets.only(left: 15, right: 15),
              onPressed: () {
                authProvider.signInWithGoogle().then((value) {
                  context.go('/home');
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
