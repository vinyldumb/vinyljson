package vinyl.json._internal;

import vinyl.json.exceptions.ParamException;
import haxe.rtti.CType.ClassField;

using StringTools;

class Utils
{
	public static function getClassFieldJsonProperty(cfield:ClassField):String
	{
		var result = cfield.name;
		
		for (entry in cfield.meta)
		{
			if (entry.name == ':json.property')
			{
				result = entry.params[0];
				if ((result.startsWith('"') && result.endsWith('"')) || (result.startsWith('\'') && result.endsWith('\'')))
				{
					result = result.substr(1, result.length - 2);
				}
			}
		}

		if (result.contains('"'))
		{
			throw new ParamException(0, 'Invalid param 0: $result');
		}

		return result;
	}

	public static function filterClassFields(cfield:ClassField):Bool
	{
		if (cfield.type.match(CFunction(_, _)))
		{
			return false;
		}

		for (entry in cfield.meta)
		{
			if (entry.name == ':json.ignore')
			{
				return false;
			}
		}

		return true;
	}
}