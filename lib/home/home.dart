import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math' as math;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool hasPermission = false;

  @override
  void initState() {
    super.initState();
    fetchPermissions();
  }

  void fetchPermissions() {
    Permission.locationWhenInUse.status.then((status) {
      if (mounted) {
        setState(() {
          hasPermission = (status == PermissionStatus.granted);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) {
          if (hasPermission) {
            return buildCompass();
          } else {
            return buildPermissionsSheet();
          }
        },
      ),
    );
  }

  Widget buildCompass() {
    return StreamBuilder(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
              child: Text("Error reading heading: ${snapshot.error}"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        double? direction = snapshot.data!.heading;

        if (direction == null) {
          return const Center(
            child: Text("Device does not have sensors"),
          );
        }
        return Center(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Transform.rotate(
              angle: direction * (math.pi / 180) * -1,
              child: Image.asset("lib/image/compass.png"),
            ),
          ),
        );
      },
    );
  }

  Widget buildPermissionsSheet() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Permission.locationWhenInUse.request().then((value) {
            fetchPermissions();
          });
        },
        child: const Text(
          "Request Permissions"
        ),
      ),
    );
  }
}
