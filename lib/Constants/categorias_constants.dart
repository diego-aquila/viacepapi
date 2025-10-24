import 'package:flutter/material.dart';

/// Constantes relacionadas às categorias de produtos
class CategoriasConstants {
  CategoriasConstants._(); // Construtor privado para prevenir instanciação

  /// Lista de todas as categorias disponíveis
  static const List<String> categorias = [
    'Frutas & Verduras',
    'Carnes & Peixes',
    'Laticínios',
    'Mercearia',
    'Bebidas',
    'Limpeza',
    'Higiene',
    'Padaria',
    'Congelados',
    'Outros',
  ];

  /// Retorna o ícone correspondente à categoria
  static IconData getIcone(String? categoria) {
    switch (categoria) {
      case 'Frutas & Verduras':
        return Icons.eco_outlined;
      case 'Carnes & Peixes':
        return Icons.set_meal_outlined;
      case 'Laticínios':
        return Icons.local_drink_outlined;
      case 'Mercearia':
        return Icons.store_outlined;
      case 'Bebidas':
        return Icons.local_bar_outlined;
      case 'Limpeza':
        return Icons.cleaning_services_outlined;
      case 'Higiene':
        return Icons.bathtub_outlined;
      case 'Padaria':
        return Icons.bakery_dining_outlined;
      case 'Congelados':
        return Icons.ac_unit_outlined;
      default:
        return Icons.shopping_basket_outlined;
    }
  }

  /// Retorna a cor correspondente à categoria
  static Color getCor(String? categoria) {
    switch (categoria) {
      case 'Frutas & Verduras':
        return const Color(0xFF8BC34A); // Light Green
      case 'Carnes & Peixes':
        return const Color(0xFFEF5350); // Red
      case 'Laticínios':
        return const Color(0xFF42A5F5); // Blue
      case 'Mercearia':
        return const Color(0xFFFFA726); // Orange
      case 'Bebidas':
        return const Color(0xFFAB47BC); // Purple
      case 'Limpeza':
        return const Color(0xFF26C6DA); // Cyan
      case 'Higiene':
        return const Color(0xFF78909C); // Blue Grey
      case 'Padaria':
        return const Color(0xFF8D6E63); // Brown
      case 'Congelados':
        return const Color(0xFF64B5F6); // Light Blue
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }
}
