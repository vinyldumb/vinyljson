package vinyl.json;

/**
 * Automatically adds @:rtti metadata to the class if it has not got it
 */
@:autoBuild(vinyl.json._internal.Macros.addRtti())
interface IJsonSerializable {}