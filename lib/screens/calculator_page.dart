import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart'; // For evaluating math expressions

// Theme constants (copied for consistency)
const Color neonCyan = Color(0xFF00E5FF);
const Color darkBackground = Color(0xFF121212);
const Color buttonColor = Color(0xFF1F1F1F); // Slightly lighter dark background for buttons

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Calculator state
  String _expression = '';
  String _history = '';
  String _output = '0';

  // Unit Converter state
  String _selectedCategory = 'Length';
  String _fromUnit = 'Meters';
  String _toUnit = 'Centimeters';
  final TextEditingController _inputValueController = TextEditingController();
  String _convertedValue = '';

  final Map<String, List<String>> _unitCategories = {
    'Length': ['Meters', 'Centimeters', 'Kilometers', 'Miles', 'Feet', 'Inches'],
    'Mass': ['Kilograms', 'Grams', 'Pounds', 'Ounces'],
    'Temperature': ['Celsius', 'Fahrenheit', 'Kelvin'],
    'Time': ['Seconds', 'Minutes', 'Hours', 'Days'],
  };

  final Map<String, Map<String, double>> _conversionRates = {
    'Length': {
      'Meters': 1.0,
      'Centimeters': 100.0,
      'Kilometers': 0.001,
      'Miles': 0.000621371,
      'Feet': 3.28084,
      'Inches': 39.3701,
    },
    'Mass': {
      'Kilograms': 1.0,
      'Grams': 1000.0,
      'Pounds': 2.20462,
      'Ounces': 35.274,
    },
    'Temperature': {
      // Conversions are more complex, handled in _convertUnits
      'Celsius': 1.0,
      'Fahrenheit': 1.0,
      'Kelvin': 1.0,
    },
    'Time': {
      'Seconds': 1.0,
      'Minutes': 1 / 60,
      'Hours': 1 / 3600,
      'Days': 1 / 86400,
    },
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _updateUnitDropdowns();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _inputValueController.dispose();
    super.dispose();
  }

  // Calculator Logic
  void _numClick(String text) {
    setState(() {
      _expression += text;
    });
  }

  void _operatorClick(String text) {
    setState(() {
      _expression += text;
    });
  }

  void _clear() {
    setState(() {
      _expression = '';
      _history = '';
      _output = '0';
    });
  }

  void _backspace() {
    setState(() {
      if (_expression.isNotEmpty) {
        _expression = _expression.substring(0, _expression.length - 1);
      }
    });
  }

  void _evaluate() {
    try {
      Parser p = Parser();
      Expression exp = p.parse(_expression);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      setState(() {
        _history = _expression;
        _output = eval.toString();
        _expression = _output; // Set expression to output for continuous calculation
      });
    } catch (e) {
      setState(() {
        _output = 'Error';
      });
    }
  }

  // Unit Converter Logic
  void _updateUnitDropdowns() {
    setState(() {
      _fromUnit = _unitCategories[_selectedCategory]![0];
      _toUnit = _unitCategories[_selectedCategory]![0];
      _convertedValue = '';
      _inputValueController.clear();
    });
  }

  void _convertUnits() {
    double? inputValue = double.tryParse(_inputValueController.text);
    if (inputValue == null) {
      setState(() {
        _convertedValue = 'Invalid Input';
      });
      return;
    }

    double result;
    if (_selectedCategory == 'Temperature') {
      result = _convertTemperature(inputValue, _fromUnit, _toUnit);
    } else {
      double baseValue = inputValue / _conversionRates[_selectedCategory]![_fromUnit]!;
      result = baseValue * _conversionRates[_selectedCategory]![_toUnit]!;
    }

    setState(() {
      _convertedValue = result.toStringAsFixed(4); // Limit to 4 decimal places
    });
  }

  double _convertTemperature(double value, String from, String to) {
    double celsius;
    // Convert to Celsius first
    if (from == 'Celsius') {
      celsius = value;
    } else if (from == 'Fahrenheit') {
      celsius = (value - 32) * 5 / 9;
    } else if (from == 'Kelvin') {
      celsius = value - 273.15;
    } else {
      celsius = 0; // Should not happen
    }

    // Convert from Celsius to target unit
    if (to == 'Celsius') {
      return celsius;
    } else if (to == 'Fahrenheit') {
      return (celsius * 9 / 5) + 32;
    } else if (to == 'Kelvin') {
      return celsius + 273.15;
    } else {
      return 0; // Should not happen
    }
  }

  // Calculator Button Widget
  Widget _buildCalculatorButton(String text, {Color? textColor, Color? buttonBgColor, VoidCallback? onPressed}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8),
        child: ElevatedButton(
          onPressed: onPressed ?? () => _numClick(text),
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonBgColor ?? buttonColor,
            padding: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: neonCyan.withOpacity(0.3), width: 1),
            ),
            shadowColor: neonCyan.withOpacity(0.5),
            elevation: 5,
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 24,
              color: textColor ?? Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: neonCyan, blurRadius: 3)],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator & Converter'),
        backgroundColor: darkBackground,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: neonCyan,
          labelColor: neonCyan,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Calculator', icon: Icon(Icons.calculate)),
            Tab(text: 'Unit Converter', icon: Icon(Icons.swap_horiz)),
          ],
        ),
      ),
      backgroundColor: darkBackground,
      body: TabBarView(
        controller: _tabController,
        children: [
          // Calculator Tab
          Column(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.bottomRight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _history,
                        style: TextStyle(fontSize: 24, color: Colors.white.withOpacity(0.6)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _expression,
                        style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold), 
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Divider(color: neonCyan),
                      Text(
                        _output,
                        style: const TextStyle(fontSize: 48, color: neonCyan, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                children: [
                  Row(
                    children: [
                      _buildCalculatorButton('C', textColor: Colors.redAccent, onPressed: _clear),
                      _buildCalculatorButton('⌫', textColor: Colors.orangeAccent, onPressed: _backspace),
                      _buildCalculatorButton('%', textColor: neonCyan, onPressed: () => _operatorClick('%')),
                      _buildCalculatorButton('/', textColor: neonCyan, onPressed: () => _operatorClick('/')),
                    ],
                  ),
                  Row(
                    children: [
                      _buildCalculatorButton('7'),
                      _buildCalculatorButton('8'),
                      _buildCalculatorButton('9'),
                      _buildCalculatorButton('x', textColor: neonCyan, onPressed: () => _operatorClick('*')),
                    ],
                  ),
                  Row(
                    children: [
                      _buildCalculatorButton('4'),
                      _buildCalculatorButton('5'),
                      _buildCalculatorButton('6'),
                      _buildCalculatorButton('-', textColor: neonCyan, onPressed: () => _operatorClick('-')),
                    ],
                  ),
                  Row(
                    children: [
                      _buildCalculatorButton('1'),
                      _buildCalculatorButton('2'),
                      _buildCalculatorButton('3'),
                      _buildCalculatorButton('+', textColor: neonCyan, onPressed: () => _operatorClick('+')),
                    ],
                  ),
                  Row(
                    children: [
                      _buildCalculatorButton('00'),
                      _buildCalculatorButton('0'),
                      _buildCalculatorButton('.', textColor: neonCyan, onPressed: () => _numClick('.')),
                      _buildCalculatorButton('=', textColor: darkBackground, buttonBgColor: neonCyan, onPressed: _evaluate),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Unit Converter Tab
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Category',
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
                ),
                DropdownButton<String>(
                  value: _selectedCategory,
                  dropdownColor: darkBackground,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  iconEnabledColor: neonCyan,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue!;
                      _updateUnitDropdowns();
                    });
                  },
                  items: _unitCategories.keys.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Text(
                  'From Unit',
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
                ),
                DropdownButton<String>(
                  value: _fromUnit,
                  dropdownColor: darkBackground,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  iconEnabledColor: neonCyan,
                  onChanged: (String? newValue) {
                    setState(() {
                      _fromUnit = newValue!;
                      _convertUnits();
                    });
                  },
                  items: _unitCategories[_selectedCategory]!.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Text(
                  'To Unit',
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
                ),
                DropdownButton<String>(
                  value: _toUnit,
                  dropdownColor: darkBackground,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  iconEnabledColor: neonCyan,
                  onChanged: (String? newValue) {
                    setState(() {
                      _toUnit = newValue!;
                      _convertUnits();
                    });
                  },
                  items: _unitCategories[_selectedCategory]!.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _inputValueController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                  decoration: InputDecoration(
                    labelText: 'Input Value',
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: neonCyan.withOpacity(0.5)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: neonCyan, width: 2),
                    ),
                  ),
                  onChanged: (_) => _convertUnits(),
                ),
                const SizedBox(height: 20),
                Text(
                  'Converted Value: $_convertedValue',
                  style: const TextStyle(color: neonCyan, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
