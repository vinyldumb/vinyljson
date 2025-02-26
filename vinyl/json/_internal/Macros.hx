package vinyl.json._internal;

import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr.Field;

class Macros
{
	/**
	 * I hope someday they make it work properly...
	 * @return Array<Field>
	 */
	public static macro function registerMetadatas():Array<Field>
	{
		Compiler.registerCustomMetadata({
			metadata: ':json.ignore',
			doc: 'TODO',
			targets: [ClassField]
		});

		Compiler.registerCustomMetadata({
			metadata: ':json.property',
			doc: 'TODO',
			params: ['name'],
			targets: [ClassField]
		});

		return Context.getBuildFields();
	}
}