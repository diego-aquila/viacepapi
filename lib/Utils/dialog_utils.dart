import 'package:flutter/material.dart';

/// Utilitário para exibir diálogos de confirmação
class DialogUtils {
  DialogUtils._(); // Construtor privado

  /// Exibe um diálogo de confirmação genérico
  static Future<bool> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
    Color? confirmColor,
    IconData? icon,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: icon != null
            ? Row(
                children: [
                  Icon(
                    icon,
                    color: confirmColor ?? const Color(0xFF6A994E),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                ],
              )
            : Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              cancelText,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor ?? const Color(0xFF6A994E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              confirmText,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Exibe diálogo de confirmação de exclusão
  static Future<bool> showDeleteConfirmDialog({
    required BuildContext context,
    required String itemName,
  }) {
    return showConfirmDialog(
      context: context,
      title: 'Confirmar Exclusão',
      message: "Tem certeza que deseja excluir '$itemName' da lista?",
      confirmText: 'Excluir',
      cancelText: 'Cancelar',
      confirmColor: const Color(0xFFD32F2F),
      icon: Icons.delete_outline,
    );
  }

  /// Exibe diálogo de confirmação de limpeza da lista
  static Future<bool> showClearListConfirmDialog({
    required BuildContext context,
  }) {
    return showConfirmDialog(
      context: context,
      title: 'Finalizar Feira?',
      message: 'Isso irá limpar todos os itens da lista.\n\nDeseja continuar?',
      confirmText: 'Finalizar',
      cancelText: 'Cancelar',
      confirmColor: const Color(0xFF6A994E),
      icon: Icons.check_circle_outline,
    );
  }

  /// Exibe um diálogo de loading
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6A994E)),
              ),
              if (message != null) ...[
                const SizedBox(height: 20),
                Text(
                  message,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Fecha o diálogo de loading
  static void dismissLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}
