import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/member_model.dart';

class MemberService {
  final _db = FirebaseFirestore.instance;

  // Stream all members
  Stream<List<MemberModel>> streamMembers() {
    return _db
        .collection('members')
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => MemberModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  // Get single member details
  Future<MemberModel?> getMember(String memberId) async {
    try {
      final doc = await _db.collection('members').doc(memberId).get();
      if (doc.exists && doc.data() != null) {
        return MemberModel.fromMap(doc.data()!, doc.id);
      }
    } catch (e) {
      print('Error getting member: $e');
    }
    return null;
  }

  // Add member
  Future<String> addMember({required String name, required String phone, String? photoUrl}) async {
    final docRef = _db.collection('members').doc();
    final newMember = MemberModel(
      id: docRef.id,
      name: name,
      phone: phone,
      photoUrl: photoUrl,
      points: 0,
      level: 'regular',
      totalVisits: 0,
      totalSpent: 0.0,
      createdAt: DateTime.now(),
    );
    await docRef.set(newMember.toMap());
    return docRef.id;
  }

  // Update member general info
  Future<void> updateMember(MemberModel member) async {
    await _db.collection('members').doc(member.id).set(member.toMap(), SetOptions(merge: true));
  }

  // Delete member
  Future<void> deleteMember(String memberId) async {
    await _db.collection('members').doc(memberId).delete();
  }

  // Update member points, level, totalSpent, and totalVisits after a transaction
  Future<void> recordVisitAndPoints({
    required String memberId,
    required double amountSpent,
    required String sessionId,
  }) async {
    final docRef = _db.collection('members').doc(memberId);

    await _db.runTransaction((transaction) async {
      final docSnapshot = await transaction.get(docRef);
      if (!docSnapshot.exists) return;

      final member = MemberModel.fromMap(docSnapshot.data()!, docSnapshot.id);

      // setiap Rp 1.000 = 1 poin
      final newPointsEarned = (amountSpent / 1000).floor();
      final updatedPoints = member.points + newPointsEarned;
      final updatedVisits = member.totalVisits + 1;
      final updatedSpent = member.totalSpent + amountSpent;

      // Determine level: Regular (0–499) → Silver (500–1.999) → Gold (2.000+)
      String updatedLevel = 'regular';
      if (updatedPoints >= 2000) {
        updatedLevel = 'gold';
      } else if (updatedPoints >= 500) {
        updatedLevel = 'silver';
      }

      transaction.update(docRef, {
        'points': updatedPoints,
        'level': updatedLevel,
        'totalVisits': updatedVisits,
        'totalSpent': updatedSpent,
      });

      // Record in /memberVisits subcollection / standalone collection
      final visitRef = _db.collection('memberVisits').doc();
      transaction.set(visitRef, {
        'memberId': memberId,
        'sessionId': sessionId,
        'date': FieldValue.serverTimestamp(),
        'pointsEarned': newPointsEarned,
        'amountSpent': amountSpent,
      });
    });
  }
}
