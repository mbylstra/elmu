Elm.Native.StringExtra = {};

Elm.Native.StringExtra.make = function(localRuntime) {
	localRuntime.Native = localRuntime.Native || {};
	localRuntime.Native.StringExtra = localRuntime.Native.StringExtra || {};
	if (localRuntime.Native.StringExtra.values)
	{
		return localRuntime.Native.StringExtra.values;
	}
	if ('values' in Elm.Native.StringExtra)
	{
		return localRuntime.Native.StringExtra.values = Elm.Native.StringExtra.values;
	}

	var Char = Elm.Char.make(localRuntime);
	var Result = Elm.Result.make(localRuntime);

	function toIntFromBase(base, s)
	{
    var result = parseInt(s, base);
    if (isNaN(result)) {
      return Result.Err("could not convert string '" + s + "' to an Int" );
    }
		return Result.Ok(parseInt(s, base));
	}

	return Elm.Native.StringExtra.values = {
    toIntFromBase: F2(toIntFromBase)
	};
};
