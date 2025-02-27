package vinyl.json._internal;

import haxe.rtti.CType.ClassField;

class Utils
{
	public static function shouldIgnoreField(field:ClassField):Bool
	{
		for (entry in field.meta)
		{
			if (entry.name == ':json.ignore')
			{
				return true;
			}
		}
		return false;
	}

	public static function getFieldJsonName(field:ClassField):String
	{
		var result = field.name;
		for (entry in field.meta)
		{
			if (entry.name == ':json.property' && entry.params[0] != null)
			{
				var firstCharCode = entry.params[0].charCodeAt(0);
				var quoted = firstCharCode == '"'.code || firstCharCode == '\''.code;

				if (quoted)
				{
					result = entry.params[0].substr(1, entry.params[0].length - 2);
				}
				else
				{
					result = entry.params[0];
				}
			}
		}
		return result;
	}

	private static var _IGNORED_CHAR_CODES =
	[
		' '.code,
		'\r'.code,
		'\n'.code,
		'\t'.code
	];

	public static function isIgnoredCharCode(charCode:Int):Bool
	{
		return _IGNORED_CHAR_CODES.contains(charCode);
	}
}