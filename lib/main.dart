import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter/services.dart';

void main() {
  runApp(CalculatorApp());
}

class CalculatorApp extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Compound Interest Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  @override
  _CalculatorPageState createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  // Define variables to hold form field values
  double principalAmount = 0.0;
  double rateOfInterest = 1.0;
  int compoundFrequency = 1;
  int numberOfYears = 1;
  double? result = 0.0;

  bool isFirstTime = false;

  final _formKey = GlobalKey<FormState>();

  Map<String, dynamic> formConfig = {
    "rateOfInterest": {
      "labelText": "Rate of Interest",
      "textColor": Colors.black,
      "textSize": 16.0,
      "values": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15],
      "valueLabels": ["1%", "2%", "3%", "4%", "5%", "6%", "7%", "8%", "9%", "10%", "11%", "12%", "13%", "14%", "15%"]
    },
    "principalAmount": {
      "labelText": "Principal Amount",
      "hintText": "Enter principal amount",
      "textColor": Colors.black,
      "textSize": 16.0,
      "minAmount": {
        "1": 10000,
        "2": 10000,
        "3": 10000,
        "4": 50000,
        "5": 50000,
        "6": 50000,
        "7": 50000,
        "8": 75000,
        "9": 75000,
        "10": 75000,
        "11": 75000,
        "12": 100000,
        "13": 100000,
        "14": 100000,
        "15": 100000
      },
      "maxAmount": 10000000,
      "errorMessages": {
        "min": "Minimum amount must be greater than or equal to {minAmount}",
        "max": "Maximum amount must be less than or equal to {maxAmount}"
      }
    },
    "compoundFrequency": {
      "labelText": "No. of times to compound in a year",
      "textColor": Colors.black,
      "textSize": 16.0,
      "values": {
        "12":[1],
        "6": [2],
        "3": [4],
      },
      "valueLabels": {
        "12":["1"],
        "6": ["2"],
        "3": ["4"],
      }
    },
    "numberOfYears": {
      "labelText": "No. of years",
      "textColor": Colors.black,
      "textSize": 16.0,
      "values": {
        "1": List.generate(10, (index) => index + 1),
        "2": List.generate(20, (index) => index + 1),
        "4": List.generate(30, (index) => index + 1)
      },
      "valueLabels": {
        "1": List.generate(10, (index) => (index + 1).toString()),
        "2": List.generate(20, (index) => (index + 1).toString()),
        "4": List.generate(30, (index) => (index + 1).toString())
      }
    },
    "outputValue": {
      "textColor": Colors.black,
      "labelText": "Compound Interest",
      "textSize": 16.0,
      "modeOfDisplay": "snackBar" // or "popUpDialog" or "textField"
    }
  };

  List<int> compoundFrequencies = [];


  Random random = Random();

  @override
  Widget build(BuildContext context) {

    var size = MediaQuery.of(context).size;
    print(formConfig["compoundFrequency"]["values"][rateOfInterest.toInt().toString()]);
    print(rateOfInterest.toInt().toString());

    compoundFrequencies = formConfig["compoundFrequency"]["values"][rateOfInterest.toInt().toString()] ?? [1,2,4];

    return Scaffold(
      //resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Compound Interest Calculator',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blue),),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
            
              children: [
                isFirstTime?SizedBox(height: size.height*0.06,):Container(),
                // Result display
                isFirstTime?Column(
                  children: [
                    Text(
                      'Compound Interest Earned',
                      style: TextStyle(fontSize: 18.0),
                    ),
                    Text(
                      result!.toStringAsFixed(2),
                      style: TextStyle(fontSize: 40.0,fontWeight: FontWeight.bold,color: Colors.green),
                    ),
                  ],
                ):Container(),
                SizedBox(height: size.height*0.02,),
                DropdownButtonFormField(
                  decoration: InputDecoration(
                    labelText: formConfig["rateOfInterest"]["labelText"], // Add label text from formConfig
                  ),
                  value: rateOfInterest,
                  items: formConfig["rateOfInterest"]["values"].map<DropdownMenuItem<double>>((value) {
                    return DropdownMenuItem<double>(
                      value: value.toDouble(),
                      child: Text(formConfig["rateOfInterest"]["valueLabels"][value - 1]),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      rateOfInterest = value!;
                      // Update other fields based on rate of interest
                      // You need to implement this logic
                    });
                  },
                ),
                // Principal amount input field
                TextFormField(
                  decoration: InputDecoration(
                    labelText: formConfig["principalAmount"]["labelText"],
                    hintText: formConfig["principalAmount"]["hintText"],
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Restrict to digits only
                  onChanged: (value) {
                    setState(() {
                      principalAmount = double.tryParse(value) ?? 0.0;
                    });
                  },
                  validator: (value) {
                    // Validate the principal amount
                    print("Checking Validator");
                    if (value!.isEmpty) {
                      print("Please enter principal amount");
                      return 'Please enter principal amount';
                    }
                    double amount = double.tryParse(value) ?? 0.0;
                    double maxAmount = double.parse(formConfig["principalAmount"]["maxAmount"].toString());
                    double minAmount = double.parse(formConfig["principalAmount"]["minAmount"][rateOfInterest.toInt().toString()].toString());

                    if (amount < minAmount) {
                      print("Checking min errorMessages");
                      return formConfig["principalAmount"]["errorMessages"]["min"].replaceAll("{minAmount}", minAmount.toString());
                    }
                    if (amount > maxAmount) {
                      print("Checking max errorMessages");
                      return formConfig["principalAmount"]["errorMessages"]["max"].replaceAll("{maxAmount}", maxAmount.toString());
                    }
                    print("Validation Succeeded");
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                // Rate of interest dropdown
            
                // Add other input fields and dropdowns similarly
                // Compound frequency dropdown
                DropdownButtonFormField(
                  decoration: InputDecoration(
                    labelText: formConfig["compoundFrequency"]["labelText"], // Add label text from formConfig
                  ),
                  value: compoundFrequencies[random.nextInt(compoundFrequencies.length)],
                  items: (formConfig["compoundFrequency"]["values"][rateOfInterest.toInt().toString()] ?? [1,2,4]).map<DropdownMenuItem<int>>((value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      compoundFrequency = value!.toInt();
                      // Update other fields based on compound frequency
                      // You need to implement this logic
                    });
                  },
                ),
                // Number of years dropdown
                DropdownButtonFormField(
                  decoration: InputDecoration(
                    labelText: formConfig["numberOfYears"]["labelText"], // Add label text from formConfig
                  ),
                  value: numberOfYears.toDouble(),
                  items: formConfig["numberOfYears"]["values"][compoundFrequency.toString()].map<DropdownMenuItem<double>>((value) {
                    return DropdownMenuItem<double>(
                      value: value.toDouble(),
                      child: Text(value.toString()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      numberOfYears = value!.toInt();
                    });
                  },
                ),
                SizedBox(height: 16.0),
                SizedBox(height: size.height*0.02,),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0), // <-- Radius
                        ),
                      padding: EdgeInsets.symmetric(vertical: 20)
                    ),
                    onPressed: () {
                      calculateCompoundInterest();
                    },
                    child: Text('Calculate',style: TextStyle(fontSize: 20),),
                  ),
                ),
            
              ],
            ),
          ),
        ),
      ),
    );
  }

  void calculateCompoundInterest() {

    // Calculate compound interest using the formula
    // A = P*(1+r/n)^(nt)
    if(!_formKey.currentState!.validate()){
      result = null;
      isFirstTime = false;
      return;
    }

    print("Calculating Results");
    isFirstTime = true;
    double A = principalAmount * pow(1 + rateOfInterest / (100 * compoundFrequency), compoundFrequency * numberOfYears);
    double compoundInterest = A - principalAmount;
    setState(() {
      result = compoundInterest;
    });
  }
}
