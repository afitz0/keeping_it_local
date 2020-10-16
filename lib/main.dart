import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:keeping_it_local/dark_notifier.dart';
import 'package:keeping_it_local/constants.dart';
import 'package:keeping_it_local/spreadsheet.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'dart:async';
import 'dart:convert';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => DarkNotifier(),
      ),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Data Access Demo',
      theme: ThemeData(
        brightness: Provider.of<DarkNotifier>(context).isDark
            ? Brightness.dark
            : Brightness.light,
        canvasColor: Theme.of(context).brightness == Brightness.dark ||
                Provider.of<DarkNotifier>(context).isDark
            ? Colors.black45
            : Colors.white,
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Keeping. It Local."),
      ),
      body: Consumer<DarkNotifier>(
        builder: (context, dark, child) {
          return Center(
            child: Clouds(dark: dark.isDark),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          bool isDark =
              Provider.of<DarkNotifier>(context, listen: false).isDark;
          Provider.of<DarkNotifier>(context, listen: false).darkMode = !isDark;
        },
        child: Icon(Icons.brightness_medium),
      ),
      drawer: Drawer(
        child: Container(
          child: ListView(
            children: <Widget>[
              DrawerHeader(
                child: Text('Other Cloudy Things'),
              ),
              ListTile(
                title: Text('Cloudy Data Input'),
                onTap: () => {
                  Navigator.pop(context),
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Spreadsheet()),
                  ),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Clouds extends StatelessWidget {
  const Clouds({
    Key key,
    @required bool dark,
  })  : _isDark = dark,
        super(key: key);

  final bool _isDark;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Cloud>>(
      future: fetchClouds(_isDark),
      builder: (context, snapshot) {
        if (snapshot.hasError) print(snapshot.error);

        return snapshot.hasData
            ? CloudsList(clouds: snapshot.data)
            : Center(child: CircularProgressIndicator());
      },
    );
  }
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

Future<List<Cloud>> fetchClouds(bool darkMode) async {
  try {
    final response = await http.Client()
        .get(backendHost + '/list?dark=' + darkMode.toString());
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
      cacheExtent: 0,
      separatorBuilder: (context, index) => SizedBox(
        height: 10,
      ),
      itemCount: clouds.length,
      padding: EdgeInsets.all(8.0),
      // TODO clean this up, break it up.
      itemBuilder: (context, index) {
        return SizedBox(
          height: screenHeight * .2,
          child: PhysicalModel(
            shadowColor: Colors.lightBlue,
            elevation: 8.0,
            color: Provider.of<DarkNotifier>(context).isDark
                ? Colors.black26
                : Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(20)),
            // TODO "live code #3" add an "onTap" feature that downloads a big file.
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
                      child: CloudImage(
                          imageUrl: backendHost + '/' + clouds[index].url),
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

      // TODO make this a snippet
      // child: CachedNetworkImage(
      //   imageUrl: imageUrl,
      //   placeholder: (context, url) =>
      //       Center(child: CircularProgressIndicator()),
      //   errorWidget: (context, url, error) => Icon(Icons.error),
      //   fadeInDuration: const Duration(milliseconds: 100),
      // ),
      // TODO "live code #2" switch this to a CachedNetworkImage.
      child: Image.network(
        imageUrl,
        loadingBuilder: (_, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
