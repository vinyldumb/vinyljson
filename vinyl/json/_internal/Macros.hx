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

	public static macro function addRtti():Array<Field>
	{
		final classRef = Context.getLocalClass();

		if (!classRef.get().meta.has(':rtti'))
		{
			classRef.get().meta.add(':rtti', [], Context.currentPos());
		}

		return Context.getBuildFields();
	}
}