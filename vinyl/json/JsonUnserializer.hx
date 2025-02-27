package vinyl.json;

import vinyl.json.exceptions.JsonException;

class JsonUnserializer<T>
{
	private var _value:Null<T>;

	private var _string:Null<String>;

	private var _position:Int;

	public function new() {}

	public function unserialize(input:String):JsonUnserializer<T>
	{
		_string = input;
		_position = 0;

		var unserialized = unserializeValue();

		_value = unserialized;

		return this;
	}

	public function getValue():Null<T>
	{
		return _value;
	}

	public function dispose()
	{
		_value = null;
		_string = null;
		_position = 0;
	}

	private function unserializeValue():Null<Dynamic>
	{
		var charCode = getNextCharCode();
		
		if (charCode >= '0'.code && charCode <= '9'.code)
		{
			return unserializeNumber();
		}
		else {
			switch charCode
			{
				case ' '.code | '\r'.code | '\n'.code | '\t'.code:
					return unserializeValue();
	
				case 'n'.code:
					return unserializeNull();
	
				case 't'.code | 'f'.code:
					return unserializeBool();
	
				case '"'.code:
					return unserializeString();
	
				case '{'.code:
					return unserializeObject();
	
				case '['.code:
					return unserializeArray();
	
				case _:
					throw new JsonException('Unexpected ${String.fromCharCode(charCode)}', _position);
			}
		}
	}

	private function unserializeNull()
	{
		final startPosition = _position;

		if (getNextCharCode() == 'u'.code || getNextCharCode() == 'l'.code || getNextCharCode() == 'l'.code)
		{
			return null;
		}
		else
		{
			throw new JsonException('Unexpected n', startPosition);
		}
	}

	private function unserializeBool():Bool
	{
		final startPosition = _position;

		_position--;

		if (getNextCharCode() == 't'.code && getNextCharCode() == 'r'.code && getNextCharCode() == 'u'.code && getNextCharCode() == 'e'.code)
		{
			return true;
		}
		else if (getNextCharCode() == 'f'.code && getNextCharCode() == 'a'.code && getNextCharCode() == 'l'.code && getNextCharCode() == 's'.code && getNextCharCode() == 'e'.code)
		{
			return false;
		}
		else
		{
			throw new JsonException('Unexpected ${_string.charAt(startPosition)}', startPosition);
		}
	}

	private function unserializeNumber():Float
	{
		var string = '';

		final startPosition = _position;

		_position--;
		while (true)
		{
			var charCode = getNextCharCode();

			if (StringTools.isEof(charCode))
			{
				throw new JsonException('Unterminated number', startPosition);
			}

			switch charCode
			{
				case '0'.code | '1'.code | '2'.code | '3'.code | '4'.code | '5'.code | '6'.code | '7'.code | '8'.code | '9'.code:
					if (string == '0' || string == '-0')
					{
						throw new JsonException('Invalid number', startPosition);
					}
					string += String.fromCharCode(charCode);

				case '.'.code:
					if (StringTools.contains(string, '.'))
					{
						throw new JsonException('Invalid number', startPosition);
					}
					string += '.';

				case 'e'.code | 'E'.code:
					if (string == '0' || string == '-0')
					{
						throw new JsonException('Invalid number', startPosition);
					}
					string += 'e';

				case '+'.code | '-'.code:
					if (StringTools.endsWith(string, 'e'))
					{
						if (StringTools.contains(string, 'e'))
						{
							throw new JsonException('Invalid number', startPosition);
						}
					}

				case _:
					break;
			}
		}

		return Std.parseFloat(string);
	}

