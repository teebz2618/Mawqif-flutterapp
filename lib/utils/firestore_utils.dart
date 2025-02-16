import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> moveAdminToAdminCollection(String uid) async {
  final firestore = FirebaseFirestore.instance;

  final userDoc = await firestore.collection('users').doc(uid).get();

  if (userDoc.exists) {
    final data = userDoc.data();

    // Copy to 'admin'
    await firestore.collection('admin').doc(uid).set(data!);

    // Delete from 'users'
    await firestore.collection('users').doc(uid).delete();

    print('✅ Admin moved successfully.');
  } else {
    print('❌ No such user document.');
  }
}
