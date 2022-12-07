import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  late final String productName;
  late final String productDescription;
  late final List<dynamic> productImage;
  late final int productNumLikes;
  late final int productPrice;
  late final int productQuantities;
  late final String productType;

  ProductModel({required this.productName,
    required this.productDescription,
    required this.productImage,
    required this.productNumLikes,
    required this.productPrice,
    required this.productQuantities,
    required this.productType});

  Map<String, dynamic> toMap() {
    return {
      'productName': productName,
      'productDescription': productDescription,
      'productImage': productImage,
      'productNumLikes': productNumLikes,
      'productPrice': productPrice,
      'productQuantities': productQuantities,
      'productType': productType};
  }

  ProductModel.fromDocumentSnapshot(DocumentSnapshot<Map<dynamic, dynamic>> doc)
      : productName = doc.data()!['productName'],
        productImage = doc.data()!['productImage'],
        productDescription = doc.data()!['productDescription'],
        productQuantities = doc.data()!['productQuantities'],
        productNumLikes = doc.data()!['productNumLikes'],
        productPrice = doc.data()!['productPrice'],
        productType = doc.data()!['productType'];
}

