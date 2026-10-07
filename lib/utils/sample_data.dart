import '../models/product_model.dart';

class SampleData {
  static List<ProductModel> get sampleProducts => [
    ProductModel(
      id: 'prod_elec_01',
      name: 'Wireless Noise-Canceling Headphones',
      price: 199.99,
      description:
          'Experience studio-grade acoustics and industry-leading active noise cancellation. 40-hour battery life with ultra-plush memory foam earcups.',
      imageUrl:
          'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=800&q=80',
      category: 'Electronics',
      rating: 4.8,
      stock: 25,
      reviewCount: 142,
      isFeatured: true,
    ),
    ProductModel(
      id: 'prod_elec_02',
      name: 'Ultra HD AMOLED Smart Watch Series 8',
      price: 149.50,
      description:
          'All-day health tracker with SpO2, continuous heart rate, GPS route tracking, and water resistance up to 50 meters.',
      imageUrl:
          'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=800&q=80',
      category: 'Electronics',
      rating: 4.6,
      stock: 40,
      reviewCount: 98,
      isFeatured: true,
    ),
    ProductModel(
      id: 'prod_fash_01',
      name: 'Minimalist Heavyweight Cotton Hoodie',
      price: 49.99,
      description:
          'Crafted from 100% organic combed cotton with French terry fleece lining. Tailored modern fit with reinforced seams.',
      imageUrl:
          'https://images.unsplash.com/photo-1556905055-8f358a7a47b2?auto=format&fit=crop&w=800&q=80',
      category: 'Fashion',
      rating: 4.7,
      stock: 60,
      reviewCount: 76,
      isFeatured: false,
    ),
    ProductModel(
      id: 'prod_fash_02',
      name: 'Classic Vintage Denim Jacket',
      price: 89.00,
      description:
          'Timeless indigo denim with durable brass hardware. Pre-shrunk premium weave offering comfort and unmatched street style.',
      imageUrl:
          'https://images.unsplash.com/photo-1576995853123-5a10305d93c0?auto=format&fit=crop&w=800&q=80',
      category: 'Fashion',
      rating: 4.5,
      stock: 30,
      reviewCount: 54,
      isFeatured: false,
    ),
    ProductModel(
      id: 'prod_home_01',
      name: 'Ergonomic Solid Oak Desk Organizer',
      price: 64.00,
      description:
          'Handcrafted solid white oak organizer with dedicated slots for tablet, phone, stationery, and wireless charging pad.',
      imageUrl:
          'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?auto=format&fit=crop&w=800&q=80',
      category: 'Home & Living',
      rating: 4.9,
      stock: 18,
      reviewCount: 89,
      isFeatured: true,
    ),
    ProductModel(
      id: 'prod_home_02',
      name: 'Ceramic Ultrasonic Aroma Diffuser',
      price: 34.99,
      description:
          'Handmade matte ceramic stone diffuser with whisper-quiet ultrasound misting and warm ambient LED night lamp.',
      imageUrl:
          'https://images.unsplash.com/photo-1608571423902-eed4a5ad8108?auto=format&fit=crop&w=800&q=80',
      category: 'Home & Living',
      rating: 4.4,
      stock: 50,
      reviewCount: 39,
      isFeatured: false,
    ),
    ProductModel(
      id: 'prod_book_01',
      name: 'Clean Code & System Architecture',
      price: 39.99,
      description:
          'A handbook of agile software craftsmanship. Master scalable design patterns, SOLID principles, and test-driven development.',
      imageUrl:
          'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&w=800&q=80',
      category: 'Books',
      rating: 4.9,
      stock: 80,
      reviewCount: 210,
      isFeatured: true,
    ),
    ProductModel(
      id: 'prod_book_02',
      name: 'Flutter & Dart: The Complete Guide',
      price: 44.50,
      description:
          'The definitive guide to building cross-platform native iOS and Android apps with beautiful Material 3 interfaces.',
      imageUrl:
          'https://images.unsplash.com/photo-1532012164546-f432f2e3777f?auto=format&fit=crop&w=800&q=80',
      category: 'Books',
      rating: 4.8,
      stock: 100,
      reviewCount: 165,
      isFeatured: false,
    ),
    ProductModel(
      id: 'prod_beau_01',
      name: 'Organic Vitamin C Glow Serum',
      price: 28.00,
      description:
          'Infused with 20% pure vitamin C, hyaluronic acid, and ferulic acid to brighten complexion and boost collagen synthesis.',
      imageUrl:
          'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=800&q=80',
      category: 'Beauty',
      rating: 4.6,
      stock: 45,
      reviewCount: 112,
      isFeatured: false,
    ),
    ProductModel(
      id: 'prod_beau_02',
      name: 'Luxury Botanical Hydrating Cream',
      price: 42.00,
      description:
          'Deep restoring peptide moisturizer formulated with shea butter, squalane, and green tea polyphenols for radiant skin.',
      imageUrl:
          'https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=800&q=80',
      category: 'Beauty',
      rating: 4.7,
      stock: 35,
      reviewCount: 88,
      isFeatured: false,
    ),
    ProductModel(
      id: 'prod_spor_01',
      name: 'Pro Non-Slip Alignment Yoga Mat',
      price: 29.99,
      description:
          'Eco-friendly natural rubber base with laser-engraved alignment lines. 6mm thick cushioning to protect knees and joints.',
      imageUrl:
          'https://images.unsplash.com/photo-1601925260368-ae2f83cf8b7f?auto=format&fit=crop&w=800&q=80',
      category: 'Sports',
      rating: 4.8,
      stock: 70,
      reviewCount: 130,
      isFeatured: false,
    ),
    ProductModel(
      id: 'prod_spor_02',
      name: 'Adjustable Steel Dumbbell 20kg Set',
      price: 119.00,
      description:
          'Quick-change weight selector ranging from 2.5kg to 20kg per dumbbell with diamond-knurled non-slip steel handle.',
      imageUrl:
          'https://images.unsplash.com/photo-1584735935682-2f2b69dff9d2?auto=format&fit=crop&w=800&q=80',
      category: 'Sports',
      rating: 4.9,
      stock: 20,
      reviewCount: 94,
      isFeatured: true,
    ),
  ];
}
