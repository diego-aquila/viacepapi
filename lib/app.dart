import 'package:flutter/material.dart';
import 'package:via_cep_api/Pages/app_compras_page.dart';
import 'package:via_cep_api/Pages/form_cadastro_usuario_page.dart';
import 'package:via_cep_api/Pages/form_create_user_page.dart';
import 'package:via_cep_api/Pages/home_page.dart';

class ViaCepApi extends StatelessWidget {
  const ViaCepApi({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const FormCadastroUsuarioPage(),
    );
  }
}