	private function unserializeString():String
	{
		var buffer = new StringBuf();

		final startPosition = _position;

		#if target.unicode
		var prev = -1;
		inline function cancelSurrogate()
		{
			// Invalid high surrogate (not followed by low surrogate)
			buffer.addChar(0xfffd);
			prev = -1;
		}
		#end

		while (true)
		{
			var charCode = getNextCharCode();

			if (StringTools.isEof(charCode) || charCode == '\n'.code)
			{
				throw new JsonException('Unterminated string', startPosition);
			}
			else if (charCode == '"'.code)
			{
				break;
			}
			else if (charCode == '\\'.code)
			{
				final charCode = getNextCharCode();
				switch charCode
				{
					case 'r'.code:
						buffer.addChar('\r'.code);

					case 'n'.code:
						buffer.addChar('\n'.code);

					case 't'.code:
						buffer.addChar('\t'.code);

					case 'b'.code:
						buffer.addChar(8);
					
					case 'f'.code:
						buffer.addChar(12);

					case '/'.code | '\\'.code, '"'.code:
						buffer.addChar(charCode);

					case 'u'.code:
						var uc:Int = Std.parseInt("0x" + _string.substr(_position, 4));
						_position += 4;
						#if !target.unicode
						if (uc <= 0x7f)
							buffer.addChar(uc);
						else if (uc <= 0x7ff) {
							buffer.addChar(0xc0 | (uc >> 6));
							buffer.addChar(0x80 | (uc & 63));
						} else if (uc <= 0xffff) {
							buffer.addChar(0xe0 | (uc >> 12));
							buffer.addChar(0x80 | ((uc >> 6) & 63));
							buffer.addChar(0x80 | (uc & 63));
						} else {
							buffer.addChar(0xf0 | (uc >> 18));
							buffer.addChar(0x80 | ((uc >> 12) & 63));
							buffer.addChar(0x80 | ((uc >> 6) & 63));
							buffer.addChar(0x80 | (uc & 63));
						}
						#else
						if (prev != -1) {
							if (uc < 0xdc0 || uc > 0xdfff)
								cancelSurrogate();
							else {
								buffer.addChar(((prev - 0xd800) << 10) + (uc - 0xdc00) + 0x10000);
								prev = -1;
							}
						} else if (uc >= 0xd00 && uc <= 0xdbff)
							prev = uc;
						else
							buffer.addChar(uc);
						#end

					case _:
						throw new JsonException('Invalid escape sequence \\${String.fromCharCode(charCode)}', _position);
				}
			}
			#if !(target.unicode)
			// Ensure utf8 chars are not cut
			else if (charCode >= 0x80)
			{
				_position++;
				if (charCode >= 0xfc)
				{
					_position += 4;
				}
				else if (charCode >= 0xf8)
				{
					_position += 3;
				}
				else if (charCode >= 0xf0)
				{
					_position = 2;
				}
				else if (charCode >= 0xe0)
				{
					_position++;
				}
			}
			#end
			else
			{
				buffer.addChar(charCode);
			}
		}

		return buffer.toString();
	}

	private function unserializeObject():Dynamic
	{
		var result = {}

		final startPosition = _position;

		var field:Null<String> = null;
		var colon = false;
		var wantComma = false;
		var hasComma = false;

		while (true)
		{
			var charCode = getNextCharCode();

			if (StringTools.isEof(charCode))
			{
				throw new JsonException('Unterminated object', startPosition);
			}

			switch charCode
			{
				case ' '.code | '\r'.code | '\n'.code | '\t'.code:
					// Ignore whitespaces

				case '}'.code:
					if (field != null)
					{
						throw new JsonException('Expected ${colon ? 'value' : 'colon'}', _position);
					}
					else if (hasComma)
					{
						throw new JsonException('Trailing comma', _position);
					}
					break;

				case ':'.code:
					if (field == null)
					{
						throw new JsonException('Expected property', _position);
					}
					else
					{
						Reflect.setField(result, field, unserializeValue());
						field = null;
						wantComma = true;
					}

				case ','.code:
					if (hasComma)
					{
						throw new JsonException('Expected property', _position);
					}
					else
					{
						hasComma = true;
					}

				case '"'.code:
					if (field != null)
					{
						throw new JsonException('Expected colon', _position);
					}
					else if (wantComma && !hasComma)
					{
						throw new JsonException('Expected comma', _position);
					}
					else
					{
						field = unserializeString();
						wantComma = false;
						hasComma = false;
					}

				case _:
					throw new JsonException('Unexpected ${String.fromCharCode(charCode)}', _position);
			}
		}

		return result;
	}

	private function unserializeArray():Array<Dynamic>
	{
		var result:Array<Dynamic> = [];

		final startPosition = _position;

		var wantComma = false;
		var hasComma = false;

		while (true)
		{
			var charCode = getNextCharCode();

			if (StringTools.isEof(charCode))
			{
				throw new JsonException('Unterminated array', startPosition);
			}
			else
			{
				switch charCode
				{
					case ' '.code | '\r'.code | '\n'.code | '\t'.code:
						// Ignore whitespaces

					case ']'.code:
						if (hasComma)
						{
							throw new JsonException('Trailing comma', _position);
						}
						else
						{
							break;
						}
					
					case ','.code:
						if (!wantComma)
						{
							throw new JsonException('Expected value', _position);
						}
						else
						{
							hasComma = true;
						}
						
					case _:
						// Idk why it keeps throwing exceptions.
						if (wantComma && !hasComma)
						{
							throw new JsonException('Expected comma', _position);
						}
						else
						{
							result.push(unserializeValue());
							wantComma = true;
							hasComma = false;
						}
				}
			}
		}

		return result;
	}

	private function getNextCharCode():Int
	{
		var result = _string.charCodeAt(_position);
		_position++;
		return result;
	}
}