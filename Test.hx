import vinyl.json.IJsonSerializable;
import vinyl.json.VinylJson;

enum TestEnum
{
	One(s:String);
	Two(b:Bool);
	Three(n:Float);
}

@:structInit
class RttiSerializable implements IJsonSerializable
{
	@:json.property('not.str')
	public var str:String;

	@:json.ignore
	public var num:Float;

	public var boolean:Bool;

	public var arr:Array<RttiSerializable>;

	public var map:Map<String, RttiSerializable>;
	
	// public var enm:TestEnum;
}

function main()
{
	var rttiObject:RttiSerializable =
	{
		str: 'cool string',
		num: 83.4,
		boolean: true,
		arr:
		[
			{
				str: 'second cool string',
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
				str: 'third cool string',
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
}