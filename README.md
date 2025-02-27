# vinyljson

JSON (un)serializer with RTTI (Runtime Type Information) support

## How to use

You can use it in the same way as haxe.Json

```haxe
var obj =
{
	string: 'string value',
	number: 83.4,
	boolean: true,
	map:
	[
		'key1' => 'hello there!'
	]
}

vinyl.json.VinylJson.serialize(obj); // {"map":{"key1":"hello there!"},"number":83.4,"string":"string value","boolean":true}
```
### Class serialization

Classes implementing IJsonSerializable can be serialized. Their fields can have the following metadata:

- @:json.ignore
- @:json.property(name)

### TODO

- [ ] JSON Unserializer (help me please 😭)