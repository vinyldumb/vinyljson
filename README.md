# vinyljson

JSON (un)serializer with RTTI (Runtime Type Information) support

### Class serialization

Classes implementing IJsonSerializable can be serialized. Their fields can have the following metadata:

- @:json.ignore
- @:json.property(name)

## TODO

- Enum serialization