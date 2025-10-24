import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:via_cep_api/Services/firebase_service.dart';

// Imports dos componentes refatorados
import '../models/item_compra.dart';
import '../constants/categorias_constants.dart';
import '../services/lista_compras_service.dart';
import '../widgets/lista_compras_header.dart';
import '../widgets/categoria_section.dart';
import '../widgets/itens_em_falta_section.dart';
import '../widgets/itens_comprados_section.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/add_item_bottom_sheet.dart';
import '../widgets/edit_item_bottom_sheet.dart';
import '../utils/message_utils.dart';
import '../utils/dialog_utils.dart';

/// Página principal da lista de compras - REFATORADA
///
/// Esta versão usa todos os componentes modulares criados
/// e segue os princípios de Clean Architecture
class ListaComprasPage extends StatefulWidget {
  const ListaComprasPage({Key? key}) : super(key: key);

  @override
  State<ListaComprasPage> createState() => _ListaComprasPageState();
}

class _ListaComprasPageState extends State<ListaComprasPage> {
  // Firebase Service
  final FirebaseService _firebaseService = FirebaseService(
    collectionName: 'mercado',
  );

  // Estado da UI
  Map<String, bool> _categoriasExpandidas = {};
  List<String> _ordemCategorias = List.from(CategoriasConstants.categorias);

