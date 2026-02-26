import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zyiarah/view_model/auth_view_model.dart';
import 'package:zyiarah/view/auth/auth_gate_screen.dart';
import 'package:zyiarah/core/widgets/luxury_loading_overlay.dart';
import 'package:zyiarah/core/widgets/fade_page_route.dart';

import 'package:zyiarah/core/theme/app_colors.dart';

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
                        child: Image.asset(
                          'assets/images/logo.jpg', 
                          height: 120, 
                          fit: BoxFit.contain,
                          errorBuilder: (c, e, s) => const Icon(Icons.spa, size: 80, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'أهلاً بك في زيارة',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary),
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
                        Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(primary: AppColors.accent, onSurface: AppColors.primary),
                          ),
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            textAlign: TextAlign.left,
                            textDirection: TextDirection.ltr,
                            cursorColor: AppColors.accentDark,
                            decoration: InputDecoration(
                              hintText: 'مثال: +9665XXXXXXXX',
                              prefixIcon: const Icon(Icons.phone, color: AppColors.primary),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.accent, width: 2),
                              ),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onChanged: authViewModel.setPhoneNumber,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: authViewModel.isLoading ? null : () => authViewModel.sendOtp(),
                          child: const Text('إرسال رمز التحقق', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ] else ...[
                        Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(primary: AppColors.accent),
                          ),
                          child: TextField(
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: const TextStyle(letterSpacing: 8, fontSize: 22, color: AppColors.primary),
                            maxLength: 6,
                            cursorColor: AppColors.accentDark,
                            decoration: InputDecoration(
                              hintText: '------',
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.accent, width: 2),
                              ),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: authViewModel.isLoading
                              ? null
                              : () async {
                                  final success = await authViewModel.verifyOtp(_otpController.text);
                                  if (success && context.mounted) {
                                    Navigator.of(context).pushReplacement(
                                      FadePageRoute(page: const AuthGateScreen()),
                                    );
                                  }
                                },
                          child: const Text('تأكيد الدخول', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        TextButton(
                          onPressed: authViewModel.isLoading ? null : authViewModel.resetAuth,
                          child: const Text('تعديل رقم الجوال', style: TextStyle(color: AppColors.primary)),
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
