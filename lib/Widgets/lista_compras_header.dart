import 'package:flutter/material.dart';
import '../services/lista_compras_service.dart';
import '../models/item_compra.dart';

/// Header da lista de compras com estatísticas e ações
class ListaComprasHeader extends StatelessWidget {
  final List<ItemCompra> itens;
  final VoidCallback? onFinalizarFeira;
  final VoidCallback? onToggleTodosGrupos;
  final bool todosExpandidos;

  const ListaComprasHeader({
    Key? key,
    required this.itens,
    this.onFinalizarFeira,
    this.onToggleTodosGrupos,
    this.todosExpandidos = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stats = ListaComprasService.contarPorStatus(itens);
    final progresso = ListaComprasService.calcularProgresso(itens);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6A994E), Color(0xFF7BAB5E)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6A994E).withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            children: [
              _buildTitleRow(),
              if (itens.isNotEmpty) ...[
                const SizedBox(height: 14),
                _buildStatsAndProgress(stats, progresso),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleRow() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.shopping_cart, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Lista de Compras',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
        ),
        if (onToggleTodosGrupos != null)
          _buildIconButton(
            icon: todosExpandidos ? Icons.unfold_less : Icons.unfold_more,
            onPressed: onToggleTodosGrupos!,
            tooltip: todosExpandidos ? 'Colapsar' : 'Expandir',
          ),
        if (itens.isNotEmpty && onFinalizarFeira != null) ...[
          const SizedBox(width: 8),
          _buildIconButton(
            icon: Icons.delete_sweep_outlined,
            onPressed: onFinalizarFeira!,
            tooltip: 'Finalizar Feira',
          ),
        ],
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onPressed,
        tooltip: tooltip,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(),
      ),
    );
  }

  Widget _buildStatsAndProgress(Map<String, int> stats, double progresso) {
    final pendentes = stats['pendentes'] ?? 0;
    final comprados = stats['comprados'] ?? 0;
    final emFalta = stats['emFalta'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.25), width: 1.5),
      ),
      child: Column(
        children: [
          // Stats em linha
          Row(
            children: [
              _buildMiniStat(
                Icons.shopping_bag_outlined,
                pendentes.toString(),
                'Pendentes',
              ),
              const SizedBox(width: 16),
              _buildMiniStat(
                Icons.check_circle_outline,
                comprados.toString(),
                'Comprados',
              ),
              if (emFalta > 0) ...[
                const SizedBox(width: 16),
                _buildMiniStat(
                  Icons.warning_amber_outlined,
                  emFalta.toString(),
                  'Falta',
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          // Progresso com destaque
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progresso',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.9),
                                Colors.white,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Text(
                            '${(progresso * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6A994E),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Barra de progresso com destaque
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Stack(
                        children: [
                          FractionallySizedBox(
                            widthFactor: progresso,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Colors.white, Color(0xFFFFFDE7)],
                                ),
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.6),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(0.8),
                height: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