  bool _compradosExpandido = false;
  bool _emFaltaExpandido = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _inicializarEstado();
  }

  /// Inicializa o estado das categorias
  void _inicializarEstado() {
    for (var cat in CategoriasConstants.categorias) {
      _categoriasExpandidas[cat] = true;
    }
    _ordemCategorias = List.from(CategoriasConstants.categorias);
  }

  /// Stream de itens do Firebase
  Stream<List<ItemCompra>> _streamItens() {
    return FirebaseFirestore.instance.collection('mercado').snapshots().map((
      snapshot,
    ) {
      final itens = snapshot.docs.map((doc) {
        return ItemCompra.fromMap(doc.data(), doc.id);
      }).toList();

      // Usa o service para ordenar
      return ListaComprasService.ordenarItens(itens);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: StreamBuilder<List<ItemCompra>>(
          stream: _streamItens(),
          builder: (context, snapshot) {
            return Column(
              children: [
                _buildHeader(snapshot.data ?? []),
                Expanded(child: _buildBody(snapshot)),
              ],
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildFAB(),
    );
  }

  /// Constrói o header
  Widget _buildHeader(List<ItemCompra> itens) {
    return ListaComprasHeader(
      itens: itens,
      onFinalizarFeira: itens.isNotEmpty ? _finalizarFeira : null,
      onToggleTodosGrupos: itens.isNotEmpty
          ? () => _toggleTodosGrupos(itens)
          : null,
      todosExpandidos: _todosExpandidos(itens),
    );
  }

  /// Constrói o corpo da página
  Widget _buildBody(AsyncSnapshot<List<ItemCompra>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return _buildLoading();
    }

    if (snapshot.hasError) {
      return _buildError();
    }

    final itens = snapshot.data ?? [];
    if (itens.isEmpty) {
      return const EmptyStateWidget();
    }

    return _buildListaAgrupada(itens);
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6A994E)),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 60,
            color: const Color(0xFFD32F2F).withOpacity(0.7),
          ),
          const SizedBox(height: 12),
          const Text(
            'Erro ao carregar itens',
            style: TextStyle(fontSize: 16, color: Color(0xFFD32F2F)),
          ),
        ],
      ),
    );
  }

  /// Constrói a lista agrupada de itens
  Widget _buildListaAgrupada(List<ItemCompra> itens) {
    // Usa o service para separar por status
    final gruposPorStatus = ListaComprasService.separarPorStatus(itens);
    final gruposPendentes = gruposPorStatus['pendentes']!;
    final gruposEmFalta = gruposPorStatus['emFalta']!;
    final gruposComprados = gruposPorStatus['comprados']!;

    // Ordena categorias pendentes
    final categoriasPendentesOrdenadas = _ordemCategorias
        .where((cat) => gruposPendentes.containsKey(cat))
        .toList();

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Seção de itens pendentes
              if (categoriasPendentesOrdenadas.isNotEmpty) ...[
                const Text(
                  'Itens Pendentes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 16),
                _buildItensPendentes(
                  categoriasPendentesOrdenadas,
                  gruposPendentes,
                ),
              ],

              // Seção de itens em falta
              if (gruposEmFalta.isNotEmpty) ...[
                const SizedBox(height: 24),
                ItensEmFaltaSection(
                  gruposEmFalta: gruposEmFalta,
                  expandido: _emFaltaExpandido,
                  onToggleExpanded: () {
                    setState(() => _emFaltaExpandido = !_emFaltaExpandido);
                  },
                  onItemTap: _marcarComprado,
                  onItemEdit: _editarItem,
                  onItemToggleEmFalta: _marcarEmFalta,
                  onItemDelete: _deletarItem,
                ),
              ],

              // Seção de itens comprados
              if (gruposComprados.isNotEmpty) ...[
                const SizedBox(height: 24),
                ItensCompradosSection(
                  gruposComprados: gruposComprados,
                  expandido: _compradosExpandido,
                  onToggleExpanded: () {
                    setState(() => _compradosExpandido = !_compradosExpandido);
                  },
                  onItemTap: _marcarComprado,
                  onItemEdit: _editarItem,
                  onItemToggleEmFalta: _marcarEmFalta,
                  onItemDelete: _deletarItem,
                ),
              ],
            ]),
          ),
        ),
      ],
    );
  }

  /// Constrói a lista de itens pendentes com reordenação
  Widget _buildItensPendentes(
    List<String> categorias,
    Map<String, List<ItemCompra>> grupos,
  ) {
    return ReorderableListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      // =====================================================================
      // <-- ALTERAÇÃO 1 AQUI: Passa a lista filtrada ('categorias')
      //     para o callback de reordenação.
      // =====================================================================
      onReorder: (oldIndex, newIndex) =>
          _onReorderCategorias(oldIndex, newIndex, categorias),
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(15),
              child: child,
            );
          },
          child: child,
        );
      },
      children: categorias.map((categoria) {
        final index = categorias.indexOf(categoria);
        final itensCategoria = grupos[categoria]!;

        return CategoriaSection(
          key: ValueKey(categoria),
          categoria: categoria,
          itens: itensCategoria,
          expandido: _categoriasExpandidas[categoria] ?? true,
          onToggleExpanded: () => _toggleCategoria(categoria),
          onItemTap: _marcarComprado,
          onItemEdit: _editarItem,
          onItemToggleEmFalta: _marcarEmFalta,
          onItemDelete: _deletarItem,
          showDragHandle: true,
          index: index,
        );
      }).toList(),
    );
  }

  /// Constrói o FAB
  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: _mostrarAdicionarItem,
      label: const Text('Adicionar Item', style: TextStyle(fontSize: 16)),
      icon: const Icon(Icons.add),
      backgroundColor: const Color(0xFF6A994E),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      elevation: 8,
    );
  }

  // ==================== AÇÕES ====================

  /// Mostra bottom sheet para adicionar item
  void _mostrarAdicionarItem() {
    AddItemBottomSheet.show(context, onItemAdded: _adicionarItem);
  }

  /// Adiciona um novo item
  Future<void> _adicionarItem(ItemCompra item) async {
    setState(() => _isLoading = true);

    try {
      await _firebaseService.create(item.toMap());
      MessageUtils.showSuccess(context, 'Item adicionado!');
    } catch (e) {
      MessageUtils.showError(context, 'Erro ao adicionar item: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Edita um item existente
  Future<void> _editarItem(ItemCompra item) async {
    final resultado = await EditItemBottomSheet.show(
      context,
      item: item,
      onItemUpdated: (itemAtualizado) async {
        try {
          await _firebaseService.update(item.id, itemAtualizado.toMap());
          MessageUtils.showSuccess(context, 'Item atualizado!');
        } catch (e) {
          MessageUtils.showError(context, 'Erro ao atualizar: $e');
        }
      },
    );
  }

  /// Marca/desmarca item como comprado
  Future<void> _marcarComprado(ItemCompra item) async {
    try {
      final itemAtualizado = item.copyWith(comprado: !item.comprado);
      await _firebaseService.update(item.id, itemAtualizado.toMap());
    } catch (e) {
      MessageUtils.showError(context, 'Erro ao atualizar item: $e');
    }
  }

  /// Marca/desmarca item como em falta
  Future<void> _marcarEmFalta(ItemCompra item) async {
    try {
      final itemAtualizado = item.copyWith(emFalta: !item.emFalta);
      await _firebaseService.update(item.id, itemAtualizado.toMap());
    } catch (e) {
      MessageUtils.showError(context, 'Erro ao atualizar item: $e');
    }
  }

  /// Deleta um item
  Future<void> _deletarItem(ItemCompra item) async {
    try {
      await _firebaseService.delete(item.id);
      MessageUtils.showSuccess(context, 'Item removido!');
    } catch (e) {
      MessageUtils.showError(context, 'Erro ao remover item: $e');
    }
  }

  /// Finaliza a feira (limpa todos os itens)
  Future<void> _finalizarFeira() async {
    final confirmar = await DialogUtils.showClearListConfirmDialog(
      context: context,
    );

    if (!confirmar) return;

    setState(() => _isLoading = true);

    try {
      // Usa o método otimizado para limpar toda a coleção de uma vez
      await _firebaseService.clearCollection();

      MessageUtils.showSuccess(context, 'Feira finalizada! 🎉');
    } catch (e) {
      MessageUtils.showError(context, 'Erro ao finalizar feira: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ==================== ESTADO UI ====================

  /// Toggle de uma categoria específica
  void _toggleCategoria(String categoria) {
    setState(() {
      _categoriasExpandidas[categoria] =
          !(_categoriasExpandidas[categoria] ?? true);
    });
  }

  /// Verifica se todos os grupos estão expandidos
  bool _todosExpandidos(List<ItemCompra> itens) {
    final grupos = ListaComprasService.agruparPorCategoria(itens);
    return grupos.keys.every((cat) => _categoriasExpandidas[cat] ?? true);
  }

  /// Toggle de todos os grupos
  void _toggleTodosGrupos(List<ItemCompra> itens) {
    final grupos = ListaComprasService.agruparPorCategoria(itens);
    final todosExpandidos = _todosExpandidos(itens);

    setState(() {
      for (var categoria in grupos.keys) {
        _categoriasExpandidas[categoria] = !todosExpandidos;
      }
    });
  }

  // =====================================================================
  // <-- ALTERAÇÃO 2 AQUI: Lógica de reordenação corrigida.
  // =====================================================================

  /// Callback de reordenação de categorias
  void _onReorderCategorias(
    int oldIndex,
    int newIndex,
    List<String> categoriasPendentes, // Recebe a lista filtrada
  ) {
    setState(() {
      // Ajusta o newIndex se o item for arrastado para baixo
      // (Comportamento padrão do ReorderableListView)
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }

      // Pega o NOME da categoria que foi movida
      final String categoriaMovida = categoriasPendentes[oldIndex];

      // Pega o NOME da categoria que servirá de referência para a inserção
      final String categoriaReferencia = categoriasPendentes[newIndex];

      // Remove a categoria movida da lista MASTER (_ordemCategorias)
      _ordemCategorias.remove(categoriaMovida);

      // Encontra o índice da categoria de referência na lista MASTER
      // (Isso é feito *depois* da remoção, para o índice estar correto)
      final int masterIndexReferencia = _ordemCategorias.indexOf(
        categoriaReferencia,
      );

      // Insere a categoria movida na posição correta
      // Se o item foi movido para cima (oldIndex > newIndex),
      // ele deve ser inserido na mesma posição do item de referência.
      // Se o item foi movido para baixo (oldIndex < newIndex),
      // ele deve ser inserido *após* o item de referência.
      if (oldIndex > newIndex) {
        _ordemCategorias.insert(masterIndexReferencia, categoriaMovida);
      } else {
        _ordemCategorias.insert(masterIndexReferencia + 1, categoriaMovida);
      }
    });
  }
}
