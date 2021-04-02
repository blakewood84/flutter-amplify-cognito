import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'amplifyconfiguration.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _amplifyConfigured = false;
  bool isSignUpComplete = false;
  bool isConfirmed = false;
  bool isSignedIn = false;
  String confirmationCode = '';
  String emailAdress = '';
  String password = '';

  @override
  void initState() {
    super.initState();
    _configureAmplify();
  }

  void _configureAmplify() async {
    if (!mounted) return;

    // Add Pinpoint and Cognito Plugins
    // Amplify.addPlugin(AmplifyAnalyticsPinpoint());
    Amplify.addPlugin(AmplifyAuthCognito());

    // Once Plugins are added, configure Amplify
    // Note: Amplify can only be configured once.
    try {
      await Amplify.configure(amplifyconfig);
    } on AmplifyAlreadyConfiguredException {
      print("Amplify was already configured. Was the app restarted?");
    }
    try {
      setState(() {
        _amplifyConfigured = true;
      });
    } catch (e) {
      print(e);
    }
  }

  void signUpTest() async {
    try {
      Map<String, String> userAttributes = {
        'email': 'blake@rewired.one',
        'phone_number': '+15307828285',
        // additional attributes as needed
      };
      SignUpResult res = await Amplify.Auth.signUp(
          username: 'blake@rewired.one',
          password: 'test1234',
          options: CognitoSignUpOptions(userAttributes: userAttributes));
      setState(() {
        isSignUpComplete = res.isSignUpComplete;
        print(inspect(res.nextStep));
        print(inspect(res));
      });
    } on AuthException catch (e) {
      print(e.message);
    }
  }

  void confirmTest(String confirmationCode) async {
    print('confirming!');
    try {
      SignUpResult res = await Amplify.Auth.confirmSignUp(
          username: 'blake@rewired.one', confirmationCode: '$confirmationCode');
      setState(() {
        isConfirmed = res.isSignUpComplete;
      });
    } on AuthException catch (e) {
      print(e.message);
    }
  }

  void testToken() async {
    try {
      var res = await Amplify.Auth.getCurrentUser();
      var res2 = await Amplify.Auth.fetchAuthSession();

      print(inspect(res));
      print(inspect(res2));
    } on AuthException catch (e) {
      print(e.message);
    }
  }

  void signInTest(String emailAddress, String password) async {
    try {
      var res = await Amplify.Auth.signIn(
        username: 'blake@rewired.one',
        password: 'test1234',
      );
      print(inspect(res));
      setState(() {
        // isSignedIn = res.isSignedIn;
      });
    } on AuthException catch (e) {
      print(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Amplify Core example app'),
        ),
        body: ListView(
          padding: EdgeInsets.all(10.0),
          children: <Widget>[
            Center(
              child: Column(
                children: [
                  const Padding(padding: EdgeInsets.all(5.0)),
                  Text(_amplifyConfigured ? 'configured' : 'not configured'),
                  ElevatedButton(
                    onPressed: () {
                      if (_amplifyConfigured) {
                        signUpTest();
                      }
                    },
                    child: const Text('Test Signup'),
                  ),
                  TextFormField(
                    initialValue: confirmationCode,
                    onChanged: (value) =>
                        setState(() => confirmationCode = value),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_amplifyConfigured) {
                        confirmTest(confirmationCode);
                      }
                    },
                    child: const Text('Confirm'),
                  ),
                  Text(isConfirmed ? 'Confirmed' : 'Not Confirmed'),
                  SizedBox(height: 60),
                  TextFormField(
                      initialValue: emailAdress,
                      onChanged: (value) =>
                          setState(() => emailAdress = value)),
                  SizedBox(height: 20),
                  TextFormField(
                    initialValue: password,
                    onChanged: (value) => setState(() => password = value),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_amplifyConfigured) {
                        signInTest(emailAdress, password);
                      }
                    },
                    child: const Text('SignIn'),
                  ),
                  Text(isSignedIn ? 'Signed In' : 'Not Signed In'),
                  ElevatedButton(
                    onPressed: () {
                      if (_amplifyConfigured) {
                        testToken();
                      }
                    },
                    child: const Text('Test Token'),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
