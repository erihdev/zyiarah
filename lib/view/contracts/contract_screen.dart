import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:signature/signature.dart';

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
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
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

      // 1. Export signature to image
      final Uint8List? signatureImage = await _signatureController.toPngBytes();
      
      String? signatureUrl;
      if (signatureImage != null) {
        // 2. Upload to Supabase Storage (assuming 'signatures' bucket exists)
        final path = 'signatures/${widget.bookingId}_${DateTime.now().millisecondsSinceEpoch}.png';
        try {
          await supabase.storage.from('signatures').uploadBinary(path, signatureImage);
          signatureUrl = supabase.storage.from('signatures').getPublicUrl(path);
        } catch (e) {
          debugPrint('Signature upload failed (bucket might be missing): $e');
          // Proceed anyway as fallback for demo
        }
      }

      // 3. Record contract acceptance in contracts table
      await supabase.from('contracts').insert({
        'booking_id': widget.bookingId,
        'client_id': user?.id,
        'status': 'active',
        'signed_at': DateTime.now().toIso8601String(),
        'service_type': widget.serviceType,
        'signature_url': signatureUrl,
      });

      setState(() {
        _signed = true;
        _isSigning = false;
      });

      if (mounted) {
        _showMsg('تم قبول العقد وتوقيعه بنجاح', isError: false);
        await Future.delayed(const Duration(seconds: 1));
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isSigning = false);
      if (mounted) _showMsg('فشل تسجيل العقد: $e');
    }
  }

  void _showMsg(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('العقد والتوقيع الإلكتروني'),
        backgroundColor: Colors.teal.shade800,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contract Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal.shade200),
              ),
              child: Column(
                children: [
                  const Text('عقد تقديم خدمة منزليّة', 
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(widget.serviceType, 
                    style: TextStyle(fontSize: 16, color: Colors.teal.shade800)),
                  Text('رقم الطلب: ${widget.bookingId.substring(0, 8)}'),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text('بنود العقد الأساسية:', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            _buildClause('البند الأول:', 'يلتزم الطرف الأول بتوفير الكوادر المؤهلة والمدربة للخدمة.'),
            _buildClause('البند الثاني:', 'يلتزم الطرف الثاني بتسديد المبالغ في موعدها المحدد.'),
            _buildClause('البند الثالث:', 'يعد هذا التوقيع الإلكتروني إقراراً بصحة البيانات والموافقة على الشروط.'),

            const SizedBox(height: 24),
            const Text('التوقيع الإلكتروني:', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // Signature Pad
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Signature(
                    controller: _signatureController,
                    height: 180,
                    backgroundColor: Colors.grey.shade50,
                  ),
                  Container(
                    color: Colors.grey.shade200,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton.icon(
                          onPressed: () => _signatureController.clear(),
                          icon: const Icon(Icons.clear, color: Colors.red),
                          label: const Text('مسح التوقيع', 
                            style: TextStyle(color: Colors.red)),
                        ),
                        const VerticalDivider(),
                        const Text('وقع داخل المربع أعلاه', 
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Agreement Checkbox
            CheckboxListTile(
              title: const Text('أقر بأنني قرأت كافة الشروط وأوافق عليها'),
              value: _agreedToTerms,
              onChanged: (val) => setState(() => _agreedToTerms = val ?? false),
              activeColor: Colors.teal,
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _agreedToTerms ? Colors.teal.shade800 : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: (_isSigning || _signed || !_agreedToTerms) ? null : _submitSignedContract,
                icon: _isSigning
                    ? const SizedBox(width: 20, height: 20, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Icon(_signed ? Icons.verified : Icons.gesture),
                label: Text(_signed ? 'تم التوقيع' : 'اعتماد العقد والتوقيع'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildClause(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
          const SizedBox(width: 8),
          Expanded(child: Text(content)),
        ],
      ),
    );
  }
}
