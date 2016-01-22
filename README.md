# StageXL GAF Player

Dart/StageXL port of Staring GAF implementation: https://github.com/CatalystApps/StarlingGAFPlayer

## Version 0.0.1 - 538 errors to go.

* The Starling code was ported with [StageXL Converter](https://github.com/blockforest/stagexl-converter-pubglobal)
* Initially, the code had 2342 errors, most of them syntactic.
* This was brought down to 538 by manually going through the hints of Dart Analyzer

    Most stuff was usage of NaN, if-conditions not being boolean, and special cases of Vectors and Lists the porting logic (it's all RegExp, mind you) did not and can not account for. 

* The tough part of porting has yet to start: ZIP support, FileLoader substitutes, Starling features to StageXL features, and whatnot
* Needless to say: The code does not run as of now.
* The index.html does not call the demo at src/demo/slot_machine.dart 