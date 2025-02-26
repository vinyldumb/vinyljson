package vinyl.json;

class VinylJson {
	public static function serialize<T>(input:T, ?space:String):String {
		return new JsonSerializer(space).serialize(input).getJson();
	}
}