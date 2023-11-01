import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:weather_app/secrets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Future<Map<String, dynamic>> fetchWeatherData() async {
    try {
      String cityName = 'bhopal';
      final res = await http.get(
        Uri.parse(
          "https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$weatherApiKey",
        ),
      );
      final data = jsonDecode(res.body);
      if (data["cod"] != "200") {
        // Handle the error condition here
        throw 'An unhandeled error';
      }
      return data;
      // temp =
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Weather App',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {});
              },
              icon: const Icon(Icons.refresh))
        ],
      ),
      body: FutureBuilder(
        future: fetchWeatherData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LinearProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          final data = snapshot.data;
          final data1 = data?["list"][0];
          double currenttemp = (data1["main"]['temp'] - 273.15);
          final currenttemp2 = currenttemp.toStringAsFixed(2);
          final curretSky = data1["weather"][0]['main'];
          final pressure = data1["main"]['pressure'];
          final windspeed = data1["wind"]['speed'];
          final humidity = data1["main"]['humidity'];
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //MainCard Weather Forecast
                SizedBox(
                  width: double.infinity,
                  child: Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                Text(
                                  '$currenttemp2 °C',
                                  style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold),
                                ),
                                Icon(
                                  curretSky == 'Clouds' || curretSky == 'rain'
                                      ? Icons.cloud
                                      : Icons.sunny,
                                  size: 70,
                                ),
                                Text(
                                  curretSky,
                                  style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w500),
                                )
                              ],
                            ),
                          ),
                        ),
                      )),
                ),
                const SizedBox(height: 20),

                //Weather Forecast Title
                const Text("Weather Forecast",
                    style:
                        TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                SizedBox(
                  height: 140,
                  child: ListView.builder(
                    itemCount: 5,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final data1 = data?['list'][index + 1];
                      final sky =
                          data?['list'][index + 1]['weather'][0]['main'];
                      final time = DateTime.parse(data1['dt_txt']);
                      double temp=data1["main"]["temp"]-273.15;
                      final temp2=temp.toStringAsFixed(2);
                      return SmallCard(
                          time: DateFormat.j().format(time),
                          temp: "$temp2 °C" ,
                          icon: sky == 'Clouds' || sky == 'rain'
                              ? Icons.cloud
                              : Icons.sunny);
                    },
                  ),
                ),

                const SizedBox(height: 20),

                //Additional Information
                const Text("Additional Information",
                    style:
                        TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Additional(
                        icon: Icons.air,
                        label: 'Wind Speed',
                        value: windspeed.toString()),
                    Additional(
                        icon: Icons.water_drop,
                        label: 'humidity',
                        value: humidity.toString()),
                    Additional(
                        icon: Icons.beach_access_sharp,
                        label: 'Pressure',
                        value: pressure.toString()),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class Additional extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const Additional(
      {super.key,
      required this.icon,
      required this.label,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 20, 15, 15),
      child: Column(
        children: [
          Icon(
            icon,
            size: 40,
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
          ),
          Text(value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500))
        ],
      ),
    );
  }
}

class SmallCard extends StatelessWidget {
  final String time;
  final String temp;
  final IconData icon;
  const SmallCard(
      {super.key, required this.time, required this.temp, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Container(
        padding: const EdgeInsets.all(10),
        width: 120,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(
              time,
              style: const TextStyle(fontSize: 20),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Icon(
              icon,
              size: 40,
            ),
            Text(
              temp,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            )
          ],
        ),
      ),
    );
  }
}
