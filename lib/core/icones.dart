import 'package:flutter/material.dart';

/// Ícones disponíveis para categorias (a chave é gravada no banco).
const Map<String, IconData> iconesCategoria = {
  'home': Icons.home_rounded,
  'restaurant': Icons.restaurant_rounded,
  'cart': Icons.shopping_cart_rounded,
  'delivery': Icons.delivery_dining_rounded,
  'car': Icons.directions_car_rounded,
  'fuel': Icons.local_gas_station_rounded,
  'wrench': Icons.build_rounded,
  'health': Icons.favorite_rounded,
  'leisure': Icons.sports_esports_rounded,
  'subscriptions': Icons.subscriptions_rounded,
  'school': Icons.school_rounded,
  'shopping': Icons.shopping_bag_rounded,
  'bills': Icons.receipt_long_rounded,
  'bolt': Icons.bolt_rounded,
  'water': Icons.water_drop_rounded,
  'wifi': Icons.wifi_rounded,
  'phone': Icons.smartphone_rounded,
  'salary': Icons.payments_rounded,
  'extra': Icons.add_card_rounded,
  'investments': Icons.trending_up_rounded,
  'pets': Icons.pets_rounded,
  'travel': Icons.flight_rounded,
  'gift': Icons.card_giftcard_rounded,
  'coffee': Icons.local_cafe_rounded,
  'fitness': Icons.fitness_center_rounded,
  'child': Icons.child_care_rounded,
  'tax': Icons.account_balance_rounded,
  'category': Icons.category_rounded,
};

IconData iconeDe(String? chave) =>
    iconesCategoria[chave] ?? Icons.category_rounded;

/// Cores oferecidas ao criar/editar categorias e cartões.
const List<int> coresDisponiveis = [
  0xFF0F766E, 0xFF14B8A6, 0xFF16A34A, 0xFF22C55E, 0xFF3B82F6, 0xFF6366F1,
  0xFF8B5CF6, 0xFFEC4899, 0xFFEF4444, 0xFFF59E0B, 0xFF64748B, 0xFF94A3B8,
];
