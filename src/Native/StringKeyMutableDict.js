Elm.Native.StringKeyMutableDict = {};
Elm.Native.StringKeyMutableDict.make = function(localRuntime) {

	localRuntime.Native = localRuntime.Native || {};
	localRuntime.Native.StringKeyMutableDict = localRuntime.Native.StringKeyMutableDict || {};
	if (localRuntime.Native.StringKeyMutableDict.values)
	{
		return localRuntime.Native.StringKeyMutableDict.values;
	}
	if ('values' in Elm.Native.StringKeyMutableDict)
	{
		return localRuntime.Native.StringKeyMutableDict.values = Elm.Native.StringKeyMutableDict.values;
	}

	var List = Elm.Native.List.make(localRuntime);
	var Maybe = Elm.Maybe.make(localRuntime);
	var Utils = Elm.Native.Utils.make(localRuntime);
	var fromArray = Utils.list;

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
    var value = dict[key];
    if (value !== undefined) {
      return Maybe.Just(value);
    } else {
		  Maybe.Nothing
    }
  }

  function unsafeNativeGet(key, dict) {
    /* This is the fastest, but the last type safe */
    return dict[key];
  }

  function insert(key, value, dict) {
    dict[key] = value;
    return dict;
  }

  function values(dict) {
    return fromArray(
      Object.keys(dict).map(function(key) {return dict[key]})
    );
  }

	Elm.Native.StringKeyMutableDict.values = {
		empty: empty,
		fromList: fromList,
		// initialize: F2(initialize),
		get: F2(get),
		unsafeNativeGet: F2(unsafeNativeGet),
		insert: F3(insert),
    values: values,
		// set: F3(set),
		// map: F2(map),
		// length: length,
	};

	return localRuntime.Native.StringKeyMutableDict.values = Elm.Native.StringKeyMutableDict.values;
};
