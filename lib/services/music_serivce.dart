import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class MusicService extends GetxService {
  final audioPlayer = AudioPlayer();

  playAudio({required String url}) async {
    if (audioPlayer.playing) {
      await audioPlayer.stop();
    }
    await audioPlayer.setUrl(url);
    audioPlayer.play();
  }

  pauseAudio() async {
    if (audioPlayer.playing) {
      await audioPlayer.pause();
    }
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }
}
