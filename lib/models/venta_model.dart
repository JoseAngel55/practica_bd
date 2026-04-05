class VentaDAO {
  String? idVenta;
  String? nombreCliente;
  String? telefonoCliente;
  String? tipo; 
  String? status; 
  String? fechaEntrega;
  String? notas;
  double? total;
  String? idUsuario;
  DateTime? fechaCreacion;

  VentaDAO({
    this.idVenta,
    this.nombreCliente,
    this.telefonoCliente,
    this.tipo,
    this.status,
    this.fechaEntrega,
    this.notas,
    this.total,
    this.idUsuario,
    this.fechaCreacion,
  });

  factory VentaDAO.fromMap(Map<String, dynamic> map, String id) {
    return VentaDAO(
      idVenta: id,
      nombreCliente: map['nombreCliente'],
      telefonoCliente: map['telefonoCliente'],
      tipo: map['tipo'],
      status: map['status'],
      fechaEntrega: map['fechaEntrega'],
      notas: map['notas'],
      total: (map['total'] as num?)?.toDouble(),
      idUsuario: map['idUsuario'],
      fechaCreacion: map['fechaCreacion'] != null
          ? DateTime.tryParse(map['fechaCreacion'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombreCliente': nombreCliente,
      'telefonoCliente': telefonoCliente,
      'tipo': tipo,
      'status': status,
      'fechaEntrega': fechaEntrega,
      'notas': notas,
      'total': total,
      'idUsuario': idUsuario,
      'fechaCreacion':
          fechaCreacion?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }
}
