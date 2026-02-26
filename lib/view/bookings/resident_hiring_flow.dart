import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:zyiarah/core/widgets/fade_page_route.dart';
import 'package:zyiarah/view/contracts/contract_screen.dart';

class ResidentHiringFlow extends StatefulWidget {
  const ResidentHiringFlow({super.key});

  @override
  State<ResidentHiringFlow> createState() => _ResidentHiringFlowState();
}

class _ResidentHiringFlowState extends State<ResidentHiringFlow> {
  int _currentStep = 0;
  String? _selectedNationality;
  String? _selectedDuration;
  String? _selectedPackage;

  final List<Map<String, dynamic>> _nationalities = [
    {'name': 'الفلبين', 'price': 3500, 'icon': '🇵🇭'},
    {'name': 'إندونيسيا', 'price': 3300, 'icon': '🇮🇩'},
    {'name': 'أوغندا', 'price': 2200, 'icon': '🇺🇬'},
    {'name': 'كينيا', 'price': 2000, 'icon': '🇰🇪'},
  ];

  final List<Map<String, dynamic>> _durations = [
    {'label': '3 أشهر', 'value': '3', 'discount': '0%'},
    {'label': '6 أشهر', 'value': '6', 'discount': '5%'},
    {'label': '12 شهر', 'value': '12', 'discount': '10%'},
    {'label': '24 شهر', 'value': '24', 'discount': '20%'},
  ];

  final List<Map<String, dynamic>> _packages = [
    {'name': 'أساسية (Standard)', 'desc': 'تأمين طبي + سكن مؤمن', 'extra': 0},
    {'name': 'متميزة (Plus)', 'desc': 'تأمين طبي + استبدال فوري + خبرة', 'extra': 300},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حجز عاملة مقيمة'),
        backgroundColor: Colors.teal.shade800,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildStepProgress(),
          Expanded(
            child: _buildCurrentStep(),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildStepProgress() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      color: Colors.teal.shade50.withValues(alpha: 0.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          bool isCompleted = index < _currentStep;
          bool isCurrent = index == _currentStep;
          return Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: isCompleted || isCurrent ? Colors.teal : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isCompleted 
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : Text('${index + 1}', style: TextStyle(color: isCompleted || isCurrent ? Colors.white : Colors.black54)),
                ),
              ),
              if (index < 2) 
                Container(
                  width: 50,
                  height: 2,
                  color: isCompleted ? Colors.teal : Colors.grey.shade300,
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0: return _buildNationalityStep();
      case 1: return _buildDurationStep();
      case 2: return _buildPackageStep();
      default: return const SizedBox();
    }
  }

  Widget _buildNationalityStep() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _nationalities.length,
      itemBuilder: (context, index) {
        final item = _nationalities[index];
        bool isSelected = _selectedNationality == item['name'];
        return Card(
          elevation: isSelected ? 4 : 1,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: isSelected ? Colors.teal : Colors.transparent, width: 2),
          ),
          child: ListTile(
            leading: Text(item['icon'], style: const TextStyle(fontSize: 30)),
            title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('يبدأ من ${item['price']} ريال / شهر'),
            trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.teal) : null,
            onTap: () => setState(() => _selectedNationality = item['name']),
          ),
        );
      },
    );
  }

  Widget _buildDurationStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('اختر مدة التعاقد:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: _durations.length,
            itemBuilder: (context, index) {
              final dur = _durations[index];
              bool isSelected = _selectedDuration == dur['value'];
              return InkWell(
                onTap: () => setState(() => _selectedDuration = dur['value']),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.teal : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.teal),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(dur['label'], style: TextStyle(color: isSelected ? Colors.white : Colors.teal, fontWeight: FontWeight.bold)),
                        if (dur['discount'] != '0%')
                          Text('خصم ${dur['discount']}', style: TextStyle(color: isSelected ? Colors.white70 : Colors.red, fontSize: 10)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPackageStep() {
     return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _packages.length,
      itemBuilder: (context, index) {
        final pkg = _packages[index];
        bool isSelected = _selectedPackage == pkg['name'];
        return Card(
          margin: const EdgeInsets.only(bottom: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: isSelected ? Colors.teal : Colors.transparent, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(pkg['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    if (isSelected) const Icon(Icons.check_circle, color: Colors.teal),
                  ],
                ),
                const SizedBox(height: 8),
                Text(pkg['desc'], style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(height: 12),
                Text('+ ${pkg['extra']} ريال إضافي', style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => setState(() => _selectedPackage = pkg['name']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected ? Colors.teal : Colors.grey.shade200,
                      foregroundColor: isSelected ? Colors.white : Colors.black,
                    ),
                    child: Text(isSelected ? 'تم الاختيار' : 'اختيار الباقة'),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep--),
                child: const Text('السابق'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 15),
          Expanded(
            child: ElevatedButton(
              onPressed: _canContinue() ? _handleNext : null,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade800, foregroundColor: Colors.white),
              child: Text(_currentStep == 2 ? 'المراجعة والتوقيع' : 'التالي'),
            ),
          ),
        ],
      ),
    );
  }

  bool _canContinue() {
    if (_currentStep == 0) return _selectedNationality != null;
    if (_currentStep == 1) return _selectedDuration != null;
    if (_currentStep == 2) return _selectedPackage != null;
    return false;
  }

  void _handleNext() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      // Go to contract screen
      Navigator.push(context, FadePageRoute(
        page: ContractScreen(
          bookingId: const Uuid().v4(), 
          serviceType: 'عاملة مقيمة ($_selectedNationality) - $_selectedDuration شهر - $_selectedPackage',
        )
      ));
    }
  }
}
