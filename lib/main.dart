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
import 'package:zyiarah/firebase_options.dart';

void main() {
  runApp(const BootStrapper());
}

class BootStrapper extends StatefulWidget {
  const BootStrapper({super.key});

  @override
  State<BootStrapper> createState() => _BootStrapperState();
}

class _BootStrapperState extends State<BootStrapper> {
  String _status = 'جاري التحقق من المحرك...';
  bool _initialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    try {
      setState(() => _status = 'جاري تهيئة الربط (Binding)...');
      WidgetsFlutterBinding.ensureInitialized();
      
      setState(() => _status = 'جاري الاتصال بقاعدة البيانات (Supabase)...');
      await SupabaseConfig.initialize();

      setState(() => _status = 'جاري تهيئة الخدمات السحابية (Firebase)...');
      try {
        await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
        await NotificationService().initialize();
      } catch (e) {
        debugPrint('Firebase non-critical fail: $e');
      }

      setState(() {
        _status = 'تم التحميل بنجاح! جاري تشغيل التطبيق...';
        _initialized = true;
      });

    } catch (e, stack) {
      setState(() {
        _error = 'خطأ في التشغيل: $e\n\n$stack';
        _status = 'فشل التحميل';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initialized) {
      return const ZyiarahApp();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF1E3A8A), // Royal Blue
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: Colors.white),
                const SizedBox(height: 24),
                Text(_status, 
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Tajawal')),
                if (_error != null) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.redAccent),
                    ),
                    child: SingleChildScrollView(
                      child: Text(_error!, 
                        style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontFamily: 'monospace')),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _initApp,
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
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

