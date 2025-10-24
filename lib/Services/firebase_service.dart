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

  Future<void> delete(String id) async {
    await _firestore.collection(collectionName).doc(id).delete();
  }

  Future<void> update(String id, Map<String, dynamic> dados) async {
    try {
      await _firestore.collection(collectionName).doc(id).update(dados);
    } catch (erro) {
      throw Exception("Erro ao atualizar o documento: $erro");
    }
  }

  /// Limpa toda a coleção de uma só vez usando batch
  /// Mais eficiente que deletar um por um
  Future<void> clearCollection() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(collectionName)
          .get();

      if (snapshot.docs.isEmpty) {
        return; // Nada para deletar
      }

      // Usa WriteBatch para operação atômica e mais rápida
      WriteBatch batch = _firestore.batch();

      for (DocumentSnapshot doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      // Executa todas as deleções de uma vez
      await batch.commit();
    } catch (erro) {
      throw Exception("Erro ao limpar a coleção: $erro");
    }
  }

  /// Limpa toda a coleção em lotes (para coleções muito grandes)
  /// Recomendado para coleções com mais de 500 documentos
  Future<void> clearCollectionInBatches({int batchSize = 500}) async {
    try {
      bool hasMore = true;

      while (hasMore) {
        final QuerySnapshot snapshot = await _firestore
            .collection(collectionName)
            .limit(batchSize)
            .get();

        if (snapshot.docs.isEmpty) {
          hasMore = false;
          break;
        }

        WriteBatch batch = _firestore.batch();

        for (DocumentSnapshot doc in snapshot.docs) {
          batch.delete(doc.reference);
        }

        await batch.commit();

        // Se retornou menos que o limite, acabou
        if (snapshot.docs.length < batchSize) {
          hasMore = false;
        }
      }
    } catch (erro) {
      throw Exception("Erro ao limpar a coleção em lotes: $erro");
    }
  }
}
