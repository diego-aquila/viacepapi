import 'package:flutter/material.dart';

/// Overlay que mostra sugestões de produtos durante a digitação
class SuggestionsOverlay extends StatelessWidget {
  final List<String> sugestoes;
  final Function(String) onSugestaoSelecionada;
  final Offset position;
  final double width;

  const SuggestionsOverlay({
    Key? key,
    required this.sugestoes,
    required this.onSugestaoSelecionada,
    required this.position,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (sugestoes.isEmpty) return const SizedBox.shrink();

    return Positioned(
      left: position.dx,
      top: position.dy,
      width: width,
      child: Material(
        elevation: 8.0,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: sugestoes.length,
            itemBuilder: (context, index) {
              final sugestao = sugestoes[index];
              return InkWell(
                onTap: () => onSugestaoSelecionada(sugestao),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: index < sugestoes.length - 1
                        ? Border(
                            bottom: BorderSide(color: Colors.grey.shade100),
                          )
                        : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        size: 18,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          sugestao,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.north_west,
                        size: 16,
                        color: Colors.grey.shade300,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
