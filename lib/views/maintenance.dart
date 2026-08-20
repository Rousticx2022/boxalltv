import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:boxalltv/utils/ui_widgets.dart';
import 'package:boxalltv/utils/styles.dart';
import 'package:remixicon/remixicon.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/user_service.dart';

class Maintenance extends StatefulWidget {
  final bool isLive, isUnderMaintenance;
  const Maintenance(
      {super.key, required this.isLive, required this.isUnderMaintenance});

  @override
  State<Maintenance> createState() => _MaintenanceState();
}

class _MaintenanceState extends State<Maintenance> {
  String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              UserService.instance.toggleActiveStatus(uid, false);
              UserService.instance.signOut();
            },
            icon: const Icon(Remix.logout_circle_r_line, color: kWhiteColor),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: !widget.isLive
                ? [
                    Image.asset("assets/logo.png", width: 200),
                    Text("Frame TV is coming soon",
                        textAlign: TextAlign.center,
                        style: fontBody(
                            fontSize: 20.sp, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: () async {
                        const url =
                            'mailto:<contact@frametv.tv>?subject=<Mention a subject please>&body=<Describe your problem in brief!>';
                        await launchUrl(Uri.parse(url));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kWhiteColor.withValues(alpha: 0.1),
                        foregroundColor: kWhiteColor,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                      ),
                      icon:
                          const Icon(Remix.mail_fill, color: Color(0xffdb3445)),
                      label: Text("Contact Support",
                          style: fontPoppins(
                              fontSize: 17.sp, fontWeight: FontWeight.w400)),
                    ),
                  ]
                : [
                    Image.asset("assets/logo.png", width: 200),
                    Text("Frame TV is under maintenance",
                        textAlign: TextAlign.center,
                        style: fontBody(
                            fontSize: 20.sp, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: () async {
                        const url =
                            'mailto:<contact@frametv.tv>?subject=<Mention a subject please>&body=<Describe your problem in brief!>';
                        await launchUrl(Uri.parse(url));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kWhiteColor.withValues(alpha: 0.1),
                        foregroundColor: kWhiteColor,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                      ),
                      icon:
                          const Icon(Remix.mail_fill, color: Color(0xffdb3445)),
                      label: Text("Contact Us",
                          style: fontPoppins(
                              fontSize: 17.sp, fontWeight: FontWeight.w400)),
                    ),
                  ],
          ),
        ),
      ),
    );
  }
}
