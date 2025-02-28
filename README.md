# vinyljson

JSON (un)serializer with RTTI (Runtime Type Information) support

### Class serialization

Classes with @:rtti metadata can be serialized. Their fields can have the following metadata:

- @:json.ignore
- @:json.property(name)

## TODO

- Enum serialization