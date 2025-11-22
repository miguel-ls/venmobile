class TipoDocumentoIdentidad {
  final int id;
  final String nombre;

  TipoDocumentoIdentidad({required this.id, required this.nombre});

  factory TipoDocumentoIdentidad.fromJson(Map<String, dynamic> json) {
    return TipoDocumentoIdentidad(
      id: json['id'],
      nombre: json['nombre'],
    );
  }
}
