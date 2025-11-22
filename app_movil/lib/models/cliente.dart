class Cliente {
  final int id;
  final int idTipoDocumentoIdentidad;
  final String numeroDocumento;
  final String nombresApellidos;
  final String? direccion;
  final String? codigoUbigeo;
  final String? email;
  final String? telefono;
  final String estado;
  final String? tipoDocumento;

  Cliente({
    required this.id,
    required this.idTipoDocumentoIdentidad,
    required this.numeroDocumento,
    required this.nombresApellidos,
    this.direccion,
    this.codigoUbigeo,
    this.email,
    this.telefono,
    required this.estado,
    this.tipoDocumento,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'],
      idTipoDocumentoIdentidad: json['id_tipo_documento_identidad'] is int
          ? json['id_tipo_documento_identidad']
          : int.tryParse(json['id_tipo_documento_identidad'] ?? '0') ?? 0,
      numeroDocumento: json['numero_documento'] ?? '',
      nombresApellidos: json['nombres_apellidos'] ?? '',
      direccion: json['direccion'],
      codigoUbigeo: json['codigo_ubigeo'],
      email: json['email'],
      telefono: json['telefono'],
      estado: json['estado'] ?? 'Activado',
      tipoDocumento: json['tipo_documento'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_tipo_documento_identidad': idTipoDocumentoIdentidad,
      'numero_documento': numeroDocumento,
      'nombres_apellidos': nombresApellidos,
      'direccion': direccion,
      'codigo_ubigeo': codigoUbigeo,
      'email': email,
      'telefono': telefono,
      'estado': estado,
    };
  }
}
