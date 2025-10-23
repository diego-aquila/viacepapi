import 'package:flutter/material.dart';
import 'package:via_cep_api/Services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Model do Item de Compra (mantido inalterado)
class ItemCompra {
  final String id;
  final String nome;
  final String quantidade;
  final bool comprado;
  final bool emFalta;
  final String? categoria;

  ItemCompra({
    required this.id,
    required this.nome,
    required this.quantidade,
    this.comprado = false,
    this.emFalta = false,
    this.categoria,
  });

  Map<String, dynamic> toMap() {
    return {
      "nome": nome,
      "quantidade": quantidade,
      "comprado": comprado,
      "emFalta": emFalta,
      "categoria": categoria,
    };
  }

  factory ItemCompra.fromMap(Map<String, dynamic> map, String id) {
    return ItemCompra(
      id: id,
      nome: map["nome"] ?? "",
      quantidade: map["quantidade"] ?? "",
      comprado: map["comprado"] ?? false,
      emFalta: map["emFalta"] ?? false,
      categoria: map["categoria"],
    );
  }

  ItemCompra copyWith({
    String? id,
    String? nome,
    String? quantidade,
    bool? comprado,
    bool? emFalta,
    String? categoria,
  }) {
    return ItemCompra(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      quantidade: quantidade ?? this.quantidade,
      comprado: comprado ?? this.comprado,
      emFalta: emFalta ?? this.emFalta,
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

  final _textFieldKey = GlobalKey();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _suggestionsOverlay;

  bool _isLoading = false;
  String? _categoriaSelecionada;
  List<String> _sugestoesItens = [];
  bool _mostrarSugestoes = false;
  bool _formularioExpandido = false; // Começa colapsado

  Map<String, bool> _categoriasExpandidas = {};
  List<String> _ordemCategorias = [];
  bool _compradosExpandido = false;
  bool _emFaltaExpandido = false;

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

  final Map<String, List<String>> _baseItens = {
    'Frutas & Verduras': [
      'Abacate',
      'Abacaxi',
      'Abóbora',
      'Acelga',
      'Agrião',
      ''
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
      'Abobrinha italiana',
      'Almeirão',
      'Batata inglesa',
      'Caju',
      'Cana-de-açúcar',
      'Coco seco',
      'Endívia',
      'Jaca',
      'Manga rosa',
      'Melão cantaloupe',
      'Mexerica',
      'Pimentinha',
      'Pimenta-do-reino (fresca)',
      'Rúcula selvagem',
      'Tomate cereja',
      'Tomate italiano',
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
      'Asa de frango',
      'Coração de frango',
      'Coxinha da asa',
      'Filé suíno',
      'Peixe tambaqui',
      'Peixe tainha',
      'Peixe bacalhau dessalgado',
      'Presunto',
      'Mortadela',
      'Peito de peru',
      'Torresmo',
      'Costelinha suína',
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
      'Creme culinário',
      'Chantilly',
      'Queijo coalho',
      'Queijo brie',
      'Queijo minas padrão',
      'Queijo gouda',
      'Queijo suíço',
      'Iogurte grego',
      'Leite em pó',
      'Bebida láctea fermentada',
      'Queijo ralado',
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
      'Arroz integral',
      'Arroz parboilizado',
      'Feijão preto',
      'Feijão carioca',
      'Molho shoyu',
      'Molho inglês',
      'Molho agridoce',
      'Ketchup picante',
      'Maionese light',
      'Sal grosso',
      'Sal rosa',
      'Farinha de rosca',
      'Tapioca',
      'Canjica',
      'Pipoca',
      'Pipoca de micro-ondas',
      'Torrada',
      'Bolacha salgada',
      'Bolacha doce',
      'Achocolatado em pó',
      'Chá mate',
      'Cereal de aveia',
      'Creme de avelã',
      'Manteiga de amendoim',
      'Vinagre balsâmico',
      'Caldo de galinha',
      'Caldo de carne',
      'Caldo de legumes',
      'Açafrão',
      'Páprica',
      'Pimenta-do-reino moída',
      'Orégano',
      'Açúcar demerara',
      'Panetone',
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
      'Água com gás',
      'Água saborizada',
      'Refrigerante zero',
      'Suco natural',
      'Chá gelado',
      'Cerveja sem álcool',
      'Espumante',
      'Gin',
      'Rum',
      'Água tônica',
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
      'Desengordurante',
      'Multiuso',
      'Limpa piso',
      'Removedor',
      'Desinfetante de banheiro',
      'Tira manchas',
      'Sabão líquido',
      'Álcool em gel',
      'Refil de limpador',
      'Desodorizador de ambiente',
      'Esfregão',
      'Luvas de limpeza',
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
      'Escova de cabelo',
      'Pente',
      'Esmalte',
      'Removedor de esmalte',
      'Papel toalha',
      'Lenço umedecido',
      'Desodorante roll-on',
      'Creme para as mãos',
      'Enxaguante bucal',
      'Creme para pentear',
      'Sabonete líquido',
      'Cotonetes',
      'Descolorante',
      'Tintura de cabelo',
      'Pomada infantil',
      'Toalhas umedecidas',
      'Talco',
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
      'Pão sírio',
      'Pão australiano',
      'Pão integral de grãos',
      'Pão doce',
      'Pão de leite',
      'Pão francês integral',
      'Pão de forma integral',
      'Pão de alho',
      'Pastel',
      'Empada',
      'Quiche',
      'Biscoito caseiro',
      'Muffin',
      'Cupcake',
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
      'Pão de queijo congelado',
      'Legumes mistos',
      'Frutas vermelhas congeladas',
      'Pizza brotinho',
      'Empanado de peixe',
      'Almôndegas congeladas',
      'Pratos prontos congelados',
      'Lasanha bolonhesa',
      'Hambúrguer vegetal',
      'Sorvete light',
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
      'Pilha recarregável',
      'Carvão vegetal',
      'Vela aromática',
      'Fósforo',
      'Saco de lixo',
      'Papel manteiga',
      'Gelo',
      'Pilhas AA',
      'Pilhas AAA',
      'Pilhas recarregáveis',
      'Pilhas botão',
      'Extensões elétricas',
      'Lâmpada',
    ],
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    for (var cat in _categorias) {
      _categoriasExpandidas[cat] = true;
    }

    _ordemCategorias = List.from(_categorias);

    _nomeController.addListener(_filtrarSugestoes);
    _nomeFocusNode.addListener(() {
      if (!_nomeFocusNode.hasFocus) {
        _removeSuggestionsOverlay();
        setState(() => _mostrarSugestoes = false);
      }
    });
  }

  @override
  void dispose() {
    _removeSuggestionsOverlay();
    _animationController.dispose();
    _nomeController.dispose();
    _quantidadeController.dispose();
    _nomeFocusNode.dispose();
    super.dispose();
  }

  void _removeSuggestionsOverlay() {
    _suggestionsOverlay?.remove();
    _suggestionsOverlay = null;
  }

  OverlayEntry _buildSuggestionsOverlay() {
    final RenderBox? renderBox =
        _textFieldKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null) {
      return OverlayEntry(builder: (context) => SizedBox.shrink());
    }

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) {
        return Positioned(
          left: offset.dx,
          top: offset.dy + size.height + 4,
          width: size.width,
          child: Material(
            elevation: 8.0,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _sugestoesItens.length,
                itemBuilder: (context, index) {
                  final sugestao = _sugestoesItens[index];
                  return InkWell(
                    onTap: () {
                      _selecionarSugestao(sugestao);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: index < _sugestoesItens.length - 1
                            ? Border(
                                bottom: BorderSide(color: Colors.grey.shade100),
                              )
                            : null,
                      ),
                      child: Text(
                        sugestao,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
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

        if (a.emFalta != b.emFalta) {
          return a.emFalta ? 1 : -1;
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
      _removeSuggestionsOverlay();
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
      _mostrarSugestoes = _sugestoesItens.isNotEmpty && _nomeFocusNode.hasFocus;
    });

    if (_mostrarSugestoes) {
      _removeSuggestionsOverlay();
      _suggestionsOverlay = _buildSuggestionsOverlay();
      Overlay.of(context).insert(_suggestionsOverlay!);
    } else {
      _removeSuggestionsOverlay();
    }
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

    _removeSuggestionsOverlay();
    FocusScope.of(context).unfocus(); // Fecha o teclado e perde o foco
  }

  Future<void> _adicionarItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final itemData = {
        "nome": _nomeController.text.trim(),
        "quantidade": _quantidadeController.text.trim(),
        "comprado": false,
        "emFalta": false,
        "categoria": _categoriaSelecionada,
      };

      await _firebaseService.create(itemData);

      _nomeController.clear();
      _quantidadeController.clear();
      setState(() => _categoriaSelecionada = null);

      _mostrarMensagem('Item adicionado!');
      setState(() => _isLoading = false);
      Navigator.of(context).pop(); // Fecha o painel de adição
    } catch (e) {
      _mostrarMensagem('Erro ao adicionar item: $e', isErro: true);
      setState(() => _isLoading = false);
    }
  }

  Future<void> _editarItem(ItemCompra item) async {
    final nomeEditController = TextEditingController(text: item.nome);
    final quantidadeEditController = TextEditingController(
      text: item.quantidade,
    );
    String? categoriaSelecionadaEdit = item.categoria;
    final formKeyEdit = GlobalKey<FormState>();

    final resultado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            padding: EdgeInsets.all(24),
            child: StatefulBuilder(
              builder: (context, setStateDialog) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Editar Item',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    SizedBox(height: 20),
                    Form(
                      key: formKeyEdit,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: nomeEditController,
                            decoration: InputDecoration(
                              labelText: 'Nome do Item',
                              hintText: 'Ex: Arroz',
                              prefixIcon: Icon(Icons.shopping_bag_outlined),
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
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: quantidadeEditController,
                            decoration: InputDecoration(
                              labelText: 'Quantidade',
                              hintText: 'Ex: 2kg',
                              prefixIcon: Icon(Icons.menu_book),
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
                          ),
                          SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: categoriaSelecionadaEdit,
                            decoration: InputDecoration(
                              labelText: 'Categoria',
                              prefixIcon: Icon(Icons.category_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
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
                                    Text(cat),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setStateDialog(() {
                                categoriaSelecionadaEdit = value;
                              });
                            },
                          ),
                          SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(
                                  'Cancelar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: () async {
                                  if (formKeyEdit.currentState!.validate()) {
                                    Navigator.pop(context, true);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF6A994E),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                                child: Text(
                                  'Salvar',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );

    if (resultado == true) {
      try {
        final itemAtualizado = item.copyWith(
          nome: nomeEditController.text.trim(),
          quantidade: quantidadeEditController.text.trim(),
          categoria: categoriaSelecionadaEdit,
        );

        await _firebaseService.update(item.id, itemAtualizado.toMap());
        _mostrarMensagem('Item atualizado com sucesso!');
      } catch (e) {
        _mostrarMensagem('Erro ao atualizar item: $e', isErro: true);
      }
    }

    nomeEditController.dispose();
    quantidadeEditController.dispose();
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

  Future<void> _marcarEmFalta(ItemCompra item) async {
    try {
      final itemAtualizado = item.copyWith(emFalta: !item.emFalta);
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
            Icon(
              Icons.check_circle_outline,
              color: Color(0xFF6A994E),
              size: 28,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Finalizar Feira?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Isso irá limpar todos os itens da lista.\n\nDeseja continuar?',
          style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancelar',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF6A994E),
              foregroundColor: Colors.white,
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
        backgroundColor: isErro ? Color(0xFFD32F2F) : Color(0xFF6A994E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  bool _todosExpandidos(List<ItemCompra> itens) {
    final grupos = _agruparPorCategoria(itens);
    return grupos.keys.every((cat) => _categoriasExpandidas[cat] ?? true);
  }

  void _toggleTodosGrupos(List<ItemCompra> itens) {
    final grupos = _agruparPorCategoria(itens);
    final todosExpandidos = _todosExpandidos(itens);

    setState(() {
      for (var categoria in grupos.keys) {
        _categoriasExpandidas[categoria] = !todosExpandidos;
      }
    });
  }

  IconData _getCategoriaIcon(String? categoria) {
    switch (categoria) {
      case 'Frutas & Verduras':
        return Icons.eco_outlined;
      case 'Carnes & Peixes':
        return Icons.set_meal_outlined;
      case 'Laticínios':
        return Icons.local_drink_outlined;
      case 'Mercearia':
        return Icons.store_outlined;
      case 'Bebidas':
        return Icons.local_bar_outlined;
      case 'Limpeza':
        return Icons.cleaning_services_outlined;
      case 'Higiene':
        return Icons.bathtub_outlined;
      case 'Padaria':
        return Icons.bakery_dining_outlined;
      case 'Congelados':
        return Icons.ac_unit_outlined;
      default:
        return Icons.shopping_basket_outlined;
    }
  }

  Color _getCategoriaColor(String? categoria) {
    switch (categoria) {
      case 'Frutas & Verduras':
        return Color(0xFF8BC34A); // Light Green
      case 'Carnes & Peixes':
        return Color(0xFFEF5350); // Red
      case 'Laticínios':
        return Color(0xFF42A5F5); // Blue
      case 'Mercearia':
        return Color(0xFFFFA726); // Orange
      case 'Bebidas':
        return Color(0xFFAB47BC); // Purple
      case 'Limpeza':
        return Color(0xFF26C6DA); // Cyan
      case 'Higiene':
        return Color(0xFF78909C); // Blue Grey
      case 'Padaria':
        return Color(0xFF8D6E63); // Brown
      case 'Congelados':
        return Color(0xFF64B5F6); // Light Blue
      default:
        return Color(0xFF9E9E9E); // Grey
    }
  }

  void _showAddItemPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            padding: EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Adicionar Novo Item',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  CompositedTransformTarget(
                    link: _layerLink,
                    child: TextFormField(
                      key: _textFieldKey,
                      controller: _nomeController,
                      focusNode: _nomeFocusNode,
                      decoration: InputDecoration(
                        labelText: 'Item',
                        hintText: 'Ex: Arroz',
                        prefixIcon: Icon(Icons.search),
                        suffixIcon: _nomeController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, size: 20),
                                onPressed: () {
                                  _nomeController.clear();
                                  _removeSuggestionsOverlay();
                                  setState(() => _mostrarSugestoes = false);
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                      onFieldSubmitted: (_) => _adicionarItem(),
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _quantidadeController,
                    decoration: InputDecoration(
                      labelText: 'Quantidade',
                      hintText: 'Ex: 1kg',
                      prefixIcon: Icon(Icons.format_list_numbered),
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
                    onFieldSubmitted: (_) => _adicionarItem(),
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _categoriaSelecionada,
                    decoration: InputDecoration(
                      labelText: 'Categoria',
                      prefixIcon: Icon(Icons.category_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
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
                            Text(cat),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _categoriaSelecionada = value);
                    },
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _adicionarItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6A994E),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            'Adicionar à Lista',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).whenComplete(() {
      _nomeController.clear();
      _quantidadeController.clear();
      setState(() {
        _categoriaSelecionada = null;
        _formularioExpandido = false; // Garante que o estado seja resetado
      });
      _removeSuggestionsOverlay(); // Garante que o overlay seja removido ao fechar o modal
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F8F8),
      body: SafeArea(
        child: StreamBuilder<List<ItemCompra>>(
          stream: _streamItens(),
          builder: (context, snapshot) {
            final itens = snapshot.data ?? [];
            final itensNaoComprados = itens
                .where((i) => !i.comprado && !i.emFalta)
                .length;
            final itensComprados = itens.where((i) => i.comprado).length;

            return Column(
              children: [
                _buildHeader(itensNaoComprados, itensComprados, itens),
                Expanded(
                  child: snapshot.connectionState == ConnectionState.waiting
                      ? Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF6A994E),
                            ),
                          ),
                        )
                      : snapshot.hasError
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 60,
                                color: Color(0xFFD32F2F).withOpacity(0.7),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Erro ao carregar itens',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFFD32F2F),
                                ),
                              ),
                            ],
                          ),
                        )
                      : itens.isEmpty
                      ? _buildEmptyState()
                      : _buildListaAgrupada(itens),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddItemPanel,
        label: Text('Adicionar Item', style: TextStyle(fontSize: 16)),
        icon: Icon(Icons.add),
        backgroundColor: Color(0xFF6A994E),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 8,
      ),
    );
  }

  Widget _buildHeader(
    int itensNaoComprados,
    int itensComprados,
    List<ItemCompra> todosItens,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Minha Lista de Compras',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              if (todosItens.isNotEmpty)
                IconButton(
                  icon: Icon(
                    Icons.delete_sweep_outlined,
                    color: Colors.grey.shade500,
                    size: 28,
                  ),
                  onPressed: _isLoading ? null : _finalizarFeira,
                  tooltip: 'Finalizar Feira e Limpar Lista',
                ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '$itensNaoComprados itens pendentes • $itensComprados itens comprados',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (todosItens.isNotEmpty)
                ActionChip(
                  avatar: Icon(
                    _todosExpandidos(todosItens)
                        ? Icons.unfold_less
                        : Icons.unfold_more,
                    color: Color(0xFF6A994E),
                    size: 18,
                  ),
                  label: Text(
                    _todosExpandidos(todosItens)
                        ? 'Colapsar Tudo'
                        : 'Expandir Tudo',
                    style: TextStyle(
                      color: Color(0xFF6A994E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () => _toggleTodosGrupos(todosItens),
                  backgroundColor: Color(0xFFE8F5E9),
                  elevation: 0,
                  pressElevation: 2,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: 20),
          Text(
            'Sua lista está vazia!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Adicione seu primeiro item para começar.',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildListaAgrupada(List<ItemCompra> itens) {
    final grupos = _agruparPorCategoria(itens);

    final gruposPendentes = <String, List<ItemCompra>>{};
    final gruposEmFalta = <String, List<ItemCompra>>{};
    final gruposComprados = <String, List<ItemCompra>>{};

    grupos.forEach((categoria, itens) {
      final pendentes = itens.where((i) => !i.comprado && !i.emFalta).toList();
      final emFalta = itens.where((i) => i.emFalta && !i.comprado).toList();
      final comprados = itens.where((i) => i.comprado).toList();

      if (pendentes.isNotEmpty) {
        gruposPendentes[categoria] = pendentes;
      }
      if (emFalta.isNotEmpty) {
        gruposEmFalta[categoria] = emFalta;
      }
      if (comprados.isNotEmpty) {
        gruposComprados[categoria] = comprados;
      }
    });

    final categoriasPendentesOrdenadas = _ordemCategorias
        .where((cat) => gruposPendentes.containsKey(cat))
        .toList();

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 100), // Espaço para o FAB
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Seção de itens pendentes
              if (categoriasPendentesOrdenadas.isNotEmpty) ...[
                Text(
                  'Itens Pendentes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                SizedBox(height: 16),
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: categoriasPendentesOrdenadas.length,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) {
                        newIndex -= 1;
                      }
                      final categoria = categoriasPendentesOrdenadas.removeAt(
                        oldIndex,
                      );
                      categoriasPendentesOrdenadas.insert(newIndex, categoria);

                      _ordemCategorias.clear();
                      _ordemCategorias.addAll(categoriasPendentesOrdenadas);
                      for (var cat in _categorias) {
                        if (!_ordemCategorias.contains(cat)) {
                          _ordemCategorias.add(cat);
                        }
                      }
                    });
                  },
                  itemBuilder: (context, index) {
                    final categoria = categoriasPendentesOrdenadas[index];
                    final itensCategoria = gruposPendentes[categoria]!;
                    return _buildCategoriaSection(
                      key: ValueKey(categoria),
                      index: index,
                      categoria: categoria,
                      itens: itensCategoria,
                      isCompradoSection: false,
                      isEmFaltaSection: false,
                    );
                  },
                ),
              ],

              // Seção de itens em falta
              if (gruposEmFalta.isNotEmpty) ...[
                SizedBox(height: 24),
                _buildGrupoEmFalta(gruposEmFalta),
              ],

              // Seção de itens comprados
              if (gruposComprados.isNotEmpty) ...[
                SizedBox(height: 24),
                _buildGrupoComprados(gruposComprados),
              ],
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildGrupoEmFalta(Map<String, List<ItemCompra>> gruposEmFalta) {
    final totalEmFalta = gruposEmFalta.values.fold<int>(
      0,
      (sum, lista) => sum + lista.length,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _emFaltaExpandido = !_emFaltaExpandido;
                });
              },
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
                bottom: _emFaltaExpandido ? Radius.zero : Radius.circular(20),
              ),
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(0xFFFB8C00),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Itens em Falta',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFB8C00),
                            ),
                          ),
                          Text(
                            '$totalEmFalta ${totalEmFalta == 1 ? "item" : "itens"}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _emFaltaExpandido
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Color(0xFFFB8C00),
                      size: 28,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_emFaltaExpandido)
            ...gruposEmFalta.entries.map((entry) {
              return _buildCategoriaSection(
                key: ValueKey('em_falta_${entry.key}'),
                index: 0,
                categoria: entry.key,
                itens: entry.value,
                isCompradoSection: false,
                isEmFaltaSection: true,
                showCategoryTitle:
                    true, // Mostrar título da categoria aqui também
                expandable:
                    false, // Não permite expandir/colapsar sub-categoria de em falta
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildGrupoComprados(Map<String, List<ItemCompra>> gruposComprados) {
    final totalComprados = gruposComprados.values.fold<int>(
      0,
      (sum, lista) => sum + lista.length,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF6A994E).withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _compradosExpandido = !_compradosExpandido;
                });
              },
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
                bottom: _compradosExpandido ? Radius.zero : Radius.circular(20),
              ),
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(0xFF6A994E),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.check_circle_outline,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Itens Comprados',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6A994E),
                            ),
                          ),
                          Text(
                            '$totalComprados ${totalComprados == 1 ? "item" : "itens"}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _compradosExpandido
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Color(0xFF6A994E),
                      size: 28,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_compradosExpandido)
            ...gruposComprados.entries.map((entry) {
              return _buildCategoriaSection(
                key: ValueKey('comprados_${entry.key}'),
                index: 0,
                categoria: entry.key,
                itens: entry.value,
                isCompradoSection: true,
                isEmFaltaSection: false,
                showCategoryTitle: true,
                expandable: false,
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildCategoriaSection({
    required Key key,
    required int index,
    required String categoria,
    required List<ItemCompra> itens,
    required bool isCompradoSection,
    required bool isEmFaltaSection,
    bool showCategoryTitle = false,
    bool expandable = true,
  }) {
    final cor = isCompradoSection
        ? Color(0xFF6A994E)
        : isEmFaltaSection
        ? Color(0xFFFB8C00)
        : _getCategoriaColor(categoria);
    final icone = _getCategoriaIcon(categoria);
    final expandido = _categoriasExpandidas[categoria] ?? true;

    if (itens.isEmpty) return SizedBox.shrink();

    return Container(
      key: key,
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: expandable
                  ? () {
                      setState(() {
                        _categoriasExpandidas[categoria] = !expandido;
                      });
                    }
                  : null,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(15),
                bottom: expandido ? Radius.zero : Radius.circular(15),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    if (!isCompradoSection && !isEmFaltaSection)
                      ReorderableDragStartListener(
                        index: index,
                        child: Icon(
                          Icons.drag_indicator,
                          color: Colors.grey.shade400,
                          size: 24,
                        ),
                      ),
                    SizedBox(
                      width: isCompradoSection || isEmFaltaSection ? 0 : 8,
                    ),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: cor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icone, color: cor, size: 20),
                    ),
                    SizedBox(width: 12),
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
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: cor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        '${itens.length}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: cor.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    if (expandable)
                      Icon(
                        expandido
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.grey.shade600,
                        size: 24,
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (expandido)
            Column(
              children: [
                Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
                ...itens.map((item) => _buildItemCard(item)).toList(),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildItemCard(ItemCompra item) {
    Color itemColor;
    if (item.comprado) {
      itemColor = Colors.grey.shade400;
    } else if (item.emFalta) {
      itemColor = Color(0xFFFB8C00);
    } else {
      itemColor = Color(0xFF333333);
    }

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        color: Colors.red.shade400,
        child: Icon(Icons.delete_outline, color: Colors.white, size: 30),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          final bool? res = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
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
                    child: Text("Excluir"),
                  ),
                ],
              );
            },
          );
          return res;
        }
        return false;
      },
      onDismissed: (direction) {
        _deletarItem(item);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: item.comprado
                ? Color(0xFFE8F5E9)
                : item.emFalta
                ? Color(0xFFFFECB3)
                : Colors.grey.shade100,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _marcarComprado(item),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: item.comprado
                          ? Color(0xFF6A994E)
                          : Colors.transparent,
                      border: Border.all(
                        color: item.comprado
                            ? Color(0xFF6A994E)
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: item.comprado
                        ? Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.nome,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: itemColor,
                            decoration: item.comprado
                                ? TextDecoration.lineThrough
                                : null,
                            decorationColor: Colors.grey.shade500,
                            decorationThickness: 1.5,
                          ),
                        ),
                        SizedBox(height: 4),
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
                  if (!item.comprado)
                    IconButton(
                      icon: Icon(
                        item.emFalta
                            ? Icons.warning_amber
                            : Icons.warning_amber_outlined,
                        color: item.emFalta
                            ? Color(0xFFFB8C00)
                            : Colors.grey.shade400,
                        size: 22,
                      ),
                      onPressed: () => _marcarEmFalta(item),
                      tooltip: item.emFalta
                          ? 'Remover de falta'
                          : 'Marcar em falta',
                      padding: EdgeInsets.all(8),
                      constraints: BoxConstraints(),
                    ),
                  IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      color: Colors.blue.shade400,
                      size: 22,
                    ),
                    onPressed: () => _editarItem(item),
                    tooltip: 'Editar item',
                    padding: EdgeInsets.all(8),
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Service Firebase (mantido inalterado, apenas para contexto)
/*
class FirebaseService {
  final String collectionName;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseService({required this.collectionName});

  Future<void> create(Map<String, dynamic> data) async {
    await _firestore.collection(collectionName).add(data);
  }

  Stream<QuerySnapshot> read() {
    return _firestore.collection(collectionName).snapshots();
  }

  Future<List<Map<String, dynamic>>> readAll() async {
    QuerySnapshot querySnapshot = await _firestore.collection(collectionName).get();
    return querySnapshot.docs.map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>}).toList();
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    await _firestore.collection(collectionName).doc(id).update(data);
  }

  Future<void> delete(String id) async {
    await _firestore.collection(collectionName).doc(id).delete();
  }
}
*/
