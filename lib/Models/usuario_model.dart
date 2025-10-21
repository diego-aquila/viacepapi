class Usuario {
  final String id;
  final String nome;
  final String email;
  final String telefone;
  final String cpf;
  final String senha;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.cpf,
    required this.senha,
  });

  Map<String, dynamic> toMap() {
    return {
      "nome": nome,
      "email": email,
      "telefone": telefone,
      "senha": senha,
      "cpf": cpf,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map, String idUser) {
    return Usuario(
      id: idUser,
      nome: map["nome"],
      email: map["email"],
      telefone: map["telefone"],
      senha: map["senha"],
      cpf: map["cpf"],
    );
  }
}
