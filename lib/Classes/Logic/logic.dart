import 'dart:math';
import 'package:math_expressions/math_expressions.dart';

class CalculatorLogic {
  String currentInput = "";
  String selectedFunction = "";
  bool isSecondFunctionActive = false;
  double memoryValue = 0.0;

  /// Processes user input and returns updated output
  String processInput(String input, String currentResult) {
    try {
      if (input == 'C') {
        currentInput = "";
        selectedFunction = "";
        isSecondFunctionActive = false;
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
        isSecondFunctionActive = !isSecondFunctionActive;
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

      if (input == 'xⁿ') {
        if (currentInput.isNotEmpty) {
          currentInput += "^";
          return currentInput;
        }
        return "Error: Enter base first";
      }

      if (input == '(' || input == ')' || input == 'π' || input == 'e') {
        currentInput += input;
        return currentInput;
      }

      if (input == "(") {
        if (currentInput.isEmpty ||
            RegExp(r'[+\-×÷^]$').hasMatch(currentInput)) {
          currentInput += "(";
        } else if (RegExp(r'[0-9πe)]$').hasMatch(currentInput)) {
          currentInput += "×("; // Ensure multiplication before "(" when needed
        } else {
          currentInput += "(";
        }
        return currentInput;
      }

      if (input == ")") {
        int openBrackets = currentInput.split("(").length - 1;
        int closeBrackets = currentInput.split(")").length - 1;

        if (openBrackets > closeBrackets &&
            RegExp(r'[0-9πe)]$').hasMatch(currentInput)) {
          currentInput += ")";
        }
        return currentInput;
      }

      // ✅ Ensure that numbers inside parentheses don't disappear
      if (RegExp(r'^\d+$').hasMatch(input)) {
        if (currentInput.isNotEmpty && currentInput.endsWith("(")) {
          // ✅ Directly append first number inside brackets
          currentInput += input;
        } else {
          currentInput += input;
        }
        return currentInput;
      }

      if (input == 'x!') {
        RegExp numberRegex = RegExp(r'\d+$'); // Find last number in input
        Match? match = numberRegex.firstMatch(currentInput);

        if (match != null) {
          String numberStr = match.group(0)!;
          int number = int.parse(numberStr);

          if (number < 0) return "Error: Factorial not defined for negatives";

          // Replace last number with its factorial
          currentInput = currentInput.replaceFirst(
            numberStr,
            _factorial(number).toString(),
          );
          return currentInput;
        } else {
          return "Error: Enter a valid number first";
        }
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
      // Convert operators to standard math symbols
      expression = expression
          .replaceAll('÷', '/')
          .replaceAll('×', '*')
          .replaceAll('π', pi.toString());

      // Ensure brackets are balanced before evaluating
      if (!_areBracketsBalanced(expression)) {
        return "Error: Unmatched brackets";
      }

      // Handle Factorial (`x!`)
      expression = expression.replaceAllMapped(
        RegExp(r'(\d+)!'), // Match numbers followed by '!'
        (match) {
          int number = int.parse(match.group(1)!);
          return _factorial(number).toString();
        },
      );

      // Handle Exponentiation (`xⁿ`)
      expression = expression.replaceAllMapped(
        RegExp(r'(\d+(\.\d+)?)\^(\d+(\.\d+)?)'),
        (match) {
          double base = double.parse(match.group(1)!);
          double exponent = double.parse(match.group(3)!);
          return pow(base, exponent).toString();
        },
      );

      // Parse and evaluate the modified expression
      Parser parser = Parser();
      Expression exp = parser.parse(expression);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      if (selectedFunction.isNotEmpty) {
        eval = _applyFunction(selectedFunction, eval);
        selectedFunction = "";
      }

      return eval.toString();
    } catch (e) {
      return "Error";
    }
  }

  /// Checks if brackets are balanced in an expression
  bool _areBracketsBalanced(String expression) {
    int balance = 0;
    for (int i = 0; i < expression.length; i++) {
      if (expression[i] == '(') balance++;
      if (expression[i] == ')') balance--;
      if (balance < 0) return false;
    }
    return balance == 0;
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
    double radians = value * (pi / 180);
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

  /// Improved Factorial function
  int _factorial(int num) {
    if (num < 0) throw ArgumentError("Factorial is not defined for negatives");
    if (num == 0 || num == 1) return 1;
    int result = 1;
    for (int i = 2; i <= num; i++) {
      result *= i;
    }
    return result;
  }
}
