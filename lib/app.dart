import 'package:flutter/material.dart';
import 'package:via_cep_api/Pages/lista_compras_page_refatorada.dart';

class ViaCepApi extends StatelessWidget {
  const ViaCepApi({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const ListaComprasPage(),
    );
  }
}
