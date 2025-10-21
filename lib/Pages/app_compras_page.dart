import 'package:flutter/material.dart';
import 'package:via_cep_api/Services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Model do Item de Compra
class ItemCompra {
  final String id;
  final String nome;
  final String quantidade;
  final bool comprado;
  final String? categoria;

  ItemCompra({
    required this.id,
    required this.nome,
    required this.quantidade,
    this.comprado = false,
    this.categoria,
  });

  Map<String, dynamic> toMap() {
    return {
      "nome": nome,
      "quantidade": quantidade,
      "comprado": comprado,
      "categoria": categoria,
    };
  }

  factory ItemCompra.fromMap(Map<String, dynamic> map, String id) {
    return ItemCompra(
      id: id,
      nome: map["nome"] ?? "",
      quantidade: map["quantidade"] ?? "",
      comprado: map["comprado"] ?? false,
      categoria: map["categoria"],
    );
  }

  ItemCompra copyWith({
    String? id,
    String? nome,
    String? quantidade,
    bool? comprado,
    String? categoria,
  }) {
    return ItemCompra(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      quantidade: quantidade ?? this.quantidade,
      comprado: comprado ?? this.comprado,
      categoria: categoria ?? this.categoria,
    );
  }
}

class ListaComprasPage extends StatefulWidget {
  const ListaComprasPage({Key? key}) : super(key: key);

  @override
  State<ListaComprasPage> createState() => _ListaComprasPageState();
}

