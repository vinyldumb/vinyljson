package vinyl.json.exceptions;

import haxe.Exception;

class JsonException extends Exception
{
	public var position(default, null):Int;

	public function new(message:String, position:Int, ?previous:Exception, ?native:Any)
	{
		super(message, previous, native);
		this.position = position;
	}

	override function toString():String
	{
		return super.toString() + ' at position $position';
	}
}