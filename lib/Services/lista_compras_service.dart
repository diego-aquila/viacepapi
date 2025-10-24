import '../models/item_compra.dart';

/// Service com lógica de negócio para manipulação de listas de compras
class ListaComprasService {
  /// Agrupa itens por categoria
  static Map<String, List<ItemCompra>> agruparPorCategoria(
    List<ItemCompra> itens,
  ) {
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

  /// Separa itens em três grupos: pendentes, em falta e comprados
  static Map<String, Map<String, List<ItemCompra>>> separarPorStatus(
    List<ItemCompra> itens,
  ) {
    final grupos = agruparPorCategoria(itens);

    final gruposPendentes = <String, List<ItemCompra>>{};
    final gruposEmFalta = <String, List<ItemCompra>>{};
    final gruposComprados = <String, List<ItemCompra>>{};

    grupos.forEach((categoria, itensCategoria) {
      final pendentes = itensCategoria
          .where((i) => !i.comprado && !i.emFalta)
          .toList();
      final emFalta = itensCategoria
          .where((i) => i.emFalta && !i.comprado)
          .toList();
      final comprados = itensCategoria
          .where((i) => i.comprado)
          .toList();

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

    return {
      'pendentes': gruposPendentes,
      'emFalta': gruposEmFalta,
      'comprados': gruposComprados,
    };
  }

  /// Ordena itens por status e categoria
  static List<ItemCompra> ordenarItens(List<ItemCompra> itens) {
    final itensCopia = List<ItemCompra>.from(itens);

    itensCopia.sort((a, b) {
      // Primeiro ordena por status (não comprados antes de comprados)
      if (a.comprado != b.comprado) {
        return a.comprado ? 1 : -1;
      }

      // Depois ordena por em falta (em falta por último entre não comprados)
      if (a.emFalta != b.emFalta) {
        return a.emFalta ? 1 : -1;
      }

      // Por fim ordena por categoria
      final catA = a.categoria ?? 'Outros';
      final catB = b.categoria ?? 'Outros';
      return catA.compareTo(catB);
    });

    return itensCopia;
  }

  /// Conta itens por status
  static Map<String, int> contarPorStatus(List<ItemCompra> itens) {
    int pendentes = 0;
    int emFalta = 0;
    int comprados = 0;

    for (var item in itens) {
      if (item.comprado) {
        comprados++;
      } else if (item.emFalta) {
        emFalta++;
      } else {
        pendentes++;
      }
    }

    return {
      'pendentes': pendentes,
      'emFalta': emFalta,
      'comprados': comprados,
      'total': itens.length,
    };
  }

  /// Calcula o progresso de compras (0.0 a 1.0)
  static double calcularProgresso(List<ItemCompra> itens) {
    if (itens.isEmpty) return 0.0;

    final comprados = itens.where((i) => i.comprado).length;
    return comprados / itens.length;
  }

  /// Valida se um item pode ser adicionado
  static String? validarNovoItem({
    required String nome,
    required String quantidade,
  }) {
    if (nome.trim().isEmpty) {
      return 'Informe o nome do item';
    }

    if (quantidade.trim().isEmpty) {
      return 'Informe a quantidade';
    }

    return null; // Válido
  }

  /// Verifica se já existe um item com mesmo nome (case-insensitive)
  static bool itemJaExiste(List<ItemCompra> itens, String nome) {
    final nomeLower = nome.toLowerCase().trim();
    return itens.any((item) => 
      item.nome.toLowerCase().trim() == nomeLower && !item.comprado
    );
  }

  /// Filtra itens por texto de busca
  static List<ItemCompra> filtrarItens(
    List<ItemCompra> itens,
    String textoBusca,
  ) {
    if (textoBusca.isEmpty) return itens;

    final busca = textoBusca.toLowerCase().trim();
    return itens.where((item) {
      return item.nome.toLowerCase().contains(busca) ||
          item.quantidade.toLowerCase().contains(busca) ||
          (item.categoria?.toLowerCase().contains(busca) ?? false);
    }).toList();
  }
}
