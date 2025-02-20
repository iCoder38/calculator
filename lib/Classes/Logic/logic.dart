import 'dart:math';
import 'package:math_expressions/math_expressions.dart';

class CalculatorLogic {
  String currentInput = "";
  String selectedFunction = ""; // Track selected function

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

      // Handling functions
      List<String> functions = [
        'sin',
        'cos',
        'tan',
        'sinh',
        'cosh',
        'tanh',
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
          return "$selectedFunction()"; // Waiting for input
        } else {
          selectedFunction = input;
          return "$selectedFunction($currentInput)";
        }
      }

      // If number is entered after selecting a function, apply function
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

  /// Evaluates the mathematical expression correctly
  String _evaluateExpression(String expression) {
    try {
      if (selectedFunction.isNotEmpty) {
        double numValue = double.tryParse(currentInput) ?? 0;

        if (selectedFunction == '√') {
          numValue = sqrt(numValue);
        } else if (selectedFunction == '∛') {
          numValue = pow(numValue, 1 / 3).toDouble(); // Cube root calculation
        } else if (selectedFunction == 'ln') {
          numValue = log(numValue); // Natural log (ln)
        } else if (selectedFunction == 'log₁₀') {
          numValue = log(numValue) / log(10); // Convert to base 10 logarithm
        } else if (selectedFunction == 'x²') {
          numValue = pow(numValue, 2).toDouble(); // Square function
        } else if (selectedFunction == 'x³') {
          numValue = pow(numValue, 3).toDouble(); // Cube function
        } else if (selectedFunction == 'x!') {
          numValue = _factorial(numValue.toInt()).toDouble(); // Factorial
        } else if (selectedFunction == 'x⁻¹') {
          numValue =
              numValue == 0
                  ? double.infinity
                  : 1 / numValue; // Reciprocal (1/x)
        } else if (selectedFunction == 'xⁿ') {
          return "$numValue^"; // Wait for the exponent input
        } else if (selectedFunction == 'e') {
          numValue = e; // Assign e (Euler's number)
        } else if (selectedFunction == 'eⁿ') {
          numValue = pow(e, numValue).toDouble(); // Calculate e^x
        } else {
          numValue = _evaluateTrigonometricFunction(selectedFunction, numValue);
        }

        selectedFunction = ""; // Reset after evaluation
        currentInput = "";

        return numValue.toString();
      }

      expression = expression.replaceAll('÷', '/').replaceAll('×', '*');

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
  double _evaluateTrigonometricFunction(String function, double value) {
    double radians = value * (pi / 180); // Convert degrees to radians
    switch (function) {
      case 'sin':
        return sin(radians);
      case 'cos':
        return cos(radians);
      case 'tan':
        return tan(radians);
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
    if (num < 0) return 0; // Factorial is undefined for negative numbers
    if (num == 0 || num == 1) return 1;
    return num * _factorial(num - 1);
  }
}
