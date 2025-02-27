package vinyl.json;

class VinylJson
{
	public static function serialize<T>(input:T, ?space:String):String
	{
		final serializer = new JsonSerializer<T>(space).serialize(input);
		final result = serializer.getJson();
		serializer.dispose();
		return result;
	}

	public static function unserialize<T>(input:String):T
	{
		final unserializer = new JsonUnserializer<T>().unserialize(input);
		final result = unserializer.getValue();
		unserializer.dispose();
		return result;
	}
}