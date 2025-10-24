import 'package:flutter/material.dart';
import '../models/item_compra.dart';
import '../constants/categorias_constants.dart';
import 'item_card.dart';

/// Widget que representa uma seção de categoria com seus itens
class CategoriaSection extends StatelessWidget {
  final String categoria;
  final List<ItemCompra> itens;
  final bool expandido;
  final VoidCallback onToggleExpanded;
  final Function(ItemCompra) onItemTap;
  final Function(ItemCompra) onItemEdit;
  final Function(ItemCompra) onItemToggleEmFalta;
  final Function(ItemCompra) onItemDelete;
  final Color? customColor;
  final bool showDragHandle;
  final int? index;

  const CategoriaSection({
    Key? key,
    required this.categoria,
    required this.itens,
    required this.expandido,
    required this.onToggleExpanded,
    required this.onItemTap,
    required this.onItemEdit,
    required this.onItemToggleEmFalta,
    required this.onItemDelete,
    this.customColor,
    this.showDragHandle = false,
    this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (itens.isEmpty) return const SizedBox.shrink();

    final cor = customColor ?? CategoriasConstants.getCor(categoria);
    final icone = CategoriasConstants.getIcone(categoria);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [_buildHeader(cor, icone), if (expandido) _buildItens()],
      ),
    );
  }

  Widget _buildHeader(Color cor, IconData icone) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onToggleExpanded,
        borderRadius: BorderRadius.vertical(
          top: const Radius.circular(15),
          bottom: expandido ? Radius.zero : const Radius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              if (showDragHandle && index != null)
                Container(
                  padding: const EdgeInsets.all(4),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: ReorderableDragStartListener(
                    index: index!,
                    child: Icon(
                      Icons.drag_handle,
                      color: Colors.grey.shade600,
                      size: 20,
                    ),
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icone, color: cor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  categoria,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              _buildCountBadge(cor),
              const SizedBox(width: 8),
              Icon(
                expandido ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: Colors.grey.shade600,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountBadge(Color cor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        '${itens.length}',
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: cor),
      ),
    );
  }

  Widget _buildItens() {
    return Column(
      children: [
        Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
        ...itens.map(
          (item) => ItemCard(
            item: item,
            onTap: () => onItemTap(item),
            onEdit: () => onItemEdit(item),
            onToggleEmFalta: () => onItemToggleEmFalta(item),
            onDelete: () => onItemDelete(item),
          ),
        ),
      ],
    );
  }
}
