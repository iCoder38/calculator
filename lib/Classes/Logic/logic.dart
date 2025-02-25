import 'dart:math';
import 'package:math_expressions/math_expressions.dart';

/*
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

      // ✅ Automatically calculate last value before applying operations
      if (input == 'x²' || input == 'x³' || input == 'xⁿ' || input == 'x!') {
        RegExp numberRegex = RegExp(r'(\d+)$'); // Extract last number
        Match? match = numberRegex.firstMatch(currentInput);

        if (match != null) {
          String numberStr = match.group(0)!;
          double number = double.parse(numberStr);

          double result;
          if (input == 'x²') {
            result = pow(number, 2).toDouble();
          } else if (input == 'x³') {
            result = pow(number, 3).toDouble();
          } else if (input == 'x!') {
            result = _factorial(number.toInt()).toDouble();
          } else if (input == 'xⁿ') {
            currentInput += "^"; // Allow user to enter exponent
            return currentInput;
          } else {
            return "Error";
          }

          // ✅ Replace the last number with its calculated result
          currentInput = currentInput.replaceFirst(
            RegExp(r'(\d+)$'),
            result.toString(),
          );
        }
        return currentInput;
      }

      // ✅ Auto-compute x⁻¹ immediately
      if (input == 'x⁻¹') {
        RegExp numberRegex = RegExp(r'(\d+)$'); // Extract last number
        Match? match = numberRegex.firstMatch(currentInput);

        if (match != null) {
          String numberStr = match.group(0)!;
          double number = double.parse(numberStr);
          if (number == 0) return "Error"; // Avoid division by zero

          double result = 1 / number;

          currentInput = currentInput.replaceFirst(
            RegExp(r'(\d+)$'),
            result.toString(),
          );
        }
        return currentInput;
      }

      if (RegExp(r'[+\-×÷^]').hasMatch(input)) {
        if (currentInput.isEmpty || currentInput.endsWith("(")) {
          return currentInput; // Prevent invalid operator placement
        }

        if (RegExp(r'[0-9πe)]$').hasMatch(currentInput)) {
          String evaluatedPart = _evaluateExpression(currentInput);
          currentInput = evaluatedPart + input; // Append operator after result
        } else {
          currentInput =
              currentInput.substring(0, currentInput.length - 1) + input;
        }
        return currentInput;
      }

      if (input == "(") {
        if (currentInput.isEmpty ||
            RegExp(r'[+\-×÷^]$').hasMatch(currentInput)) {
          currentInput += "(";
        } else {
          currentInput += "×("; // Ensure multiplication before "("
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

      if (RegExp(r'^\d+$').hasMatch(input)) {
        if (currentInput.isNotEmpty && currentInput.endsWith("(")) {
          currentInput += input;
        } else {
          currentInput += input;
        }
        return currentInput;
      }

      if (input == 'π' || input == 'e') {
        currentInput += input;
        return currentInput;
      }

      if (input == 'log₁₀') {
        if (currentInput.isNotEmpty) {
          currentInput = "log10($currentInput)";
        } else {
          currentInput = "log10(";
        }
        return currentInput;
      }

      // sin cos tan
      if (input == 'sin' || input == 'cos' || input == 'tan' || 
    input == 'sin⁻¹' || input == 'cos⁻¹' || input == 'tan⁻¹') {
  
  RegExp numberRegex = RegExp(r'(\d+)$'); // Extract last number
  Match? match = numberRegex.firstMatch(currentInput);

  if (match != null) {
    String numberStr = match.group(0)!;
    // ✅ Convert `90 tan` → `tan(90)`
    currentInput = currentInput.replaceFirst(RegExp(r'\d+$'), "$input($numberStr)");
  } else {
    // ✅ If `tan` is entered first, show `tan()`
    if (currentInput.isEmpty || currentInput.endsWith("+") || currentInput.endsWith("-") ||
        currentInput.endsWith("×") || currentInput.endsWith("÷") || currentInput.endsWith("^") ||
        currentInput.endsWith("(")) {
      currentInput += "$input()"; // ✅ Show `tan()`, `sin()`, etc.
    } else {
      currentInput += "×$input()"; // ✅ Ensures multiplication like `5×sin()`
    }
  }
  return currentInput;
}

// ✅ If a user enters a number right after `tan()`, put it inside `()`
RegExp functionRegex = RegExp(r'(sin\(\)|cos\(\)|tan\(\)|sin⁻¹\(\)|cos⁻¹\(\)|tan⁻¹\(\))');
if (RegExp(r'^\d+$').hasMatch(input) && functionRegex.hasMatch(currentInput)) {
  // ✅ Replace empty `()` with `(number)`
  currentInput = currentInput.replaceFirst(RegExp(r'\(\)'), "($input)");
  return currentInput;
}


      // log 10
      if (input == 'log₁₀') {
        RegExp numberRegex = RegExp(r'(\d+)$'); // Extract last number
        Match? match = numberRegex.firstMatch(currentInput);

        if (match != null) {
          String numberStr = match.group(0)!;
          double number = double.parse(numberStr);

          if (number <= 0)
            return "Error: log₁₀ undefined"; // ✅ Prevents log(0) and log(negative)

          double result =
              log(number) / log(10); // ✅ Correct log base 10 calculation

          // ✅ Replace the last number with its calculated log₁₀ result
          currentInput = currentInput.replaceFirst(
            RegExp(r'(\d+)$'),
            result.toString(),
          );
        }
        return currentInput;
      }

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
        if (value <= 0)
          return double.nan; // ✅ Prevents log(0) and log(negative)
        return log(value) / log(10);
      case 'x²':
        return pow(value, 2).toDouble();
      case 'x³':
        return pow(value, 3).toDouble();
      case 'x!':
        return _factorial(value.toInt()).toDouble();
      case 'x⁻¹':
        return value == 0
            ? double.infinity
            : 1 / value; // ✅ FIXED: Inverse calculation
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
*/

