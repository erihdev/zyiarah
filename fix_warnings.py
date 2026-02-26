import os
import sys

files_to_fixes = {
    'lib/main.dart': [("import 'package:zyiarah/view/home/home_screen.dart';", '')],
    'lib/services/order_service.dart': [("import '../data/models/product_model.dart';", '')],
    'lib/services/wallet_service.dart': [("import 'package:zyiarah/data/models/user_model.dart';", ''), ("print(", 'debugPrint(')],
    'lib/view/orders/orders_screen.dart': [("import 'package:zyiarah/data/models/booking_model.dart';", '')],
    'lib/view/profile/address_screen.dart': [("import 'package:zyiarah/data/models/address_model.dart';", '')],
    'lib/view/worker/worker_dashboard_screen.dart': [("import 'package:zyiarah/data/models/booking_model.dart';", '')],
    'lib/view_model/wallet_view_model.dart': [("print(", 'debugPrint('), ('+ amount!', '+ amount'), ('- amount!', '- amount')],
    'lib/view_model/auth_view_model.dart': [("'+' +", "'+'")], # We will fix string interpolation manually using another script or by hand.
}

for path, fixes in files_to_fixes.items():
    filepath = os.path.normpath(path)
    if os.path.exists(filepath):
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        orig_content = content
        for old, new in fixes:
            content = content.replace(old, new)
        
        # Clean up empty import lines left behind
        lines = content.split('\n')
        lines = [line for line in lines if not (line.strip() == '' and orig_content.count('\n\n') < content.count('\n\n'))]
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print('Fixed ' + filepath)
    else:
        print('Not found: ' + filepath)
