class Order {
  final String id;
  final String productId;
  final int quantity;
  final double total;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.total,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['ID'],
      productId: json['ProductID'],
      quantity: json['Quantity'],
      total: double.parse(json['Total'].toString()),
      createdAt: DateTime.parse(json['CreatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ProductID': productId,
      'Quantity': quantity,
      'Total': total
    };
  }
}
