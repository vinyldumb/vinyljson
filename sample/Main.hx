import vinyl.json.VinylJson;
import vinyl.json.IJsonSerializable;

@:structInit
class TestClass implements IJsonSerializable
{
	@:json.property('lbl')
	public var label:String;

	@:json.property('bpm')
	public var beatsPerMinute:Float;

	@:json.ignore
	public var ignoreMePls:Bool;

	public var mapValue:Map<String, TestClass>;

	public var numbers:Array<Int>;

	public function toString():String
	{
		return 'TestClass(label: $label | beatsPerMeasure: $beatsPerMinute | ignoreMePls: $ignoreMePls | mapValue: $mapValue | numbers: $numbers)';
	}
}

function main() {
	final object:TestClass = {
		label: 'VinylJson test',
		beatsPerMinute: 100.4,
		ignoreMePls: true,
		mapValue: [
			'first' => {
				label: 'object',
				beatsPerMinute: 10.76,
				ignoreMePls: false,
				mapValue: [],
				numbers: [1, 2, 3]
			}
		],
		numbers: [5, 4, 8, 6]
	}

	final json = VinylJson.serialize(object, '\t');

	Sys.println(json);
	Sys.println(VinylJson.unserialize(json, TestClass));
}