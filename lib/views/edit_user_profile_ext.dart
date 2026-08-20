part of 'edit_user_profile.dart';

extension EditUserProfileExt on _EditUserProfileState {

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;

    DocumentSnapshot user = await usersCollection.doc(widget.uid).get();

    String imageURL = user["profileImage"];

    if (imagePath.isNotEmpty) {
      final storageRef = FirebaseStorage.instance.ref();

      String ext = imagePath.split(".").last;
      int fileName = DateTime.now().millisecondsSinceEpoch;

      try {
        final postRef =
            storageRef.child("user/${widget.uid}/pp_$fileName.$ext");
        await postRef.putFile(File(imagePath));
        imageURL = await postRef.getDownloadURL();
      } on FirebaseException catch (e) {
        customSnackBar(text: e.code);
      }
    }
    await usersCollection.doc(widget.uid).update({
      "profileImage": imageURL,
      "name": nameController.text,
      "country": countryController.text,
      "phoneNumber": phoneController.text,
      "zipcode": zipcodeController.text,
    });

    Get.back();
    customSnackBar(text: "Profile updated successfully");
  }
}
