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

vinyl.json.VinylJson.serialize(obj);
```

### TODO

- [ ] JSON Unserializer (help me please 😭)