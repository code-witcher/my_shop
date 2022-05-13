import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_shop/providers/auth_provider.dart';
import 'package:provider/provider.dart';

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
                    backgroundImage: NetworkImage(
                      'https://64.media.tumblr.com/03beab1e7ba71b5fc6e31b91f9f42c18/f39ef18f19d2b20b-68/s400x600/ace2a6fecf2087e07979d702b4f94a110dc53d24.pnj',
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

class _UserDetailsState extends State<UserDetails> {
  final passwordController = TextEditingController();
  var _signup = false;
  final _formKey = GlobalKey<FormState>();
  final authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;

  void _saveData() async {
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState?.save();

    setState(() {
      _isLoading = true;
    });
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
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          child: Column(
            children: [
              /** Email */
              TextFormField(
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
                  if (!value.contains('@') || !value.contains('.')) {
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
                TextFormField(
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please re-enter your password';
                    }
                    if (value != passwordController.text) {
                      return 'This doesn\'t match your password';
                    }
                    return null;
                  },
                ),
              const SizedBox(
                height: 16,
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
                },
                child: Text(_signup ? 'Login' : 'Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
