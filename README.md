# XFactor Intelligent

## Stack

- State Management: [GetX](https://pub.dev/packages/get)
- Data class: [Freezed](https://pub.dev/packages/freezed)
- Rest API: [Dio](https://pub.dev/packages/dio)
- Storage: [Get Storage](https://pub.dev/packages/get_storage)
- Lints: [Flutter Lints](https://pub.dev/packages/flutter_lints) + [Dart code metrics](https://pub.dev/packages/dart_code_metrics)
- Code generation: [Build Runner](https://pub.dev/packages/build_runner) + [Freezed](https://pub.dev/packages/freezed) + [Json Serializable](https://pub.dev/packages/json_serializable)
- Assets generation: [Flutter Gen](https://pub.dev/packages/flutter_gen) + [Flutter Launcher Icons](https://pub.dev/packages/flutter_launcher_icons) + [Flutter Native Splash](https://pub.dev/packages/flutter_native_splash)

## Structure

```bash
./lib
├── bindings
├── core
│   ├── configs
│   ├── constants
│   ├── exceptions
│   ├── extensions
│   ├── helpers
│   ├── mixins
│   └── utils
├── data
│   ├── api
│   │   ├── clients
│   │   └── interceptors
│   ├── base
│   ├── mappers
│   │   ├── base
│   │   ├── exception_mappers
│   │   └── response_mapper
│   └── preferences
├── l10n
├── models
│   └── base
├── presentation
│   ├── base
│   ├── common_controller.dart
│   ├── common_widgets
│   ├── features
│   │   ├── auth
│   │   │   ├── bindings
│   │   │   ├── controllers
│   │   │   └── views
│   │   └── splash
│   │       ├── bindings
│   │       ├── controllers
│   │       └── views
│   ├── resource
│   │   ├── gen
│   │   └── styles
│   └── routing
│       ├── middlewares
│       ├── observer
│       └── routers
└── repositories

```

## Getting Started 🚀

### After changing models with `@JsonSerializable` or `@freezed` or add new assets, run:

    make gen_code

### Notable files

#### Environment setup

Create a `.env` file for each flavor following the `env.example`

```
API_URL=[Your API URL]
```
