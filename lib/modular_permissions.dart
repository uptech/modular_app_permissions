import 'package:flutter/services.dart';

class ModularPermissions {
  static const MethodChannel _channelLocation =
      MethodChannel('ch.upte.modularLocationPermissions');

  static const String UNKNOWN = "unknown";
  static const String NOT_GRANTED = "not_granted";
  static const String DENIED = "denied";
  static const String RESTRICTED = "restricted";
  static const String GRANTED = "granted";

  static Future<ModularPermissionInfo> checkPermissionStatus(
      PermissionRequest request) async {
    var methodName = 'check${_getMethodNameFromType(request.permissionType)}';
    var channel = _getChannelFromType(request.permissionType);

    try {
      //Arguments are ignored in Android
      //Arguments are used in iOS only for Location
      final String result = await channel
          .invokeMethod(methodName, {'permissionArgs': request.arguments});
      return _permissionInfoFromType(request.permissionType, result);
    } catch (err) {
      return _handleError(err, request);
    }
  }

  static Future<ModularPermissionInfo> requestPermission(
      PermissionRequest request) async {
    var methodName = 'request${_getMethodNameFromType(request.permissionType)}';
    var channel = _getChannelFromType(request.permissionType);
    try {
      //Arguments are ignored in Android
      //Arguments are used in iOS only for Location
      final String result = await channel
          .invokeMethod(methodName, {'permissionArgs': request.arguments});
      return _permissionInfoFromType(request.permissionType, result);
    } catch (err) {
      return _handleError(err, request);
    }
  }

  static Future<void> openAppSettings(
      PermissionRequest permissionRequest) async {
    try {
      //On iOS this will open root settings. Limitation of iOS
      //On Android this will open the specific app's settings page.
      await _getChannelFromType(permissionRequest.permissionType)
          .invokeMethod('openAppSettings');
    } catch (err) {}
  }

  static String _getMethodNameFromType(PermissionType type) {
    var methodName = "";
    switch (type) {
      case PermissionType.LOCATION_ALWAYS:
      case PermissionType.LOCATION_WHEN_IN_USE:
        methodName = "LocationPermission";
        break;
    }
    return methodName;
  }

  static MethodChannel _getChannelFromType(PermissionType type) {
    switch (type) {
      case PermissionType.LOCATION_ALWAYS:
      case PermissionType.LOCATION_WHEN_IN_USE:
        return _channelLocation;
        break;
      default:
        return null;
    }
  }

  static ModularPermissionInfo _permissionInfoFromType(
      PermissionType type, String result) {
    switch (type) {
      case PermissionType.LOCATION_ALWAYS:
      case PermissionType.LOCATION_WHEN_IN_USE:
        return _handleResultForLocationPermission(result);
        break;
      default:
        return null;
    }
  }

  static ModularPermissionInfo _handleResultForLocationPermission(
      String result) {
    switch (result) {
      case DENIED:
        return ModularPermissionInfo(
            false, "The Location permission request was denied.");
      case RESTRICTED:
        return ModularPermissionInfo(false,
            "The Location permission request was permanently denied or restricted.");
      case GRANTED:
        return ModularPermissionInfo(
            true, "The Location permission request was granted.");
      case NOT_GRANTED:
        return ModularPermissionInfo(
            false, "The Location permission is not granted");
      case UNKNOWN:
      default:
        return ModularPermissionInfo(
            false, "Unable to determine status of Location permission request");
    }
  }

  static ModularPermissionInfo _handleError(
      dynamic error, PermissionRequest request) {
    print(error.toString());
    return ModularPermissionInfo(false,
        '${request.permissionType} request can not be handled. Do you have the correct permission module installed for ${request.permissionType}?');
  }
}

class ModularPermissionInfo {
  final bool granted;
  final String info;

  ModularPermissionInfo(this.granted, this.info);

  @override
  String toString() {
    return 'ModularPermissionInfo{granted: $granted, info: $info}';
  }
}

abstract class PermissionRequest {
  PermissionType permissionType;
  String arguments;
}

enum PermissionType {
  LOCATION_ALWAYS, //Android = FINE_LOCATION
  LOCATION_WHEN_IN_USE, //Android = FINE_LOCATION
}

class LocationAlwaysPermissionRequest extends PermissionRequest {
  @override
  PermissionType get permissionType => PermissionType.LOCATION_ALWAYS;

  @override
  String get arguments => "LocationAlways";
}

class LocationWhenInUsePermissionRequest extends PermissionRequest {
  @override
  PermissionType get permissionType => PermissionType.LOCATION_WHEN_IN_USE;

  @override
  String get arguments => "LocationWhenInUse";
}
