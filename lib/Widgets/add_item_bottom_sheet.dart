import 'package:flutter/material.dart';
import '../models/item_compra.dart';
import '../constants/categorias_constants.dart';
import '../services/sugestoes_service.dart';
import '../widgets/suggestions_overlay.dart';

/// Bottom Sheet para adicionar um novo item à lista
class AddItemBottomSheet extends StatefulWidget {
  final Function(ItemCompra) onItemAdded;

  const AddItemBottomSheet({Key? key, required this.onItemAdded})
    : super(key: key);

  @override
  State<AddItemBottomSheet> createState() => _AddItemBottomSheetState();

  /// Método estático para facilitar a abertura do bottom sheet
  static Future<void> show(
    BuildContext context, {
    required Function(ItemCompra) onItemAdded,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddItemBottomSheet(onItemAdded: onItemAdded),
    );
  }
}

class _AddItemBottomSheetState extends State<AddItemBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _quantidadeController = TextEditingController();
  final _nomeFocusNode = FocusNode();
  final _textFieldKey = GlobalKey();
  final LayerLink _layerLink = LayerLink();

  OverlayEntry? _suggestionsOverlay;
  String? _categoriaSelecionada;
  List<String> _sugestoes = [];
  bool _mostrarSugestoes = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nomeController.addListener(_onNomeChanged);
    _nomeFocusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _removeSuggestionsOverlay();
    _nomeController.dispose();
    _quantidadeController.dispose();
    _nomeFocusNode.dispose();
    super.dispose();
  }

  void _onNomeChanged() {
    final texto = _nomeController.text;

    if (texto.isEmpty) {
      setState(() {
        _sugestoes = [];
        _mostrarSugestoes = false;
      });
      _removeSuggestionsOverlay();
      return;
    }

    // Obtém sugestões usando o service
    final sugestoes = SugestoesService.obterSugestoes(texto, maxSugestoes: 8);

    setState(() {
      _sugestoes = sugestoes;
      _mostrarSugestoes = sugestoes.isNotEmpty && _nomeFocusNode.hasFocus;
    });

    if (_mostrarSugestoes) {
      _showSuggestionsOverlay();
    } else {
      _removeSuggestionsOverlay();
    }
  }

  void _onFocusChanged() {
    if (!_nomeFocusNode.hasFocus) {
      _removeSuggestionsOverlay();
      setState(() => _mostrarSugestoes = false);
    }
  }

  void _showSuggestionsOverlay() {
    _removeSuggestionsOverlay();

    final RenderBox? renderBox =
        _textFieldKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null) return;

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _suggestionsOverlay = OverlayEntry(
      builder: (context) => SuggestionsOverlay(
        sugestoes: _sugestoes,
        position: Offset(offset.dx, offset.dy + size.height + 4),
        width: size.width,
        onSugestaoSelecionada: _onSugestaoSelecionada,
      ),
    );

    Overlay.of(context).insert(_suggestionsOverlay!);
  }

  void _removeSuggestionsOverlay() {
    _suggestionsOverlay?.remove();
    _suggestionsOverlay = null;
  }

  void _onSugestaoSelecionada(String sugestao) {
    _nomeController.text = sugestao;

    // Detecta categoria automaticamente
    final categoria = SugestoesService.detectarCategoriaProduto(sugestao);

    setState(() {
      _mostrarSugestoes = false;
      if (categoria != null) {
        _categoriaSelecionada = categoria;
      }
    });

    _removeSuggestionsOverlay();
    FocusScope.of(context).unfocus();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Cria o item
    final novoItem = ItemCompra(
      id: '', // Firebase gerará o ID
      nome: _nomeController.text.trim(),
      quantidade: _quantidadeController.text.trim(),
      categoria: _categoriaSelecionada,
    );

    // Chama callback
    widget.onItemAdded(novoItem);

    // Limpa os campos para adicionar mais itens
    _limparCampos();

    setState(() => _isLoading = false);

    // Foca no campo nome para facilitar próxima adição
    _nomeFocusNode.requestFocus();
  }

  /// Limpa os campos do formulário
  void _limparCampos() {
    _nomeController.clear();
    _quantidadeController.clear();
    // Mantém a categoria selecionada para facilitar
    // Se quiser limpar também, descomente a linha abaixo:
    // _categoriaSelecionada = null;
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
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildNomeField(),
              const SizedBox(height: 16),
              _buildQuantidadeField(),
              const SizedBox(height: 16),
              _buildCategoriaDropdown(),
              const SizedBox(height: 24),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Expanded(
          child: Text(
            'Adicionar Novo Item',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF666666)),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Fechar',
        ),
      ],
    );
  }

  Widget _buildNomeField() {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        key: _textFieldKey,
        controller: _nomeController,
        focusNode: _nomeFocusNode,
        decoration: InputDecoration(
          labelText: 'Item',
          hintText: 'Ex: Arroz',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _nomeController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _nomeController.clear();
                    _removeSuggestionsOverlay();
                    setState(() => _mostrarSugestoes = false);
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        textCapitalization: TextCapitalization.sentences,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Informe o item';
          }
          return null;
        },
        onFieldSubmitted: (_) => _onSubmit(),
      ),
    );
  }

  Widget _buildQuantidadeField() {
    return TextFormField(
      controller: _quantidadeController,
      decoration: InputDecoration(
        labelText: 'Quantidade',
        hintText: 'Ex: 1kg',
        prefixIcon: const Icon(Icons.format_list_numbered),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Informe a quantidade';
        }
        return null;
      },
      onFieldSubmitted: (_) => _onSubmit(),
    );
  }

  Widget _buildCategoriaDropdown() {
    return DropdownButtonFormField<String>(
      value: _categoriaSelecionada,
      decoration: InputDecoration(
        labelText: 'Categoria',
        prefixIcon: const Icon(Icons.category_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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

  Widget _buildSubmitButton() {
    return Row(
      children: [
        // Botão secundário para adicionar e fechar
        // Expanded(
        //   child: OutlinedButton.icon(
        //     onPressed: _isLoading ? null : _onSubmitAndClose,
        //     icon: const Icon(Icons.check),
        //     label: const Text(
        //       'Adicionar e Fechar',
        //       style: TextStyle(fontSize: 14),
        //     ),
        //     style: OutlinedButton.styleFrom(
        //       foregroundColor: const Color(0xFF6A994E),
        //       side: const BorderSide(color: Color(0xFF6A994E), width: 2),
        //       padding: const EdgeInsets.symmetric(vertical: 16),
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(15),
        //       ),
        //     ),
        //   ),
        // ),
        const SizedBox(width: 12),
        // Botão principal para adicionar e continuar
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _onSubmit,
            icon: const Icon(Icons.add),
            label: const Text(
              'Adicionar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A994E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
            ),
          ),
        ),
      ],
    );
  }

  /// Adiciona o item e fecha o bottom sheet
  void _onSubmitAndClose() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Cria o item
    final novoItem = ItemCompra(
      id: '',
      nome: _nomeController.text.trim(),
      quantidade: _quantidadeController.text.trim(),
      categoria: _categoriaSelecionada,
    );

    // Chama callback
    widget.onItemAdded(novoItem);

    // Fecha o bottom sheet
    Navigator.of(context).pop();
  }
}
