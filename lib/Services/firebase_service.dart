import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final String collectionName;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseService({required this.collectionName});

  Future<String> create(Map<String, dynamic> dados) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(collectionName)
          .add(dados);

      return docRef.id;
    } catch (erro) {
      throw Exception("Erro ao criar o documento: $erro");
    }
  }

  Future<List<Map<String, dynamic>>> readAll() async {
    try {
      final query = await _firestore.collection(collectionName).get();
      return query.docs.map((doc) => {"id": doc.id, ...doc.data()}).toList();
    } catch (erro) {
      throw Exception("Erro ao buscar documentos: $erro");
    }
  }

  Future<Map<String, dynamic>?> readById(String id) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(collectionName)
          .doc(id)
          .get();

      return doc.exists ? doc.data() as Map<String, dynamic> : null;
    } catch (erro) {
      throw Exception("Erro ao buscar o documento selecionado: $erro");
    }
  }

  Future<bool> delete(String id) async {
    try {
      await _firestore.collection(collectionName).doc(id).delete();

      if (await readById(id) != null) {
        return false;
      }

      return true;
    } catch (erro) {
      throw Exception("Erro ao deletar o documento: $erro ");
    }
  }

  Future<void> update(String id, Map<String, dynamic> dados) async {
    try {
      await _firestore.collection(collectionName).doc(id).update(dados);
    } catch (erro) {
      throw Exception("Erro ao atualizar o documento: $erro");
    }
  }
}
