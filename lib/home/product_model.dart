class ProductModel {
  final String id;
  final String name;
  final num priceBefore;
  final num priceAfter;

  ProductModel({
    required this.id,
    required this.name,
    required this.priceBefore,
    required this.priceAfter,
  });

//  factory ProductModel.fromMap(Map<String, dynamic> data) {
//     return ProductModel(
//       name: data['name'] ?? '',
//       id: data['id'] ?? '',
//       priceBefore: (data['priceBefore'] as num).toDouble(), // Handles both int & double
//       priceAfter: (data['priceAfter'] as num).toDouble(),  // Handles both int & double
//     );
//   }
}
