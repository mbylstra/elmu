Elm.Native.Orchestrator = {};
Elm.Native.Orchestrator.make = function(localRuntime) {

	localRuntime.Native = localRuntime.Native || {};
	localRuntime.Native.Orchestrator = localRuntime.Native.Orchestrator || {};
	if (localRuntime.Native.Orchestrator.values)
	{
		return localRuntime.Native.Orchestrator.values;
	}
	if ('values' in Elm.Native.Orchestrator)
	{
		return localRuntime.Native.Orchestrator.values = Elm.Native.Orchestrator.values;
	}

	var List = Elm.Native.List.make(localRuntime);
	var Maybe = Elm.Maybe.make(localRuntime);


  var getInputValue = function(uiModel, statePool, graph, input) {
    switch (input.ctor) {
      case "Value":
        return input._0;
      case "AutoID":
      // case "UI": ??
        var node = graph[input._0];
        return updateNode(uiModel, statePool, graph, node);
    }
  }

  var updateInputValues = function(uiModel, statePool, nodeState, graph, inputsDict) {
    var inputValues = nodeState.inputValues;
    Object.keys(inputsDict).map(function(key, i) { // hmm, elm dicts are a major pain! (and slow as F). Make it a
      // var input = inputsDict[key]; // shit, have to use elm for this
      var input = inputsDict[key];// this sucks for performance! we can't use dicts :/ maybe records are better if possible??
      var value = getInputValue(uiModel, statePool, graph, input);
      inputValues[i] = value;
    });
    // inputsDict is actually just a JS object
  }

  var updateGraph = function(uiModel, statePool, graph) {
    // console.log('native updateGraph');
    var destinationNode = graph.Destination;
    return updateNode(uiModel, statePool, graph, destinationNode);
  }

  var updateNode = function(uiModel, statePool, graph, node) {

    var func = node._0;
    var constantBaseProps = node._1;
    var dynamicBaseProps = node._2;
    var nodeId = constantBaseProps.autoId._0;
    var nodeState = statePool[nodeId];
    var inputs =  constantBaseProps.inputs;
    var inputValues = nodeState.inputValues;

    updateInputValues(uiModel, statePool, nodeState, graph, inputs);

    switch (node.ctor) {
      case "Oscillator":
        // console.log("osicillator");

        var oscProps = node._3;

        var frequency = inputValues[0];
        var frequencyOffset = inputValues[1];
        var phaseOffset = inputValues[2];
        var prevPhase = oscProps.phase;
        // var result = func(frequency)(frequencyOffset)(phaseOffset)(prevPhase); // yowza.. this currying shit is going to hurt performance!
        var result = 0;
// func(frequency)(frequencyOffset)(phaseOffset)(prevPhase); // yowza.. this currying shit is going to hurt performance!
        // var newValue = result._0;
        // var newPhase = result._1;
        var newValue = 0.0;
        var newPhase = 0.0;
        dynamicBaseProps.outputValue = newValue;
        oscProps.phase = newPhase;
        oscProps.outputValue = newValue;

        // what Happened to updating the phase???

        return newValue;

      case "Adder":
        newValue = func(inputValues);
        return newValue;

      case "Destination":
        // console.log("Dest");
        var newValue = inputValues[0];
        return newValue;

    }
  }


	Elm.Native.Orchestrator.values = {
		updateGraph: F3(updateGraph),
	};

	return localRuntime.Native.Orchestrator.values = Elm.Native.Orchestrator.values;
};
