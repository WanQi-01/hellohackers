import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import "ui/user_login.dart";
import "ui/user_signup.dart";
import "ui/pharmacist_login.dart";
import "ui/forgot_password.dart";
import "ui/user_dashboard.dart";
import "ui/pharmacist_dashboard.dart";
import "ui/case_card.dart";
import "ui/case_detailed_view.dart";
import "core/colors.dart";
import 'api_service.dart';


//Firebase initialisation

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // FirebaseAuth.instance.signOut();
  // print(FirebaseAuth.instance.currentUser);
  runApp(MyApp());
}

//App Root
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediAI',
      theme: ThemeData(

  colorScheme: const ColorScheme.light(
    primary: AppColors.lightBlue,
    secondary: AppColors.green,
    surface: Colors.white,
  ),

  scaffoldBackgroundColor: Colors.white,

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.teal700,
      foregroundColor: AppColors.darkTeal,
    ),
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.lightBlue,
    foregroundColor: AppColors.blue,
    elevation: 0,
  ),
),themeMode: ThemeMode.system,

      //routes
      home: const UserLoginPage(),

      routes: {
        '/userLogin': (context) => const UserLoginPage(),
        '/signUp': (context) => const UserSignupPage(),
        '/pharmacistLogin': (context) => const PharmacistLoginPage(),
        '/forgotPassword': (context) => const ForgotPasswordPage(),
      },
    );
  }
}

///has a state obj, and the class is a configuration, it holds the value
///the field needs to be defined as "final", eg final String title (as an attribute).
///the attribute is then used by the build method of the State
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
