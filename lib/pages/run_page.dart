import 'package:flutter/material.dart';
import 'package:movite_app/components/datetime_selector.dart';
import 'package:movite_app/components/place_selector.dart';
import 'package:movite_app/pages/search_page.dart';

class RunPage extends StatefulWidget {
  static String tag = 'run-page';

  @override
  _RunPageState createState() => new _RunPageState();
}

class _RunPageState extends State<RunPage> {
  final _formKey = GlobalKey<FormState>();

  final fromController = TextEditingController();
  final toController = TextEditingController();
  final dateController = TextEditingController();

  void showBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: new Text(value),
      behavior: SnackBarBehavior.floating,
      elevation: 8,
    ));
  }

  @override
  Widget build(BuildContext context) {
    Map args = ModalRoute.of(context).settings.arguments;

    if (args != null) {
      if (args.containsKey('showBar3')) {
        if (args['showBar3']) {
          args['showBar3'] = false;
          WidgetsBinding.instance.addPostFrameCallback(
                  (_) => showBar("Run offered"));
        }
      }
      if (args.containsKey('showBar4')) {
        if (args['showBar4']) {
          args['showBar4'] = false;
          WidgetsBinding.instance.addPostFrameCallback(
                  (_) => showBar("Request sent"));
        }
      }

    }

    return new Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
            children: <Widget>[
              Text(
                "Da dove parti?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 20.0,
                ),
              ),
              PlaceSelector("Da", fromController, true),
              SizedBox(
                height: 5,
              ),
              Text(
                "Dove vuoi andare?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 20.0,
                ),
              ),
              PlaceSelector("A", toController, false),
              SizedBox(
                height: 5,
              ),
              Text(
                "Quando?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 20.0,
                ),
              ),
              DatetimeSelector("Quando", dateController),
              SizedBox(
                height: 5,
              ),
              Align(
                  child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchPage(),
                            ),
                          );
                        }
                      },
                      child: Text('Search',
                          style: TextStyle(color: Colors.white)))),
            ],
          ),
        ),
      ),
    );
  }
}

/*
var uuid = new Uuid();

class CustomSearchScaffold extends PlacesAutocompleteWidget {
  CustomSearchScaffold()
      : super(
    apiKey: kGoogleApiKey,
    sessionToken: uuid.v4(),
    language: "en",
    components: [Component(Component.country, "it")],
  );

  @override
  _CustomSearchScaffoldState createState() => _CustomSearchScaffoldState();
}

class _CustomSearchScaffoldState extends PlacesAutocompleteState {
  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(title: AppBarPlacesAutoCompleteTextField());
    final body = PlacesAutocompleteResult(
      onTap: (p) {
        print(p.toString());
      },
      logo: Row(
        children: [FlutterLogo()],
        mainAxisAlignment: MainAxisAlignment.center,
      ),
    );
    return Scaffold(appBar: appBar, body: body);
  }

  @override
  void onResponseError(PlacesAutocompleteResponse response) {
    super.onResponseError(response);

    //

  }

  @override
  void onResponse(PlacesAutocompleteResponse response) {
    super.onResponse(response);
    if (response != null && response.predictions.isNotEmpty) {

      //
    }
  }
}

 */
