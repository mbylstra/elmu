Elm.Native.MutableArray = {};
Elm.Native.MutableArray.make = function(localRuntime) {

	localRuntime.Native = localRuntime.Native || {};
	localRuntime.Native.MutableArray = localRuntime.Native.MutableArray || {};
	if (localRuntime.Native.MutableArray.values)
	{
		return localRuntime.Native.MutableArray.values;
	}
	if ('values' in Elm.Native.MutableArray)
	{
		return localRuntime.Native.MutableArray.values = Elm.Native.MutableArray.values;
	}

	function get(i, array)
	{
		if (i < 0 || i >= length(array))
		{
			throw new Error(
				'Index ' + i + ' is out of range. Check the length of ' +
				'your array first or use getMaybe or getWithDefault.');
		}
		return array[i];
	}

  function unsafeNativeGet(i, array) {
    return array[i];
  }

	function set(i, item, array)
	{
    array[i] = item;
    return array;
	}

  function push(item, array)
  {
    array.push(item);
    return array;
  }

	function initialize(len, f)
	{
    var array = [];
  	for (var i = 0; i < len; i++)
		{
		  array[i] = f(i);
		}
    return array;
	}

  function empty()
  {
    return [];
  }

	// Maps a function over the elements of an array.
	function map(f, a)
	{
    return a.map(f);
	}

	// Returns how many items are in the tree.
	function length(array)
	{
    return array.length;
	}

	Elm.Native.MutableArray.values = {
    empty: empty,
		initialize: F2(initialize),
		get: F2(get),
		unsafeNativeGet: F2(unsafeNativeGet),
		set: F3(set),
		map: F2(map),
		push: F2(push),
		length: length,
	};

	return localRuntime.Native.MutableArray.values = Elm.Native.MutableArray.values;
};
