Elm.Native.GenericMutableDict = {};
Elm.Native.GenericMutableDict.make = function(localRuntime) {

	localRuntime.Native = localRuntime.Native || {};
	localRuntime.Native.GenericMutableDict = localRuntime.Native.GenericMutableDict || {};
	if (localRuntime.Native.GenericMutableDict.values)
	{
		return localRuntime.Native.GenericMutableDict.values;
	}
	if ('values' in Elm.Native.GenericMutableDict)
	{
		return localRuntime.Native.GenericMutableDict.values = Elm.Native.GenericMutableDict.values;
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
      var key = item._0;
      var value = item._1;
      out[key] = value
    }
    return out;
  }

  function get(key, dict) {
    var value = dict[key.ctor];
    if (value !== undefined) {
      return Maybe.Just(value);
    } else {
		  Maybe.Nothing
    }
  }

  function unsafeNativeGet(key, dict) {
    return dict[key];
  }

  function insert(key, value, dict) {
    dict[key] = value;
    return dict;
  }

	Elm.Native.GenericMutableDict.values = {
		empty: empty,
		fromList: fromList,
		// initialize: F2(initialize),
    insert: F3(insert),
		get: F2(get),
    unsafeNativeGet: F2(unsafeNativeGet)
		// set: F3(set),
		// map: F2(map),
		// length: length,
	};

	return localRuntime.Native.GenericMutableDict.values = Elm.Native.GenericMutableDict.values;
};
