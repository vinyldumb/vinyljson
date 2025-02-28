import vinyl.json.VinylJson;
import vinyl.json.IJsonSerializable;

enum TestEnum
{
	One(s:String);
	Two(b:Bool);
	Three(n:Float);
}

@:structInit
class TestClass implements IJsonSerializable
{
	@:json.property('not.str')
	public var str:String;

	@:json.ignore
	public var num:Float;

	public var boolean:Bool;

	public var arr:Array<TestClass>;

	public var map:Map<String, TestClass>;
	
	// public var enm:TestEnum;

	public function toString():String
	{
		return 'TestClass(str: $str | num: $num | boolean: $boolean | arr: $arr | map: $map)';
	}
}

function main()
{
	var rttiObject:TestClass =
	{
		str: 'best string',
		num: 83.4,
		boolean: true,
		arr:
		[
			{
				str: 'awesome string',
				num: 33000.1,
				boolean: false,
				arr: [],
				map: [],
				// enm: Two(true)
			}
		],
		map:
		[
			'cool' =>
			{
				str: 'another awesome string',
				num: 2301.79,
				boolean: true,
				arr: [],
				map: [],
				// enm: Three(7.49)
			}
		],
		// enm: One('hello')
	}

	final json = VinylJson.serialize(rttiObject, '\t');

	Sys.println(json);
	sys.io.File.saveContent('output.json', json);

	Sys.println(VinylJson.unserialize(json, TestClass));
}