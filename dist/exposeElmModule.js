function exposeElmModule(module) {

		// function init(display, container, module, args, moduleToReplace)


		var Display = {
			FULLSCREEN: 0,
			COMPONENT: 1,
			NONE: 2
		};

    var display = Display.NONE
    var container = {}
    var args = {}

    // Elm.worker = function(module, args)
		// {
		// 	return init(Display.NONE, {}, module, args || {});
		// };

		// defining state needed for an instance of the Elm RTS
		var inputs = [];



		/* OFFSET
		 * Elm's time traveling debugger lets you pause time. This means
		 * "now" may be shifted a bit into the past. By wrapping Date.now()
		 * we can manage this.
		 */
		var timer = {
			programStart: Date.now(),
			now: function()
			{
				return Date.now();
			}
		};

		var updateInProgress = false;
		function notify(id, v)
		{
			if (updateInProgress)
			{
				throw new Error(
					'The notify function has been called synchronously!\n' +
					'This can lead to frames being dropped.\n' +
					'Definitely report this to <https://github.com/elm-lang/Elm/issues>\n');
			}
			updateInProgress = true;
			var timestep = timer.now();
			for (var i = inputs.length; i--; )
			{
				inputs[i].notify(timestep, id, v);
			}
			updateInProgress = false;
		}
		function setTimeout(func, delay)
		{
			return window.setTimeout(func, delay);
		}

		var listeners = [];
		function addListener(relevantInputs, domNode, eventName, func)
		{
      // NOTE: uncommenting this out seems to work! Dodgy as all hell though.
			// domNode.addEventListener(eventName, func);
			// var listener = {
			// 	relevantInputs: relevantInputs,
			// 	domNode: domNode,
			// 	eventName: eventName,
			// 	func: func
			// };
			// listeners.push(listener);
		}

		var argsTracker = {};
		for (var name in args)
		{
			argsTracker[name] = {
				value: args[name],
				used: false
			};
		}

		// create the actual RTS. Any impure modules will attach themselves to this
		// object. This permits many Elm programs to be embedded per document.
		var elm = {
			notify: notify,
			setTimeout: setTimeout,
			node: container,
			addListener: addListener,
			inputs: inputs,
			timer: timer,
			argsTracker: argsTracker,
			ports: {},

			isFullscreen: function() { return display === Display.FULLSCREEN; },
			isEmbed: function() { return display === Display.COMPONENT; },
			isWorker: function() { return display === Display.NONE; }
		};
    return module.make(elm);


}
