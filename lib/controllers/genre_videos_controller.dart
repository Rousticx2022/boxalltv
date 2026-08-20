import '../services/content_service.dart';
import 'package:get/get.dart';

class GenreVideosController extends GetxController {
  String? genre = Get.parameters["genre"];
  String? genreID = Get.parameters["genreID"];
  String? uid = Get.parameters["uid"];

  @override
  void onInit() {
    ContentService.instance.updateGenrePopularity(genreID!);
    super.onInit();
  }
}
