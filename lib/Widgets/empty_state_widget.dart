import 'package:flutter/material.dart';

/// Widget exibido quando a lista está vazia
class EmptyStateWidget extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final IconData icone;

  const EmptyStateWidget({
    Key? key,
    this.titulo = 'Sua lista está vazia!',
    this.subtitulo = 'Adicione seu primeiro item para começar.',
    this.icone = Icons.shopping_cart_outlined,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icone,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 20),
          Text(
            titulo,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              subtitulo,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
