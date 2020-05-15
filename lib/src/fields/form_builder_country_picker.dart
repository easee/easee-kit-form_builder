import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class FormBuilderCountryPicker extends StatefulWidget {
  final String attribute;
  final List<FormFieldValidator> validators;
  final bool readOnly;
  final InputDecoration decoration;
  final ValueChanged onChanged;
  final ValueTransformer valueTransformer;

  final TextStyle style;
  final FormFieldSetter onSaved;

  // For country dialog
  final String searchText;
  final EdgeInsets titlePadding;
  final bool isSearchable;
  final Text dialogTitle;
  final String defaultSelectedCountryIsoCode;
  final List<String> priorityListByIsoCode;
  final List<String> countryFilterByIsoCode;
  final TextStyle dialogTextStyle;
  final bool isCupertinoPicker;
  final double cupertinoPickerSheetHeight;
  final Color cursorColor;

  FormBuilderCountryPicker(
      {Key key,
      @required this.attribute,
      this.validators = const [],
      this.readOnly = false,
      this.decoration = const InputDecoration(),
      this.style,
      this.onChanged,
      this.valueTransformer,
      this.onSaved,
      this.searchText,
      this.titlePadding,
      this.dialogTitle,
      this.isSearchable,
      @required this.defaultSelectedCountryIsoCode,
      this.priorityListByIsoCode,
      this.countryFilterByIsoCode,
      this.dialogTextStyle,
      this.isCupertinoPicker,
      this.cupertinoPickerSheetHeight,
      this.cursorColor})
      : assert(defaultSelectedCountryIsoCode != null),
        super(key: key);

  @override
  _FormBuilderCountryPickerState createState() => _FormBuilderCountryPickerState();
}

class _FormBuilderCountryPickerState extends State<FormBuilderCountryPicker> {
  bool _readOnly = false;
  final GlobalKey<FormFieldState> _fieldKey = GlobalKey<FormFieldState>();
  FormBuilderState _formState;
  Country _selectedDialogCountry;

  void _openCupertinoCountryPicker() => showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) {
          return CountryPickerCupertino(
            pickerSheetHeight: widget.cupertinoPickerSheetHeight ?? 300.0,
            onValuePicked: (Country country) => setState(() => _selectedDialogCountry = country),
            itemFilter: widget.countryFilterByIsoCode != null
                ? (c) => widget.countryFilterByIsoCode.contains(c.isoCode)
                : null,
            priorityList: widget.priorityListByIsoCode != null
                ? List.generate(widget.priorityListByIsoCode.length,
                    (index) => CountryPickerUtils.getCountryByIsoCode(widget.priorityListByIsoCode[index]))
                : null,
          );
        },
      );

  void _openCountryPickerDialog() => showDialog(
        context: context,
        builder: (context) => Theme(
          data: Theme.of(context).copyWith(
            cursorColor: Theme.of(context).primaryColor,
            primaryColor: widget.cursorColor ?? Theme.of(context).primaryColor,
          ),
          child: CountryPickerDialog(
            titlePadding: widget.titlePadding ?? EdgeInsets.all(8.0),
            searchCursorColor: widget.cursorColor ?? Theme.of(context).primaryColor,
            searchInputDecoration: InputDecoration(hintText: widget.searchText ?? 'Search...'),
            isSearchable: widget.isSearchable ?? true,
            title: widget.dialogTitle ??
                Text(
                  'Select Your Country',
                  style: widget.dialogTextStyle ?? widget.style,
                ),
            onValuePicked: (Country country) => setState(() => _selectedDialogCountry = country),
            itemFilter: widget.countryFilterByIsoCode != null
                ? (c) => widget.countryFilterByIsoCode.contains(c.isoCode)
                : null,
            priorityList: widget.priorityListByIsoCode != null
                ? List.generate(widget.priorityListByIsoCode.length,
                    (index) => CountryPickerUtils.getCountryByIsoCode(widget.priorityListByIsoCode[index]))
                : null,
            itemBuilder: _buildDialogItem,
          ),
        ),
      );

  Widget _buildDialogItem(Country country) => Container(
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CountryPickerUtils.getDefaultFlagImage(country),
          title: Text("${country.name}"),
          // visualDensity: VisualDensity.compact,
        ),
      );

  @override
  void initState() {
    _formState = FormBuilder.of(context);
    _formState?.registerFieldKey(widget.attribute, _fieldKey);
    _selectedDialogCountry = CountryPickerUtils.getCountryByIsoCode(widget.defaultSelectedCountryIsoCode);

    super.initState();
  }

  @override
  void dispose() {
    _formState?.unregisterFieldKey(widget.attribute);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _readOnly = (_formState?.readOnly == true) ? true : widget.readOnly;

    return FormField<Country>(
      key: _fieldKey,
      enabled: !_readOnly,
      initialValue: CountryPickerUtils.getCountryByIsoCode(widget.defaultSelectedCountryIsoCode),
      validator: (val) {
        for (int i = 0; i < widget.validators.length; i++) {
          if (widget.validators[i](val) != null) return widget.validators[i](val);
        }
        return null;
      },
      onSaved: (val) {
        dynamic transformed;
        if (widget.valueTransformer != null) {
          transformed = widget.valueTransformer(_selectedDialogCountry);
          _formState?.setAttributeValue(widget.attribute, transformed);
        } else
          _formState?.setAttributeValue(widget.attribute, _selectedDialogCountry.name);
        if (widget.onSaved != null) {
          widget.onSaved(transformed ?? _selectedDialogCountry.name);
        }
      },
      builder: (FormFieldState<Country> field) {
        return GestureDetector(
          onTap: widget.isCupertinoPicker != null
              ? (widget.isCupertinoPicker ? _openCupertinoCountryPicker : _openCountryPickerDialog)
              : _openCountryPickerDialog,
          child: InputDecorator(
            decoration: widget.decoration.copyWith(
              errorText: field.errorText,
            ),
            child: Row(
              children: [
                CountryPickerUtils.getDefaultFlagImage(_selectedDialogCountry),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text(
                    "${_selectedDialogCountry.name}",
                    style: widget.style,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
