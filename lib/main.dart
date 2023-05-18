import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

void main() {
  runApp(MaterialApp(home: MainPage()));
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // виджет MaterialApp - главный виджет приложения, который
    // позволяет настроить тему и использовать
    // Material Design для разработки.
    return MaterialApp(
      // заголовок приложения
      // обычно виден, когда мы сворачиваем приложение
      title: 'Yandex Map',
      // настройка темы, мы ещё вернёмся к этому
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      // указываем исходную страницу, которую мы создадим позже
      home: _PlacemarkMapObjectExample(),
    );
  }
}

class _PlacemarkMapObjectExample extends StatefulWidget {
  @override
  _PlacemarkMapObjectExampleState createState() =>
      _PlacemarkMapObjectExampleState();
}

class _PlacemarkMapObjectExampleState
    extends State<_PlacemarkMapObjectExample> {
  final mapControllerCompleter = Completer<YandexMapController>();
  final List<MapObject> _mapObjects = [];
  AppLatLong? location;
  final MapObjectId mapObjectWithDynamicIconId =
      MapObjectId('dynamic_icon_placemark');

  Future<void> _initPermission() async {
    if (!await LocationService().checkPermission()) {
      await LocationService().requestPermission();
    }
    await _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    const defLocation = MoscowLocation();
    try {
      location = await LocationService().getCurrentLocation();
    } catch (_) {
      location = defLocation;
    }
    _moveToCurrentLocation();
  }

  Future<void> _moveToCurrentLocation() async {
    (await mapControllerCompleter.future).moveCamera(
      animation: const MapAnimation(type: MapAnimationType.linear, duration: 1),
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: Point(
            latitude: location!.lat,
            longitude: location!.long,
          ),
          zoom: 15,
        ),
      ),
    );
    print("object object object object object object object");
    final mapObjectWithDynamicIcon = PlacemarkMapObject(
        mapId: mapObjectWithDynamicIconId,
        point: Point(latitude: location!.lat, longitude: location!.long),
        onTap: (PlacemarkMapObject self, Point point) =>
            print('Tapped me at $point'),
        icon: PlacemarkIcon.single(PlacemarkIconStyle(
            image: BitmapDescriptor.fromAssetImage(
              'assets/place.png',
            ),
            rotationType: RotationType.rotate)));
    setState(() {
      _mapObjects.add(mapObjectWithDynamicIcon);
    });
  }

  @override
  void initState() {
    super.initState();
    _initPermission().ignore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Текущее местоположение'),
      ),
      body: YandexMap(
        onMapCreated: (controller) {
          mapControllerCompleter.complete(controller);
        },
        mapObjects: _mapObjects,
      ),
    );
  }
}

class AppLatLong {
  final double lat;
  final double long;

  const AppLatLong({
    required this.lat,
    required this.long,
  });
}

class MoscowLocation extends AppLatLong {
  const MoscowLocation({
    super.lat = 55.7522200,
    super.long = 37.6155600,
  });
}

abstract class AppLocation {
  Future<AppLatLong> getCurrentLocation();

  Future<bool> requestPermission();

  Future<bool> checkPermission();
}

class LocationService implements AppLocation {
  final defLocation = const MoscowLocation();

  @override
  Future<AppLatLong> getCurrentLocation() async {
    return Geolocator.getCurrentPosition().then((value) {
      return AppLatLong(lat: value.latitude, long: value.longitude);
    }).catchError(
      (_) => defLocation,
    );
  }

  @override
  Future<bool> requestPermission() {
    return Geolocator.requestPermission()
        .then((value) =>
            value == LocationPermission.always ||
            value == LocationPermission.whileInUse)
        .catchError((_) => false);
  }

  @override
  Future<bool> checkPermission() {
    return Geolocator.checkPermission()
        .then((value) =>
            value == LocationPermission.always ||
            value == LocationPermission.whileInUse)
        .catchError((_) => false);
  }
}