class _ListaComprasPageState extends State<ListaComprasPage>
    with SingleTickerProviderStateMixin {
  final FirebaseService _firebaseService = FirebaseService(
    collectionName: 'mercado',
  );
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _quantidadeController = TextEditingController();
  final _nomeFocusNode = FocusNode();

  bool _isLoading = false;
  String? _categoriaSelecionada;
  List<String> _sugestoesItens = [];
  bool _mostrarSugestoes = false;

  late AnimationController _animationController;

  final List<String> _categorias = [
    'Frutas & Verduras',
    'Carnes & Peixes',
    'Laticínios',
    'Mercearia',
    'Bebidas',
    'Limpeza',
    'Higiene',
    'Padaria',
    'Congelados',
    'Outros',
  ];

  // Base de dados de itens de supermercado
  final Map<String, List<String>> _baseItens = {
    'Frutas & Verduras': [
      'Abacate',
      'Abacaxi',
      'Abóbora',
      'Acelga',
      'Agrião',
      'Aipim',
      'Alface',
      'Alho',
      'Alho-poró',
      'Ameixa',
      'Abobrinha',
      'Banana',
      'Batata',
      'Batata-doce',
      'Berinjela',
      'Beterraba',
      'Brócolis',
      'Caqui',
      'Cará',
      'Cebolinha',
      'Cebola',
      'Cenoura',
      'Chicória',
      'Chuchu',
      'Coentro',
      'Couve',
      'Couve-flor',
      'Espinafre',
      'Gengibre',
      'Goiaba',
      'Inhame',
      'Jabuticaba',
      'Jiló',
      'Kiwi',
      'Laranja',
      'Limão',
      'Maçã',
      'Mamão',
      'Mandioca',
      'Manga',
      'Manjericão',
      'Maracujá',
      'Maxixe',
      'Melancia',
      'Melão',
      'Milho verde',
      'Morango',
      'Nectarina',
      'Pepino',
      'Pera',
      'Pêssego',
      'Pimentão',
      'Quiabo',
      'Rabanete',
      'Repolho',
      'Rúcula',
      'Salsa',
      'Tangerina',
      'Tomate',
      'Uva',
      'Vagem',
    ],
    'Carnes & Peixes': [
      'Acém',
      'Alcatra',
      'Atum',
      'Bacalhau',
      'Bacon',
      'Bisteca',
      'Carne moída',
      'Contra-filé',
      'Cordeiro',
      'Costela',
      'Coxa de frango',
      'Cupim',
      'Espetinho',
      'Filé de frango',
      'Filé de peixe',
      'Filé mignon',
      'Frango',
      'Hambúrguer',
      'Lagosta',
      'Linguiça',
      'Lombo',
      'Maminha',
      'Merluza',
      'Músculo',
      'Patinho',
      'Peito de frango',
      'Pernil',
      'Pescada',
      'Picanha',
      'Porco',
      'Salame',
      'Salmão',
      'Salsicha',
      'Sardinha',
      'Tilápia',
    ],
    'Laticínios': [
      'Creme de leite',
      'Iogurte',
      'Leite',
      'Leite condensado',
      'Manteiga',
      'Margarina',
      'Nata',
      'Queijo minas',
      'Queijo mussarela',
      'Queijo parmesão',
      'Queijo prato',
      'Queijo provolone',
      'Queijo cottage',
      'Requeijão',
      'Creme de ricota',
      'Coalhada',
      'Queijo cheddar',
      'Queijo gorgonzola',
    ],
    'Mercearia': [
      'Açúcar',
      'Açúcar mascavo',
      'Azeite',
      'Arroz',
      'Aveia',
      'Biscoito',
      'Café',
      'Catchup',
      'Chocolate',
      'Farinha de trigo',
      'Farinha de mandioca',
      'Feijão',
      'Fubá',
      'Gelatina',
      'Granola',
      'Macarrão',
      'Maionese',
      'Mel',
      'Milho',
      'Molho de tomate',
      'Mostarda',
      'Óleo',
      'Pão',
      'Pão de forma',
      'Sal',
      'Tempero',
      'Vinagre',
      'Extrato de tomate',
      'Macarrão instantâneo',
      'Massa pronta',
      'Amido de milho',
      'Fermento',
      'Polvilho',
      'Leite de coco',
      'Amendoim',
      'Castanha',
      'Cereal matinal',
      'Ervilha',
      'Milho verde lata',
      'Atum lata',
      'Sardinha lata',
      'Azeitona',
      'Palmito',
      'Ervilha seca',
      'Lentilha',
      'Grão de bico',
      'Farinha integral',
    ],
    'Bebidas': [
      'Água',
      'Água de coco',
      'Café solúvel',
      'Cerveja',
      'Chá',
      'Energético',
      'Leite de caixinha',
      'Refrigerante',
      'Suco',
      'Vinho',
      'Whisky',
      'Vodka',
      'Guaraná natural',
      'Achocolatado',
      'Isotônico',
    ],
    'Limpeza': [
      'Água sanitária',
      'Amaciante',
      'Desinfetante',
      'Detergente',
      'Esponja',
      'Limpa vidros',
      'Lustra móveis',
      'Sabão em pó',
      'Sabão em barra',
      'Saco de lixo',
      'Álcool',
      'Alvejante',
      'Flanela',
      'Pano de chão',
      'Vassoura',
      'Rodo',
      'Balde',
      'Inseticida',
      'Cloro',
      'Sapólio',
    ],
    'Higiene': [
      'Absorvente',
      'Algodão',
      'Cotonete',
      'Creme dental',
      'Desodorante',
      'Escova de dente',
      'Fio dental',
      'Lenço de papel',
      'Papel higiênico',
      'Sabonete',
      'Shampoo',
      'Condicionador',
      'Fralda',
      'Hastes flexíveis',
      'Hidratante',
      'Protetor solar',
      'Repelente',
      'Perfume',
      'Máscara facial',
      'Aparelho de barbear',
      'Espuma de barbear',
      'Loção pós-barba',
    ],
    'Padaria': [
      'Baguete',
      'Bisnaga',
      'Bolo',
      'Brioche',
      'Croissant',
      'Filão',
      'Pão de queijo',
      'Pão francês',
      'Pão de forma',
      'Pão integral',
      'Rosca',
      'Sonho',
      'Torta',
      'Pão de hambúrguer',
      'Pão de hot dog',
    ],
    'Congelados': [
      'Batata frita congelada',
      'Frango empanado',
      'Hambúrguer congelado',
      'Lasanha congelada',
      'Pizza congelada',
      'Sorvete',
      'Nuggets',
      'Polpa de frutas',
      'Vegetais congelados',
      'Peixe empanado',
    ],
    'Outros': [
      'Ração para cachorro',
      'Ração para gato',
      'Vela',
      'Pilha',
      'Isqueiro',
      'Guardanapo',
      'Papel alumínio',
      'Filme plástico',
      'Carvão',
    ],
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _nomeController.addListener(_filtrarSugestoes);
    _nomeFocusNode.addListener(() {
      if (!_nomeFocusNode.hasFocus) {
        setState(() => _mostrarSugestoes = false);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nomeController.dispose();
    _quantidadeController.dispose();
    _nomeFocusNode.dispose();
    super.dispose();
  }

  Stream<List<ItemCompra>> _streamItens() {
    return FirebaseFirestore.instance.collection('mercado').snapshots().map((
      snapshot,
    ) {
      final itens = snapshot.docs.map((doc) {
        return ItemCompra.fromMap(doc.data(), doc.id);
      }).toList();

      itens.sort((a, b) {
        if (a.comprado != b.comprado) {
          return a.comprado ? 1 : -1;
        }
        final catA = a.categoria ?? 'Outros';
        final catB = b.categoria ?? 'Outros';
        return catA.compareTo(catB);
      });

      return itens;
    });
  }

  void _filtrarSugestoes() {
    final texto = _nomeController.text.toLowerCase().trim();

    if (texto.isEmpty) {
      setState(() {
        _sugestoesItens = [];
        _mostrarSugestoes = false;
      });
      return;
    }

    List<String> sugestoes = [];
    _baseItens.forEach((categoria, itens) {
      for (var item in itens) {
        if (item.toLowerCase().contains(texto)) {
          sugestoes.add(item);
        }
      }
    });

    sugestoes.sort((a, b) {
      final aComeca = a.toLowerCase().startsWith(texto);
      final bComeca = b.toLowerCase().startsWith(texto);

      if (aComeca && !bComeca) return -1;
      if (!aComeca && bComeca) return 1;
      return a.compareTo(b);
    });

    setState(() {
      _sugestoesItens = sugestoes.take(8).toList();
      _mostrarSugestoes = sugestoes.isNotEmpty && _nomeFocusNode.hasFocus;
    });
  }

  void _selecionarSugestao(String item) {
    _nomeController.text = item;

    String? categoriaDetectada;
    _baseItens.forEach((categoria, itens) {
      if (itens.contains(item)) {
        categoriaDetectada = categoria;
      }
    });

    setState(() {
      _mostrarSugestoes = false;
      if (categoriaDetectada != null) {
        _categoriaSelecionada = categoriaDetectada;
      }
    });

    FocusScope.of(context).nextFocus();
  }

  Future<void> _adicionarItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final itemData = {
        "nome": _nomeController.text.trim(),
        "quantidade": _quantidadeController.text.trim(),
        "comprado": false,
        "categoria": _categoriaSelecionada,
      };

      await _firebaseService.create(itemData);

      _nomeController.clear();
      _quantidadeController.clear();
      setState(() => _categoriaSelecionada = null);

      _mostrarMensagem('Item adicionado!');
      setState(() => _isLoading = false);
    } catch (e) {
      _mostrarMensagem('Erro ao adicionar item: $e', isErro: true);
      setState(() => _isLoading = false);
    }
  }

  Map<String, List<ItemCompra>> _agruparPorCategoria(List<ItemCompra> itens) {
    final Map<String, List<ItemCompra>> grupos = {};

    for (var item in itens) {
      final categoria = item.categoria ?? 'Outros';
      if (!grupos.containsKey(categoria)) {
        grupos[categoria] = [];
      }
      grupos[categoria]!.add(item);
    }

    return grupos;
  }

  Future<void> _marcarComprado(ItemCompra item) async {
    try {
      final itemAtualizado = item.copyWith(comprado: !item.comprado);
      await _firebaseService.update(item.id, itemAtualizado.toMap());
    } catch (e) {
      _mostrarMensagem('Erro ao atualizar item: $e', isErro: true);
    }
  }

  Future<void> _finalizarFeira() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade600, Colors.blue.shade600],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.check_circle_outline,
                color: Colors.white,
                size: 28,
              ),
            ),
            SizedBox(width: 12),
            Expanded(child: Text('Finalizar Feira?')),
          ],
        ),
        content: Text(
          'Isso irá limpar todos os itens da lista.\n\nDeseja continuar?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: TextStyle(fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Finalizar', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => _isLoading = true);

    try {
      final dados = await _firebaseService.readAll();

      for (var itemData in dados) {
        await _firebaseService.delete(itemData['id']);
      }

      setState(() => _isLoading = false);

      _mostrarMensagem('Feira finalizada! Lista limpa com sucesso 🎉');
    } catch (e) {
      _mostrarMensagem('Erro ao finalizar feira: $e', isErro: true);
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deletarItem(ItemCompra item) async {
    try {
      await _firebaseService.delete(item.id);
      _mostrarMensagem('Item removido!');
    } catch (e) {
      _mostrarMensagem('Erro ao remover item: $e', isErro: true);
    }
  }

  void _mostrarMensagem(String mensagem, {bool isErro = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isErro ? Icons.error_outline : Icons.check_circle,
              color: Colors.white,
            ),
            SizedBox(width: 12),
            Expanded(child: Text(mensagem, style: TextStyle(fontSize: 16))),
          ],
        ),
        backgroundColor: isErro ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  IconData _getCategoriaIcon(String? categoria) {
    switch (categoria) {
      case 'Frutas & Verduras':
        return Icons.eco;
      case 'Carnes & Peixes':
        return Icons.set_meal;
      case 'Laticínios':
        return Icons.local_drink;
      case 'Mercearia':
        return Icons.store;
      case 'Bebidas':
        return Icons.local_cafe;
      case 'Limpeza':
        return Icons.cleaning_services;
      case 'Higiene':
        return Icons.sanitizer;
      case 'Padaria':
        return Icons.bakery_dining;
      case 'Congelados':
        return Icons.ac_unit;
      default:
        return Icons.shopping_basket;
    }
  }

  Color _getCategoriaColor(String? categoria) {
    switch (categoria) {
      case 'Frutas & Verduras':
        return Colors.green;
      case 'Carnes & Peixes':
        return Colors.red;
      case 'Laticínios':
        return Colors.blue;
      case 'Mercearia':
        return Colors.amber;
      case 'Bebidas':
        return Colors.orange;
      case 'Limpeza':
        return Colors.purple;
      case 'Higiene':
        return Colors.teal;
      case 'Padaria':
        return Colors.brown;
      case 'Congelados':
        return Colors.lightBlue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.green.shade50, Colors.white, Colors.blue.shade50],
          ),
        ),
        child: SafeArea(
          child: StreamBuilder<List<ItemCompra>>(
            stream: _streamItens(),
            builder: (context, snapshot) {
              final itens = snapshot.data ?? [];
              final itensNaoComprados = itens.where((i) => !i.comprado).length;
              final itensComprados = itens.where((i) => i.comprado).length;

              return Column(
                children: [
                  // Header compacto
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.shade600,
                                Colors.blue.shade600,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.shopping_cart,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Lista de Compras',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              Text(
                                '$itensNaoComprados pendentes • $itensComprados comprados',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (itens.isNotEmpty)
                          ElevatedButton.icon(
                            onPressed: _isLoading ? null : _finalizarFeira,
                            icon: Icon(Icons.check, size: 18),
                            label: Text(
                              'Finalizar',
                              style: TextStyle(fontSize: 13),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Formulário compacto
                  Container(
                    margin: EdgeInsets.all(12),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: _nomeController,
                                      focusNode: _nomeFocusNode,
                                      decoration: InputDecoration(
                                        labelText: 'Item',
                                        hintText: 'Ex: Arroz',
                                        prefixIcon: Icon(
                                          Icons.search,
                                          color: Colors.green.shade600,
                                          size: 20,
                                        ),
                                        suffixIcon:
                                            _nomeController.text.isNotEmpty
                                            ? IconButton(
                                                icon: Icon(
                                                  Icons.clear,
                                                  size: 18,
                                                ),
                                                onPressed: () {
                                                  _nomeController.clear();
                                                  setState(
                                                    () => _mostrarSugestoes =
                                                        false,
                                                  );
                                                },
                                              )
                                            : null,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey.shade50,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 12,
                                        ),
                                        isDense: true,
                                      ),
                                      style: TextStyle(fontSize: 14),
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Informe o item';
                                        }
                                        return null;
                                      },
                                      onFieldSubmitted: (_) => _adicionarItem(),
                                      onChanged: (value) => setState(() {}),
                                    ),

                                    // Lista de sugestões
                                    if (_mostrarSugestoes &&
                                        _sugestoesItens.isNotEmpty)
                                      Container(
                                        margin: EdgeInsets.only(top: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.1,
                                              ),
                                              blurRadius: 8,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        constraints: BoxConstraints(
                                          maxHeight: 200,
                                        ),
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          padding: EdgeInsets.zero,
                                          itemCount: _sugestoesItens.length,
                                          itemBuilder: (context, index) {
                                            final sugestao =
                                                _sugestoesItens[index];
                                            return InkWell(
                                              onTap: () =>
                                                  _selecionarSugestao(sugestao),
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 10,
                                                ),
                                                decoration: BoxDecoration(
                                                  border:
                                                      index <
                                                          _sugestoesItens
                                                                  .length -
                                                              1
                                                      ? Border(
                                                          bottom: BorderSide(
                                                            color: Colors
                                                                .grey
                                                                .shade200,
                                                          ),
                                                        )
                                                      : null,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.shopping_basket,
                                                      size: 16,
                                                      color:
                                                          Colors.grey.shade600,
                                                    ),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      sugestao,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  controller: _quantidadeController,
                                  decoration: InputDecoration(
                                    labelText: 'Qtd',
                                    hintText: '1kg',
                                    prefixIcon: Icon(
                                      Icons.numbers,
                                      color: Colors.blue.shade600,
                                      size: 20,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                    isDense: true,
                                  ),
                                  style: TextStyle(fontSize: 14),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Qtd';
                                    }
                                    return null;
                                  },
                                  onFieldSubmitted: (_) => _adicionarItem(),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _categoriaSelecionada,
                                  decoration: InputDecoration(
                                    labelText: 'Categoria',
                                    prefixIcon: Icon(
                                      Icons.category,
                                      color: Colors.purple.shade600,
                                      size: 20,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    isDense: true,
                                  ),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                  items: _categorias.map((cat) {
                                    return DropdownMenuItem(
                                      value: cat,
                                      child: Row(
                                        children: [
                                          Icon(
                                            _getCategoriaIcon(cat),
                                            size: 18,
                                            color: _getCategoriaColor(cat),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            cat,
                                            style: TextStyle(fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(
                                      () => _categoriaSelecionada = value,
                                    );
                                  },
                                ),
                              ),
                              SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: _isLoading ? null : _adicionarItem,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade600,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isLoading
                                    ? SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : Icon(Icons.add, size: 24),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Lista de itens
                  Expanded(
                    child: snapshot.connectionState == ConnectionState.waiting
                        ? Center(child: CircularProgressIndicator())
                        : snapshot.hasError
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 60,
                                  color: Colors.red.shade400,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Erro ao carregar itens',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.red.shade600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : itens.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shopping_cart_outlined,
                                  size: 60,
                                  color: Colors.grey.shade300,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Sua lista está vazia',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Adicione itens acima',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _buildListaAgrupada(itens),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildListaAgrupada(List<ItemCompra> itens) {
    final grupos = _agruparPorCategoria(itens);

    final gruposNaoComprados = <String, List<ItemCompra>>{};
    final gruposComprados = <String, List<ItemCompra>>{};

    grupos.forEach((categoria, itens) {
      final naoComprados = itens.where((i) => !i.comprado).toList();
      final comprados = itens.where((i) => i.comprado).toList();

      if (naoComprados.isNotEmpty) {
        gruposNaoComprados[categoria] = naoComprados;
      }
      if (comprados.isNotEmpty) {
        gruposComprados[categoria] = comprados;
      }
    });

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      children: [
        ...gruposNaoComprados.entries.map((entry) {
          return _buildGrupoCategoria(entry.key, entry.value, comprado: false);
        }).toList(),

        if (gruposComprados.isNotEmpty) ...[
          SizedBox(height: 4),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Expanded(child: Divider(thickness: 1.5)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green.shade600,
                        size: 18,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Comprados',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(child: Divider(thickness: 1.5)),
              ],
            ),
          ),
        ],

        ...gruposComprados.entries.map((entry) {
          return _buildGrupoCategoria(entry.key, entry.value, comprado: true);
        }).toList(),

        SizedBox(height: 12),
      ],
    );
  }

  Widget _buildGrupoCategoria(
    String categoria,
    List<ItemCompra> itens, {
    required bool comprado,
  }) {
    final cor = _getCategoriaColor(categoria);
    final icone = _getCategoriaIcon(categoria);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 6, top: 8),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: cor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icone, color: cor, size: 18),
              ),
              SizedBox(width: 10),
              Text(
                categoria,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(width: 6),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: cor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${itens.length}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: cor.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
        ),

        ...itens.map((item) => _buildItemCard(item)).toList(),
      ],
    );
  }

  Widget _buildItemCard(ItemCompra item) {
    return Container(
      margin: EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.comprado ? Colors.green.shade200 : Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _marcarComprado(item),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: item.comprado
                        ? Colors.green.shade600
                        : Colors.transparent,
                    border: Border.all(
                      color: item.comprado
                          ? Colors.green.shade600
                          : Colors.grey.shade400,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: item.comprado
                      ? Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
                SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.nome,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: item.comprado
                              ? Colors.grey.shade500
                              : Colors.grey.shade800,
                          decoration: item.comprado
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        item.quantidade,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.red.shade400,
                    size: 20,
                  ),
                  onPressed: () => _deletarItem(item),
                  tooltip: 'Remover',
                  padding: EdgeInsets.all(4),
                  constraints: BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
