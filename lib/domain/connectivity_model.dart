part of '../jocaagura_domain.dart';

enum ConnectionTypeEnum {
  none,
  wifi,
  wired,
  sim,
  bluetooth,
  ethernet,
  mobile, // 3G, 4G, 5G, etc.
  satellite,
  vpn,
  hotspot,
  usb,
  nfc,
  other,
}

enum ConnectivityModelEnum {
  connectionType,
  internetSpeed,
}

const ConnectivityModel defaultConnectivityModel = ConnectivityModel(
  connectionType: ConnectionTypeEnum.none,
  internetSpeed: 0.0,
);

class ConnectivityModel extends Model {
  const ConnectivityModel({
    required this.connectionType,
    required this.internetSpeed,
  });

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
  final ConnectionTypeEnum connectionType;
  final double internetSpeed;

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

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      ConnectivityModelEnum.connectionType.name: connectionType.name,
      ConnectivityModelEnum.internetSpeed.name: internetSpeed,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectivityModel &&
          runtimeType == other.runtimeType &&
          connectionType == other.connectionType &&
          internetSpeed == other.internetSpeed &&
          other.hashCode == hashCode;

  @override
  int get hashCode => connectionType.hashCode ^ internetSpeed.hashCode;

  static ConnectionTypeEnum getConnectionTypeEnumFromString(
    String typeAsString,
  ) {
    return ConnectionTypeEnum.values.firstWhere(
      (ConnectionTypeEnum value) =>
          value.name.toLowerCase() == typeAsString.toLowerCase(),
      orElse: () => ConnectionTypeEnum.other,
    );
  }

  bool get isConnected => connectionType != ConnectionTypeEnum.none;

  @override
  String toString() {
    return 'ConnectivityModel(connectionType: $connectionType, internetSpeed: '
        '$internetSpeed)';
  }
}
