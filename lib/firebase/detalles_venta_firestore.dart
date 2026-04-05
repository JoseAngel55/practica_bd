import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:practica_bd/models/detalle_venta.dart';

class DetallesVentaFirestore {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference? detallesCollection;

  DetallesVentaFirestore() {
    detallesCollection = _firestore.collection('detalles_venta');
  }

  Future<bool> insertDetalle(Map<String, dynamic> data) async {
    try {
      await detallesCollection!.add(data);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> deleteDetallesByVenta(String idVenta) async {
    try {
      final snap = await detallesCollection!
          .where('idVenta', isEqualTo: idVenta)
          .get();
      for (var doc in snap.docs) {
        await doc.reference.delete();
      }
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<List<DetalleVentaDAO>> getDetallesByVenta(String idVenta) async {
    try {
      final snap = await detallesCollection!
          .where('idVenta', isEqualTo: idVenta)
          .get();
      return snap.docs
          .map((d) =>
              DetalleVentaDAO.fromMap(d.data() as Map<String, dynamic>, d.id))
          .toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  Stream<QuerySnapshot> streamDetallesByVenta(String idVenta) {
    return detallesCollection!
        .where('idVenta', isEqualTo: idVenta)
        .snapshots();
  }
}
