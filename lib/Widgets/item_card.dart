import 'package:flutter/material.dart';
import '../models/item_compra.dart';

/// Widget que representa um card de item da lista de compras
class ItemCard extends StatelessWidget {
  final ItemCompra item;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onToggleEmFalta;
  final VoidCallback onDelete;

  const ItemCard({
    Key? key,
    required this.item,
    required this.onTap,
    required this.onEdit,
    required this.onToggleEmFalta,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color itemColor;
    if (item.comprado) {
      itemColor = Colors.grey.shade400;
    } else if (item.emFalta) {
      itemColor = const Color(0xFFFB8C00);
    } else {
      itemColor = const Color(0xFF333333);
    }

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red.shade400,
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 30),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return await _confirmarExclusao(context);
        }
        return false;
      },
      onDismissed: (direction) => onDelete(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: item.comprado
                ? const Color(0xFFE8F5E9)
                : item.emFalta
                ? const Color(0xFFFFECB3)
                : Colors.grey.shade100,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              _buildCheckbox(),
              const SizedBox(width: 16),
              Expanded(child: _buildItemInfo(itemColor)),
              if (!item.comprado) _buildEmFaltaButton(),
              _buildEditButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox() {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: item.comprado ? const Color(0xFF6A994E) : Colors.transparent,
          border: Border.all(
            color: item.comprado
                ? const Color(0xFF6A994E)
                : Colors.grey.shade400,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: item.comprado
            ? const Icon(Icons.check, color: Colors.white, size: 16)
            : null,
      ),
    );
  }

  Widget _buildItemInfo(Color itemColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.nome,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: itemColor,
            decoration: item.comprado ? TextDecoration.lineThrough : null,
            decorationColor: Colors.grey.shade500,
            decorationThickness: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          item.quantidade,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildEmFaltaButton() {
    return IconButton(
      icon: Icon(
        item.emFalta ? Icons.warning_amber : Icons.warning_amber_outlined,
        color: item.emFalta ? const Color(0xFFFB8C00) : Colors.grey.shade400,
        size: 22,
      ),
      onPressed: onToggleEmFalta,
      tooltip: item.emFalta ? 'Remover de falta' : 'Marcar em falta',
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(),
    );
  }

  Widget _buildEditButton() {
    return IconButton(
      icon: Icon(Icons.edit_outlined, color: Colors.blue.shade400, size: 22),
      onPressed: onEdit,
      tooltip: 'Editar item',
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(),
    );
  }

  Future<bool?> _confirmarExclusao(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Confirmar Exclusão",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Tem certeza que deseja excluir '${item.nome}' da lista?",
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                "Cancelar",
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
              ),
              child: const Text("Excluir"),
            ),
          ],
        );
      },
    );
  }
}
