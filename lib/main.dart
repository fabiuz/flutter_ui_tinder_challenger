import 'package:flutter/material.dart';
import './cards.dart';
import './matches.dart';
import './profiles.dart';

void main() => runApp(new MyApp());
final MatchEngine matchEngine = MatchEngine(
  matches: demoProfiles.map((Profile profile){
    return DateMatch(profile: profile);
  }).toList()
);

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primaryColorBrightness: Brightness.light,
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      leading: IconButton(
        icon: Icon(
          Icons.person,
          color: Colors.grey,
          size: 40.0,
        ),
        onPressed: (){},
      ),
      title: FlutterLogo(size: 30.0, colors: Colors.red),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.person,
            color: Colors.grey,
            size: 40.0,
          ),
          onPressed: () {},
        ),
      ],
      centerTitle: true,
    );
  }

  Widget _buildBottomBar() {
    return BottomAppBar(
      color: Colors.transparent,
      elevation: 0.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            RoundIconButton.small(
              icon: Icons.refresh,
              iconColor: Colors.orange,
              onPressed: () {},
            ),
            RoundIconButton.large(
              icon: Icons.clear,
              iconColor: Colors.red,
              onPressed: () {
                matchEngine.currentMatch.nope();
              },
            ),
            RoundIconButton.small(
              icon: Icons.star,
              iconColor: Colors.blue,
              onPressed: () {
                matchEngine.currentMatch.superLike();
              },
            ),
            RoundIconButton.large(
              icon: Icons.favorite,
              iconColor: Colors.green,
              onPressed: () {
                matchEngine.currentMatch.like();
              },
            ),
            RoundIconButton.small(
              icon: Icons.lock,
              iconColor: Colors.purple,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: _buildAppBar(),
      body: CardStack(
        matchEngine: matchEngine,
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }
}

class RoundIconButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final double size;
  final VoidCallback onPressed;

  RoundIconButton.large({
    this.icon,
    this.iconColor,
    this.onPressed,
  }) : size = 60.0;

  RoundIconButton.small({
    this.icon,
    this.iconColor,
    this.onPressed,
  }) : size = 50.0;

  RoundIconButton({
    this.icon,
    this.iconColor,
    this.size,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0x11000000),
            blurRadius: 10.0,
          )
        ],
      ),
      child: RawMaterialButton(
        shape: CircleBorder(),
        elevation: 0.0,
        child: Icon(
          icon,
          color: iconColor,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
