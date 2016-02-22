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


  var List = Elm.Native.List.make(localRuntime);

  function empty()
	{
    return [];
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

  function unsafeNativeGet(i, array)
 	{
		return array[i];
	}

	function set(i, item, array)
	{
    array[i] = item;
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

  function fromList(list)
	{
    return List.toArray(list);
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

  function push(item, a)
  {
    a.push(item);
    return a;
  }

	Elm.Native.MutableArray.values = {
    empty : empty,
		initialize: F2(initialize),
		unsafeNativeGet: F2(get),
		get: F2(get),
		set: F3(set),
		map: F2(map),
		length: length,
		push: F2(push),
	};

	return localRuntime.Native.MutableArray.values = Elm.Native.MutableArray.values;
};
