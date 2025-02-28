package vinyl.json.exceptions;

import haxe.Exception;

/**
 * An exception that is thrown when an invalid value provided for an parameter of a metadata
 */
class ParamException extends Exception
{
	public final param:Int;

	public function new(param:Int, ?message:String, ?previous:Exception, ?native:Any)
	{
		super(message ?? 'Invalid param $param', previous, native);
		this.param = param;
	}
}