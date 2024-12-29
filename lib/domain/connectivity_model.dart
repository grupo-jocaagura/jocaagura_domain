part of '../jocaagura_domain.dart';

/// Enum [ConnectionTypeEnum] lists various types of network connections.
///
/// - **none**: No connection.
/// - **wifi**: Wireless internet connection.
/// - **wired**: Direct wired connection.
/// - **sim**: Cellular connection through SIM card.
/// - **bluetooth**: Connection via Bluetooth.
/// - **ethernet**: Standard Ethernet connection.
/// - **mobile**: Mobile network connection (e.g., 3G, 4G, 5G).
/// - **satellite**: Connection through satellite.
/// - **vpn**: Virtual Private Network connection.
/// - **hotspot**: Connection via a mobile or WiFi hotspot.
/// - **usb**: USB tethering connection.
/// - **nfc**: Near Field Communication connection.
/// - **other**: Other types of connections not specified.
enum ConnectionTypeEnum {
  none,
  wifi,
  wired,
  sim,
  bluetooth,
  ethernet,
  mobile,
  satellite,
  vpn,
  hotspot,
  usb,
  nfc,
  other,
}

/// Enum [ConnectivityModelEnum] defines the properties of [ConnectivityModel].
///
/// - **connectionType**: The type of network connection.
/// - **internetSpeed**: The internet speed in Mbps.
enum ConnectivityModelEnum {
  connectionType,
  internetSpeed,
}

/// Default instance of [ConnectivityModel] with no connection and zero internet speed.
const ConnectivityModel defaultConnectivityModel = ConnectivityModel(
  connectionType: ConnectionTypeEnum.none,
  internetSpeed: 0.0,
);

/// Represents a network connectivity status in a system.
///
/// The [ConnectivityModel] class encapsulates the type of network connection
/// and the internet speed, providing information about the user's connectivity.
///
/// Example usage:
///
/// ```dart
/// void main() {
///   var connectivity = ConnectivityModel(
///     connectionType: ConnectionTypeEnum.wifi,
///     internetSpeed: 100.5,
///   );
///
///   print('Connection Type: ${connectivity.connectionType}');
///   print('Internet Speed: ${connectivity.internetSpeed} Mbps');
///   print('Is Connected: ${connectivity.isConnected}');
/// }
/// ```
class ConnectivityModel extends Model {
  /// Constructs a new [ConnectivityModel] with the specified [connectionType]
  /// and [internetSpeed].
  const ConnectivityModel({
    required this.connectionType,
    required this.internetSpeed,
  });

  /// Deserializes a JSON map into an instance of [ConnectivityModel].
  ///
  /// The JSON map must contain keys corresponding to the properties of this class.
  factory ConnectivityModel.fromJson(Map<String, dynamic> json) {
    return ConnectivityModel(
      connectionType: getConnectionTypeEnumFromString(
        Utils.getStringFromDynamic(
          json[ConnectivityModelEnum.connectionType.name],
        ),
      ),
      internetSpeed:
          Utils.getDouble(json[ConnectivityModelEnum.internetSpeed.name]),
    );
  }

  /// The type of network connection.
  final ConnectionTypeEnum connectionType;

  /// The internet speed in Mbps.
  final double internetSpeed;

  /// Creates a copy of this [ConnectivityModel] with optional new values.
  @override
  ConnectivityModel copyWith({
    ConnectionTypeEnum? connectionType,
    double? internetSpeed,
  }) {
    return ConnectivityModel(
      connectionType: connectionType ?? this.connectionType,
      internetSpeed: internetSpeed ?? this.internetSpeed,
    );
  }

  /// Serializes this [ConnectivityModel] into a JSON map.
  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      ConnectivityModelEnum.connectionType.name: connectionType.name,
      ConnectivityModelEnum.internetSpeed.name: internetSpeed,
    };
  }

  /// Compares this [ConnectivityModel] to another object.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectivityModel &&
          runtimeType == other.runtimeType &&
          connectionType == other.connectionType &&
          internetSpeed == other.internetSpeed &&
          other.hashCode == hashCode;

  /// Returns the hash code for this [ConnectivityModel].
  @override
  int get hashCode => connectionType.hashCode ^ internetSpeed.hashCode;

  /// Gets the [ConnectionTypeEnum] from a string.
  ///
  /// If the string does not match any value, [ConnectionTypeEnum.other] is returned.
  static ConnectionTypeEnum getConnectionTypeEnumFromString(
    String typeAsString,
  ) {
    return ConnectionTypeEnum.values.firstWhere(
      (ConnectionTypeEnum value) =>
          value.name.toLowerCase() == typeAsString.toLowerCase(),
      orElse: () => ConnectionTypeEnum.other,
    );
  }

  /// Indicates whether the device is connected to any network.
  bool get isConnected => connectionType != ConnectionTypeEnum.none;

  /// Returns a string representation of this [ConnectivityModel].
  @override
  String toString() {
    return 'ConnectivityModel(connectionType: $connectionType, internetSpeed: '
        '$internetSpeed)';
  }
}
