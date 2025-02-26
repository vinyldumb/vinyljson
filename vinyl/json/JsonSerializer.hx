package vinyl.json;

import haxe.EnumTools.EnumValueTools;
import haxe.ds.StringMap;
import haxe.rtti.CType.ClassField;
import haxe.rtti.Rtti;

class JsonSerializer
{
	private var _buf:StringBuf;

	private var _spc:String;

	private var _lvl:Int;

	public function new(?space:String)
	{
		_spc = space;
	}

	public function serialize<T>(input:T):JsonSerializer
	{
		_buf = new StringBuf();
		_lvl = 0;

		serializeValue(input);

		return this;
	}

	public function getJson():String {
		return _buf.toString();
	}

	private function serializeValue<T>(value:T)
	{
		switch Type.typeof(value) {
			case TNull:
				_buf.add('null');
			
			case TInt | TFloat | TBool:
				_buf.add(Std.string(value));

			case TObject:
				serializeObject(value);

			case TClass(c):
				switch c
				{
					case String:
						_buf.add('"$value"');

					case Array:
						serializeArray(cast value);

					case haxe.ds.StringMap:
						serializeStringMap(cast value);

					case _:
						if (Rtti.hasRtti(c))
						{
							serializeClass(c, value);
						}
						else
						{
							serializeObject(value);
						}
				}

			case TEnum(e):
				serializeEnum(e, cast value);

			case t:
				throw 'Unsupported value type $t';
		}
	}

	private function serializeObject(value:Dynamic)
	{
		final fields = Reflect.fields(value);

		if (fields.length == 0)
		{
			_buf.add('{}');
			return;
		}
		
		_buf.addChar('{'.code);
		_lvl++;
		addSpace();

		for (i => name in fields)
		{
			final value = Reflect.field(value, name);

			_buf.add('"$name":');
			if (isPretty())
			{
				_buf.addChar(' '.code);
			}

			serializeValue(value);

			if (i < fields.length - 2)
			{
				_buf.addChar(','.code);
				addSpace();
			}
		}

		_lvl--;
		addSpace();
		_buf.addChar('}'.code);
	}

	private function serializeArray<T>(value:Array<T>)
	{
		if (value.length == 0)
		{
			_buf.add('[]');
			return;
		}

		_buf.addChar('['.code);
		_lvl++;
		addSpace();

		for (i => element in value)
		{
			serializeValue(element);

			if (i < value.length - 2)
			{
				_buf.addChar(','.code);
				addSpace();
			}
		}

		_lvl--;
		addSpace();
		_buf.addChar(']'.code);
	}

	private function serializeStringMap<T>(value:StringMap<T>)
	{
		final keys = [for (key in value.keys()) key];

		if (keys.length == 0)
		{
			_buf.add('{}');
			return;
		}
		
		_buf.addChar('{'.code);
		_lvl++;
		addSpace();

		for (i => key in keys)
		{
			final value = value.get(key);

			_buf.add('"$key":');
			if (isPretty())
			{
				_buf.addChar(' '.code);
			}

			serializeValue(value);

			if (i < keys.length - 2)
			{
				_buf.addChar(','.code);
				addSpace();
			}
		}

		_lvl--;
		addSpace();
		_buf.addChar('}'.code);
	}

	private function serializeClass<T>(c:Class<T>, value:T)
	{
		final def = Rtti.getRtti(c);
		final fields = def.fields.filter(field -> !shouldIgnore(field));

		if (fields.length == 0)
		{
			_buf.add('{}');
			return;
		}
		
		_buf.addChar('{'.code);
		_lvl++;
		addSpace();

		for (i => field in fields)
		{
			if (field.type.match(CFunction(_, _)))
			{
				continue;
			}

			final name = getFieldJsonName(field);
			final value = Reflect.getProperty(value, field.name);

			_buf.add('"$name":');
			if (isPretty())
			{
				_buf.addChar(' '.code);
			}

			serializeValue(value);

			if (i < fields.length - 2)
			{
				_buf.addChar(','.code);
				addSpace();
			}
		}

		_lvl--;
		addSpace();
		_buf.addChar('}'.code);
	}

	private function serializeEnum<T>(e:Enum<T>, value:EnumValue)
	{
		throw new haxe.exceptions.NotImplementedException('Enum values serialization not implemented');

		/*_buf.addChar('"'.code);

		_buf.add(EnumValueTools.getName(value));

		final params = EnumValueTools.getParameters(value);
		if (params.length > 0)
		{
			_buf.addChar('('.code);
			for (param in params)
			{
				serializeValue(param);
			}
			_buf.addChar(')'.code);
		}
		
		_buf.addChar('"'.code);*/
	}

	private function isPretty():Bool
	{
		return _spc != null;
	}

	private function addSpace()
	{
		if (_spc != null)
		{
			_buf.addChar('\n'.code);
			_buf.add([for (i in 0..._lvl) _spc].join(''));
		}
	}

	private function shouldIgnore(field:ClassField):Bool
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

	private function getFieldJsonName(field:ClassField):String
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
}