import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:login_email/blocs/internet_bloc.dart';
import 'package:login_email/blocs/sign_in_bloc.dart';
import 'package:login_email/pages/forget_password_page.dart';
import 'package:login_email/pages/home_page.dart';
import 'package:login_email/pages/sign_up_page.dart';
import 'package:login_email/utils/next_screen.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() {
    return _SignInPageState();
  }
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String _errorMessage = '';

  void onChange() {
    setState(() {
      _errorMessage = '';
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  handleSignIn() async {
    final sb = context.read<SignInBloc>();
    final ib = context.read<InternetBloc>();
    setState(() => _loading = true);
    await ib.checkInternet();
    if (ib.checkInternet() == false) {
    } else {
      sb
          .signIn(
        email: emailController.text,
        password: passwordController.text,
      )
          .then((_) {
        if (sb.hasError == true) {
          processError(sb.errorCode!);
          setState(() => _loading = false);
        } else {
          if (!sb.isVeryfy) {
            processError("verify");
          } else {
            sb.getUserDatafromFirebase(sb.uid).then((value) =>
                sb.saveDataToSP().then((value) => sb.setSignIn().then((value) {
                      nextScreenCloseOthers(context, const HomePage());
                    })));
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);

    emailController.addListener(onChange);
    passwordController.addListener(onChange);

    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.only(left: 24.0, right: 24.0),
              children: <Widget>[
                Hero(
                  tag: 'hero',
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: 48.0,
                    child: Image.asset('assets/logo.png'),
                  ),
                ),
                const SizedBox(height: 24.0),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(fontSize: 14.0, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12.0),
                TextFormField(
                  validator: (value) {
                    if (value!.isEmpty || !value.contains('@')) {
                      return 'Please enter a valid email.';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.emailAddress,
                  autofocus: false,
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    contentPadding:
                        const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32.0)),
                  ),
                  textInputAction: TextInputAction.next,
                  onEditingComplete: () => node.nextFocus(),
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  autofocus: false,
                  obscureText: true,
                  controller: passwordController,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (v) {
                    FocusScope.of(context).requestFocus(node);
                  },
                  decoration: InputDecoration(
                    hintText: 'Password',
                    contentPadding:
                        const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32.0)),
                  ),
                ),
                const SizedBox(height: 24.0),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.lightBlueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.all(12),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        handleSignIn();
                      }
                    },
                    child: !_loading
                        ? const Text('Log In',
                            style: TextStyle(color: Colors.white))
                        : const Center(
                            child: CircularProgressIndicator(
                                backgroundColor: Colors.white),
                          ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.zero,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.lightGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.all(12),
                      ),
                      onPressed: () {
                        nextScreen(context, const SignUpPage());
                      },
                      child: const Text('Register',
                          style: TextStyle(color: Colors.white))),
                ),
                TextButton(
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(color: Colors.black54),
                  ),
                  onPressed: () {
                    nextScreen(context, const ForgetPasswordPage());
                  },
                )
              ],
            ),
          ),
        ));
  }

  void processError(final String error) {
    if (error == "user-not-found") {
      setState(() {
        _errorMessage = "Unable to find user. Please register.";
      });
    } else if (error == "wrong-password") {
      setState(() {
        _errorMessage = "Incorrect password.";
      });
    } else if (error == "verify") {
      setState(() {
        _errorMessage = "Please verification account.";
      });
    } else {
      setState(() {
        _errorMessage =
            "There was an error logging in. Please try again later.";
      });
    }
  }
}
