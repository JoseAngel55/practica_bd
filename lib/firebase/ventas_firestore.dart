import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:practica_bd/models/venta_model.dart';

class VentasFirestore {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference? ventasCollection;

  VentasFirestore() {
    ventasCollection = _firestore.collection('ventas');
  }

  Future<String?> insertVenta(Map<String, dynamic> data) async {
    try {
      final doc = await ventasCollection!.add(data);
      return doc.id;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<bool> updateVenta(String id, Map<String, dynamic> data) async {
    try {
      await ventasCollection!.doc(id).update(data);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> deleteVenta(String id) async {
    try {
      await ventasCollection!.doc(id).delete();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Stream<QuerySnapshot> getVentas(String idUsuario) {
    return ventasCollection!
        .where('idUsuario', isEqualTo: idUsuario)
        .orderBy('fechaEntrega')
        .snapshots();
  }

  Stream<QuerySnapshot> getVentasByEstatus(String idUsuario, String status) {
    return ventasCollection!
        .where('idUsuario', isEqualTo: idUsuario)
        .where('status', isEqualTo: status)
        .snapshots();
  }

  Future<List<VentaDAO>> getVentasByFecha(
      String idUsuario, String fecha) async {
    try {
      final snap = await ventasCollection!
          .where('idUsuario', isEqualTo: idUsuario)
          .where('fechaEntrega', isEqualTo: fecha)
          .get();
      return snap.docs
          .map((d) => VentaDAO.fromMap(d.data() as Map<String, dynamic>, d.id))
          .toList();
    } catch (e) {
      print(e);
      return [];
    }
  }
}
