import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:signature/signature.dart';
import 'dart:ui';

class ContractScreen extends StatefulWidget {
  final String bookingId;
  final String serviceType;

  const ContractScreen({super.key, required this.bookingId, required this.serviceType});

  @override
  State<ContractScreen> createState() => _ContractScreenState();
}

class _ContractScreenState extends State<ContractScreen> {
  bool _agreedToTerms = false;
  bool _isSigning = false;
  bool _signed = false;

  late SignatureController _signatureController;

  @override
  void initState() {
    super.initState();
    _signatureController = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.white,
      exportBackgroundColor: const Color(0xFF1E3A8A),
    );
  }

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  Future<void> _submitSignedContract() async {
    if (!_agreedToTerms) {
      _showMsg('يجب الموافقة على بنود العقد أولاً');
      return;
    }

    if (_signatureController.isEmpty) {
      _showMsg('يرجى التوقيع في المربع المخصص');
      return;
    }

    setState(() => _isSigning = true);

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      final Uint8List? signatureImage = await _signatureController.toPngBytes();
      
      String? signatureUrl;
      if (signatureImage != null) {
        final path = 'signatures/${widget.bookingId}_${DateTime.now().millisecondsSinceEpoch}.png';
        try {
          await supabase.storage.from('signatures').uploadBinary(path, signatureImage);
          signatureUrl = supabase.storage.from('signatures').getPublicUrl(path);
        } catch (e) {
          debugPrint('Signature upload error: $e');
        }
      }

      await supabase.from('contracts').insert({
        'booking_id': widget.bookingId,
        'user_id': user?.id,
        'status': 'active',
        'created_at': DateTime.now().toIso8601String(),
        'signature_url': signatureUrl,
        'start_date': DateTime.now().toIso8601String().split('T')[0],
        'end_date': DateTime.now().add(const Duration(days: 365)).toIso8601String().split('T')[0],
      });

      setState(() {
        _signed = true;
        _isSigning = false;
      });

      if (mounted) {
        _showMsg('تم اعتماد العقد بنجاح', isError: false);
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) return;
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isSigning = false);
      if (mounted) _showMsg('خطأ في التسجيل: $e');
    }
  }

  void _showMsg(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'Tajawal')),
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF1E3A8A),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const royalBlue = Color(0xFF1E3A8A); // Deep Luxury Blue

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('العقد الرقمي الموحد (v1.0.7)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: royalBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [royalBlue.withValues(alpha: 0.05), Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Badge
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: royalBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.gavel, size: 16, color: royalBlue),
                      const SizedBox(width: 8),
                      Text('اتفاقية تقديم خدمة قانونية', 
                        style: TextStyle(color: royalBlue, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Glassmorphism Contract Info
              ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: royalBlue.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: royalBlue.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10)),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.description, color: Colors.white, size: 40),
                        const SizedBox(height: 12),
                        const Text('تفاصيل التعاقد', 
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(widget.serviceType, 
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70, fontSize: 14)),
                        const Divider(color: Colors.white24, height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('رقم المرجع:', style: TextStyle(color: Colors.white60, fontSize: 12)),
                            const SizedBox(width: 8),
                            Text(widget.bookingId.substring(0, 10), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
              const Text('بنود الاتفاقية:', 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: royalBlue)),
              const SizedBox(height: 16),

              _buildLuxuryClause('1', 'التزام الشركة:', 'يلتزم الطرف الأول (شركة زيارة) بتوفير الخدمة المختارة وفق أعلى معايير الجودة والسلامة.'),
              _buildLuxuryClause('2', 'مسؤولية العميل:', 'يلتزم الطرف الثاني بتوفير بيئة عمل مناسبة وسداد الرسوم المتفق عليها في وقتها.'),
              _buildLuxuryClause('3', 'الخصوصية:', 'تلتزم الشركة بالحفاظ على خصوصية بيانات العميل وسرية المعلومات داخل المنزل.'),
              _buildLuxuryClause('4', 'التوقيع:', 'يعد هذا التوقيع الإلكتروني ملزماً للطرفين وله الحجية القانونية الكاملة.'),

              const SizedBox(height: 32),
              const Text('منطقة التوقيع الإلكتروني:', 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: royalBlue)),
              const SizedBox(height: 12),

              // Signature Pad (Luxury Style)
              Container(
                decoration: BoxDecoration(
                  color: royalBlue,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: royalBlue.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 5)),
                  ],
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: Signature(
                        controller: _signatureController,
                        height: 200,
                        backgroundColor: royalBlue,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: const BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton.icon(
                            onPressed: () => _signatureController.clear(),
                            icon: const Icon(Icons.refresh, color: Colors.orangeAccent),
                            label: const Text('إعادة التوقيع', style: TextStyle(color: Colors.white)),
                          ),
                          const Text('وقع هنا باللمس', style: TextStyle(color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Agreement Checkbox
              Theme(
                data: ThemeData(unselectedWidgetColor: royalBlue),
                child: CheckboxListTile(
                  title: const Text('أقر وأوافق على كافة الشروط المذكورة أعلاه', 
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: royalBlue)),
                  value: _agreedToTerms,
                  onChanged: (val) => setState(() => _agreedToTerms = val ?? false),
                  activeColor: royalBlue,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
              ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: royalBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: _agreedToTerms ? 8 : 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: (_isSigning || _signed || !_agreedToTerms) ? null : _submitSignedContract,
                  child: _isSigning
                      ? const SizedBox(width: 24, height: 24, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_signed ? Icons.check_circle : Icons.draw, size: 24),
                            const SizedBox(width: 12),
                            Text(_signed ? 'تم الاعتماد' : 'اعتماد وتوقيع العقد', 
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLuxuryClause(String num, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Color(0xFF1E3A8A), shape: BoxShape.circle),
            child: Text(num, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                const SizedBox(height: 4),
                Text(content, style: TextStyle(color: Colors.grey.shade700, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
