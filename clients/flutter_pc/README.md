# flutter_pc

Desktop Flutter client that will integrate with `app_api` and `app_socket`.

## Protobuf generation

The project consumes the shared `.proto` definitions from `common/proto` so we
can talk to the backend using the same message schema.

Prerequisites:

- `protoc` installed locally
- Dart protobuf plugin: `dart pub global activate protoc_plugin` (ensure
  `~/.pub-cache/bin` is on your `PATH` so `protoc-gen-dart` can be found)

Generate the Dart sources:

```bash
cd clients/flutter_pc
./tool/gen_protos.sh
```

Generated files are written to `lib/proto/` and should be committed so the
client can build without requiring `protoc` at runtime.
