package vinyl.json;

import vinyl.json._internal.JsonToValueConverter;
import vinyl.json._internal.ValueToJsonConverter;

class VinylJson
{
	public static function serialize(input:Dynamic, ?space:String):String
	{
		final json = ValueToJsonConverter.convert(input);
		return hxjsonast.Printer.print(json, space);
	}

	public static function unserialize<T>(input:String, ?filename:String, ?c:Class<T>):T
	{
		final json = hxjsonast.Parser.parse(input, filename);
		return JsonToValueConverter.convert(json, c);
	}
}