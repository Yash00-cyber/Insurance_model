import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(InsuranceApp());
}

class InsuranceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: InsuranceForm(),
    );
  }
}

class InsuranceForm extends StatefulWidget {
  @override
  _InsuranceFormState createState() => _InsuranceFormState();
}

class _InsuranceFormState extends State<InsuranceForm> {
  final TextEditingController ageController = TextEditingController();
  final TextEditingController bmiController = TextEditingController();
  final TextEditingController childrenController = TextEditingController();
  final TextEditingController smokerController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController regionNwController = TextEditingController();
  final TextEditingController regionSeController = TextEditingController();
  final TextEditingController regionSwController = TextEditingController();

  String result = "";

  // Function to determine API URL based on the platform
  String getApiUrl() {
    return "http://192.168.1.8:5000/predict"; // Use for emulator
    // return "http://your-server-ip:5000/predict"; // Use this for a real device on the same network
  }

  Future<void> predictInsuranceCost() async {
    try {
      final response = await http.post(
        Uri.parse(getApiUrl()),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "age": int.parse(ageController.text),
          "bmi": double.parse(bmiController.text),
          "children": int.parse(childrenController.text),
          "smoker": int.parse(smokerController.text),
          "gender": int.parse(genderController.text),
          "region_nw": int.parse(regionNwController.text),
          "region_se": int.parse(regionSeController.text),
          "region_sw": int.parse(regionSwController.text),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          result = "Estimated Cost: ₹${data['estimated_cost']}";
        });
      } else {
        setState(() {
          result = "Error: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        result = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Medical Insurance Cost Prediction")),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(controller: ageController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Age")),
              TextField(controller: bmiController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "BMI")),
              TextField(controller: childrenController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Children")),
              TextField(controller: smokerController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Smoker (1: Yes, 0: No)")),
              TextField(controller: genderController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Gender (1: Male, 0: Female)")),
              TextField(controller: regionNwController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Region NW (1 or 0)")),
              TextField(controller: regionSeController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Region SE (1 or 0)")),
              TextField(controller: regionSwController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Region SW (1 or 0)")),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(onPressed: predictInsuranceCost, child: Text("Predict Cost")),
              ),
              SizedBox(height: 20),
              Center(
                child: Text(result, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
