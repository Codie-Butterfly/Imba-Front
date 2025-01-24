import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:imba/ui/layouts/home_layout.dart';
import 'package:imba/ui/screens/search_results.dart';
import 'package:intl/intl.dart';

import '../../bloc/user/user_bloc.dart';
import '../../utilities/constants.dart';
import '../widgets/custom_drop_down_button.dart';
import '../widgets/custom_elevated_button.dart';
import '../widgets/custom_search_range.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/date_formatter.dart';
import '../widgets/house_details_widget.dart';
import '../widgets/logo.dart';
import 'edit_property.dart';

class Search extends StatefulWidget {
  final List<String> types;
  final List<String> classifications;

  const Search({Key? key, required this.types, required this.classifications})
      : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  bool isChecked = false;

  final contactText = TextEditingController();
  bool validate = false;
  final _areaController = TextEditingController();
  final _cityController = TextEditingController();
  final _contactController = TextEditingController();
  final _minRentController = TextEditingController();
  final _maxRentController = TextEditingController();
  final _minRoomsController = TextEditingController();
  final _maxRoomsController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _SearchFieldController = TextEditingController();
  var classificationsValue = '';
  var typeValue = "";
  var isBorehole = false;
  var isSolar = false;
  var isWater = false;
  var isElectricity = false;
  var isGated = false;
  var isTiled = false;
  var isWalled = false;
  var isDeposit = false;
  late final UserBloc userBloc;
  var isStartSelected = false;
  var isEndSelected = false;

  @override
  void initState() {
    userBloc = BlocProvider.of<UserBloc>(context);
    _contactController.text = userBloc.userPhoneNumber;
    classificationsValue = widget.classifications[0];
    typeValue = widget.types[0];

    super.initState();
  }

  @override
  void dispose() {
    contactText.dispose();
    _areaController.dispose();
    _cityController.dispose();
    _contactController.dispose();
    _minRentController.dispose();
    _maxRentController.dispose();
    _minRoomsController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();

    super.dispose();
  }

