import 'package:blaulichtplaner_app/auth/authentication.dart';
import 'package:blaulichtplaner_app/widgets/loader.dart';
import 'package:blaulichtplaner_lib/blaulichtplaner.dart';
import 'package:flutter/material.dart';

class _CompanyLocation {
  final Location location;
  final DocumentReference companyRef;

  _CompanyLocation(this.location, this.companyRef);
}

class LocationView extends StatefulWidget {
  final List<DocumentReference> companyRefs;
  final bool favoritesForSelection;

  const LocationView(
      {Key key, @required this.companyRefs, this.favoritesForSelection = false})
      : super(key: key);

  @override
  _LocationViewState createState() => _LocationViewState();
}

class _LocationViewState extends State<LocationView> {
  List<_CompanyLocation> _locations;
  Set<DocumentReference> _favorites;
  DocumentReference favoritesRef;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    BlpUser user = UserManager.instance.user;
    favoritesRef =
        user.userRef.collection("settings").document("locationFavorites");
    _loadLocations();
    _loadFavorites();
  }

  void _loadFavorites() async {
    _favorites = Set();
    DocumentSnapshot snapshot = await favoritesRef.document;
    if (snapshot.exists) {
      List<DocumentReference> favorites =
          List.castFrom(snapshot.data["favorites"]);
      if (favorites != null) {
        setState(() {
          _favorites = Set.from(favorites);
        });
      }
    }
  }

  Future<void> _saveFavorites() async {
    for (DocumentReference favoriteLocation in _favorites.toList()) {
      final found = _locations.firstWhere((_CompanyLocation companyLocation) {
        return favoriteLocation == companyLocation.location.selfRef;
      }, orElse: () => null);
      if (found == null) {
        _favorites.remove(favoriteLocation);
      }
    }
  

    return favoritesRef.setData({"favorites": _favorites.toList()});
  }

  void _loadLocations() async {
    setState(() {
      _loading = true;
    });
    _locations = [];
    for (DocumentReference companyRef in widget.companyRefs) {
      QuerySnapshot snapshots = await companyRef
          .collection("locations")
          .orderBy("locationLabel")
          .getDocuments();
      for (DocumentSnapshot snapshot in snapshots.documents) {
        _locations.add(_CompanyLocation(
            Location.fromMap(snapshot.data, locationRef: snapshot.reference),
            companyRef));
      }
    }
    setState(() {
      _loading = false;
    });
  }

  Widget _itemBuilder(BuildContext context, int index) {
    _CompanyLocation companyLocation = _locations[index];
    Location location = companyLocation.location;
    return ListTile(
      title: Text(location.locationLabel),
      subtitle: location.hasAddress() ? Text(location.createAddress()) : null,
      trailing: IconButton(
        icon: Icon(_favorites.contains(location.selfRef)
            ? Icons.star
            : Icons.star_border),
        onPressed: () {
          setState(() {
            if (_favorites.contains(location.selfRef)) {
              _favorites.remove(location.selfRef);
            } else {
              _favorites.add(location.selfRef);
            }
          });
        },
      ),
    );
  }

  Widget _body() {
    if (widget.favoritesForSelection) {
      return Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "Wählen Sie hier Ihre bevorzugten Standorte aus. Ohne eine Auswahl werden alle Standorte angezeigt.",
              textAlign: TextAlign.center,
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: _locations.length,
            itemBuilder: _itemBuilder,
          )
        ],
      );
    } else {
      return ListView.builder(
        itemCount: _locations.length,
        itemBuilder: _itemBuilder,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.favoritesForSelection ? "Standortauswahl" : "Standorte"),
      ),
      body: WillPopScope(
        onWillPop: () async {
          _saveFavorites(); // won't await since it creates an issue on the framework side
          return true;
        },
        child: LoaderBodyWidget(
          loading: _loading,
          fallbackText: "Keine Standorte gefunden",
          empty: _locations == null || _locations.isEmpty,
          child: _body(),
        ),
      ),
    );
  }
}
