import 'package:air_controller/network/device_connection_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ContactAvatarView extends StatelessWidget {
  final int rawContactId;
  final double width;
  final double height;
  final double iconSize;
  final bool addTimestamp;
  final VoidCallback? onTap;

  const ContactAvatarView({
    Key? key,
    required this.rawContactId,
    required this.width,
    required this.height,
    this.addTimestamp = false,
    this.iconSize = 24,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String imageUrl =
        "${DeviceConnectionManager.instance.rootURL}/stream/rawContactPhoto?id=$rawContactId";

    if (addTimestamp) {
      final timeInMills = DateTime.now().millisecondsSinceEpoch;
      imageUrl += "&timestamp=$timeInMills";
    }

    return GestureDetector(
      child: Container(
        child: CachedNetworkImage(
            imageUrl: imageUrl,
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorWidget: (context, url, error) {
              return Container(
                color: Color(0xff34a9ff),
                alignment: Alignment.center,
                width: width,
                height: height,
                child: Image.asset(
                  "assets/icons/default_contact.png",
                  width: iconSize,
                  height: iconSize,
                  color: Colors.white,
                ),
              );
            }),
        decoration: BoxDecoration(
          border: Border.all(
            color: Color(0xffdedede),
            width: 1,
          ),
        ),
      ),
      onTap: onTap,
    );
  }
}
