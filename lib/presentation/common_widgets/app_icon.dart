import 'package:flutter/material.dart';

import '../../core/extensions/all.dart';
import '../resource/resource.dart';

class AppIcon extends StatelessWidget {
  const AppIcon({
    required this.icon,
    super.key,
    this.color,
    this.backgroundColor,
    this.size = Sizes.s24,
    this.padding,
    this.onTap,
    this.isCircle = false,
  });

  final Object icon;
  final Color? color;
  final Color? backgroundColor;
  final double? size;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool isCircle;

  @override
  Widget build(BuildContext context) {
    Widget? iconWidget;

    final iconColor = color ?? Colors.white;
    if (icon is IconData) {
      iconWidget = Icon(
        icon as IconData,
        color: iconColor,
        size: size,
      );
    } else if (icon is SvgGenImage) {
      iconWidget = (icon as SvgGenImage).svg(
        width: size,
        height: size,
        colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
      );
    } else if (icon is AssetGenImage) {
      iconWidget = (icon as AssetGenImage).image(
        width: size,
        height: size,
      );
    } else if (icon is Widget) {
      iconWidget = icon as Widget;
    }

    iconWidget = Padding(
      padding: padding ?? EdgeInsets.zero,
      child: iconWidget,
    );

    if (isCircle) {
      iconWidget = Container(
        padding: padding ?? const EdgeInsets.all(Sizes.s4),
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Center(child: iconWidget),
      );
    } else if (backgroundColor != null) {
      iconWidget = DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
        ),
        child: Center(child: iconWidget),
      );
    }

    if (onTap != null) {
      return iconWidget.clickable(onTap!);
    }

    return iconWidget;
  }
}

class AppIcons {
  const AppIcons._();

  static SvgGenImage arrowLeft = Assets.icons.arrowLeft;
  static SvgGenImage arrowRight = Assets.icons.arrowRight;
  static SvgGenImage close = Assets.icons.close;
  static SvgGenImage homeRegular = Assets.icons.houseRegular;
  static SvgGenImage menuRegular = Assets.icons.barsRegular;
  static SvgGenImage send = Assets.icons.sendThin;
  static SvgGenImage emoji = Assets.icons.faceSmileLight;
  static SvgGenImage eyeOpen = Assets.icons.eyeOpen;
  static SvgGenImage eyeClose = Assets.icons.eyeClose;
  static SvgGenImage logout = Assets.icons.logout;
  static SvgGenImage user = Assets.icons.userDefault;
  static SvgGenImage success = Assets.icons.success;
  static SvgGenImage checkBlur = Assets.icons.checkBlur;
  static SvgGenImage chat = Assets.icons.chat;
  static SvgGenImage search = Assets.icons.searchIcon;
  static SvgGenImage edit = Assets.icons.edit;
  static SvgGenImage news = Assets.icons.news;
  static SvgGenImage call = Assets.icons.endCallBroken;
  static SvgGenImage mintCoin = Assets.icons.mintCoin;
  static SvgGenImage promotion = Assets.icons.promotion;
  static SvgGenImage addTab = Assets.icons.addTab;
  static SvgGenImage setting = Assets.icons.setting;
  static SvgGenImage editLight = Assets.icons.editLight;
  static SvgGenImage avatarUserDefault = Assets.icons.userDefault;
  static SvgGenImage bell = Assets.icons.notification;
  static SvgGenImage assistant = Assets.icons.assistant;
  static SvgGenImage cameraChange = Assets.icons.camera;
  static SvgGenImage circleTick = Assets.icons.circleTick;
  static SvgGenImage networkPolicy = Assets.icons.networkPolicy;
  static SvgGenImage uiconsDocument = Assets.icons.uiconsDocument;
  static SvgGenImage personDelete = Assets.icons.personDelete;
  static SvgGenImage infoOutline = Assets.icons.infoOutline;

  static SvgGenImage camera = Assets.icons.solarCameraBroken;
  static SvgGenImage gallery = Assets.icons.galleryBroken;
  static SvgGenImage microphone = Assets.icons.voice;
  static SvgGenImage document = Assets.icons.uiconsDocument;

