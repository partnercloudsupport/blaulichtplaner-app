import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Über Blaulichtplaner"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                        "Blaulichtplaner - Die Platform für das Notärzte Netwerk"),
                    Text("Vernetzung, Dienstplanung, Abrechnung"),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        "Technische Umsetzung",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Text("GrundID GmbH\nHebelstr. 6\n74831 Gundelsheim"),
                  ]),
            ),
            LinkListTile(title: "www.grundid.de", url: "https://grundid.de"),
            LinkListTile(
                title: "info@blaulichtplaner.de",
                url: "mailto:info@blaulichtplaner.de"),
            /*LinkListTile(
                title: "Datenschutzerklärung anzeigen",
                url: "https://blaulichtplaner.de"),*/
          ],
        ),
      ),
    );
  }
}

class LinkListTile extends StatelessWidget {
  final String title;
  final String url;

  const LinkListTile({
    Key key,
    @required this.title,
    @required this.url,
  }) : super(key: key);

  _launchUrl() async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Can not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: _launchUrl,
      title: Text(title),
      trailing: IconButton(
        icon: Icon(Icons.open_in_new),
        onPressed: _launchUrl,
      ),
    );
  }
}