// #2
class CalculatorLogic {
  double memory = 0.0;

  String processInput(String label, String currentResult) {
    if (currentResult == '0' && _isNumericOrFunction(label)) {
      currentResult = ''; // ✅ Ensure `0` is removed when starting new input
    }

    switch (label) {
      case 'C':
        return '0';
      case '⌫':
        return currentResult.isEmpty || currentResult == '0'
            ? '0'
            : currentResult.substring(0, currentResult.length - 1);
      case 'π':
        return currentResult == '0' ? 'π' : '$currentResultπ';
      case 'e':
        return currentResult == '0' ? 'e' : '${currentResult}e';

      // ✅ Ensure `sin(`, `cos(`, `tan(` start fresh (remove default "0")
      case 'sin':
      case 'cos':
      case 'tan':
      case 'sin⁻¹':
      case 'cos⁻¹':
      case 'tan⁻¹':
      case 'sinh':
      case 'cosh':
      case 'tanh':
      case 'ln':
      case '√':
      case '∛':
      case 'eⁿ':
        return '${currentResult == '0' ? '' : currentResult}$label(';
      case 'x²':
        return '$currentResult^2';
      case 'x³':
        return '$currentResult^3';
      case 'x⁻¹':
        return '$currentResult^(-1)';
      case 'xⁿ':
        return '$currentResult^';
      case 'x!':
        return '$currentResult!';
      case 'log₁₀':
        return '${currentResult == '0' ? '' : currentResult}log10(';
      case '(':
      case ')':
        return currentResult + label;
      case '÷':
        return '$currentResult/';
      case '×':
        return '$currentResult*';
      case '−':
        return '$currentResult-';
      case '+':
        return '$currentResult+';

      default:
        return currentResult == '0' ? label : currentResult + label;
    }
  }

  bool _isNumericOrFunction(String label) {
    return RegExp(r'^[0-9πesincostanlog√∛!%()÷×−+.]$').hasMatch(label);
  }

