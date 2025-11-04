import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  StreamController? _connectivityController;

  void initialize() {
    _connectivityController = StreamController.broadcast();

    checkconnectivity();

    _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> listResult,
    ) {
      _verifyConnectionStatus(listResult);
    });
  }

  Future<bool> checkconnectivity() async {
    try {
      List<ConnectivityResult> listResult = await _connectivity
          .checkConnectivity();

      bool resultStatusConnection = _verifyConnectionStatus(listResult);
      return resultStatusConnection;
    } catch (e) {
      throw Exception("Erro ao checar conectividade do usuário");
    }
  }

  bool _verifyConnectionStatus(List<ConnectivityResult> listResult) {
    if (listResult.contains(ConnectivityResult.none) &&
        listResult.length == 1) {
      print("Sem internet");

      _connectivityController?.add(false);

      return false;
    }

    print("Conectado");

    for (var result in listResult) {
      if (result == ConnectivityResult.wifi) {
        print("Wifi está ativo");
      }
      if (result == ConnectivityResult.mobile) {
        print("Dados móveis está ativo");
      }
    }
    _connectivityController?.add(true);
    return true;
  }

  Stream get connectivityStream {
    if (_connectivityController == null) {
      initialize();
    }

    return _connectivityController!.stream;
  }

  void dispose() {
    _connectivityController?.close();
  }
}
