import 'package:flutter/material.dart';

/// Utilitário para exibir mensagens ao usuário
class MessageUtils {
  MessageUtils._(); // Construtor privado

  /// Exibe uma SnackBar de sucesso
  static void showSuccess(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      backgroundColor: const Color(0xFF6A994E),
      icon: Icons.check_circle,
    );
  }

  /// Exibe uma SnackBar de erro
  static void showError(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      backgroundColor: const Color(0xFFD32F2F),
      icon: Icons.error_outline,
    );
  }

  /// Exibe uma SnackBar de informação
  static void showInfo(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      backgroundColor: const Color(0xFF1976D2),
      icon: Icons.info_outline,
    );
  }

  /// Exibe uma SnackBar de aviso
  static void showWarning(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      backgroundColor: const Color(0xFFFB8C00),
      icon: Icons.warning_amber,
    );
  }

  /// Método interno para exibir a SnackBar
  static void _showSnackBar(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    required IconData icon,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
