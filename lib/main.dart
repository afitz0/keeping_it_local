import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:convert';

final host = "http://localhost:8080";

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Data Access Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isDark = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Keeping. It. Local."),
      ),
      body: Center(
        // DON'T DO THIS IN REAL LIFE
        child: FutureBuilder<bool>(
          future: fetchPrefs(http.Client()),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            return FutureBuilder<List<Cloud>>(
              future: fetchClouds(http.Client(), _isDark),
              builder: (context, snapshot) {
                if (snapshot.hasError) print(snapshot.error);

                return snapshot.hasData
                    ? CloudsList(clouds: snapshot.data)
                    : Center(child: CircularProgressIndicator());
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() => _isDark = !_isDark);
        },
        child: Icon(Icons.brightness_medium),
      ),
    );
  }
}

Future<bool> fetchPrefs(http) {
  var response = http.Client().get(host + '/prefs');
  final parsed = jsonDecode(response.body);
  return parsed["dark"];
}

class Cloud {
  final String url;
  final String title;
  final double price;
  final String currencySymbol;
  final int rating;

  Cloud({this.title, this.price, this.currencySymbol, this.rating, this.url});

  factory Cloud.fromJson(Map<String, dynamic> json) {
    return Cloud(
      price: json['price'] as double,
      currencySymbol: json['currency'] as String,
      url: json['url'] as String,
      rating: json['rating'] as int,
      title: json['title'] as String,
    );
  }
}

List<Cloud> parseClouds(String responseBody) {
  final parsed = jsonDecode(responseBody);
  return parsed["clouds"].map<Cloud>((json) => Cloud.fromJson(json)).toList();
}

Future<List<Cloud>> fetchClouds(http.Client client, bool darkMode) async {
  try {
    final response =
        await client.get(host + '/list?dark=' + darkMode.toString());
    return parseClouds(response.body);
  } catch (e) {
    print(e);
  }

  return new Future(() => <Cloud>[]);
}

class CloudsList extends StatelessWidget {
  final List<Cloud> clouds;

  CloudsList({Key key, this.clouds}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;

    return ListView.separated(
      separatorBuilder: (context, index) => SizedBox(
        height: 10,
      ),
      itemCount: clouds.length,
      padding: EdgeInsets.all(8.0),
      itemBuilder: (context, index) {
        return SizedBox(
          height: screenHeight * .2,
          child: PhysicalModel(
            shadowColor: Colors.lightBlue,
            elevation: 8.0,
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(20)),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.lightBlue),
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child:
                          CloudImage(imageUrl: host + '/' + clouds[index].url),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(clouds[index].title),
                          Text(clouds[index].currencySymbol +
                              clouds[index].price.toStringAsFixed(2)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (int i = 0; i < clouds[index].rating; i++)
                                Text("☁️")
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class CloudImage extends StatelessWidget {
  const CloudImage({
    Key key,
    @required this.imageUrl,
  }) : super(key: key);

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(90)),
      child: Image.network(
        imageUrl,
        loadingBuilder: (_, Widget child, ImageChunkEvent loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
