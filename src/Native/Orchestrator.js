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

  var updateGraph = function(uiModel, statePool, graph) {
    var destinationNode = graph.Destination;
    return updateNode(uiModel, statePool, graph, destinationNode);
    // return 0.0;
  }

  var updateNode = function(uiModel, statePool, graph, node) {
    var func = node._0;
    var constantBaseProps = node._1;
    var dynamicBaseProps = node._2;
    var nodeId = constantBaseProps.autoId._0;
    var nodeState = statePool[nodeId];
    var inputs =  constantBaseProps.inputs;
    var inputValues = nodeState.inputValues;

    var i = 0;
    for (var key in inputs) {
      var input = inputs[key];// this sucks for performance! we can't use dicts :/ maybe records are better if possible??
      var value;
      switch (input.ctor) {
        case "Value":
          value = input._0;
          break;
        case "AutoID":
          var node = graph[input._0];
          value = updateNode(uiModel, statePool, graph, node);
          return 0.0
          break;
      }
      inputValues[i] = value;
      i++;
    }

    switch (node.ctor) {
      case "Oscillator":
        // console.log("osicillator");
        // return 0.0

        var oscProps = node._3;


        var frequency = inputValues[0];
        var frequencyOffset = inputValues[1];
        var phaseOffset = inputValues[2];
        var prevPhase = oscProps.phase;
        var result = func(frequency)(frequencyOffset)(phaseOffset)(prevPhase); // yowza.. this currying shit is going to hurt performance!
        // console.log(result);
        var newValue = result._0;
        var newPhase = result._1;
        dynamicBaseProps.outputValue = newValue;
        oscProps.phase = newPhase;
        oscProps.outputValue = newValue;
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

  // var updateInputValues = function(uiModel, statePool, nodeState, graph, inputsDict) {
  // }

  // var getInputValue = function(uiModel, statePool, graph, input) {
  // }


	Elm.Native.Orchestrator.values = {
		updateGraph: F3(updateGraph),
	};

	return localRuntime.Native.Orchestrator.values = Elm.Native.Orchestrator.values;
};
