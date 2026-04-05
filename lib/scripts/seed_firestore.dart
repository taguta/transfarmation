import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/farm/presentation/providers/farm_providers.dart';
import '../features/inputs/presentation/providers/input_providers.dart';
import '../features/savings/presentation/providers/savings_providers.dart';
import '../features/notifications/presentation/providers/notification_providers.dart';

/// A utility script to save current in-memory mock data to Firestore.
/// You can call this function from a hidden developer button or a temporary
/// ElevatedButton in the HomeScreen during development.
Future<void> seedMockDataToFirestore() async {
  final firestore = FirebaseFirestore.instance;
  final container = ProviderContainer();

  try {
    print('Seeding inputs...');
    final inputs = await container.read(inputsProvider.future);
    final inputBatch = firestore.batch();
    for (var input in inputs) {
      final doc = firestore.collection('inputs').doc(input.id);
      inputBatch.set(doc, {
        'id': input.id,
        'name': input.name,
        'category': input.category,
        'supplier': input.supplier,
        'description': input.description,
        'price': input.price,
        'unit': input.unit,
        'bulkPrice': input.bulkPrice,
        'bulkMinQuantity': input.bulkMinQuantity,
        'isVerified': input.isVerified,
        'inStock': input.inStock,
      });
    }
    await inputBatch.commit();
    print('Successfully seeded ${inputs.length} inputs.');

    print('Seeding savings groups...');
    final groups = await container.read(savingsGroupsProvider.future);
    final groupBatch = firestore.batch();
    for (var group in groups) {
      final doc = firestore.collection('savings_groups').doc(group.id);
      groupBatch.set(doc, {
        'id': group.id,
        'name': group.name,
        'description': group.description,
        'contributionAmount': group.contributionAmount,
        'frequency': group.frequency,
        'memberCount': group.memberCount,
        'maxMembers': group.maxMembers,
        'status': group.status,
        'nextPayoutDate': group.nextPayoutDate.toIso8601String(),
        'nextRecipient': group.nextRecipient,
        'totalPool': group.totalPool,
        'members':
            group.members
                .map(
                  (m) => {
                    'id': m.id,
                    'name': m.name,
                    'payoutOrder': m.payoutOrder,
                    'hasReceivedPayout': m.hasReceivedPayout,
                    'totalContributed': m.totalContributed,
                    'isCurrentPayer': m.isCurrentPayer,
                  },
                )
                .toList(),
      });
    }
    await groupBatch.commit();
    print('Successfully seeded ${groups.length} savings groups.');

    print('Seeding farm data...');
    final farm = await container.read(farmProvider.future);
    await firestore.collection('farms').doc(farm.id).set({
      'id': farm.id,
      'farmerId': farm.farmerId,
      'name': farm.name,
      'province': farm.province,
      'sizeHectares': farm.sizeHectares,
      'farmingMethod': farm.farmingMethod.toString(),
      'crops':
          farm.crops
              .map(
                (c) => {
                  'id': c.id,
                  'cropName': c.cropName,
                  'areHectares': c.areHectares,
                  'status': c.status.toString(),
                  'plantedDate': c.plantedDate.toIso8601String(),
                  'expectedHarvest': c.expectedHarvest?.toIso8601String(),
                  'expectedYield': c.expectedYield,
                  'actualYield': c.actualYield,
                  'notes': c.notes,
                },
              )
              .toList(),
      'livestock':
          farm.livestock
              .map(
                (l) => {
                  'id': l.id,
                  'type': l.type,
                  'count': l.count,
                  'healthStatus': l.healthStatus,
                },
              )
              .toList(),
    });
    print('Successfully seeded farm data.');

    print('Seeding notifications...');
    final notifications = await container.read(notificationProvider.future);
    final notificationBatch = firestore.batch();
    for (var n in notifications) {
      final doc = firestore.collection('notifications').doc(n.id);
      notificationBatch.set(doc, {
        'id': n.id,
        'title': n.title,
        'body': n.body,
        'timestamp': n.timestamp.toIso8601String(),
        'type': n.type.toString(),
        'isRead': n.isRead,
        'actionRoute': n.actionRoute,
      });
    }
    await notificationBatch.commit();
    print('Successfully seeded ${notifications.length} notifications.');

    print('Seeding experts...');
    final expertBatch = firestore.batch();
    final experts = [
      {
        'id': 'exp-1',
        'name': 'Dr. Chipo Nyathi',
        'specialization': 'Agronomist · Crop Science',
        'rating': 4.8,
        'reviewsCount': 124,
        'consultationFee': 15.0,
        'isAvailable': true,
      },
      {
        'id': 'exp-2',
        'name': 'Eng. Tapiwa Moyo',
        'specialization': 'Irrigation & Water Management',
        'rating': 4.6,
        'reviewsCount': 89,
        'consultationFee': 25.0,
        'isAvailable': true,
      },
      {
        'id': 'exp-3',
        'name': 'Dr. Rumbidzai Mhandu',
        'specialization': 'Veterinary · Livestock Health',
        'rating': 4.9,
        'reviewsCount': 210,
        'consultationFee': 20.0,
        'isAvailable': false,
      },
      {
        'id': 'exp-4',
        'name': 'Mr. Blessing Chirwa',
        'specialization': 'Soil Science & Fertilizers',
        'rating': 4.5,
        'reviewsCount': 45,
        'consultationFee': 10.0,
        'isAvailable': false,
      },
    ];

    for (var exp in experts) {
      final doc = firestore.collection('experts').doc(exp['id'] as String);
      expertBatch.set(doc, exp);
    }
    await expertBatch.commit();
    print('Successfully seeded ${experts.length} experts.');

    print('Seeding marketplace products...');
    final productBatch = firestore.batch();
    final products = [
      {
        'id': 'prod-1',
        'sellerId': 'user-123',
        'title': 'Organic Tomatoes',
        'description': 'Freshly harvested organic tomatoes from Field Alpha. High quality, zero pesticides.',
        'price': 12.50,
        'category': 'Vegetables',
        'imageUrls': <String>[],
        'postedAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      },
      {
        'id': 'prod-2',
        'sellerId': 'user-456',
        'title': 'Premium Maize Seeds',
        'description': 'Drought-resistant maize seeds suitable for arid regions. 10kg bag.',
        'price': 45.00,
        'category': 'Seeds',
        'imageUrls': <String>[],
        'postedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'prod-3',
        'sellerId': 'user-789',
        'title': 'NPK Fertilizer 50kg',
        'description': 'Standard NPK fertilizer to boost your yields. Delivery available within 50km.',
        'price': 30.00,
        'category': 'Agro-Chemicals',
        'imageUrls': <String>[],
        'postedAt': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
      },
    ];

    for (var prod in products) {
      final doc = firestore.collection('products').doc(prod['id'] as String);
      productBatch.set(doc, prod);
    }
    await productBatch.commit();
    print('Successfully seeded ${products.length} marketplace products.');

    print('Mock data seeding complete!');
  } catch (e) {
    print('Failed to seed: $e');
  } finally {
    container.dispose();
  }
}
