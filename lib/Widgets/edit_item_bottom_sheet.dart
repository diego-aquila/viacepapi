import 'package:flutter/material.dart';
import '../models/item_compra.dart';
import '../constants/categorias_constants.dart';

/// Bottom Sheet para editar um item existente
class EditItemBottomSheet extends StatefulWidget {
  final ItemCompra item;
  final Function(ItemCompra) onItemUpdated;

  const EditItemBottomSheet({
    Key? key,
    required this.item,
    required this.onItemUpdated,
  }) : super(key: key);

  @override
  State<EditItemBottomSheet> createState() => _EditItemBottomSheetState();

  /// Método estático para facilitar a abertura do bottom sheet
  static Future<bool?> show(
    BuildContext context, {
    required ItemCompra item,
    required Function(ItemCompra) onItemUpdated,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditItemBottomSheet(
        item: item,
        onItemUpdated: onItemUpdated,
      ),
    );
  }
}

class _EditItemBottomSheetState extends State<EditItemBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _quantidadeController;
  String? _categoriaSelecionada;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.item.nome);
    _quantidadeController = TextEditingController(text: widget.item.quantidade);
    _categoriaSelecionada = widget.item.categoria;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _quantidadeController.dispose();
    super.dispose();
  }

  void _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Cria o item atualizado
    final itemAtualizado = widget.item.copyWith(
      nome: _nomeController.text.trim(),
      quantidade: _quantidadeController.text.trim(),
      categoria: _categoriaSelecionada,
    );

    // Chama callback
    widget.onItemUpdated(itemAtualizado);

    // Fecha o bottom sheet
    Navigator.of(context).pop(true);
  }

  void _onCancel() {
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildNomeField(),
              const SizedBox(height: 16),
              _buildQuantidadeField(),
              const SizedBox(height: 16),
              _buildCategoriaDropdown(),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Text(
      'Editar Item',
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Color(0xFF333333),
      ),
    );
  }

  Widget _buildNomeField() {
    return TextFormField(
      controller: _nomeController,
      decoration: InputDecoration(
        labelText: 'Nome do Item',
        hintText: 'Ex: Arroz',
        prefixIcon: const Icon(Icons.shopping_bag_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      textCapitalization: TextCapitalization.sentences,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Informe o nome do item';
        }
        return null;
      },
    );
  }

  Widget _buildQuantidadeField() {
    return TextFormField(
      controller: _quantidadeController,
      decoration: InputDecoration(
        labelText: 'Quantidade',
        hintText: 'Ex: 2kg',
        prefixIcon: const Icon(Icons.menu_book),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Informe a quantidade';
        }
        return null;
      },
    );
  }

  Widget _buildCategoriaDropdown() {
    return DropdownButtonFormField<String>(
      value: _categoriaSelecionada,
      decoration: InputDecoration(
        labelText: 'Categoria',
        prefixIcon: const Icon(Icons.category_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      items: CategoriasConstants.categorias.map((cat) {
        return DropdownMenuItem(
          value: cat,
          child: Row(
            children: [
              Icon(
                CategoriasConstants.getIcone(cat),
                size: 18,
                color: CategoriasConstants.getCor(cat),
              ),
              const SizedBox(width: 8),
              Text(cat),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => _categoriaSelecionada = value);
      },
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: _isLoading ? null : _onCancel,
          child: Text(
            'Cancelar',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: _isLoading ? null : _onSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6A994E),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Salvar',
                  style: TextStyle(fontSize: 16),
                ),
        ),
      ],
    );
  }
}
