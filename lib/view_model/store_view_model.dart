import 'package:flutter/foundation.dart';
import '../data/models/product_model.dart';
import '../data/models/store_cart_item_model.dart';
import '../services/store_service.dart';

class StoreViewModel extends ChangeNotifier {
  final _storeService = StoreService();

  List<ProductModel> _products = [];
  List<ProductModel> get products => _products;

  final List<StoreCartItemModel> _cart = [];
  List<StoreCartItemModel> get cart => _cart;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _storeService.fetchProducts();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addToCart(ProductModel product) {
    // Check if product already exists in cart
    final existingIndex = _cart.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      _cart[existingIndex].quantity += 1;
    } else {
      _cart.add(StoreCartItemModel(product: product, quantity: 1));
    }
    notifyListeners();
  }

  void removeFromCart(ProductModel product) {
    _cart.removeWhere((item) => item.product.id == product.id);
    notifyListeners();
  }

  void updateQuantity(ProductModel product, int quantity) {
    if (quantity <= 0) {
      removeFromCart(product);
      return;
    }
    
    final existingIndex = _cart.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      _cart[existingIndex].quantity = quantity;
      notifyListeners();
    }
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  double get cartTotal {
    return _cart.fold(0, (sum, item) => sum + item.totalPrice);
  }

  int get cartItemCount {
    return _cart.fold(0, (sum, item) => sum + item.quantity);
  }

  Future<bool> submitOrder({String? notes, String? promoCodeId, double discountAmount = 0}) async {
    if (_cart.isEmpty) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final finalTotal = (cartTotal - discountAmount).clamp(0.0, double.infinity);

    try {
      await _storeService.submitStoreOrder(
        _cart,
        finalTotal,
        notes: notes,
        promoCodeId: promoCodeId,
        discountAmount: discountAmount,
      );
      clearCart();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
