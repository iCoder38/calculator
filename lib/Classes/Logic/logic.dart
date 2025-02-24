import 'dart:math';
import 'package:math_expressions/math_expressions.dart';

class CalculatorLogic {
  String currentInput = "";
  String selectedFunction = ""; // Track selected function
  bool isSecondFunctionActive = false; // Toggle state for `2nd` button
  double memoryValue = 0.0; // Memory register for `M+`, `M-`, `MR`

  /// Processes user input and returns updated output
  String processInput(String input, String currentResult) {
    try {
      if (input == 'C') {
        currentInput = "";
        selectedFunction = "";
        isSecondFunctionActive = false; // Reset the 2nd function toggle
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

      if (input == '2nd') {
        isSecondFunctionActive =
            !isSecondFunctionActive; // Toggle the secondary function state
        return currentResult;
      }

      if (input == 'MC') {
        memoryValue = 0.0;
        return currentInput;
      }

      if (input == 'M+') {
        double currentValue =
            double.tryParse(_evaluateExpression(currentInput)) ?? 0.0;
        memoryValue += currentValue;
        return memoryValue.toString();
      }

      if (input == 'M-') {
        double currentValue =
            double.tryParse(_evaluateExpression(currentInput)) ?? 0.0;
        memoryValue -= currentValue;
        return memoryValue.toString();
      }

      if (input == 'MR') {
        currentInput = memoryValue.toString();
        return currentInput;
      }

      if (input == '(' || input == ')' || input == 'π' || input == 'e') {
        currentInput += input;
        return currentInput;
      }

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
        'eⁿ',
      ];

      if (functions.contains(input)) {
        selectedFunction = input;
        return currentInput.isNotEmpty
            ? "$selectedFunction($currentInput)"
            : "$selectedFunction()";
      }

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

  /// Evaluates mathematical expressions
  String _evaluateExpression(String expression) {
    try {
      // Convert operators
      expression = expression
          .replaceAll('÷', '/')
          .replaceAll('×', '*')
          .replaceAll('π', pi.toString());

      // Handle `4%*45` as `4% of 45`
      expression = expression.replaceAllMapped(
        RegExp(r'(\d+(\.\d+)?)%\*(\d+(\.\d+)?)'),
        (match) {
          double base = double.parse(match.group(1)!);
          double percent = double.parse(match.group(3)!);
          return (base * percent / 100)
              .toString(); // Convert to percentage calculation
        },
      );

      // Handle `4%x45` as `4% of 45`
      expression = expression.replaceAllMapped(
        RegExp(r'(\d+(\.\d+)?)%x(\d+(\.\d+)?)'),
        (match) {
          double base = double.parse(match.group(1)!);
          double percent = double.parse(match.group(3)!);
          return (base * percent / 100)
              .toString(); // Convert to percentage calculation
        },
      );

      // Handle `4%45` as modulus (`4 mod 45`)
      expression = expression.replaceAllMapped(
        RegExp(r'(\d+(\.\d+)?)%(\d+(\.\d+)?)'),
        (match) {
          double num1 = double.parse(match.group(1)!);
          double num2 = double.parse(match.group(3)!);
          return (num1 % num2).toString(); // 4 % 45
        },
      );

      Parser parser = Parser();
      Expression exp = parser.parse(expression);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      // If a function was selected, apply it
      if (selectedFunction.isNotEmpty) {
        eval = _applyFunction(selectedFunction, eval);
        selectedFunction = ""; // Clear the function after applying it
      }

      return eval.toString();
    } catch (e) {
      return "Error";
    }
  }

  /// Applies mathematical functions to a value
  double _applyFunction(String function, double value) {
    switch (function) {
      case '√':
        return sqrt(value);
      case '∛':
        return pow(value, 1 / 3).toDouble();
      case 'ln':
        return log(value);
      case 'log₁₀':
        return log(value) / log(10);
      case 'x²':
        return pow(value, 2).toDouble();
      case 'x³':
        return pow(value, 3).toDouble();
      case 'x!':
        return _factorial(value.toInt()).toDouble();
      case 'x⁻¹':
        return value == 0 ? double.infinity : 1 / value;
      case 'e':
        return e;
      case 'eⁿ':
        return pow(e, value).toDouble();
      case 'sin⁻¹':
        return asin(value) * (180 / pi);
      case 'cos⁻¹':
        return acos(value) * (180 / pi);
      case 'tan⁻¹':
        return atan(value) * (180 / pi);
      default:
        return _evaluateTrigonometricFunction(function, value);
    }
  }

  /// Handles trigonometric and hyperbolic functions
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
  double _sinh(double x) => (exp(x) - exp(-x)) / 2;
  double _cosh(double x) => (exp(x) + exp(-x)) / 2;
  double _tanh(double x) => _sinh(x) / _cosh(x);

  /// Factorial function
  int _factorial(int num) {
    if (num < 0) return 0;
    if (num == 0 || num == 1) return 1;
    return num * _factorial(num - 1);
  }
}
