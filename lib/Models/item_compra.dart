import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo que representa um item da lista de compras
class ItemCompra {
  final String id;
  final String nome;
  final String quantidade;
  final bool comprado;
  final bool emFalta;
  final String? categoria;
  final DateTime? dataCriacao;
  final DateTime? dataAtualizacao;

  ItemCompra({
    required this.id,
    required this.nome,
    required this.quantidade,
    this.comprado = false,
    this.emFalta = false,
    this.categoria,
    this.dataCriacao,
    this.dataAtualizacao,
  });

  /// Converte o objeto para um Map para salvar no Firebase
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'quantidade': quantidade,
      'comprado': comprado,
      'emFalta': emFalta,
      'categoria': categoria,
      'dataCriacao': dataCriacao ?? FieldValue.serverTimestamp(),
      'dataAtualizacao': FieldValue.serverTimestamp(),
    };
  }

  /// Cria um ItemCompra a partir de um Map do Firebase
  factory ItemCompra.fromMap(Map<String, dynamic> map, String id) {
    return ItemCompra(
      id: id,
      nome: map['nome'] ?? '',
      quantidade: map['quantidade'] ?? '',
      comprado: map['comprado'] ?? false,
      emFalta: map['emFalta'] ?? false,
      categoria: map['categoria'],
      dataCriacao: (map['dataCriacao'] as Timestamp?)?.toDate(),
      dataAtualizacao: (map['dataAtualizacao'] as Timestamp?)?.toDate(),
    );
  }

  /// Cria uma cópia do item com algumas propriedades modificadas
  ItemCompra copyWith({
    String? id,
    String? nome,
    String? quantidade,
    bool? comprado,
    bool? emFalta,
    String? categoria,
    DateTime? dataCriacao,
    DateTime? dataAtualizacao,
  }) {
    return ItemCompra(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      quantidade: quantidade ?? this.quantidade,
      comprado: comprado ?? this.comprado,
      emFalta: emFalta ?? this.emFalta,
      categoria: categoria ?? this.categoria,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataAtualizacao: dataAtualizacao ?? this.dataAtualizacao,
    );
  }

  /// Verifica se o item está pendente (não comprado e não em falta)
  bool get isPendente => !comprado && !emFalta;

  /// Retorna uma representação em String do objeto
  @override
  String toString() {
    return 'ItemCompra(id: $id, nome: $nome, quantidade: $quantidade, '
        'comprado: $comprado, emFalta: $emFalta, categoria: $categoria)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ItemCompra &&
        other.id == id &&
        other.nome == nome &&
        other.quantidade == quantidade &&
        other.comprado == comprado &&
        other.emFalta == emFalta &&
        other.categoria == categoria;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        nome.hashCode ^
        quantidade.hashCode ^
        comprado.hashCode ^
        emFalta.hashCode ^
        (categoria?.hashCode ?? 0);
  }
}
