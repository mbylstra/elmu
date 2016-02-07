Elm.Native.MutableDict = {};
Elm.Native.MutableDict.make = function(localRuntime) {

	localRuntime.Native = localRuntime.Native || {};
	localRuntime.Native.MutableDict = localRuntime.Native.MutableDict || {};
	if (localRuntime.Native.MutableDict.values)
	{
		return localRuntime.Native.MutableDict.values;
	}
	if ('values' in Elm.Native.MutableDict)
	{
		return localRuntime.Native.MutableDict.values = Elm.Native.MutableDict.values;
	}

	var List = Elm.Native.List.make(localRuntime);
	var Maybe = Elm.Maybe.make(localRuntime);

  function empty()
  {
    return {};
  }

  function fromList(list)
  {
		if (list === List.Nil)
		{
			return empty();
		}

    var jsArray = List.toArray(list);

    var out = {};

    for (var i = 0; i < jsArray.length; i++) {
      var item = jsArray[i];
      var key = item._0.ctor;
      var value = item._1;
      out[key] = value
    }
    return out;
  }

  function get(key, dict) {
    var value = return dict[key.ctor];
    if (value !== undefined) {
      return Maybe.Just(value);
    } else {
		  Maybe.Nothing
    }
  }

  function insert(key, value, dict) {
    dict[key.ctor] = value;
    return dict;
  }

	Elm.Native.MutableDict.values = {
		empty: empty,
		fromList: fromList,
		// initialize: F2(initialize),
		get: F2(get),
		// set: F3(set),
		// map: F2(map),
		// length: length,
	};

	return localRuntime.Native.MutableDict.values = Elm.Native.MutableDict.values;
};
