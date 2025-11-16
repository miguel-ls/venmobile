class TipoCambio {
  final int? id;
  final String fecha;
  final double compra;
  final double venta;
  final String moneda;

  TipoCambio({this.id, required this.fecha, required this.compra, required this.venta, required this.moneda});

  factory TipoCambio.fromJson(Map<String, dynamic> json) {
    return TipoCambio(
      id: json['id'],
      fecha: json['fecha'],
      compra: json['compra'].toDouble(),
      venta: json['venta'].toDouble(),
      moneda: json['moneda'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fecha': fecha,
      'compra': compra,
      'venta': venta,
      'moneda': moneda,
    };
  }
}