  String evaluateExpression(String expression) {
    String expr = expression
        .replaceAll('π', pi.toString())
        .replaceAll('e', e.toString());

    // ✅ Handle percentages
    expr = expr.replaceAllMapped(RegExp(r'(\d+\.?\d*)%'), (match) {
      double number = double.parse(match.group(1)!);
      return (number / 100).toString();
    });

    // ✅ Handle factorial
    expr = expr.replaceAllMapped(RegExp(r'(\d+)!'), (match) {
      int number = int.parse(match.group(1)!);
      int factorial = 1;
      for (int i = 2; i <= number; i++) {
        factorial *= i;
      }
      return factorial.toString();
    });

    // ✅ Convert `√(x)` to `sqrt(x)`
    expr = expr.replaceAllMapped(RegExp(r'√\(([^)]+)\)'), (match) {
      double num = _evaluateSimpleExpression(match.group(1)!);
      return num < 0 ? 'Error' : sqrt(num).toString();
    });

    // ✅ Convert `∛(x)` to `cbrt(x)`
    expr = expr.replaceAllMapped(RegExp(r'∛\(([^)]+)\)'), (match) {
      double num = _evaluateSimpleExpression(match.group(1)!);
      double result = pow(num, 1 / 3).toDouble();
      return result % 1 == 0
          ? result.toInt().toString()
          : result.toStringAsFixed(6);
    });

    // ✅ Convert `log10(x)` to `log(x) / log(10)`
    expr = expr.replaceAllMapped(RegExp(r'log10\(([^)]+)\)'), (match) {
      double? num =
          double.tryParse(match.group(1)!) ??
          _evaluateSimpleExpression(match.group(1)!);
      return (num > 0) ? (log(num) / log(10)).toString() : 'Error';
    });

    // ✅ Convert `ln(x)` to `log(x) / log(e)`
    expr = expr.replaceAllMapped(RegExp(r'ln\(([^)]+)\)'), (match) {
      double num = _evaluateSimpleExpression(match.group(1)!);
      return num <= 0 ? 'Error' : (log(num) / log(e)).toString();
    });

    // ✅ Convert trigonometric functions from degrees to radians before parsing
    expr = expr.replaceAllMapped(RegExp(r'sin\(([^)]+)\)'), (match) {
      double num = _evaluateSimpleExpression(match.group(1)!);
      return sin(num * (pi / 180)).toString();
    });

    expr = expr.replaceAllMapped(RegExp(r'cos\(([^)]+)\)'), (match) {
      double num = _evaluateSimpleExpression(match.group(1)!);
      return cos(num * (pi / 180)).toString();
    });

    expr = expr.replaceAllMapped(RegExp(r'tan\(([^)]+)\)'), (match) {
      double num = _evaluateSimpleExpression(match.group(1)!);
      return tan(num * (pi / 180)).toString();
    });

    // ✅ Convert hyperbolic functions properly (using radian values)
    expr = expr.replaceAllMapped(RegExp(r'sinh\(([^)]+)\)'), (match) {
      double num = _evaluateSimpleExpression(match.group(1)!);
      return _sinh(num * (pi / 180)).toString();
    });

    expr = expr.replaceAllMapped(RegExp(r'cosh\(([^)]+)\)'), (match) {
      double num = _evaluateSimpleExpression(match.group(1)!);
      return _cosh(num * (pi / 180)).toString();
    });

    expr = expr.replaceAllMapped(RegExp(r'tanh\(([^)]+)\)'), (match) {
      double num = _evaluateSimpleExpression(match.group(1)!);
      return _tanh(num * (pi / 180)).toString();
    });

    // ✅ Convert radians to degrees for inverse trig functions
    expr = expr.replaceAllMapped(RegExp(r'asin\(([^)]+)\)'), (match) {
      double num = _evaluateSimpleExpression(match.group(1)!);
      return (asin(num) * (180 / pi)).toString();
    });

    expr = expr.replaceAllMapped(RegExp(r'acos\(([^)]+)\)'), (match) {
      double num = _evaluateSimpleExpression(match.group(1)!);
      return (acos(num) * (180 / pi)).toString();
    });

    expr = expr.replaceAllMapped(RegExp(r'atan\(([^)]+)\)'), (match) {
      double num = _evaluateSimpleExpression(match.group(1)!);
      return (atan(num) * (180 / pi)).toString();
    });

    // ✅ Handle `e^x` as `exp(x)`
    expr = expr.replaceAllMapped(RegExp(r'e\^([0-9.]+)'), (match) {
      double num = double.parse(match.group(1)!);
      return exp(num).toString();
    });

    // ✅ Convert `x⁻¹` (reciprocal) to `1/x` and prevent division by zero
    expr = expr.replaceAllMapped(RegExp(r'(\d+|\([^)]*\))\^\(-1\)'), (match) {
      double num = _evaluateSimpleExpression(match.group(1)!);
      return (num != 0)
          ? (1 / num).toString()
          : 'Error'; // ❌ Prevents division by zero
    });

    try {
      Parser p = Parser();
      Expression exp = p.parse(expr);
      ContextModel cm = ContextModel();

      double evalResult = exp.evaluate(EvaluationType.REAL, cm);
      return evalResult % 1 == 0
          ? evalResult.toInt().toString()
          : evalResult.toString();
    } catch (e) {
      return 'Error';
    }
  }

  /// ✅ Helper function to evaluate simple expressions inside `log10()`, `ln()`, etc.
  double _evaluateSimpleExpression(String expression) {
    try {
      Parser p = Parser();
      Expression exp = p.parse(expression);
      ContextModel cm = ContextModel();
      return exp.evaluate(EvaluationType.REAL, cm);
    } catch (e) {
      return double.nan;
    }
  }

  /// ✅ Manually defined hyperbolic functions
  double _sinh(double x) {
    return (exp(x) - exp(-x)) / 2;
  }

  double _cosh(double x) {
    return (exp(x) + exp(-x)) / 2;
  }

  double _tanh(double x) {
    return _sinh(x) / _cosh(x);
  }
}
