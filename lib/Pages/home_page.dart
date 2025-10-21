import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:via_cep_api/Models/endereco_model.dart';
import 'package:via_cep_api/Services/via_cep_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController controllerCep = TextEditingController();
  TextEditingController controllerLogradouro = TextEditingController();
  TextEditingController controllerComplemento = TextEditingController();
  TextEditingController controllerBairro = TextEditingController();
  TextEditingController controllerCidade = TextEditingController();
  TextEditingController controllerEstado = TextEditingController();
  Endereco? endereco; //Variável pode receber null "?"
  bool isLoading = false;

  ViaCepService viaCepService = ViaCepService();

  Future<void> buscarCep(String cep) async {
    clearControllers();
    setState(() {
      isLoading = true;
    });
    try {
      Endereco? response = await viaCepService.buscarEndereco(cep);

      if (response?.localidade == null) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              icon: Icon(Icons.warning),
              title: Text("Atenção"),
              content: Text("Cep não encontrado"),
            );
          },
        );
        controllerCep.clear();
        return;
      }

      setState(() {
        endereco = response;
      });

      setControllersCep(endereco!);
    } catch (erro) {
      throw Exception("Erro ao buscar CEP: $erro");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void setControllersCep(Endereco endereco) {
    controllerLogradouro.text = endereco.logradouro!;
    controllerComplemento.text = endereco.complemento!;
    controllerBairro.text = endereco.bairro!;
    controllerCidade.text = endereco.localidade!;
    controllerEstado.text = endereco.estado!;
  }

  void clearControllers() {
    controllerBairro.clear();
    controllerLogradouro.clear();
    controllerCidade.clear();
    controllerLogradouro.clear();
    controllerEstado.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("ViaCEP Api"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            spacing: 20,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                onChanged: (valor) {
                  if (valor.isEmpty) {
                    setState(() {
                      endereco = null;
                    });
                    clearControllers();
                  }
                },
                controller: controllerCep,
                maxLength: 8,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  suffixIcon: isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : IconButton(
                          onPressed: () {
                            buscarCep(controllerCep.text);
                          },
                          icon: Icon(Icons.search),
                        ),
                  border: OutlineInputBorder(),
                  labelText: "CEP",
                ),
              ),
              if (endereco?.bairro != null)
                Column(
                  spacing: 10,
                  children: [
                    TextField(
                      controller: controllerLogradouro,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Logradouro",
                      ),
                    ),
                    TextField(
                      controller: controllerComplemento,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Complemento",
                      ),
                    ),
                    TextField(
                      controller: controllerBairro,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Bairro",
                      ),
                    ),
                    TextField(
                      controller: controllerCidade,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Cidade",
                      ),
                    ),
                    TextField(
                      controller: controllerEstado,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Estado",
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
