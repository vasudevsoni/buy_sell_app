// import 'package:country_state_city_pro/country_state_city_pro.dart';
// import 'package:csc_picker/csc_picker.dart';
// import 'package:flutter/material.dart';
// import '../../widgets/custom_text_field.dart';

// class LocationManualScreen extends StatefulWidget {
//   static const String routeName = '/location-manual-screen';
//   const LocationManualScreen({super.key});

//   @override
//   State<LocationManualScreen> createState() => _LocationManualScreenState();
// }

// class _LocationManualScreenState extends State<LocationManualScreen> {
//   String? countryValue = "";
//   String? stateValue = "";
//   String? cityValue = "";
//   String address = "";
//   TextEditingController locationController = TextEditingController();

//   @override
//   void dispose() {
//     locationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0.2,
//         backgroundColor: Colors.white,
//         iconTheme: const IconThemeData(color: Colors.black),
//         centerTitle: true,
//         title: const Text(
//           'Set location manually',
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: 15,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(15.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               CustomTextField(
//                 controller: locationController,
//                 label: 'Search for city, area or neighbourhood',
//                 hint: 'Enter your email address',
//                 keyboardType: TextInputType.text,
//                 maxLength: 40,
//               ),
//               const SizedBox(
//                 height: 20,
//               ),
//               CSCPicker(
//                 layout: Layout.vertical,
//                 flagState: CountryFlag.DISABLE,
//                 defaultCountry: DefaultCountry.India,
//                 disableCountry: true,
//                 searchBarRadius: 10,
//                 onCountryChanged: (value) {
//                   setState(() {
//                     countryValue = value;
//                   });
//                 },
//                 onStateChanged: (value) {
//                   setState(() {
//                     stateValue = value;
//                   });
//                 },
//                 onCityChanged: (value) {
//                   setState(() {
//                     cityValue = value;
//                     address = '$cityValue, $stateValue, $countryValue';
//                   });
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
