import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:via_cep_api/Services/location_service.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  String locationText = "";
  final LocationService locationService = LocationService();

  @override
  void initState() {
    super.initState();

    getLocation();
  }

  Future<void> getLocation() async {
    Position? position = await locationService.getCurrentLocation();

    if (position != null) {
      setState(() {
        locationText =
            "Latitude: ${position.latitude}, Longitude: ${position.longitude}";
      });
      return;
    }

    setState(() {
      locationText = "Localização não permitida";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(locationText)));
  }
}
