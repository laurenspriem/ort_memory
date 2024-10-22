# ort_memory

This is an MRE for a reported [ONNX issue on Android](https://github.com/microsoft/onnxruntime/issues/22520).

To reproduce the crash, simply follow these steps:

1. Connect an Android phone or emulator
2. Run run_app.sh to start the app (or `flutter run -t lib/main.dart` if you have flutter installed)
3. Hit the floating button in bottom right corner to start inference
4. Wait for the app to crash (somewhere after a couple hundred inference runs)

If the app does not start, you might have to properly install Flutter.
