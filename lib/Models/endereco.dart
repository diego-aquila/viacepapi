class Endereco {
  String? cep;
  String? logradouro;
  String? complemento;
  String? bairro;
  String? localidade;
  String? uf;
  String? estado;

  Endereco({
    this.cep,
    this.logradouro,
    this.complemento,
    this.bairro,
    this.estado,
    this.localidade,
    this.uf,
  });

  factory Endereco.fromJson(Map<String, dynamic> json) {
    return Endereco(
      cep: json["cep"],
      logradouro: json["logradouro"],
      complemento: json["complemento"],
      bairro: json["bairro"],
      estado: json["estado"],
      localidade: json["localidade"],
      uf: json["uf"],
    );
  }
}