  static GlobalKey<FormState> formKey = GlobalKey<FormState>(); //key for form
  DateTime currentDate = DateTime.now();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return HomeLayout(
        hasBack: true,
        title: 'Search Houses',
        isSuccess: false,
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: TextField(
                    controller: _SearchFieldController,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Enter search value',
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 10.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: ColorConstants.yellow),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: ColorConstants.yellow),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: ColorConstants.yellow)),
                    ),
                  ),
                ),
              ),

              CustomTextField(
                readOnly: false,
                hintText: '',
                labelText: 'Area',
                controller: _areaController,
                onChanged: (value) {
                  if (formKey.currentState!.validate()) {}
                },
              ),
              CustomTextField(
                readOnly: false,
                hintText: '',
                labelText: 'City',
                controller: _cityController,
                onChanged: (value) {
                  if (formKey.currentState!.validate()) {}
                },
                // validator: (value) {
                //   if (value == null || value.isEmpty) {
                //     return 'Please enter city';
                //   }
                //   return null;
                // },
              ),
              //  const   CustomTextField(hintText: '', labelText: 'Type',),
              _buildDropdownField(
                label: 'Type',
                value: typeValue,
                items: widget.types,
                onChanged: (newValue) =>
                    setState(() => typeValue = newValue.toString()),
              ),
              CustomTextField(
                readOnly: false,
                hintText: '',
                labelText: 'Contact',
                controller: _contactController,
                onChanged: (value) {
                  if (formKey.currentState!.validate()) {}
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter contact';
                  }
                  if (!value.startsWith("+")) {
                    return 'enter country code';
                  }
                  return null;
                },
              ),
              _buildDropdownField(
                label: 'Classification',
                value: classificationsValue,
                items: widget.classifications,
                onChanged: (newValue) =>
                    setState(() => classificationsValue = newValue.toString()),
              ),
              SearchRangeTextfield(
                name: 'Rentals',
                maxHint: 'max',
                minHint: 'min',
                minController: _minRentController,
                maxController: _maxRentController,
                onChanged: (value) {
                  if (formKey.currentState!.validate()) {}
                },
              ),

              SearchRangeTextfield(
                name: 'Number of Rooms',
                maxHint: 'max',
                minHint: 'min',
                minController: _minRoomsController,
                maxController: _maxRoomsController,
                onChanged: (value) {
                  if (formKey.currentState!.validate()) {}
                },
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 10),
                    child: Text("Occupation Date",
                        style: GoogleFonts.montserrat(
                            fontSize: 16, color: Colors.black87)),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: buildDateTextField(
                          controller: _startDateController,
                          hintText:
                              DateFormat.yMMMMd('en_US').format(startDate),
                          fieldType: 'start',
                          onTap: () {
                            setState(() {
                              isStartSelected = true;
                            });
                            _selectDate(context, 'start');
                          },
                          isSelected: isStartSelected,
                          validator: (value) {
                            if (!isStartSelected) {
                              return 'Please select start date';
                            }
                            return "";
                          },
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 1,
                        child: buildDateTextField(
                          controller: _endDateController,
                          hintText: DateFormat.yMMMMd('en_US').format(endDate),
                          fieldType: 'end',
                          onTap: () {
                            setState(() {
                              isStartSelected = true;
                            });
                            _selectDate(context, 'end');
                          },
                          isSelected: isStartSelected,
                          validator: (value) {
                            if (!isStartSelected) {
                              return 'Please select end date';
                            }
                            return "";
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: HouseDetails(
                  text1: 'Borehole',
                  text2: 'Rent Includes Electricity',
                  onChanged1: (bool? value) {
                    setState(() {
                      isBorehole = value!;
                    });
                  },
                  onChanged2: (bool? value) {
                    setState(() {
                      isElectricity = value!;
                    });
                  },
                  isText1: isBorehole,
                  isText2: isElectricity,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: HouseDetails(
                  text1: 'Solar',
                  text2: 'Rent Includes Water',
                  onChanged1: (bool? value) {
                    setState(() {
                      isSolar = value!;
                    });
                  },
                  onChanged2: (bool? value) {
                    setState(() {
                      isWater = value!;
                    });
                  },
                  isText1: isSolar,
                  isText2: isWater,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: HouseDetails(
                  text1: 'Walled',
                  text2: 'Gated',
                  onChanged1: (bool? value) {
                    setState(() {
                      isWalled = value!;
                    });
                  },
                  onChanged2: (bool? value) {
                    setState(() {
                      isGated = value!;
                    });
                  },
                  isText1: isWalled,
                  isText2: isGated,
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: HouseDetails(
                  text1: 'Tiled',
                  text2: 'Deposit',
                  onChanged1: (bool? value) {
                    setState(() {
                      isTiled = value!;
                    });
                  },
                  onChanged2: (bool? value) {
                    setState(() {
                      isDeposit = value!;
                    });
                  },
                  isText1: isTiled,
                  isText2: isDeposit,
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(15.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 60,
                  child: CustomElevateButton(
                    name: 'FIND',
                    color: ColorConstants.yellow,
                    onSubmit: () {
                      setState(() {
                        contactText.text.isEmpty
                            ? validate = true
                            : validate = false;
                      });
                      if (formKey.currentState!.validate()) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SearchResults(
                                    minNumberRooms:
                                        _minRoomsController.text.trim(),
                                    maxNumberRooms:
                                        _maxRoomsController.text.trim(),
                                    area: _areaController.text.trim(),
                                    city: _cityController.text.trim(),
                                    type: typeValue,
                                    classification: classificationsValue,
                                    contact: _contactController.text.trim(),
                                    electricityInclusive: isElectricity,
                                    isBorehole: isBorehole,
                                    isDeposit: isDeposit,
                                    isGated: isGated,
                                    isSolar: isSolar,
                                    isTiled: isTiled,
                                    isWalled: isWalled,
                                    searchValue:
                                        _SearchFieldController.text.trim(),
                                    maxRent: _maxRentController.text.trim(),
                                    minRent: _minRentController.text.trim(),
                                    page: 0,
                                    size: 0,
                                    token: '',
                                    waterInclusive: isWater,
                                    startDate: startDate.toString(),
                                    endDate: endDate.toString())));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text('Fill out missing fields'),
                          duration: const Duration(seconds: 2),
                          action: SnackBarAction(
                            label: '',
                            onPressed: () {},
                          ),
                        ));
                      }
                    },
                  ),
                ),
              ),
            ]),
          ),
        ));
  }

  Future<void> _selectDate(BuildContext context, String pos) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2050),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: ColorConstants.yellow, // <-- SEE HERE
              onPrimary: Colors.black, // <-- SEE HERE
              onSurface: Colors.black, // <-- SEE HERE
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != currentDate) {
      setState(() {
        currentDate = pickedDate;
        pos == 'start' ? startDate = pickedDate : endDate = pickedDate;
      });
    }
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: ColorConstants.yellow),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: ColorConstants.yellow),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.red),
          ),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: ColorConstants.yellow)),
        ),
        onChanged: onChanged,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item,
                style: GoogleFonts.montserrat(
                    fontSize: 16, color: Colors.black87)),
          );
        }).toList(),
      ),
    );
  }

  //build date

  Widget _buildCheckboxRow({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
        ),
        Text(label,
            style: GoogleFonts.montserrat(fontSize: 16, color: Colors.black87)),
      ],
    );
  }

  Widget buildDateTextField({
    required TextEditingController controller,
    required String hintText,
    required String fieldType,
    required void Function() onTap,
    required bool isSelected,
    required String Function(String?) validator,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: CustomTextField(
          controller: controller
            ..text = DateFormat('dd/MM/yyyy').format(DateTime.now()),
          labelText: fieldType == 'start' ? 'Start Date' : 'End Date',
          validator: (value) => value == null || value.isEmpty
              ? 'Please enter occupation date'
              : null,
          // inputFormatters: [DateFormatter()],
        ),
      ),
    );
  }

  TimeOfDay _time = TimeOfDay(
      hour: (DateTime(DateTime.now().hour).hour),
      minute: (DateTime(DateTime.now().minute).minute));

  void _selectTime() async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (newTime != null) {
      setState(() {
        _time = newTime;
      });
    }
  }
}