  static SvgGenImage deleteAudio = Assets.icons.deleteAudio;
  static SvgGenImage pauseAudio = Assets.icons.pauseAudio;
  static SvgGenImage playAudio = Assets.icons.playAudio;

  static SvgGenImage history = Assets.icons.history;
  static SvgGenImage contacts = Assets.icons.contacts;
  static SvgGenImage keyboard = Assets.icons.keyboard;
  static SvgGenImage phoneOut = Assets.icons.phoneOut;
  static SvgGenImage phoneIn = Assets.icons.phoneIn;
  static SvgGenImage phoneMissed = Assets.icons.phoneMissed;
  static SvgGenImage callBroken = Assets.icons.endCallBroken;
  static SvgGenImage video = Assets.icons.video;
  static SvgGenImage phoneVoice = Assets.icons.phoneVoice;
  static SvgGenImage group = Assets.icons.group;
  static SvgGenImage asterisk = Assets.icons.asterisk;
  static SvgGenImage number = Assets.icons.number;
  static SvgGenImage callFill = Assets.icons.callFill;
  static SvgGenImage changeAccount = Assets.icons.changeAccount;
  static SvgGenImage info = Assets.icons.info;
  static SvgGenImage addContact = Assets.icons.addContact;

  static AssetGenImage comingSoonMintCoin = Assets.images.comingSoonMintCoin;
  static AssetGenImage comingSoonPromotion = Assets.images.comingSoonPromotion;
  static AssetGenImage flagVietnam = Assets.images.flagVietnam;

  static SvgGenImage media = Assets.icons.mediaOutline;
  static SvgGenImage delete = Assets.icons.delete;
  static SvgGenImage internet = Assets.icons.internet;
  static SvgGenImage videoPost = Assets.icons.videoPost;
  // static SvgGenImage react = Assets.icons.heartBroken;
  // static SvgGenImage reacted = Assets.icons.reacted;
  static SvgGenImage comment = Assets.icons.comment;
  static SvgGenImage share = Assets.icons.shareIcon;
  static SvgGenImage image = Assets.icons.image;
  static SvgGenImage more = Assets.icons.more;
  static SvgGenImage report = Assets.icons.report;
  static SvgGenImage language = Assets.icons.language;
  static SvgGenImage zoom = Assets.icons.zoom;
  static SvgGenImage public = Assets.icons.public;
  static SvgGenImage checkBroken = Assets.icons.checkBroken;

  static IconData link = Icons.link_rounded;
  static IconData copy = Icons.copy_rounded;
  static IconData block = Icons.block_rounded;

  static AssetGenImage like = Assets.images.like;
  static AssetGenImage love = Assets.images.love;
  static AssetGenImage haha = Assets.images.haha;
  static AssetGenImage wow = Assets.images.wow;
  static AssetGenImage sad = Assets.images.sad;
  static AssetGenImage angry = Assets.images.angry;

  static SvgGenImage sticker = Assets.icons.sticker;

  static AssetGenImage google = Assets.images.google;
  static AssetGenImage apple = Assets.images.apple;

  static AssetGenImage react = Assets.icons.unlike;
  static AssetGenImage reacted = Assets.icons.like;

  static SvgGenImage videoOn = Assets.icons.videoOn;
  static SvgGenImage videoOff = Assets.icons.videoOff;
  static SvgGenImage micOn = Assets.icons.micOn;
  static SvgGenImage micOff = Assets.icons.micOff;
  static SvgGenImage speaker = Assets.icons.speaker;
  static SvgGenImage callAudio = Assets.icons.callAudio;

  static SvgGenImage reply = Assets.icons.reply;
  static SvgGenImage forward = Assets.icons.forward;
  static SvgGenImage pin = Assets.icons.pin;
  static SvgGenImage unpin = Assets.icons.unpin;
  static SvgGenImage reportMessage = Assets.icons.reportMessage;
  static SvgGenImage trashMessage = Assets.icons.trashMessage;
  static SvgGenImage download = Assets.icons.download;
  static SvgGenImage mediaLibrary = Assets.icons.mediaLibrary;
  static SvgGenImage userBlock = Assets.icons.userBlock;
  static SvgGenImage plus = Assets.icons.plus;
  static SvgGenImage createGroup = Assets.icons.createGroup;
}
