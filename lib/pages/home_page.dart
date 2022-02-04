import 'package:flutter/material.dart';
import 'package:login_email/blocs/sign_in_bloc.dart';
import 'package:login_email/pages/sign_in_page.dart';
import 'package:login_email/utils/next_screen.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final SignInBloc sb = Provider.of<SignInBloc>(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                sb.name!,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                sb.email!,
                style: const TextStyle(fontSize: 18),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextButton(
                    onPressed: () => openLogoutDialog(context),
                    style: TextButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5))),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.logout,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Logout',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        )
                      ],
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void openLogoutDialog(context) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout From Application'),
          actions: [
            TextButton(
              child: const Text('NO'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('YES'),
              onPressed: () async {
                Navigator.pop(context);
                await context.read<SignInBloc>().userSignout().then((value) =>
                    nextScreenCloseOthers(context, const SignInPage()));
              },
            )
          ],
        );
      });
}
