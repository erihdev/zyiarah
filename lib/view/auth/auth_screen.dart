import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zyiarah/view_model/auth_view_model.dart';
import 'package:zyiarah/view/home/home_screen.dart';
import 'package:zyiarah/core/widgets/luxury_loading_overlay.dart';
import 'package:zyiarah/core/widgets/fade_page_route.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (authViewModel.errorMessage != null) {
              _showError(context, authViewModel.errorMessage!);
              authViewModel.resetAuth();
            }
          });

          return LuxuryLoadingOverlay(
            isLoading: authViewModel.isLoading,
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo Area
                      Center(
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Colors.teal.shade400, Colors.teal.shade800],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(color: Colors.teal.withOpacity(0.3), blurRadius: 20, spreadRadius: 3),
                            ],
                          ),
                          child: const Icon(Icons.spa_outlined, size: 50, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'أهلاً بك في زيارة',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        authViewModel.isOtpSent
                            ? 'أدخل رمز التحقق المرسل إلى جوالك'
                            : 'الرجاء إدخال رقم الجوال للمتابعة',
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),

                      if (!authViewModel.isOtpSent) ...[
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          textAlign: TextAlign.left,
                          textDirection: TextDirection.ltr,
                          decoration: InputDecoration(
                            hintText: 'مثال: +9665XXXXXXXX',
                            prefixIcon: const Icon(Icons.phone),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onChanged: authViewModel.setPhoneNumber,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: authViewModel.isLoading ? null : () => authViewModel.sendOtp(),
                          child: const Text('إرسال رمز التحقق', style: TextStyle(fontSize: 18)),
                        ),
                      ] else ...[
                        TextField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(letterSpacing: 8, fontSize: 22),
                          maxLength: 6,
                          decoration: InputDecoration(
                            hintText: '------',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: authViewModel.isLoading
                              ? null
                              : () async {
                                  final success = await authViewModel.verifyOtp(_otpController.text);
                                  if (success && context.mounted) {
                                    Navigator.of(context).pushReplacement(
                                      FadePageRoute(page: const HomeScreen()),
                                    );
                                  }
                                },
                          child: const Text('تأكيد الدخول', style: TextStyle(fontSize: 18)),
                        ),
                        TextButton(
                          onPressed: authViewModel.isLoading ? null : authViewModel.resetAuth,
                          child: const Text('تعديل رقم الجوال', style: TextStyle(color: Colors.teal)),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
