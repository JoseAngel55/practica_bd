class ProductoDAO {
  String? idProducto;
  String? nombre;
  String? descripcion;
  double? precio;
  String? idCategoria;
  String? unidad; 

  ProductoDAO({
    this.idProducto,
    this.nombre,
    this.descripcion,
    this.precio,
    this.idCategoria,
    this.unidad,
  });

  factory ProductoDAO.fromMap(Map<String, dynamic> map, String id) {
    return ProductoDAO(
      idProducto: id,
      nombre: map['nombre'],
      descripcion: map['descripcion'],
      precio: (map['precio'] as num?)?.toDouble(),
      idCategoria: map['idCategoria'],
      unidad: map['unidad'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'idCategoria': idCategoria,
      'unidad': unidad,
    };
  }
}
