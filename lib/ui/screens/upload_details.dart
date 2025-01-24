import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:imba/bloc/upload/upload_bloc.dart';
import 'package:imba/bloc/upload/upload_event.dart';
import 'package:imba/bloc/upload/upload_state.dart';
import 'package:imba/bloc/user/user_bloc.dart';
import 'package:imba/ui/layouts/home_layout.dart';
import 'package:imba/ui/screens/upload_images.dart';
import 'package:imba/utilities/constants.dart';
import 'package:intl/intl.dart';

import '../widgets/custom_elevated_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/date_formatter.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/logo.dart';
import '../widgets/property_error_widget.dart';
import '../widgets/upload_details_header.dart';
import 'uploads.dart';

class UploadDetails extends StatefulWidget {
  final List<String> types;
  final List<String> classifications;

  const UploadDetails({
    Key? key,
    required this.types,
    required this.classifications,
  }) : super(key: key);

  @override
  _UploadDetailsState createState() => _UploadDetailsState();
}

class _UploadDetailsState extends State<UploadDetails> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _homeAddressController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _rentalsController = TextEditingController();
  final TextEditingController _roomsController = TextEditingController();
  final TextEditingController _occupationDateController =
      TextEditingController();
  final TextEditingController _extraDetailsController = TextEditingController();
  final TextEditingController _depositController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  late UserBloc _userBloc;
  DateTime _currentDate = DateTime.now();
  String _classificationsValue = '';
  String _typeValue = '';

  bool _isBorehole = false;
  bool _isElectricity = false;
  bool _isSolar = false;
  bool _isWater = false;
  bool _isWalled = false;
  bool _isTiled = false;
  bool _isGated = false;
  bool _isOccupied = false;

  @override
  void initState() {
    super.initState();
    _userBloc = BlocProvider.of<UserBloc>(context);
    _classificationsValue = widget.classifications[0];
    _typeValue = widget.types[0];
    _contactController.text = _userBloc.userPhoneNumber;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _homeAddressController.dispose();
    _areaController.dispose();
    _cityController.dispose();
    _rentalsController.dispose();
    _roomsController.dispose();
    _occupationDateController.dispose();
    _extraDetailsController.dispose();
    _depositController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _currentDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2050),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ColorConstants.yellow,
              onPrimary: Colors.black,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != _currentDate) {
      setState(() {
        _currentDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return HomeLayout(
      hasBack: true,
      title: 'Upload House Details',
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomUploadDetailsHeaders(header: 'House Details'),
                _buildTextField(
                  controller: _homeAddressController,
                  labelText: 'Home Address',
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter house address'
                      : null,
                ),
                _buildTextField(
                  controller: _areaController,
                  labelText: 'Area',
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter area'
                      : null,
                ),
                _buildTextField(
                  controller: _cityController,
                  labelText: 'City',
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter city'
                      : null,
                ),
                const SizedBox(height: 15),
                const CustomUploadDetailsHeaders(header: 'Occupation Details'),
                _buildTextField(
                  controller: _rentalsController,
                  labelText: 'Rentals',
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter rent'
                      : null,
                ),
                _buildTextField(
                  controller: _roomsController,
                  labelText: '# of Rooms',
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter number of rooms'
                      : null,
                ),
                _buildOccupationDateField(),
                _buildTextField(
                  controller: _extraDetailsController,
                  labelText: 'Extra Details',
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter extra details'
                      : null,
                ),
                _buildTextField(
                  controller: _depositController,
                  labelText: 'Deposit',
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter deposit'
                      : null,
                ),
                _buildDropdownField(
                  label: 'Type',
                  value: _typeValue,
                  items: widget.types,
                  onChanged: (newValue) =>
                      setState(() => _typeValue = newValue.toString()),
                ),
                _buildTextField(
                  controller: _contactController,
                  labelText: 'Contact',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter contact';
                    }
                    if (!value.startsWith("+")) {
                      return 'Start with country code';
                    }
                    return null;
                  },
                ),
                _buildDropdownField(
                  label: 'Classification',
                  value: _classificationsValue,
                  items: widget.classifications,
                  onChanged: (newValue) => setState(
                      () => _classificationsValue = newValue.toString()),
                ),
                _buildTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                      return 'Invalid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                const CustomUploadDetailsHeaders(header: 'House Features'),
                _buildCheckboxRow(
                    label: 'Borehole',
                    value: _isBorehole,
                    onChanged: (value) => setState(() => _isBorehole = value!)),
                _buildCheckboxRow(
                    label: 'Rent Includes Electricity',
                    value: _isElectricity,
                    onChanged: (value) =>
                        setState(() => _isElectricity = value!)),
                _buildCheckboxRow(
                    label: 'Solar',
                    value: _isSolar,
                    onChanged: (value) => setState(() => _isSolar = value!)),
                _buildCheckboxRow(
                    label: 'Rent Includes Water',
                    value: _isWater,
                    onChanged: (value) => setState(() => _isWater = value!)),
                _buildCheckboxRow(
                    label: 'Walled',
                    value: _isWalled,
                    onChanged: (value) => setState(() => _isWalled = value!)),
                _buildCheckboxRow(
                    label: 'Gated',
                    value: _isGated,
                    onChanged: (value) => setState(() => _isGated = value!)),
                _buildCheckboxRow(
                    label: 'Tiled',
                    value: _isTiled,
                    onChanged: (value) => setState(() => _isTiled = value!)),
                const SizedBox(height: 15),
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: 60,
                    child: BlocListener<UploadBloc, UploadState>(
                      listener: (context, state) {
                        if (state is UploadLoadingState) {
                          // Show loading dialog
                          LoadingDialog.show(context);
                        } else {
                          // Dismiss loading dialog if it exists
                          LoadingDialog.dismiss(context);
                        }

                        if (state is UploadSuccessState || state is UploadHouseSuccessState) {
                          // Navigate to the next screen
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UploadsList()),
                          );
                        } else if (state is UploadFailedState) {
                          // Show error message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.message),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: CustomElevateButton(
                        color: Colors.orange,
                        name: 'Submit',
                        onSubmit: () {
                          if (_formKey.currentState!.validate()) {
                            BlocProvider.of<UploadBloc>(context).add(
                              UploadHouseEvent(
                                area: _areaController.text,
                                type: _typeValue,
                                walled: _isWalled,
                                tiled: _isTiled,
                                solar: _isSolar,
                                token: '',
                                boreHole: _isBorehole,
                                city: _cityController.text,
                                classification: _classificationsValue,
                                contact: _contactController.text,
                                deposit: int.parse(_depositController.text),
                                email: _emailController.text,
                                extraDetails: _extraDetailsController.text,
                                gated: _isGated,
                                houseAddress: _homeAddressController.text,
                                numberRooms: int.parse(_roomsController.text),
                                occupationDate: _currentDate.toString(),
                                occupied: _isOccupied,
                                rent: int.parse(_rentalsController.text),
                                rentElectricityInclusive: _isElectricity,
                                rentWaterInclusive: _isWater,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0),
      child: CustomTextField(
        controller: controller,
        labelText: labelText,
        validator: validator,
      ),
    );
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

  Widget _buildOccupationDateField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () => _selectDate(context),
        child: AbsorbPointer(
          child: CustomTextField(
            controller: _occupationDateController
              ..text = DateFormat('dd/MM/yyyy').format(_currentDate),
            labelText: 'Occupation Date',
            validator: (value) => value == null || value.isEmpty
                ? 'Please enter occupation date'
                : null,
            // inputFormatters: [DateFormatter()],
          ),
        ),
      ),
    );
  }

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
}

class LoadingDialog {
  static bool isShowing = false;

  static void show(BuildContext context) {
    if (!isShowing) {
      isShowing = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const LoadingIndicator();
        },
      );
    }
  }

  static void dismiss(BuildContext context) {
    if (isShowing && Navigator.canPop(context)) {
      isShowing = false;
      Navigator.pop(context);
    }
  }
}
