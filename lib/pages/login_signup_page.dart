import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:password_strength_checker/password_strength_checker.dart';
import 'dart:ui';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  String usernameError = '';
  String passwordError = '';
  String confirmPasswordError = '';
  String state = "login";
  String password = '';
  String username = '';
  String confirmPassword = '';
  bool showPasswordStrength = false;
  bool isAnimating = true;
  final passNotifier = ValueNotifier<PasswordStrength?>(null);

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          isAnimating = false;
        });
      }
    });

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 1100));
      setState(() {
        isAnimating = false;
      });
    });
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  double currentSize =
                      lerpDouble(0.5, 1, _animationController.value)!;
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(0, isAnimating ? 0 : 0),
                      end: Offset(0, isAnimating ? -1.695 : 0),
                    ).animate(CurvedAnimation(
                      curve: Curves.easeInOut,
                      parent: _animationController,
                    )),
                    child: Transform.scale(
                      scale: currentSize,
                      child: child,
                    ),
                  );
                },
                child: Opacity(
                  opacity: 1, // Fade effect based on animation value
                  child: Image.asset('assets/logo.png', height: 250),
                ),
              ),
              if (!isAnimating)
                AnimatedOpacity(
                  opacity: _animationController.value,
                  duration: const Duration(milliseconds: 500),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: const EdgeInsets.fromLTRB(50, 0, 50, 0),
                        child: SizedBox(
                          width: 250,
                          child: TextField(
                            controller: usernameController,
                            onChanged: (value) => username = value,
                            decoration: InputDecoration(
                              helperText: usernameError,
                              border: const OutlineInputBorder(),
                              labelText: 'Username',
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(50, 0, 50, 0),
                        child: SizedBox(
                          width: 250,
                          child: TextField(
                            onChanged: (value) {
                              password = value;
                              passNotifier.value =
                                  PasswordStrength.calculate(text: value);
                            },
                            obscureText: true,
                            onTap: () => setState(() {
                              if (state == "signup") {
                                showPasswordStrength = true;
                              }
                            }),
                            controller: passwordController,
                            decoration: InputDecoration(
                              helperText: passwordError,
                              border: const OutlineInputBorder(),
                              labelText: 'Password',
                            ),
                          ),
                        ),
                      ),
                      if (state == 'signup' && showPasswordStrength)
                        Container(
                          margin: const EdgeInsets.fromLTRB(50, 00, 50, 15),
                          child: PasswordStrengthChecker(
                            strength: passNotifier,
                          ),
                        ),
                      if (state == 'signup')
                        Container(
                          margin: const EdgeInsets.fromLTRB(50, 0, 50, 30),
                          child: SizedBox(
                            width: 250,
                            child: TextField(
                              controller: confirmPasswordController,
                              onChanged: (value) => confirmPassword = value,
                              decoration: InputDecoration(
                                helperText: confirmPasswordError,
                                border: const OutlineInputBorder(),
                                labelText: 'ConfirmPassword',
                              ),
                            ),
                          ),
                        ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(50, 00, 50, 15),
                        child: FilledButton.tonal(
                          onPressed: () async {
                            setState(() {
                              context.go("/homepage");
                              return;
                              if (username == '') {
                                usernameError = 'Username is required';
                              } else {
                                usernameError = '';
                              }
                              if (password == '') {
                                passwordError = 'Password is required';
                              } else {
                                passwordError = '';
                              }
                              if (confirmPassword == '') {
                                confirmPasswordError =
                                    'Confirm Password is required';
                              } else {
                                confirmPasswordError = '';
                              }
                            });
                            if (state == "login" && username == '' ||
                                password == '') {
                              return;
                            } else if (state == "signup" && username == '' ||
                                password == '' ||
                                confirmPassword == '') {
                              return;
                            }
                            RegExp emailRegex = RegExp(
                              r'^[a-zA-Z]+[.][a-zA-Z]+@(student\.)?guc\.edu\.eg$',
                            );

                            if (password != confirmPassword &&
                                state == "signup") {
                              await showDialog<void>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Error'),
                                    content: const Text(
                                        'The passwords do not match!'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else if (!emailRegex.hasMatch(username)) {
                              await showDialog<void>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Error'),
                                    content: const Text('Invalid GUC email!'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else if (state ==
                                "login") //add and condition for db returning false
                            {
                              await showDialog<void>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Error'),
                                    content: const Text(
                                        'Invalid username or password!'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else if (false) // fail on signup from db
                              await showDialog<void>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Error'),
                                    content: const Text('User already exists!'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            else if (true) {
                              //success login from db (assign tokens)
                              context.go('/homepage');
                            } else if (true) {
                              // success signup from db (assign tokens)
                              context.go('/homepage');
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(state == "login" ? 'Login' : 'Sign Up',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                )),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(50, 00, 50, 15),
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              if (state == "login") {
                                state = "signup";
                              } else {
                                state = "login";
                              }
                              username = '';
                              password = '';
                              confirmPassword = '';
                              passwordError = '';
                              usernameError = '';
                              confirmPasswordError = '';
                              usernameController.clear();
                              passwordController.clear();
                              confirmPasswordController.clear();
                              passNotifier.value =
                                  PasswordStrength.calculate(text: "");
                              showPasswordStrength = false;
                            });
                          },
                          child: Text(
                              state == "login"
                                  ? 'Sign Up instead'
                                  : 'Login instead',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                              )),
                        ),
                      )
                    ],
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}