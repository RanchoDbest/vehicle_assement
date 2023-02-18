import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vehicle_assesment/Model/data_model.dart';

const String dataBoxName = "data";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final document = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(document.path);
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(DataModelAdapter());
  }

  await Hive.openBox<DataModel>(dataBoxName);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),
      home: const MyHomePage(title: 'Vehicle Assesment'),
	    debugShowCheckedModeBanner: false,

    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
	final GlobalKey<FormState> _key = GlobalKey<FormState>();

	Box<DataModel>? dataBox;

  final TextEditingController averageController = TextEditingController();
  final TextEditingController yearsController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dataBox = Hive.box<DataModel>(dataBoxName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: ValueListenableBuilder(
                valueListenable: dataBox!.listenable(),
                builder: (context, Box<DataModel> items, _) {
                  List<int> keys = items.keys.cast<int>().toList();
				  print(dataBox!.keys.length.toString());
                  return ListView.separated(
                      itemBuilder: (_, index) {
                        final int key = keys[index];
                        final DataModel? data = items.get(key);
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Avg:' + data!.average.toString() + ' km/litre',
                                  style: TextStyle(fontSize: 16),
                                ),
                                Text('Years : ' + data!.years.toString(), style: TextStyle(fontSize: 16)),
                                if (data!.average >= 15 && data!.years <= 5) ...[
                                  Text(
                                    'Low Pollutant',
                                    style: TextStyle(color: Colors.green, fontSize: 16),
                                  ),
                                  Icon(
                                    Icons.directions_car,
                                    color: Colors.green,
                                  )
                                ] else if (data!.average >= 15 && data!.years >= 5) ...[
                                  Text(
                                    'Moderatly Pollutant',
                                    style: TextStyle(color: Colors.amber, fontSize: 16),
                                  ),
                                  Icon(
                                    Icons.directions_car,
                                    color: Colors.yellow,
                                  )
                                ] else ...[
                                  Text(
                                    'Pollutant',
                                    style: TextStyle(color: Colors.red, fontSize: 16),
                                  ),
                                  Icon(
                                    Icons.directions_car,
                                    color: Colors.red,
                                  )
                                ]
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, index) => Divider(),
                      itemCount: keys.length);
                }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Add Vehicle Details'),
                content: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    child: Form(
                      key: _key,
	                  child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          TextFormField(
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Field is required.';
                              return null;
                            },
                            decoration: InputDecoration(hintText: "Enter Vehicle Average"),
                            controller: averageController,
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          TextFormField(
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Field is required.';
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: "Enter Vehicle years",
                            ),
                            controller: yearsController,
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          ElevatedButton(
                            child: Text(
                              "Add Data",
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () {

	                            if (_key.currentState!.validate()) {
		                            // _key.currentState!.save();
		                            // print("form submitted.");
		                            final String average = averageController.text;
		                            final String years = yearsController.text;
		                            averageController.clear();
		                            yearsController.clear();
		                            DataModel data = DataModel(
			                            average: int.parse(average),
			                            years: int.parse(years),
		                            );
		                            dataBox?.add(data);
		                            Navigator.pop(context);
	                            }

                            },
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
        tooltip: 'Add Vehicle Details',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
