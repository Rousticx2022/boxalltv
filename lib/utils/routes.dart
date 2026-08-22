import 'package:boxalltv/views/channel/your_channel.dart';
import 'package:boxalltv/views/social/post_details.dart';
import 'package:boxalltv/views/wallet.dart';

import '../views/cart.dart';
import '../views/advertisers/advertiser.dart';
import '../views/reels/video_recorder.dart';
import '../views/social/public_profile.dart';
import '../views/notifications.dart';
import '../views/social/create_post.dart';
import '../views/signup.dart';
import '../views/social/messages.dart';
import '../views/watch.dart';
import '../views/view_more.dart';
import '../views/genre_videos.dart';
import '../views/details.dart';
import '../views/bottom_tab.dart';
import '../views/login.dart';
import '../views/splash.dart';
import 'package:get/get.dart';
import 'bindings.dart';

class Pages {
  static final allRoutes = [
    GetPage(name: '/', page: () => const Splash(), binding: SplashBinding()),
    GetPage(name: '/login', page: () => const Login(), binding: LoginBinding()),
    GetPage(
      name: '/signup',
      page: () => const Signup(),
      binding: SignupBinding(),
    ),
    GetPage(
      name: '/bottom_tab',
      page: () => const BottomTab(),
      binding: BottomTabBinding(),
    ),
    GetPage(
      name: '/details',
      page: () => const Details(),
      binding: DetailsBinding(),
    ),
    GetPage(
      name: '/genre_videos/:genre',
      page: () => const GenreVideos(),
      binding: GenreVideosBinding(),
    ),
    GetPage(
      name: '/view_more/:section',
      page: () => const ViewMore(),
      binding: ViewMoreBinding(),
    ),
    GetPage(name: '/watch', page: () => const Watch(), binding: WatchBinding()),
    GetPage(
      name: "/create_post",
      page: () => const CreatePost(),
      binding: CreatePostBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: "/notifications",
      page: () => const Notifications(),
      binding: NotificationsBinding(),
    ),
    GetPage(
      name: "/messages",
      page: () => const Messages(),
      binding: MessagesBinding(),
    ),
    GetPage(
      name: "/public_profile",
      page: () => const PublicProfile(),
      binding: PublicProfileBinding(),
    ),
    GetPage(name: "/cart", page: () => const Cart(), binding: CartBinding()),
    GetPage(
      name: "/video_recorder",
      page: () => const VideoRecorder(),
      binding: VideoRecorderBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: "/your_channel",
      page: () => const YourChannel(),
      binding: YourChannelBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: "/post",
      page: () => const PostDetails(),
      binding: PostDetailsBinding(),
      fullscreenDialog: true,
    ),
    GetPage(name: "/wallet", page: () => const Wallet()),
    GetPage(
      name: "/advertiser",
      page: () => const Advertiser(),
      binding: AdvertiserBinding(),
    ),

    //tv routes
    /* GetPage(name: '/loginTV', page: () => const LoginTV(), binding: LoginBinding()),
    GetPage(name: '/bottom_tabTV/:utilsd', page: () => const BottomTabTV(), binding: BottomTabBinding()),
    GetPage(name: '/detailsTV/:vid', page: () => const DetailsTV(), binding: DetailsBinding()),
    GetPage(name: '/watchTV', page: () => const WatchTV(), binding: WatchTVBinding()),*/
  ];
}
