import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:api_example_app/LandingScreen/components/control_button.dart';
import 'package:api_example_app/LandingScreen/components/custom_card.dart';
import 'package:api_example_app/LandingScreen/components/MQTTClientManager.dart';
import 'package:mqtt_client/mqtt_client.dart';

import '../../constants.dart';

class LandingScreenBody extends StatefulWidget {
  @override
  _LandingScreenBodyState createState() => _LandingScreenBodyState();
}

class _LandingScreenBodyState extends State<LandingScreenBody> {
  //late List<String> log;
  double _temp = 24;
  String TempRec = "";
  String AcData = "";
  String TempSet = "";
  String DoorData = "";
  final teste = <String>["", "", ""];
  final data = List<String>.filled(4, "");
  var log = List<String>.filled(4, "");

  MQTTClientManager mqttClientManager = MQTTClientManager();
  final String pubTopic = "test/ac_control";
  @override
  void initState() {
    setupMqttClient();
    //receiveTempMQTT();
    setupUpdatesListener();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(height: size.height * 0.05),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LISHA Control App',
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: kDarkGreyColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
              Container(
                height: 72,
                width: 108,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    "assets/images/lisha-site.png",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.1),
          Center(
            child: Text(
              'Choose what you want to control in the lab.',
              textAlign: TextAlign.center,
              style: TextStyle(color: kDarkGreyColor, fontSize: 18),
            ),
          ),
          SizedBox(height: size.height * 0.0001),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomCard(
                size: size,
                icon: Icon(
                  Icons.thermostat_outlined,
                  size: 40,
                  color: Colors.grey.shade400,
                ),
                title: "AC ON",
                statusOn: "ON",
                statusOff: "OFF",
                notifyOnState: _ACOn,
                notifyOffState: _ACOff,
              ),
              Column(
                children: [
                  Text(
                    "AC Temperature:\n$_temp ºC",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "Room Temperature:\n${data[3]} ºC",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              new ControlButton(
                size: size,
                title: 'Decrease\nTemperature',
                icon: Icons.exposure_minus_1_outlined,
                notifyButton: _decrementTemp,
              ),
              new ControlButton(
                size: size,
                title: 'Increase\nTemperature',
                icon: Icons.plus_one,
                notifyButton: _incrementTemp,
              ),
              new ControlButton(
                size: size,
                title: 'LISHA\nAccess',
                icon: Icons.vpn_key,
                notifyButton: _DoorOpen,
              ),
            ],
          ),
          Column(
            children: [
              Text(
                "System Log:",
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              Text(
                "AC status: ${log[0]}, AC elected temperatura: ${log[1]}, Door status: ${log[2]}, Room temperature: ${log[3]}!\n",
                style: TextStyle(fontSize: 12, color: Colors.black),
                textAlign: TextAlign.center,
              )
            ],
          ),
          SizedBox(height: size.height * 0.05),
        ],
      ),
    );
  }

  void _incrementTemp() {
    setState(() {
      _temp++;
      print("Updated temp+: $_temp");
      data[1] = _temp.toString();
      //TempSet = _temp.toString();
      mqttClientManager.publishMessage(
          pubTopic, "${data[0]},${data[1]},${data[2]},${data[3]}");
    });
  }

  void _decrementTemp() {
    setState(() {
      _temp--;
      print("Updated temp-: $_temp");
      data[1] = _temp.toString();
      //TempSet = _temp.toString();
      mqttClientManager.publishMessage(
          pubTopic, "${data[0]},${data[1]},${data[2]},${data[3]}");
      // pubTopic, "${AcData},${TempSet},${DoorData},${TempRec}");
    });
  }

  void _ACOn() {
    setState(() {
      data[0] = "ON";
      //AcData = "ON";
      mqttClientManager.publishMessage(
          pubTopic, "${data[0]},${data[1]},${data[2]},${data[3]}");
      // pubTopic, "${AcData},${TempSet},${DoorData},${TempRec}");
    });
  }

  void _ACOff() {
    setState(() {
      data[0] = "OFF";
      mqttClientManager.publishMessage(
          pubTopic, "${data[0]},${data[1]},${data[2]},${data[3]}");
      // pubTopic, "${AcData},${TempSet},${DoorData},${TempRec}");
    });
  }

  void _DoorOpen() {
    setState(() {
      data[2] = "OPEN";
      //DoorData = "OPEN";
      mqttClientManager.publishMessage(
          pubTopic, "${data[0]},${data[1]},${data[2]},${data[3]}");
      // pubTopic, "${AcData},${TempSet},${DoorData},${TempRec}");
      data[2] = "CLOSED";
    });
  }

  Future<void> setupMqttClient() async {
    await mqttClientManager.connect();
    mqttClientManager.subscribe(pubTopic);
  }

  void setupUpdatesListener() {
    mqttClientManager
        .getMessagesStream()!
        .listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final message =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      print(
          'MQTTClient::Message received on topic: <${c[0].topic}> is $message\n');
      setState(() {
        List<String> aux = message.split(",");
        data[3] = aux.last;
        log = aux;
        print(
            "RECEIVE TEMPERATURE: ${data[3]} | split list: $aux and log list: $log, log list 2: ${log[3]}");
      });
    });
  }

  @override
  void dispose() {
    mqttClientManager.disconnect();
    super.dispose();
  }
}
