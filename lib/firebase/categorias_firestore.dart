import 'package:cloud_firestore/cloud_firestore.dart';

class CategoriasFirestore {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference? categoriasCollection;

  CategoriasFirestore() {
    categoriasCollection = _firestore.collection('categorias');
  }

  Future<bool> insertCategoria(Map<String, dynamic> data) async {
    try {
      await categoriasCollection!.add(data);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> updateCategoria(String id, Map<String, dynamic> data) async {
    try {
      await categoriasCollection!.doc(id).update(data);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> deleteCategoria(String id) async {
    try {
      await categoriasCollection!.doc(id).delete();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Stream<QuerySnapshot> getCategorias() {
    return categoriasCollection!.orderBy('nombre').snapshots();
  }
}
