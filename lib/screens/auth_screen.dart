import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_shop/providers/auth_provider.dart';
import 'package:provider/provider.dart';

import '../models/http_exception.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.red,
                    Colors.orange,
                    Colors.pink,
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage(
                      'images/splash.png',
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text(
                    'Glitter',
                    style: GoogleFonts.macondo(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  const UserDetails(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class UserDetails extends StatefulWidget {
  const UserDetails({Key? key}) : super(key: key);

  @override
  State<UserDetails> createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails>
    with SingleTickerProviderStateMixin {
  final passwordController = TextEditingController();
  var _signup = false;
  final _formKey = GlobalKey<FormState>();
  final authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slidAnimation;
  late AnimationController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    _slidAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _saveData() async {
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState?.save();

    setState(() {
      _isLoading = true;
    });
    try {
      if (_signup) {
        await Provider.of<AuthProvider>(
          context,
          listen: false,
        ).signup(authData['email'], authData['password']);
      } else {
        await Provider.of<AuthProvider>(
          context,
          listen: false,
        ).login(authData['email'], authData['password']);
      }
      setState(() {
        _isLoading = false;
      });
    } on HttpException catch (error) {
      var errorMessage = '';
      // 1
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email already exists try to Login instead';
      }
      // 2
      else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage =
            'Invalid email please try again with valid email adress.';
      }
      // 3
      else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'This is too weak password';
      }
      // 4
      else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'This email isn\'t registered yet try to Sing up';
      }
      // 5
      else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage =
            'Incorrect password please try again with valid password';
      }
      // 6
      else if (error.toString().contains('USER_DISABLED')) {
        errorMessage = 'Your account has been disabled by an administrator.';
      }
      showAlertDialog(errorMessage);
    } catch (e) {
      print('in AuthScreen 172 $e');
      var errorMessage = 'An error occurred please try again later';
      showAlertDialog(errorMessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void showAlertDialog(String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('An Error occurred'),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      key: _formKey,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          constraints: BoxConstraints(
            minHeight: _signup ? 350 : 300,
          ),
          height: _signup ? 350 : 300,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                /** Email */
                TextFormField(
                  textInputAction: TextInputAction.next,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    label: const Text('Email'),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(),
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email address';
                    }
                    if (!value.contains('@') || !value.contains('.com')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  onSaved: (email) {
                    authData['email'] = email!;
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                /** Password */
                TextFormField(
                  textInputAction: TextInputAction.next,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    label: const Text('Password'),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(),
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  controller: passwordController,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  obscuringCharacter: '×',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password can be at least 6 characters';
                    }
                    return null;
                  },
                  onSaved: (password) {
                    authData['password'] = password!;
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                /** Confirm Password */
                if (_signup)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    constraints: BoxConstraints(
                      minHeight: _signup ? 50 : 0,
                      maxHeight: _signup ? 150 : 0,
                    ),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slidAnimation,
                        child: TextFormField(
                          enabled: _signup,
                          textInputAction: TextInputAction.next,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: InputDecoration(
                            label: const Text('Confirm Password'),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(),
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: true,
                          obscuringCharacter: '×',
                          validator: _signup
                              ? (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please re-enter your password';
                                  }
                                  if (value != passwordController.text) {
                                    return 'This doesn\'t match your password';
                                  }
                                  return null;
                                }
                              : null,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      _saveData();
                    },
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text(
                            _signup ? 'Sign Up' : 'Login',
                            style: GoogleFonts.macondo(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                FlatButton(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onPressed: () {
                    setState(() {
                      _signup = !_signup;
                    });
                    if (_signup) {
                      _controller.forward();
                    } else {
                      _controller.reverse();
                    }
                  },
                  child: Text(_signup ? 'Login' : 'Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
