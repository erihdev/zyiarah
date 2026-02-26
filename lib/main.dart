import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zyiarah/core/config/supabase_config.dart';
import 'package:zyiarah/view/auth/auth_screen.dart';
import 'package:zyiarah/view/home/home_screen.dart';
import 'package:zyiarah/view_model/auth_view_model.dart';
import 'package:zyiarah/view_model/wallet_view_model.dart';
import 'package:zyiarah/view_model/store_view_model.dart';
import 'package:zyiarah/view_model/order_view_model.dart';
import 'package:zyiarah/view_model/profile_view_model.dart';
import 'package:zyiarah/view_model/worker_view_model.dart';
import 'package:zyiarah/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  
  // Initialize Firebase & Notifications (wrapped in try-catch in service)
  await Firebase.initializeApp();
  await NotificationService().initialize();
  
  runApp(const ZyiarahApp());
}

class ZyiarahApp extends StatelessWidget {
  const ZyiarahApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => WalletViewModel()),
        ChangeNotifierProvider(create: (_) => StoreViewModel()),
        ChangeNotifierProvider(create: (_) => OrderViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => WorkerViewModel()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Zyiarah',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
          fontFamily: 'Tajawal', // Suggested Arabic font
        ),
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          );
        },
        home: _getInitialScreen(),
      ),
    );
  }
  
  Widget _getInitialScreen() {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      return const HomeScreen();
    } else {
      return const AuthScreen();
    }
  }
}

