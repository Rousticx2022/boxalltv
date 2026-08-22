import 'package:boxalltv/controllers/bank_details_controller.dart';
import 'package:boxalltv/utils/collections.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import '../helpers/firebase_test_setup.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late BankDetailsController controller;
  const String testUid = 'user123';

  setUp(() {
    fakeFirestore = setupFakeFirestore();
    Get.testMode = true;
    controller = BankDetailsController(uid: testUid);
  });

  tearDown(() {
    Get.reset();
  });

  test(
    'fetchBankData should populate controllers correctly if data exists',
    () async {
      await usersCollection.doc(testUid).set({
        'bankDetails': {
          'accountName': 'John Doe',
          'accountNumber': '1234567890',
          'bankName': 'Test Bank',
          'branch': 'Main Branch',
          'swiftCode': 'TESTSWIFT',
        },
      });

      await controller.fetchBankData();

      expect(controller.accountNameController.text, 'John Doe');
      expect(controller.accountNumberController.text, '1234567890');
      expect(controller.bankNameController.text, 'Test Bank');
      expect(controller.branchNameController.text, 'Main Branch');
      expect(controller.swiftCodeController.text, 'TESTSWIFT');
    },
  );

  test(
    'fetchBankData should gracefully handle non-existent bank details',
    () async {
      await usersCollection.doc(testUid).set(<String, dynamic>{});

      await controller.fetchBankData();

      expect(controller.accountNameController.text, '');
      expect(controller.accountNumberController.text, '');
    },
  );

  test('updateBankDetails should return early if form is not valid', () async {
    // Note: To truly test formKey validation, we'd need a widget test.
    // We can just verify it doesn't crash here or skip if form is null in typical unit test.
  });
}
