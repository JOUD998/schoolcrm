import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart' as loc;
import 'package:schoolcrm/view/consatans/colors.dart';
import 'package:speed_dial_fab/speed_dial_fab.dart';

class DriverMap extends StatefulWidget {
  @override
  State<DriverMap> createState() => _DriverMapState();
}

class _DriverMapState extends State<DriverMap> {
  final loc.Location location = loc.Location();
  GoogleMapController? _controller;
  bool _added = false;
  BitmapDescriptor? busIcon;
  Set<Marker> markers = Set();
  StreamSubscription<loc.LocationData>? locationSubscription;

  @override
  void initState() {
    super.initState();
    requestPermission();
    location.changeSettings(interval: 300, accuracy: loc.LocationAccuracy.high);
    location.enableBackgroundMode(enable: true);
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(10, 10)), "assets/images/myBus.png")
        .then((onValue) {
      setState(() {
        busIcon = onValue;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection("drivers").snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              print("Empty Snapshot");
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData) {
              print("!Empty Snapshot");
              if (_added) myMap(snapshot);

              return GoogleMap(
                mapType: MapType.normal,
                markers: {
                  if (busIcon != null)
                    Marker(
                      markerId: MarkerId("id"),
                      position: LatLng(
                        snapshot.data!.docs.first["latitude"],
                        snapshot.data!.docs.first["longitude"],
                      ),
                      icon: busIcon!,
                    )
                },
                initialCameraPosition: CameraPosition(
                  zoom: 15.0,
                  target: LatLng(
                    snapshot.data!.docs.first["latitude"],
                    snapshot.data!.docs.first["longitude"],
                  ),
                ),
                onMapCreated: (GoogleMapController controller) async {
                  setState(() {
                    _controller = controller;
                    _added = true;
                  });
                },
              );
            }
            return Container();
          }),
      floatingActionButton: SpeedDialFabWidget(
        secondaryIconsList: [
          Icons.play_arrow,
          Icons.stop,
        ],
        secondaryIconsText: [
          "start",
          "stop"
        ],
        secondaryIconsOnPress: [
              () => {listenLocation()},
              () => {stopListening()},
        ],
        secondaryBackgroundColor: primaryColor,
        secondaryForegroundColor: Colors.white,
        primaryBackgroundColor: primaryColor,
        primaryForegroundColor: Colors.white,
      ),
    );
  }

  Future<void> myMap(AsyncSnapshot<QuerySnapshot> snapshot) async {
    await _controller?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(
        snapshot.data!.docs.first["latitude"],
        snapshot.data!.docs.first["longitude"],
      ),
      zoom: 15,
    )));
  }

  requestPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted)
      print("Done");
    else if (status.isDenied)
      requestPermission();
    else if (status.isPermanentlyDenied) openAppSettings();
  }

  Future<void> listenLocation() async {
    locationSubscription = location.onLocationChanged.handleError((onError) {
      print(onError);
      locationSubscription?.cancel();
      setState(() {
        locationSubscription = null;
      });
    }).listen((loc.LocationData currentLocation) async {
      print(
          "latitude: ${currentLocation.latitude}, longitude: ${currentLocation.longitude}");

      await FirebaseFirestore.instance.collection('drivers').doc('ah2s4If9Xz4vuirFW3fg').set({
        'latitude': currentLocation.latitude,
        'longitude': currentLocation.longitude,
      }, SetOptions(merge: true));
    });
  }

  void stopListening() {
    locationSubscription?.cancel();
    setState(() {
      locationSubscription = null;
    });
  }
}