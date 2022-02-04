import 'package:flutter/material.dart';
import 'package:login_email/blocs/internet_bloc.dart';
import 'package:login_email/blocs/sign_in_bloc.dart';
import 'package:login_email/pages/sign_in_page.dart';
import 'package:login_email/utils/next_screen.dart';
import 'package:provider/provider.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({Key? key}) : super(key: key);

  @override
  _ForgetPasswordPageState createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();

  String _errorMessage = '';

  void onChange() {
    setState(() {
      _errorMessage = '';
    });
  }

  handleForgetPassword() async {
    final sb = context.read<SignInBloc>();
    final ib = context.read<InternetBloc>();
    setState(() => _loading = true);
    await ib.checkInternet();
    if (ib.checkInternet() == false) {
    } else {
      sb
          .forgetPassword(
        email: emailController.text,
      )
          .then((_) {
        if (sb.hasError == true) {
          processError(sb.errorCode!);
          setState(() => _loading = false);
        } else {
          showDialog(
              context: context,
              builder: (_) => SimpleDialog(
                    contentPadding: const EdgeInsets.all(50),
                    elevation: 0,
                    children: [
                      const Text("Please Check Your Email",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w900)),
                      const SizedBox(
                        height: 10,
                      ),
                      Text('we send email to your account to reset password...',
                          style: TextStyle(
                              color: Colors.grey[900],
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(
                        height: 30,
                      ),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.purpleAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.all(12),
                          ),
                          child: const Text(
                            'Oke',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                          onPressed: () =>
                              nextScreen(context, const SignInPage()),
                        ),
                      )
                    ],
                  ));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);
    emailController.addListener(onChange);

    final errorMessage = Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        _errorMessage,
        style: const TextStyle(fontSize: 14.0, color: Colors.red),
        textAlign: TextAlign.center,
      ),
    );

    return Scaffold(
      body: Center(
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.only(left: 24.0, right: 24.0),
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Forget Password',
                  style: TextStyle(fontSize: 36.0, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24.0),
              errorMessage,
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
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.lightGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.all(12),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      handleForgetPassword();
                    }
                  },
                  child: !_loading
                      ? Text('Forget Password'.toUpperCase(),
                          style: const TextStyle(color: Colors.white))
                      : const Center(
                          child: CircularProgressIndicator(
                              backgroundColor: Colors.white),
                        ),
                ),
              ),
              Padding(
                  padding: EdgeInsets.zero,
                  child: TextButton(
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.black54),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ))
            ],
          ),
        ),
      ),
    );
  }

  void processError(final String error) {
    setState(() {
      _errorMessage = error;
    });
  }
}
