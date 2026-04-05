import 'package:cloud_firestore/cloud_firestore.dart';

class ProductosFirestore {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference? productosCollection;

  ProductosFirestore() {
    productosCollection = _firestore.collection('productos');
  }

  Future<bool> insertProducto(Map<String, dynamic> data) async {
    try {
      await productosCollection!.add(data);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> updateProducto(String id, Map<String, dynamic> data) async {
    try {
      await productosCollection!.doc(id).update(data);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> deleteProducto(String id) async {
    try {
      await productosCollection!.doc(id).delete();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Stream<QuerySnapshot> getProductos() {
    return productosCollection!.orderBy('nombre').snapshots();
  }

  Stream<QuerySnapshot> getProductosByCategoria(String idCategoria) {
    return productosCollection!
        .where('idCategoria', isEqualTo: idCategoria)
        .snapshots();
  }
}
