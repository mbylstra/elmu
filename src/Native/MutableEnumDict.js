Elm.Native.MutableEnumDict = {};
Elm.Native.MutableEnumDict.make = function(localRuntime) {

	localRuntime.Native = localRuntime.Native || {};
	localRuntime.Native.MutableEnumDict = localRuntime.Native.MutableEnumDict || {};
	if (localRuntime.Native.MutableEnumDict.values)
	{
		return localRuntime.Native.MutableEnumDict.values;
	}
	if ('values' in Elm.Native.MutableEnumDict)
	{
		return localRuntime.Native.MutableEnumDict.values = Elm.Native.MutableEnumDict.values;
	}

	var List = Elm.Native.List.make(localRuntime);

  function empty()
  {
    return {};
  }

  // function fromList(list)
  // {
  //
  // }
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
    console.log('key', key);
    console.log('dict', dict);
    return dict[key.ctor];
  }

	// function get(i, array)
	// {
	// 	if (i < 0 || i >= length(array))
	// 	{
	// 		throw new Error(
	// 			'Index ' + i + ' is out of range. Check the length of ' +
	// 			'your array first or use getMaybe or getWithDefault.');
	// 	}
	// 	return array[i];
	// }
  //
	// function set(i, item, array)
	// {
  //   array[i] = item;
  //   return array;
	// }
  //
	// function initialize(len, f)
	// {
  //   var array = [];
  // 	for (var i = 0; i < len; i++)
	// 	{
	// 	  array[i] = f(i);
	// 	}
  //   return array;
	// }
  //
	// // Maps a function over the elements of an array.
	// function map(f, a)
	// {
  //   return a.map(f);
	// }
  //
	// // Returns how many items are in the tree.
	// function length(array)
	// {
  //   return array.length;
	// }

	Elm.Native.MutableEnumDict.values = {
		empty: empty,
		fromList: fromList,
		// initialize: F2(initialize),
		get: F2(get),
		// set: F3(set),
		// map: F2(map),
		// length: length,
	};

	return localRuntime.Native.MutableEnumDict.values = Elm.Native.MutableEnumDict.values;
};
