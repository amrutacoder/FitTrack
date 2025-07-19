import 'package:alera/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'diet_logging.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'water_intake.dart';
import 'BMIcalculator.dart';
import 'relaxcountdown.dart';
import 'MedicationProvider.dart';
import 'medicinereminder.dart';
import 'NotificationService.dart';
import 'profile.dart';
import 'edit_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  tz.initializeTimeZones();
  await NotificationService().init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => MedicationProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(), // Using the AuthWrapper instead of LoginPage
      routes: {
        "/signup": (context) => RegisterPage(),
        "/login": (context) => LoginPage(),
        "/home": (context) => HomeScreen(),
        "/water_intake": (context) => WaterIntakeScreen(),
        "/BMI": (context) => BMICalculatorScreen(),
        "/Diet": (context) => DietLoggingScreen(),
        "/relax": (context) => RelaxationCountdownScreen(),
        "/MRS": (context) => MedicationScreen(),
        "/profile": (context) => ProfilePage(),
        "/editprofile": (context) => EditProfilePage(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          return HomeScreen();
        }
        return LoginPage();
      },
    );
  }
}
