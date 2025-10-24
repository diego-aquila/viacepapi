import 'package:via_cep_api/Data/produtos_database.dart';

/// Service responsável por fornecer sugestões de produtos
class SugestoesService {
  /// Retorna até 8 sugestões baseadas no texto digitado
  static List<String> obterSugestoes(String texto, {int maxSugestoes = 8}) {
    if (texto.isEmpty) return [];

    final sugestoes = ProdutosDatabase.buscarProdutos(texto);
    return sugestoes.take(maxSugestoes).toList();
  }

  /// Detecta automaticamente a categoria de um produto
  static String? detectarCategoriaProduto(String nomeProduto) {
    return ProdutosDatabase.detectarCategoria(nomeProduto);
  }

  /// Verifica se um produto existe na base de dados
  static bool produtoExiste(String nomeProduto) {
    return ProdutosDatabase.detectarCategoria(nomeProduto) != null;
  }

  /// Obtém produtos similares (mesmo começo de nome)
  static List<String> obterProdutosSimilares(
    String nomeProduto, {
    int max = 5,
  }) {
    if (nomeProduto.isEmpty) return [];

    final palavraInicial = nomeProduto.split(' ').first.toLowerCase();
    final sugestoes = ProdutosDatabase.buscarProdutos(palavraInicial);

    return sugestoes
        .where((p) => p.toLowerCase() != nomeProduto.toLowerCase())
        .take(max)
        .toList();
  }
}
