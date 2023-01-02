
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LoadMapScreen extends StatefulWidget {
  static const routeName='/load_map';
  const LoadMapScreen({Key? key}) : super(key: key);

  @override
  State<LoadMapScreen> createState() => _LoadMapScreenState();
}

class _LoadMapScreenState extends State<LoadMapScreen> {
  final GeolocatorPlatform geolocatorPlatform = GeolocatorPlatform.instance;
  final List<PositionItem> arrPositionItems = <PositionItem>[];
  late GoogleMapController controller;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Load Map from user location"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        child: InkWell(
          onTap: () async{
            await getCurrentPosition();
          },
          child:
            Column(
              children: [
                Text("Load Map"),
                Container(
                  width:300,
                  height:500,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                        target: LatLng(-7.291306,112.7562541),
                        zoom: 11.0
                      ),
                    onMapCreated: onMapCreated,
                  )
                )
              ],
            ),
        )
      )
    );
  }

  Future<void> getCurrentPosition() async{
    final hasPermission= await handlePermission();
    if (!hasPermission) {
      return;
    }
    final position = await geolocatorPlatform.getCurrentPosition();
    updatePositionList(PositionItemType.position, position.toString());
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude,position.longitude),
          zoom: 15.0,
        )));
  }

  Future<bool> handlePermission() async{
    bool locationServiceEnabled;
    LocationPermission locationPermission;
    locationServiceEnabled=await geolocatorPlatform.isLocationServiceEnabled();
    if (!locationServiceEnabled) {
      updatePositionList(PositionItemType.log, "Location service di disable");
      return false;
    }
    locationPermission = await geolocatorPlatform.checkPermission();
    if (locationPermission == LocationPermission.denied) {
      locationPermission = await geolocatorPlatform.requestPermission();
      if (locationPermission == LocationPermission.denied) {
        updatePositionList(PositionItemType.log, "Permission denied");
        return false;
      }
    }
    if (locationPermission == LocationPermission.deniedForever) {
        updatePositionList(PositionItemType.log, "Permission denied forever");
        return false;
    }
    updatePositionList(PositionItemType.log, "Permission granted");
    return true;
  }
  void updatePositionList(PositionItemType type, String displayValue)
  {
    arrPositionItems.add(PositionItem(type, displayValue));
    setState(() {});
  }

  void onMapCreated(GoogleMapController gmapcontroller) {
    setState(() {
      controller = gmapcontroller;
    });
  }
}
enum PositionItemType {
  log,
  position
}
class PositionItem {
  PositionItem(this.type,this.displayValue);
  final PositionItemType type;
  final String displayValue;
}

