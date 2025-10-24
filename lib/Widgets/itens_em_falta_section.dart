import 'package:flutter/material.dart';
import 'package:via_cep_api/Widgets/item_card.dart';
import '../models/item_compra.dart';

/// Seção agrupada para itens marcados como "em falta"
class ItensEmFaltaSection extends StatelessWidget {
  final Map<String, List<ItemCompra>> gruposEmFalta;
  final bool expandido;
  final VoidCallback onToggleExpanded;
  final Function(ItemCompra) onItemTap;
  final Function(ItemCompra) onItemEdit;
  final Function(ItemCompra) onItemToggleEmFalta;
  final Function(ItemCompra) onItemDelete;

  const ItensEmFaltaSection({
    Key? key,
    required this.gruposEmFalta,
    required this.expandido,
    required this.onToggleExpanded,
    required this.onItemTap,
    required this.onItemEdit,
    required this.onItemToggleEmFalta,
    required this.onItemDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (gruposEmFalta.isEmpty) return const SizedBox.shrink();

    final totalEmFalta = gruposEmFalta.values.fold<int>(
      0,
      (sum, lista) => sum + lista.length,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [_buildHeader(totalEmFalta), if (expandido) _buildItens()],
      ),
    );
  }

  Widget _buildHeader(int total) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onToggleExpanded,
        borderRadius: BorderRadius.vertical(
          top: const Radius.circular(20),
          bottom: expandido ? Radius.zero : const Radius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFB8C00),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Itens em Falta',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFB8C00),
                      ),
                    ),
                    Text(
                      '$total ${total == 1 ? "item" : "itens"}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                expandido ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: const Color(0xFFFB8C00),
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItens() {
    return Column(
      children: [
        Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
        ...gruposEmFalta.entries.expand((entry) {
          return entry.value.map((item) {
            return ItemCard(
              item: item,
              onTap: () => onItemTap(item),
              onEdit: () => onItemEdit(item),
              onToggleEmFalta: () => onItemToggleEmFalta(item),
              onDelete: () => onItemDelete(item),
            );
          });
        }),
      ],
    );
  }
}
