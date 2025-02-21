import 'dart:math';

import 'package:math_expressions/math_expressions.dart';

class CalculatorLogic {
  String currentInput = "";
  String selectedFunction = ""; // Track selected function
  bool isSecondFunctionActive = false; // ✅ Toggle state for `2nd` button
  double memoryValue = 0.0; // ✅ Memory register for `M+`, `M-`, `MR`

  String processInput(String input, String currentResult) {
    try {
      if (input == 'C') {
        currentInput = "";
        selectedFunction = "";
        return "0";
      }

      if (input == '⌫') {
        if (currentInput.isNotEmpty) {
          currentInput = currentInput.substring(0, currentInput.length - 1);
          return currentInput.isNotEmpty ? currentInput : "0";
        }
        return "0";
      }

      if (input == '=') {
        return _evaluateExpression(currentInput);
      }

      // ✅ Handle Memory Functions
      if (input == 'MC') {
        memoryValue = 0.0; // Clear memory
        return currentInput;
      }

      if (input == 'M+') {
        double currentValue = double.tryParse(currentInput) ?? 0.0;
        memoryValue += currentValue; // Add to memory
        return currentInput;
      }

      if (input == 'M-') {
        double currentValue = double.tryParse(currentInput) ?? 0.0;
        memoryValue -= currentValue; // Subtract from memory
        return currentInput;
      }

      if (input == 'MR') {
        currentInput = memoryValue.toString(); // Recall memory
        return currentInput;
      }

      // ✅ Handling Parentheses `()`
      if (input == '(' || input == ')') {
        currentInput += input;
        return currentInput;
      }

      // ✅ Handling Special Constants
      if (input == 'π') {
        currentInput += pi.toString();
        return currentInput;
      }

      // ✅ Handling Functions With Automatic Bracket Formatting
      List<String> functions = [
        'sin',
        'cos',
        'tan',
        'sinh',
        'cosh',
        'tanh',
        'sin⁻¹',
        'cos⁻¹',
        'tan⁻¹',
        'ln',
        'log₁₀',
        '√',
        '∛',
        'xⁿ',
        'x³',
        'x²',
        'x!',
        'x⁻¹',
        'e',
        'eⁿ',
      ];

      if (functions.contains(input)) {
        if (selectedFunction.isEmpty) {
          selectedFunction = input;

          if (currentInput.isNotEmpty) {
            return "$selectedFunction($currentInput)";
          }
          return "$selectedFunction()"; // Waiting for input
        } else {
          selectedFunction = input;
          return "$selectedFunction($currentInput)";
        }
      }

      // ✅ If User Enters a Number and a Function Was Selected
      if (selectedFunction.isNotEmpty &&
          RegExp(r'^\d+(\.\d+)?$').hasMatch(input)) {
        currentInput += input;
        return "$selectedFunction($currentInput)";
      }

      currentInput += input;
      return currentInput;
    } catch (e) {
      return "Error";
    }
  }

  String _evaluateExpression(String expression) {
    try {
      if (selectedFunction.isNotEmpty) {
        // ✅ Extract expression inside parentheses and evaluate it
        String innerExpression = currentInput.replaceAll(
          RegExp(r'[^\d+\-*/().]'),
          '',
        );
        Parser parser = Parser();
        Expression exp = parser.parse(innerExpression);
        ContextModel cm = ContextModel();
        double numValue = exp.evaluate(EvaluationType.REAL, cm);

        // ✅ Apply function to evaluated number
        if (selectedFunction == '√') {
          numValue = sqrt(numValue);
        } else if (selectedFunction == '∛') {
          numValue = pow(numValue, 1 / 3).toDouble();
        } else if (selectedFunction == 'ln') {
          numValue = log(numValue);
        } else if (selectedFunction == 'log₁₀') {
          numValue = log(numValue) / log(10);
        } else if (selectedFunction == 'x²') {
          numValue = pow(numValue, 2).toDouble();
        } else if (selectedFunction == 'x³') {
          numValue = pow(numValue, 3).toDouble();
        } else if (selectedFunction == 'x!') {
          numValue = _factorial(numValue.toInt()).toDouble();
        } else if (selectedFunction == 'x⁻¹') {
          numValue = numValue == 0 ? double.infinity : 1 / numValue;
        } else if (selectedFunction == 'xⁿ') {
          return "$numValue^";
        } else if (selectedFunction == 'e') {
          numValue = e;
        } else if (selectedFunction == 'eⁿ') {
          numValue = pow(e, numValue).toDouble();
        }
        // ✅ Handle inverse trigonometric functions
        else if (selectedFunction == 'sin⁻¹') {
          numValue = asin(numValue) * (180 / pi);
        } else if (selectedFunction == 'cos⁻¹') {
          numValue = acos(numValue) * (180 / pi);
        } else if (selectedFunction == 'tan⁻¹') {
          numValue = atan(numValue) * (180 / pi);
        }
        // ✅ Handle standard trigonometric functions
        else if ([
          'sin',
          'cos',
          'tan',
          'sinh',
          'cosh',
          'tanh',
        ].contains(selectedFunction)) {
          numValue = _evaluateTrigonometricFunction(selectedFunction, numValue);
        }

        selectedFunction = "";
        currentInput = "";

        return numValue.toString();
      }

      // ✅ Convert and evaluate standard mathematical expressions
      expression = expression
          .replaceAll('÷', '/')
          .replaceAll('×', '*')
          .replaceAll('π', pi.toString());

      Parser parser = Parser();
      Expression exp = parser.parse(expression);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      return eval.toString();
    } catch (e) {
      return "Error";
    }
  }

  /// Handles trigonometric & hyperbolic functions
  /// Handles trigonometric & hyperbolic functions correctly
  double _evaluateTrigonometricFunction(String function, double value) {
    double radians = value * (pi / 180); // Convert degrees to radians

    switch (function) {
      case 'sin':
        return sin(radians);
      case 'cos':
        return cos(radians);
      case 'tan':
        return tan(radians);
      case 'sin⁻¹': // ✅ Inverse sin
        return asin(value) * (180 / pi);
      case 'cos⁻¹': // ✅ Inverse cos
        return acos(value) * (180 / pi);
      case 'tan⁻¹': // ✅ Inverse tan
        return atan(value) * (180 / pi);
      case 'sinh':
        return _sinh(value);
      case 'cosh':
        return _cosh(value);
      case 'tanh':
        return _tanh(value);
      default:
        return value;
    }
  }

  /// Manually implementing hyperbolic functions
  double _sinh(double x) {
    return (exp(x) - exp(-x)) / 2;
  }

  double _cosh(double x) {
    return (exp(x) + exp(-x)) / 2;
  }

  double _tanh(double x) {
    return _sinh(x) / _cosh(x);
  }

  /// Factorial function
  int _factorial(int num) {
    if (num < 0) return 0;
    if (num == 0 || num == 1) return 1;
    return num * _factorial(num - 1);
  }
}
