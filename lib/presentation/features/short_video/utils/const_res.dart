class ConstRes {
  static const String base = 'https://short.izidotech.com/';
  static const String apiKey = 'shortzz123';
  static const String baseUrl = 'https://backenddev.tienichnlu.uk/api';

  static const String itemBaseUrl =
      'https://www.google.com/imgres?q=h%C3%ACnh%20%E1%BA%A3nh&imgurl=https%3A%2F%2Fimg.tripi.vn%2Fcdn-cgi%2Fimage%2Fwidth%3D700%2Cheight%3D700%2Fhttps%3A%2F%2Fgcs.tripi.vn%2Fpublic-tripi%2Ftripi-feed%2Fimg%2F474113Zud%2Fhinh-anh-canh-dong-hoa-dep-nhat_014855679_thumb.jpg&imgrefurl=https%3A%2F%2Fmytour.vn%2Fvi%2Fblog%2Fbai-viet%2Fhinh-anh-tuyet-voi-ve-canh-dep-tren-toan-the-gioi.html&docid=vBpqjXF7IfKHHM&tbnid=JYluolgB7Vr_cM&vet=12ahUKEwjg5aepkIyKAxVmsK8BHcnjChcQM3oECFMQAA..i&w=700&h=415&hcb=2&ved=2ahUKEwjg5aepkIyKAxVmsK8BHcnjChcQM3oECFMQAA';

  // Agora Credential
  static const String customerId = '----------- Agora CustomerId ---------- ';
  static const String customerSecret =
      '---------------- Agora Customer Secret --------------';

  // Starting screen open end_user_license_agreement sheet link
  static const String agreementUrl = 'https://work.bubbletokapp.com/';

  static const String bubblyCamera = 'bubbly_camera';
  static const bool isDialog = false;
}

const String appName = 'Shortzz';
const companyName = 'FM_Tech';
const defaultPlaceHolderText = 'S';
const byDefaultLanguage = 'en';

const int paginationLimit = 10;

// Live broadcast Video Quality : Resolution (Width×Height)
int liveWeight = 640;
int liveHeight = 480;
int liveFrameRate = 15; //Frame rate (fps）

// Image Quality
double maxHeight = 720;
double maxWidth = 720;
int imageQuality = 100;

//Strings
const List<String> paymentMethods = ['Paypal', 'Paytm', 'Other'];
const List<String> reportReasons = ['Sexual', 'Nudity', 'Religion', 'Other'];

// Video Moderation models  :- https://sightengine.com/docs/moderate-stored-video-asynchronously
String nudityModels = 'nudity,wad';
