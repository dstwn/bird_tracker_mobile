import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:mobile_apps/model/Data.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DeviceScreen extends StatefulWidget {
  final BluetoothDevice device;
  DeviceScreen({Key key, @required this.device}) : super(key: key);

  @override
  _DeviceScreenState createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {

  static String CHARACTERISTIC_UUID = "beb5483e-36e1-4688-b7f5-ea07361b26a8";

  String _dataParser(List<int> dataFromDevice) {
    var decode = utf8.decode(dataFromDevice);
    return decode;
  }

  GoogleMapController mapController;

  final LatLng _center = const LatLng(45.521563, -122.677433);
  
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Widget _myService(List<BluetoothService> services) {
    Stream<List<int>> stream;

    services.forEach((service) {
      service.characteristics.forEach((character) {
        if (character.uuid.toString() == CHARACTERISTIC_UUID) {
          character.setNotifyValue(!character.isNotifying);
          stream = character.value;
        }
      });
    });

    return Container(
      child: StreamBuilder<List<int>>(
          stream: stream,
          builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
            if (snapshot.hasError) return Text('Error : ${snapshot.error}');

            if (snapshot.connectionState == ConnectionState.active) {
              var currentValue = _dataParser(snapshot.data);
              //_getNewDataSet(currentValue);
              var high = currentValue.split(",")[0];
              var speed = currentValue.split(",")[1];
              var lt = currentValue.split(",")[2];
              var lg = currentValue.split(",")[3];
              return new Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 50),
                    new Container(
                      width : 500.0,
                      height : 500.0,
                      child: new GoogleMap(
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: _center,
                          zoom: 11.0,
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    Text(
                      "high: ${high}, speed: ${speed}, latitude: ${lt}, longitude: ${lg}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            } else {
              return Text('Check the stream');
            }
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Provider<DataBird>(
      create: (context) => DataBird(),
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: Text("Birds Tracker"),
            actions: <Widget>[
              StreamBuilder<BluetoothDeviceState>(
                stream: widget.device.state,
                initialData: BluetoothDeviceState.connecting,
                builder: (c, snapshot) {
                  VoidCallback onPressed;
                  String text;
                  switch (snapshot.data) {
                    case BluetoothDeviceState.connected:
                      onPressed = () => widget.device.disconnect();
                      text = 'DISCONNECT';
                      break;
                    case BluetoothDeviceState.disconnected:
                      onPressed = () => widget.device.connect();
                      text = 'CONNECT';
                      break;
                    default:
                      onPressed = null;
                      text =
                          snapshot.data.toString().substring(21).toUpperCase();
                      break;
                  }
                  return FlatButton(
                      onPressed: onPressed,
                      child: Text(
                        text,
                        style: Theme.of(context)
                            .primaryTextTheme
                            .button
                            .copyWith(color: Colors.white),
                      ));
                },
              )
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                StreamBuilder<BluetoothDeviceState>(
                  stream: widget.device.state,
                  initialData: BluetoothDeviceState.connecting,
                  builder: (c, snapshot) => ListTile(
                    leading: (snapshot.data == BluetoothDeviceState.connected)
                        ? Icon(Icons.bluetooth_connected)
                        : Icon(Icons.bluetooth_disabled),
                    title: Text(
                        'Device is ${snapshot.data.toString().split('.')[1]}.'),
                    subtitle: Text('${widget.device.name}'),
                    trailing: StreamBuilder<bool>(
                      stream: widget.device.isDiscoveringServices,
                      initialData: false,
                      builder: (c, snapshot) => IndexedStack(
                        index: snapshot.data ? 1 : 0,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.refresh),
                            onPressed: () => widget.device.discoverServices(),
                          ),
                          IconButton(
                            icon: SizedBox(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(Colors.grey),
                              ),
                              width: 18.0,
                              height: 18.0,
                            ),
                            onPressed: null,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                StreamBuilder<List<BluetoothService>>(
                  stream: widget.device.services,
                  initialData: [],
                  builder: (c, snapshot) {
                    return _myService(snapshot.data);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
