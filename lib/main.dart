import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/providers/user_data_provider.dart';
import '/providers/auth_provider.dart';
import '/providers/my_fridge_provider.dart';
import '/providers/search_provider.dart';
import '/screens/splash_screen.dart';
import '/screens/login_screen.dart';
import '/screens/home_screen.dart';

late final SupabaseClient supabase;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  supabase = Supabase.instance.client;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        ChangeNotifierProxyProvider<AuthProvider, UserDataProvider>(
          create: (_) => UserDataProvider(),
          update: (context, auth, previousUserData) {
            if (auth.user != null &&
                previousUserData?.userProfile?.id != auth.user!.id) {
              print("Auth user detected. Initializing UserDataProvider...");
              return UserDataProvider()..loadAllUserData();
            }
            if (auth.user == null) {
              return UserDataProvider();
            }
            return previousUserData ?? UserDataProvider();
          },
        ),

        ChangeNotifierProxyProvider<AuthProvider, MyFridgeProvider>(
          create: (_) => MyFridgeProvider(),
          update: (context, auth, previousFridgeData) {
            if (auth.user != null &&
                (previousFridgeData == null ||
                    previousFridgeData.myFridgeItems.isEmpty)) {
              print("Auth user detected. Initializing MyFridgeProvider...");
              return MyFridgeProvider()..initialize();
            }
            if (auth.user == null) {
              return MyFridgeProvider();
            }
            return previousFridgeData ?? MyFridgeProvider();
          },
        ),

        ChangeNotifierProvider(create: (_) => SearchProvider()),
      ],
      child: MaterialApp(
        title: 'Fridge Chef',
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          scaffoldBackgroundColor: Colors.grey[100],
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 1,
            iconTheme: IconThemeData(color: Colors.black87),
            titleTextStyle: TextStyle(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }
        if (snapshot.hasData && snapshot.data?.session != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.read<AuthProvider>().setUser(
                snapshot.data!.session!.user,
              );
            }
          });
          return const HomeScreen();
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            context.read<AuthProvider>().setUser(null);
          }
        });
        return const LoginScreen();
      },
    );
  }
}
