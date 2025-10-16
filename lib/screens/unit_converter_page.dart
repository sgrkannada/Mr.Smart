import 'package:flutter/material.dart';

class UnitConverterPage extends StatefulWidget {
  const UnitConverterPage({super.key});

  @override
  State<UnitConverterPage> createState() => _UnitConverterPageState();
}

class _UnitConverterPageState extends State<UnitConverterPage> {
  final TextEditingController _inputValueController = TextEditingController();
  String _selectedCategory = 'Length';
  String _fromUnit = 'meters';
  String _toUnit = 'feet';
  String _outputValue = '';

  final Map<String, List<String>> _units = {
    'Length': ['meters', 'feet', 'inches', 'centimeters', 'kilometers', 'miles'],
    'Mass': ['kilograms', 'grams', 'pounds', 'ounces'],
    'Temperature': ['celsius', 'fahrenheit', 'kelvin'],
    'Time': ['seconds', 'minutes', 'hours', 'days'],
    'Pressure': ['pascals', 'psi', 'atmospheres', 'bars'],
  };

  final Map<String, Map<String, double>> _conversionFactors = {
    'Length': {
      'meters': 1.0,
      'feet': 3.28084,
      'inches': 39.3701,
      'centimeters': 100.0,
      'kilometers': 0.001,
      'miles': 0.000621371,
    },
    'Mass': {
      'kilograms': 1.0,
      'grams': 1000.0,
      'pounds': 2.20462,
      'ounces': 35.274,
    },
    'Temperature': {
      // Conversions are more complex, handled in _convertTemperature
    },
    'Time': {
      'seconds': 1.0,
      'minutes': 1 / 60,
      'hours': 1 / 3600,
      'days': 1 / 86400,
    },
    'Pressure': {
      'pascals': 1.0,
      'psi': 0.000145038,
      'atmospheres': 0.00000986923,
      'bars': 0.00001,
    },
  };

  @override
  void initState() {
    super.initState();
    _updateUnits();
  }

  void _updateUnits() {
    setState(() {
      _fromUnit = _units[_selectedCategory]![0];
      _toUnit = _units[_selectedCategory]![1];
      _outputValue = '';
      _inputValueController.clear();
    });
  }

  void _convert() {
    final double? inputValue = double.tryParse(_inputValueController.text);
    if (inputValue == null) {
      setState(() {
        _outputValue = 'Invalid input';
      });
      return;
    }

    double result;
    if (_selectedCategory == 'Temperature') {
      result = _convertTemperature(inputValue, _fromUnit, _toUnit);
    } else {
      final double baseValue = inputValue / _conversionFactors[_selectedCategory]![_fromUnit]!;
      result = baseValue * _conversionFactors[_selectedCategory]![_toUnit]!;
    }

    setState(() {
      _outputValue = result.toStringAsFixed(4);
    });
  }

  double _convertTemperature(double value, String fromUnit, String toUnit) {
    double celsiusValue;

    // Convert to Celsius first
    if (fromUnit == 'celsius') {
      celsiusValue = value;
    } else if (fromUnit == 'fahrenheit') {
      celsiusValue = (value - 32) * 5 / 9;
    } else if (fromUnit == 'kelvin') {
      celsiusValue = value - 273.15;
    } else {
      return 0.0; // Should not happen
    }

    // Convert from Celsius to target unit
    if (toUnit == 'celsius') {
      return celsiusValue;
    } else if (toUnit == 'fahrenheit') {
      return (celsiusValue * 9 / 5) + 32;
    } else if (toUnit == 'kelvin') {
      return celsiusValue + 273.15;
    } else {
      return 0.0; // Should not happen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unit Converter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedCategory = newValue;
                    _updateUnits();
                  });
                }
              },
              items: _units.keys.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _inputValueController,
              keyboardType: TextInputType.number, // Only allow numbers
              decoration: const InputDecoration(
                labelText: 'Input Value',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _convert(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _fromUnit,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _fromUnit = newValue;
                          _convert();
                        });
                      }
                    },
                    items: _units[_selectedCategory]!.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                      labelText: 'From',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _toUnit,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _toUnit = newValue;
                          _convert();
                        });
                      }
                    },
                    items: _units[_selectedCategory]!.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                      labelText: 'To',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Converted Value: ', // Placeholder for actual value
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              _outputValue,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
          ],
        ),
      ),
    );
  }
}
