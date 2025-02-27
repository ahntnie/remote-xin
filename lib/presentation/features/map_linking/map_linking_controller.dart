import 'dart:async';
import 'dart:developer';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/map_linking/category_map.dart';
import '../../../models/map_linking/map_style.dart';
import '../../../models/map_linking/position_map.dart';
import '../../../repositories/map_linking_repo.dart';
import '../../base/all.dart';
import '../../common_controller.dart/language_controller.dart';

class MapLinkingController extends BaseController
    with GetTickerProviderStateMixin {
  Location locationController = Location();
  late StreamSubscription<LocationData> locationSubscription;
  final mapLinkingRepo = Get.find<MapLinkingRepository>();

  late TabController tabController;

  Completer<GoogleMapController> mapController =
      Completer<GoogleMapController>();

  final Rx<LatLng?> currentP = Rx<LatLng?>(null);
  LatLng pGooglePlex = const LatLng(37.4223, -122.0848);

  Map<PolylineId, Polyline> polylines = {};

  final RxBool isExpanded = false.obs;

  final RxBool showNavigator = false.obs;

  LatLng? positionNavigator;

  final double expandedHeight =
      1.sh - MediaQuery.of(Get.context!).padding.top - 20;
  final double collapsedHeight = 105.0;

  // Thêm biến để lưu marker
  final RxSet<Marker> _markers = <Marker>{}.obs;
  Set<Marker> get markers => _markers.toSet();

  // Thêm biến để lưu BitmapDescriptor
  BitmapDescriptor? customIcon;

  bool isFirst = true;

  RxList<CategoryMap> categories = <CategoryMap>[].obs;

  RxString category = ''.obs;

  RxInt numberPosition = 0.obs;

  RxInt indexTheme = 0.obs;

  final key = Get.find<LanguageController>()
      .languages[Get.find<LanguageController>().currentIndex.value]['flagCode'];

  void toggleContainer() {
    isExpanded.value = !isExpanded.value;
  }

  @override
  Future<void> onInit() async {
    super.onInit();

    await loadCustomMarker();
    await getLocationUpdates();
    unawaited(loadCategory());
  }

  @override
  void onClose() {
    locationSubscription.cancel();
    super.onClose();
  }

  Future<void> loadCustomMarker() async {
    final ByteData byteData =
        await rootBundle.load('assets/images/marker-xin.png');
    final Uint8List uint8List = byteData.buffer.asUint8List();
    final codec = await ui.instantiateImageCodec(
      uint8List,
      targetWidth: 0.45.sw.toInt(),
    );
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final data =
        await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
    customIcon = BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  Future<void> loadCategory() async {
    categories.value = await mapLinkingRepo.getCategoryMap();
    category.value = categories.toList().first.language[key];
    tabController = TabController(length: categories.length, vsync: this);
    tabController.addListener(() {
      loadMarker(categories[tabController.index].positions ?? []);
      category.value = categories[tabController.index].language[key];
      numberPosition.value = categories[tabController.index].positions!.length;
    });
    loadPosition();
  }

  Future<void> loadPosition() async {
    _markers.clear();
    for (int i = 0; i < categories.length; i++) {
      if (i == 0) {
        final positions =
            await mapLinkingRepo.getPositionMap(categories.toList().first.id);
        categories.first =
            categories.toList().first.copyWith(positions: positions);
        numberPosition.value = positions.length;

        for (var item in positions) {
          _markers.add(Marker(
            markerId: MarkerId(item.id),
            onTap: () {
              showNavigator.value = true;
              positionNavigator = LatLng(item.latitude, item.longitude);
              cameraToPosition(LatLng(item.latitude, item.longitude), 14);
            },
            position: LatLng(item.latitude, item.longitude),
            anchor: const Offset(0.5, 0.9),
            icon: customIcon ??
                BitmapDescriptor.defaultMarker, // Sử dụng custom icon
            infoWindow: InfoWindow(
              title: item.name,
              snippet: item.physicalAddress,
            ),
          ));
        }
      } else {
        final positions =
            await mapLinkingRepo.getPositionMap(categories.toList()[i].id);
        categories[i] = categories.toList()[i].copyWith(positions: positions);
      }
    }
  }

  Future<void> zoomInMap() async {
    final GoogleMapController mapControl = await mapController.future;
    await mapControl.animateCamera(CameraUpdate.zoomIn());
  }

  Future<void> zoomOutMap() async {
    final GoogleMapController mapControl = await mapController.future;
    await mapControl.animateCamera(CameraUpdate.zoomOut());
  }

  Future<void> openGoogleMapsNavigation() async {
    if (currentP.value != null) {
      final url =
          'https://www.google.com/maps/dir/?api=1&origin=${currentP.value!.latitude},${currentP.value!.longitude}&destination=${positionNavigator!.latitude},${positionNavigator!.longitude}&travelmode=driving';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } else {
      // Handle the case when the current location is not available
      print('Current location not available');
    }
  }

  void loadMarker(List<PositionMap> positions) {
    _markers.clear();
    for (var item in positions) {
      _markers.add(Marker(
        markerId: MarkerId(item.id),
        onTap: () {
          showNavigator.value = true;
          positionNavigator = LatLng(item.latitude, item.longitude);
          cameraToPosition(LatLng(item.latitude, item.longitude), 14);
        },
        position: LatLng(item.latitude, item.longitude),
        anchor: const Offset(0.5, 0.9),
        icon:
            customIcon ?? BitmapDescriptor.defaultMarker, // Sử dụng custom icon
        infoWindow: InfoWindow(
          title: item.name,
          snippet: item.physicalAddress,
        ),
      ));
    }
  }

  Future<void> cameraToPosition(LatLng pos, double zoom) async {
    final GoogleMapController mapControl = await mapController.future;
    final CameraPosition newCameraPosition = CameraPosition(
      target: pos,
      zoom: zoom,
    );
    await mapControl.animateCamera(
      CameraUpdate.newCameraPosition(newCameraPosition),
    );
  }

  Future<void> getLocationUpdates() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await locationController.serviceEnabled();
    if (serviceEnabled) {
      serviceEnabled = await locationController.requestService();
    } else {
      return;
    }

    permissionGranted = await locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationSubscription = locationController.onLocationChanged
        .listen((LocationData currentLocation) {
      log(currentLocation.toString());
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        currentP.value =
            LatLng(currentLocation.latitude!, currentLocation.longitude!);
        log(currentP.value!.toString());
        if (isFirst) {
          cameraToPosition(currentP.value!, 13);
          isFirst = false;
        }
      }
    });
  }

  Future<void> setMapStyle(String mapStyle) async {
    final GoogleMapController mapControl = await mapController.future;
    await mapControl.setMapStyle(mapStyle);
  }

  final List<dynamic> mapThemes = [
    {
      'name': 'Standard',
      'style': MapStyle().normal,
      'image':
          'https://maps.googleapis.com/maps/api/staticmap?center=-33.9775,151.036&zoom=13&format=png&maptype=roadmap&style=element:labels%7Cvisibility:off&style=feature:administrative.land_parcel%7Cvisibility:off&style=feature:administrative.neighborhood%7Cvisibility:off&size=164x132&key=AIzaSyDk4C4EBWgjuL1eBnJlu1J80WytEtSIags&scale=2',
    },
    {
      'name': 'Sliver',
      'style': MapStyle().sliver,
      'image':
          'https://maps.googleapis.com/maps/api/staticmap?center=-33.9775,151.036&zoom=13&format=png&maptype=roadmap&style=element:geometry%7Ccolor:0xf5f5f5&style=element:labels%7Cvisibility:off&style=element:labels.icon%7Cvisibility:off&style=element:labels.text.fill%7Ccolor:0x616161&style=element:labels.text.stroke%7Ccolor:0xf5f5f5&style=feature:administrative.land_parcel%7Cvisibility:off&style=feature:administrative.land_parcel%7Celement:labels.text.fill%7Ccolor:0xbdbdbd&style=feature:administrative.neighborhood%7Cvisibility:off&style=feature:poi%7Celement:geometry%7Ccolor:0xeeeeee&style=feature:poi%7Celement:labels.text.fill%7Ccolor:0x757575&style=feature:poi.park%7Celement:geometry%7Ccolor:0xe5e5e5&style=feature:poi.park%7Celement:labels.text.fill%7Ccolor:0x9e9e9e&style=feature:road%7Celement:geometry%7Ccolor:0xffffff&style=feature:road.arterial%7Celement:labels.text.fill%7Ccolor:0x757575&style=feature:road.highway%7Celement:geometry%7Ccolor:0xdadada&style=feature:road.highway%7Celement:labels.text.fill%7Ccolor:0x616161&style=feature:road.local%7Celement:labels.text.fill%7Ccolor:0x9e9e9e&style=feature:transit.line%7Celement:geometry%7Ccolor:0xe5e5e5&style=feature:transit.station%7Celement:geometry%7Ccolor:0xeeeeee&style=feature:water%7Celement:geometry%7Ccolor:0xc9c9c9&style=feature:water%7Celement:labels.text.fill%7Ccolor:0x9e9e9e&size=164x132&key=AIzaSyDk4C4EBWgjuL1eBnJlu1J80WytEtSIags&scale=2',
    },
    {
      'name': 'Retro',
      'style': MapStyle().retro,
      'image':
          'https://maps.googleapis.com/maps/api/staticmap?center=-33.9775,151.036&zoom=13&format=png&maptype=roadmap&style=element:geometry%7Ccolor:0xebe3cd&style=element:labels%7Cvisibility:off&style=element:labels.text.fill%7Ccolor:0x523735&style=element:labels.text.stroke%7Ccolor:0xf5f1e6&style=feature:administrative%7Celement:geometry.stroke%7Ccolor:0xc9b2a6&style=feature:administrative.land_parcel%7Cvisibility:off&style=feature:administrative.land_parcel%7Celement:geometry.stroke%7Ccolor:0xdcd2be&style=feature:administrative.land_parcel%7Celement:labels.text.fill%7Ccolor:0xae9e90&style=feature:administrative.neighborhood%7Cvisibility:off&style=feature:landscape.natural%7Celement:geometry%7Ccolor:0xdfd2ae&style=feature:poi%7Celement:geometry%7Ccolor:0xdfd2ae&style=feature:poi%7Celement:labels.text.fill%7Ccolor:0x93817c&style=feature:poi.park%7Celement:geometry.fill%7Ccolor:0xa5b076&style=feature:poi.park%7Celement:labels.text.fill%7Ccolor:0x447530&style=feature:road%7Celement:geometry%7Ccolor:0xf5f1e6&style=feature:road.arterial%7Celement:geometry%7Ccolor:0xfdfcf8&style=feature:road.highway%7Celement:geometry%7Ccolor:0xf8c967&style=feature:road.highway%7Celement:geometry.stroke%7Ccolor:0xe9bc62&style=feature:road.highway.controlled_access%7Celement:geometry%7Ccolor:0xe98d58&style=feature:road.highway.controlled_access%7Celement:geometry.stroke%7Ccolor:0xdb8555&style=feature:road.local%7Celement:labels.text.fill%7Ccolor:0x806b63&style=feature:transit.line%7Celement:geometry%7Ccolor:0xdfd2ae&style=feature:transit.line%7Celement:labels.text.fill%7Ccolor:0x8f7d77&style=feature:transit.line%7Celement:labels.text.stroke%7Ccolor:0xebe3cd&style=feature:transit.station%7Celement:geometry%7Ccolor:0xdfd2ae&style=feature:water%7Celement:geometry.fill%7Ccolor:0xb9d3c2&style=feature:water%7Celement:labels.text.fill%7Ccolor:0x92998d&size=164x132&key=AIzaSyDk4C4EBWgjuL1eBnJlu1J80WytEtSIags&scale=2',
    },
    {
      'name': 'Dark',
      'style': MapStyle().dark,
      'image':
          'https://maps.googleapis.com/maps/api/staticmap?center=-33.9775,151.036&zoom=13&format=png&maptype=roadmap&style=element:geometry%7Ccolor:0x212121&style=element:labels%7Cvisibility:off&style=element:labels.icon%7Cvisibility:off&style=element:labels.text.fill%7Ccolor:0x757575&style=element:labels.text.stroke%7Ccolor:0x212121&style=feature:administrative%7Celement:geometry%7Ccolor:0x757575&style=feature:administrative.country%7Celement:labels.text.fill%7Ccolor:0x9e9e9e&style=feature:administrative.land_parcel%7Cvisibility:off&style=feature:administrative.locality%7Celement:labels.text.fill%7Ccolor:0xbdbdbd&style=feature:administrative.neighborhood%7Cvisibility:off&style=feature:poi%7Celement:labels.text.fill%7Ccolor:0x757575&style=feature:poi.park%7Celement:geometry%7Ccolor:0x181818&style=feature:poi.park%7Celement:labels.text.fill%7Ccolor:0x616161&style=feature:poi.park%7Celement:labels.text.stroke%7Ccolor:0x1b1b1b&style=feature:road%7Celement:geometry.fill%7Ccolor:0x2c2c2c&style=feature:road%7Celement:labels.text.fill%7Ccolor:0x8a8a8a&style=feature:road.arterial%7Celement:geometry%7Ccolor:0x373737&style=feature:road.highway%7Celement:geometry%7Ccolor:0x3c3c3c&style=feature:road.highway.controlled_access%7Celement:geometry%7Ccolor:0x4e4e4e&style=feature:road.local%7Celement:labels.text.fill%7Ccolor:0x616161&style=feature:transit%7Celement:labels.text.fill%7Ccolor:0x757575&style=feature:water%7Celement:geometry%7Ccolor:0x000000&style=feature:water%7Celement:labels.text.fill%7Ccolor:0x3d3d3d&size=164x132&key=AIzaSyDk4C4EBWgjuL1eBnJlu1J80WytEtSIags&scale=2',
    },
    {
      'name': 'Night',
      'style': MapStyle().night,
      'image':
          'https://maps.googleapis.com/maps/api/staticmap?center=-33.9775,151.036&zoom=13&format=png&maptype=roadmap&style=element:geometry%7Ccolor:0x242f3e&style=element:labels%7Cvisibility:off&style=element:labels.text.fill%7Ccolor:0x746855&style=element:labels.text.stroke%7Ccolor:0x242f3e&style=feature:administrative.land_parcel%7Cvisibility:off&style=feature:administrative.locality%7Celement:labels.text.fill%7Ccolor:0xd59563&style=feature:administrative.neighborhood%7Cvisibility:off&style=feature:poi%7Celement:labels.text.fill%7Ccolor:0xd59563&style=feature:poi.park%7Celement:geometry%7Ccolor:0x263c3f&style=feature:poi.park%7Celement:labels.text.fill%7Ccolor:0x6b9a76&style=feature:road%7Celement:geometry%7Ccolor:0x38414e&style=feature:road%7Celement:geometry.stroke%7Ccolor:0x212a37&style=feature:road%7Celement:labels.text.fill%7Ccolor:0x9ca5b3&style=feature:road.highway%7Celement:geometry%7Ccolor:0x746855&style=feature:road.highway%7Celement:geometry.stroke%7Ccolor:0x1f2835&style=feature:road.highway%7Celement:labels.text.fill%7Ccolor:0xf3d19c&style=feature:transit%7Celement:geometry%7Ccolor:0x2f3948&style=feature:transit.station%7Celement:labels.text.fill%7Ccolor:0xd59563&style=feature:water%7Celement:geometry%7Ccolor:0x17263c&style=feature:water%7Celement:labels.text.fill%7Ccolor:0x515c6d&style=feature:water%7Celement:labels.text.stroke%7Ccolor:0x17263c&size=164x132&key=AIzaSyDk4C4EBWgjuL1eBnJlu1J80WytEtSIags&scale=2',
    },
    {
      'name': 'Aubergine',
      'style': MapStyle().aubergine,
      'image':
          'https://maps.googleapis.com/maps/api/staticmap?center=-33.9775,151.036&zoom=13&format=png&maptype=roadmap&style=element:geometry%7Ccolor:0x1d2c4d&style=element:labels%7Cvisibility:off&style=element:labels.text.fill%7Ccolor:0x8ec3b9&style=element:labels.text.stroke%7Ccolor:0x1a3646&style=feature:administrative.country%7Celement:geometry.stroke%7Ccolor:0x4b6878&style=feature:administrative.land_parcel%7Cvisibility:off&style=feature:administrative.land_parcel%7Celement:labels.text.fill%7Ccolor:0x64779e&style=feature:administrative.neighborhood%7Cvisibility:off&style=feature:administrative.province%7Celement:geometry.stroke%7Ccolor:0x4b6878&style=feature:landscape.man_made%7Celement:geometry.stroke%7Ccolor:0x334e87&style=feature:landscape.natural%7Celement:geometry%7Ccolor:0x023e58&style=feature:poi%7Celement:geometry%7Ccolor:0x283d6a&style=feature:poi%7Celement:labels.text.fill%7Ccolor:0x6f9ba5&style=feature:poi%7Celement:labels.text.stroke%7Ccolor:0x1d2c4d&style=feature:poi.park%7Celement:geometry.fill%7Ccolor:0x023e58&style=feature:poi.park%7Celement:labels.text.fill%7Ccolor:0x3C7680&style=feature:road%7Celement:geometry%7Ccolor:0x304a7d&style=feature:road%7Celement:labels.text.fill%7Ccolor:0x98a5be&style=feature:road%7Celement:labels.text.stroke%7Ccolor:0x1d2c4d&style=feature:road.highway%7Celement:geometry%7Ccolor:0x2c6675&style=feature:road.highway%7Celement:geometry.stroke%7Ccolor:0x255763&style=feature:road.highway%7Celement:labels.text.fill%7Ccolor:0xb0d5ce&style=feature:road.highway%7Celement:labels.text.stroke%7Ccolor:0x023e58&style=feature:transit%7Celement:labels.text.fill%7Ccolor:0x98a5be&style=feature:transit%7Celement:labels.text.stroke%7Ccolor:0x1d2c4d&style=feature:transit.line%7Celement:geometry.fill%7Ccolor:0x283d6a&style=feature:transit.station%7Celement:geometry%7Ccolor:0x3a4762&style=feature:water%7Celement:geometry%7Ccolor:0x0e1626&style=feature:water%7Celement:labels.text.fill%7Ccolor:0x4e6d70&size=164x132&key=AIzaSyDk4C4EBWgjuL1eBnJlu1J80WytEtSIags&scale=2',
    },
  ];
}
