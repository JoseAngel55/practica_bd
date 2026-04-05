class DetalleVentaDAO {
  String? idDetalle;
  String? idVenta;
  String? idProducto;
  String? nombreProducto;
  double? precioUnitario;
  int? cantidad;
  double? subtotal;

  DetalleVentaDAO({
    this.idDetalle,
    this.idVenta,
    this.idProducto,
    this.nombreProducto,
    this.precioUnitario,
    this.cantidad,
    this.subtotal,
  });

  factory DetalleVentaDAO.fromMap(Map<String, dynamic> map, String id) {
    return DetalleVentaDAO(
      idDetalle: id,
      idVenta: map['idVenta'],
      idProducto: map['idProducto'],
      nombreProducto: map['nombreProducto'],
      precioUnitario: (map['precioUnitario'] as num?)?.toDouble(),
      cantidad: map['cantidad'],
      subtotal: (map['subtotal'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idVenta': idVenta,
      'idProducto': idProducto,
      'nombreProducto': nombreProducto,
      'precioUnitario': precioUnitario,
      'cantidad': cantidad,
      'subtotal': subtotal,
    };
  }
}

class CarritoItem {
  final String idProducto;
  final String nombreProducto;
  final double precioUnitario;
  int cantidad;
  final String unidad;

  CarritoItem({
    required this.idProducto,
    required this.nombreProducto,
    required this.precioUnitario,
    required this.cantidad,
    required this.unidad,
  });

  double get subtotal => precioUnitario * cantidad;
}
