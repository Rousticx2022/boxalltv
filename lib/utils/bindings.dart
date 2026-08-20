import 'package:boxalltv/controllers/advertiser_controller.dart';
import 'package:boxalltv/services/music_serivce.dart';
import '../controllers/post_details_controller.dart';
import '../controllers/your_channel_controller.dart';
import '../controllers/cart_controller.dart';
import '../services/purchase_service.dart';
import '../controllers/public_profile_controller.dart';
import '../controllers/create_post_controller.dart';
import '../controllers/messages_controller.dart';
import '../controllers/notifications_controller.dart';
import '../controllers/upload_controller.dart';
import '../controllers/signup_controller.dart';
import '../controllers/video_recorder_controller.dart';
import '../controllers/watch_controller.dart';
import '../controllers/genre_videos_controller.dart';
import '../controllers/view_more_controller.dart';
import '../controllers/splash_controller.dart';
import '../controllers/bottomtab_controller.dart';
import '../controllers/details_controller.dart';
import '../controllers/login_controller.dart';

import 'package:get/get.dart';

import '../services/upload_service.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SplashController>(SplashController());
  }
}

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
  }
}

class SignupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignupController>(() => SignupController());
  }
}

class BottomTabBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BottomTabController>(() => BottomTabController());
    Get.put<PurchaseService>(PurchaseService());
    Get.put<MusicService>(MusicService());
    Get.put<UploadService>(UploadService());
    Get.put<UploadController>(UploadController());
  }
}

class DetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailsController>(() => DetailsController());
  }
}

class GenreVideosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GenreVideosController>(() => GenreVideosController());
  }
}

class ViewMoreBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ViewMoreController>(() => ViewMoreController());
  }
}

class WatchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WatchController>(() => WatchController());
  }
}

class CreatePostBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreatePostController>(() => CreatePostController());
  }
}

class NotificationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationsController>(() => NotificationsController());
  }
}

class MessagesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MessagesController>(() => MessagesController());
  }
}

class PublicProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PublicProfileController>(() => PublicProfileController());
  }
}

class CartBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CartController>(() => CartController());
  }
}

class VideoRecorderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VideoRecorderController>(() => VideoRecorderController());
  }
}

class YourChannelBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<YourChannelController>(() => YourChannelController());
  }
}

class PostDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PostDetailsController>(() => PostDetailsController());
  }
}

class AdvertiserBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdvertiserController>(() => AdvertiserController());
  }
}
