package vinyl.json._internal;

import haxe.ds.StringMap;
import haxe.rtti.CType;
import haxe.exceptions.ArgumentException;
import haxe.rtti.Rtti;
import hxjsonast.Json;

class JsonToValueConverter
{
	public static function convert<T>(input:Json, ?c:Class<T>):T
	{
		if (c != null)
		{
			return convertClass(input, c);
		}

		switch input.value
		{
			case JString(s):
				return cast s;

			case JNumber(s):
				return cast Std.parseFloat(s);

			case JObject(fields):
				var result = {}
				for (field in fields)
				{
					Reflect.setField(result, field.name, convert(field.value));
				}
				return cast result;

			case JArray(values):
				var result:Array<Dynamic> = [];
				for (value in values)
				{
					result.push(convert(value));
				}
				return cast result;

			case JBool(b):
				return cast b;

			case JNull:
				return null;
		}
	}

	private static function convertClass<T>(input:Json, c:Class<T>):T
	{
		if (!Rtti.hasRtti(c))
		{
			throw new ArgumentException('c', 'Class ${Type.getClassName(c)} has no RTTI');
		}

		final struct = convert(input);
		if (!Type.typeof(struct).match(TObject))
		{
			throw new ArgumentException('input', 'Input should contain object');
		}

		return struct2class(struct, c);
	}

	private static function struct2class<T>(struct:Dynamic, c:Class<T>):T
	{
		final cdef = Rtti.getRtti(c);
		final cfields = cdef.fields.filter(Utils.filterClassFields);

		final cfieldMap =
		[
			for (cfield in cfields)
			{
				Utils.getClassFieldJsonProperty(cfield) => cfield;
			}
		];

		final result = Type.createEmptyInstance(c);

		for (field in Reflect.fields(struct))
		{
			if (!cfieldMap.exists(field))
			{
				continue;
			}

			final cfield = cfieldMap.get(field);
			final value = Reflect.field(struct, field);

			Reflect.setProperty(result, cfield.name, convertValue(cfield.type, value));
		}

		return result;
	}

	private static function convertValue(ctype:CType, input:Dynamic):Any
	{
		final type = Type.typeof(input);
		switch type
		{
			case TNull:
				if (!isNullableType(ctype))
				{
					throw new ArgumentException('input', 'Invalid input type $type');
				}
				return null;

			case TInt:
				if (!ctype.match(CAbstract('Int', _)))
				{
					throw new ArgumentException('input', 'Invalid input type $type');
				}
				return Math.floor(input);

			case TFloat:
				if (!ctype.match(CAbstract('Float', _)) && !ctype.match(CAbstract('Single', _)))
				{
					throw new ArgumentException('input', 'Invalid input type $type');
				}
				return input;

			case TBool:
				if (!ctype.match(CAbstract('Bool', _)))
				{
					throw new ArgumentException('input', 'Invalid input type $type');
				}
				return input;

			case TObject:
				switch ctype
				{
					case CClass('StringMap', [paramCType]) | CAbstract('haxe.ds.Map', [CClass('String', []), paramCType]) | CTypedef('Map', [CClass('String', []), paramCType]):
						var result = new StringMap<Any>();
						for (field in Reflect.fields(input))
						{
							final value = Reflect.field(input, field);
							result.set(field, value);
						}
						return result;

					case CClass(name, _):
						return struct2class(input, Type.resolveClass(name));

					case _:
						return input;
				}

			case TClass(String):
				return Std.string(input);

			case TClass(Array):
				switch ctype
				{
					case CClass('Array', [paramCType]):
						var result:Array<Any> = input.map(value ->
							{
								return convertValue(paramCType, value);
							});
						return result;

					case _:
						throw new ArgumentException('input', 'Invalid input type $type');
				}

			case _:
				throw new ArgumentException('input', 'Invalid input type $type');
		}
	}

	private static function isNullableType(ctype:CType):Bool
	{
		if (ctype.match(CAbstract('Float', _)))
		{
			return false;
		}
		else if (ctype.match(CAbstract('Int', _)))
		{
			return false;
		}
		else if (ctype.match(CAbstract('Single', _)))
		{
			return false;
		}
		else if (ctype.match(CAbstract('Bool', _)))
		{
			return false;
		}
		
		return true;
	}
}