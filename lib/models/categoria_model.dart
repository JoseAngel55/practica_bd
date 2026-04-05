class CategoriaDAO {
  String? idCategoria;
  String? nombre;
  String? descripcion;
  String? icono; 
  String? color;

  CategoriaDAO({
    this.idCategoria,
    this.nombre,
    this.descripcion,
    this.icono,
    this.color,
  });

  factory CategoriaDAO.fromMap(Map<String, dynamic> map, String id) {
    return CategoriaDAO(
      idCategoria: id,
      nombre: map['nombre'],
      descripcion: map['descripcion'],
      icono: map['icono'],
      color: map['color'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'icono': icono,
      'color': color,
    };
  }
}
