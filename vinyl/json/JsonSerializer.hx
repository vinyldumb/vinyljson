package vinyl.json;

import haxe.EnumTools.EnumValueTools;
import haxe.ds.StringMap;
import haxe.rtti.CType.ClassField;
import haxe.rtti.Rtti;

class JsonSerializer<T>
{
	private var _buffer:StringBuf;

	private var _space:String;

	private var _level:Int;

	public function new(?space:String)
	{
		_space = space;
	}

	public function serialize(input:T):JsonSerializer<T>
	{
		_buffer = new StringBuf();
		_level = 0;

		serializeValue(input);

		return this;
	}

	public function getJson():String
	{
		return _buffer.toString();
	}

	public function dispose()
	{
		_buffer = null;
		_space = null;
		_level = 0;
	}

	private function serializeValue(value:Dynamic)
	{
		switch Type.typeof(value) {
			case TNull:
				_buffer.add('null');
			
			case TInt | TFloat | TBool:
				_buffer.add(Std.string(value));

			case TObject:
				serializeObject(value);

			case TClass(String):
				_buffer.add('"$value"');

			case TClass(Array):
				serializeArray(cast value);

			case TClass(haxe.ds.StringMap):
				serializeStringMap(cast value);

			case TClass(c) if (Rtti.hasRtti(c)):
				serializeClass(cast c, value);

			case TEnum(e):
				serializeEnum(cast e, cast value);

			case t:
				throw 'Unsupported value type $t';
		}
	}

	private function serializeObject(value:Dynamic)
	{
		final fields = Reflect.fields(value);

		if (fields.length == 0)
		{
			_buffer.add('{}');
			return;
		}
		
		_buffer.addChar('{'.code);
		_level++;
		addSpace();

		for (i => name in fields)
		{
			final value = Reflect.field(value, name);

			_buffer.add('"$name":');
			if (isPretty())
			{
				_buffer.addChar(' '.code);
			}

			serializeValue(value);

			if (i < fields.length - 1)
			{
				_buffer.addChar(','.code);
				addSpace();
			}
		}

		_level--;
		addSpace();
		_buffer.addChar('}'.code);
	}

	private function serializeArray(value:Array<T>)
	{
		if (value.length == 0)
		{
			_buffer.add('[]');
			return;
		}

		_buffer.addChar('['.code);
		_level++;
		addSpace();

		for (i => element in value)
		{
			if (i > 0)
			{
				_buffer.addChar(','.code);
				addSpace();
			}
			
			serializeValue(element);
		}

		_level--;
		addSpace();
		_buffer.addChar(']'.code);
	}

	private function serializeStringMap(value:StringMap<T>)
	{
		final keys = [for (key in value.keys()) key];

		if (keys.length == 0)
		{
			_buffer.add('{}');
			return;
		}
		
		_buffer.addChar('{'.code);
		_level++;
		addSpace();

		for (i => key in keys)
		{
			if (i > 0)
			{
				_buffer.addChar(','.code);
				addSpace();
			}

			final value = value.get(key);

			_buffer.add('"$key":');
			if (isPretty())
			{
				_buffer.addChar(' '.code);
			}

			serializeValue(value);
		}

		_level--;
		addSpace();
		_buffer.addChar('}'.code);
	}

	private function serializeClass(c:Class<T>, value:T)
	{
		final def = Rtti.getRtti(c);
		final fields = def.fields.filter(field -> !shouldIgnore(field));

		if (fields.length == 0)
		{
			_buffer.add('{}');
			return;
		}
		
		_buffer.addChar('{'.code);
		_level++;
		addSpace();

		for (i => field in fields)
		{
			if (field.type.match(CFunction(_, _)))
			{
				continue;
			}

			if (i < fields.length - 1)
			{
				_buffer.addChar(','.code);
				addSpace();
			}

			final name = getFieldJsonName(field);
			final value = Reflect.getProperty(value, field.name);

			_buffer.add('"$name":');
			if (isPretty())
			{
				_buffer.addChar(' '.code);
			}

			serializeValue(value);
		}

		_level--;
		addSpace();
		_buffer.addChar('}'.code);
	}

	private function serializeEnum(e:Enum<T>, value:EnumValue)
	{
		throw new haxe.exceptions.NotImplementedException('Enum values serialization not implemented');

		/*_buffer.addChar('"'.code);

		_buffer.add(EnumValueTools.getName(value));

		final params = EnumValueTools.getParameters(value);
		if (params.length > 0)
		{
			_buffer.addChar('('.code);
			for (param in params)
			{
				serializeValue(param);
			}
			_buffer.addChar(')'.code);
		}
		
		_buffer.addChar('"'.code);*/
	}

	private function isPretty():Bool
	{
		return _space != null;
	}

	private function addSpace()
	{
		if (_space != null)
		{
			_buffer.addChar('\n'.code);
			_buffer.add([for (i in 0..._level) _space].join(''));
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
