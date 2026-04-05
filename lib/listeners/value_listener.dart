import 'package:flutter/material.dart';
import 'package:practica_bd/models/detalle_venta.dart';

class ValueListener {
  static final ValueNotifier<bool> refreshVentas = ValueNotifier(false);
  static final ValueNotifier<bool> refreshCategorias = ValueNotifier(false);
  static final ValueNotifier<bool> refreshProductos = ValueNotifier(false);
  static final ValueNotifier<List<CarritoItem>> carrito =
      ValueNotifier<List<CarritoItem>>([]);

  static int get totalItemsCarrito {
    return carrito.value.fold(0, (sum, item) => sum + item.cantidad);
  }

  static void agregarAlCarrito(CarritoItem item) {
    final lista = List<CarritoItem>.from(carrito.value);
    final idx = lista.indexWhere((e) => e.idProducto == item.idProducto);
    if (idx >= 0) {
      lista[idx].cantidad += item.cantidad;
    } else {
      lista.add(item);
    }
    carrito.value = lista;
  }

  static void quitarDelCarrito(String idProducto) {
    final lista = List<CarritoItem>.from(carrito.value);
    lista.removeWhere((e) => e.idProducto == idProducto);
    carrito.value = lista;
  }

  static void limpiarCarrito() {
    carrito.value = [];
  }

  static double get totalCarrito {
    return carrito.value.fold(0.0, (sum, item) => sum + item.subtotal);
  }
}
