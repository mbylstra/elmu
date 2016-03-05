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


  // module Orchestrator where
  //
  // --------------------------------------------------------------------------------
  // -- EXTERNAL DEPENDENCIES
  // --------------------------------------------------------------------------------
  //
  // import Dict exposing (Dict)
  //
  // --------------------------------------------------------------------------------
  // -- INTERNAL DEPENDENCIES
  // --------------------------------------------------------------------------------
  //
  // import Lib.MutableArray as MutableArray exposing (MutableArray)
  // import Lib.GenericOrchestrator as GenericOrchestrator exposing (GenericOrchestrator)
  // import Lib.StringKeyOrchestrator as StringKeyOrchestrator
  // import Audio.StatePool as StatePool exposing (StatePool)
  // import Audio.MainTypes exposing (AudioNode(Destination, Oscillator, Adder), getNodeAutoId, DictGraph, InputsDict, Input(Value, Default, UI, AutoID, Node, ID))
  //
  // --------------------------------------------------------------------------------
  // -- TYPE DEFINITIONS
  // --------------------------------------------------------------------------------
  //
  // type alias ExternalState ui=
  //     { time : Float
  //     , externalInputState : ui
  //     }
  //
  // {- the InputHelper type further groups the Input type into
  //   two types: NodeInput and ValueInput. This reduces concerns
  //   for this implemenetation code, without making the end user
  //   API for Input not annoylingly nested to be used as a DSL
  // -}
  // type InputHelper ui
  //   = ReferencedNodeInput (AudioNode ui)
  //   | ValueInput Float
  //
  //
  // --------------------------------------------------------------------------------
  // -- MAIN
  // --------------------------------------------------------------------------------
  //
  // updateGraph : ui -> StatePool -> DictGraph ui  -> (Float, DictGraph ui)
  // updateGraph uiModel statePool graph  =
  //   let
  //     destinationNode = getDestinationNode graph
  //   in
  //     (updateNode uiModel statePool graph destinationNode, graph) -- a tuple is OK here beacuse it's only created once
  //

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
  // getInputValue : ui -> StatePool -> DictGraph ui -> Input ui -> Float
  // getInputValue uiModel statePool graph input =
  //   case getInputHelper uiModel graph input of
  //     ValueInput value ->
  //       value
  //     ReferencedNodeInput node ->
  //       updateNode uiModel statePool graph node
  //
  //
  // getInputHelper : ui -> DictGraph ui -> Input ui
  //           -> InputHelper ui
  // getInputHelper ui graph input =
  //   case input of
  //     Value value ->
  //       ValueInput value
  //     Default ->
  //       ValueInput 0.0
  //     UI func ->
  //       ValueInput (func ui)
  //     AutoID id ->
  //       case StringKeyOrchestrator.get id graph of
  //         Just node ->
  //           ReferencedNodeInput node
  //         Nothing ->
  //           Debug.crash "This shouldn't happen. Could not find a node. The graph must not have been validated first"
  //     Node node ->
  //       Debug.crash "This shouldn't happen. The graph should have been flattened"
  //     ID id ->
  //       Debug.crash "This shouldn't happen. All ID inputs should have been converted to AutoID inputs"

  var updateInputValues = function(uiModel, statePool, nodeState, graph, inputsDict) {
    var Dict = Elm.Dict.make(localRuntime);
    var inputValues = nodeState.inputValues;
    Object.keys(inputsDict).map(function(key, i) { // hmm, elm dicts are a major pain! (and slow as F)
      // var input = inputsDict[key]; // shit, have to use elm for this
      var input = Dict.get(key)(inputsDict)._0;// this sucks for performance! we can't use dicts :/ maybe records are better if possible??
      var value = getInputValue(uiModel, statePool, graph, input);
      inputValues[i] = value;
    });
    // inputsDict is actually just a JS object

  }


  var updateGraph = function(uiModel, statePool, graph) {
    console.log('native updateGraph');
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
        console.log("osicillator");

        var oscProps = node._3;

        var frequency = inputValues[0];
        var frequencyOffset = inputValues[1];
        var phaseOffset = inputValues[2];
        var prevPhase = oscProps.phase;
        var result = func(frequency, frequencyOffset, phaseOffset, prevPhase);
        var newValue = result._0;
        var newPhase = result._1;
        dynamicBaseProps.outputValue = newValue;
        oscProps.outputValue = newValue;
        return newValue;

      case "Adder":
        newValue = func(inputValues);
        return newValue;
  //       Adder func constantBaseProps dynamicBaseProps ->
  //         let
  //           inputs = constantBaseProps.inputs
  //           inputValues = updateInputValues uiModel statePool nodeState graph inputs
  //           newValue = -- damn, need to do sometin gabout this friggen tuple
  //             func inputValues
  //           _ = StringKeyOrchestrator.insert (getNodeAutoId node) node graph
  //         in
  //           newValue

      case "Destination":
        console.log("Dest");
        var newValue = inputValues[0];
        return newValue;

  //       Destination constantBaseProps dynamicBaseProps ->
  //         let
  //           inputs = constantBaseProps.inputs
  //           inputValues = updateInputValues uiModel statePool nodeState graph inputs
  //           newValue = (MutableArray.unsafeNativeGet 0 inputValues)
  //
  //           _ = GenericOrchestrator.insert "outputValue" newValue dynamicBaseProps
  //
  //           id = getNodeAutoId node  -- < 1%
  //           graph3 = StringKeyOrchestrator.insert id node graph   -- the dict insert adds ~ 5-10 %  -- this is so much faster now!!
  //         in
  //           newValue
  //
  //       _ -> Debug.crash("")

    }
  }

  // updateNode : ui -> StatePool -> DictGraph ui -> AudioNode ui -> Float
  // updateNode uiModel statePool graph node =
  //
  //   let
  //     nodeId = getNodeAutoId node
  //     nodeState = StringKeyOrchestrator.unsafeNativeGet nodeId statePool

  //   in
  //     case node of
  //       Oscillator func constantBaseProps dynamicBaseProps oscProps ->
  //         let
  //
  //           -- I reckon this can be automated (particularly in JS)
  //           -- You just need a list of props names, and the rest can be done
  //           -- Automatically. This doesn't even need to be defined in JS.
  //
  //           inputs = constantBaseProps.inputs
  //           inputValues = updateInputValues uiModel statePool nodeState graph inputs
  //           frequency = (MutableArray.unsafeNativeGet 0 inputValues)
  //           frequencyOffset = (MutableArray.unsafeNativeGet 1 inputValues)
  //           phaseOffset = (MutableArray.unsafeNativeGet 2 inputValues)
  //           prevPhase = (GenericOrchestrator.unsafeNativeGet "phase" oscProps)
  //           (newValue, newPhase) = -- damn, need to do sometin gabout this friggen tuple
  //             func frequency frequencyOffset phaseOffset prevPhase
  //           _ = GenericOrchestrator.insert "outputValue" newValue dynamicBaseProps
  //           _ = GenericOrchestrator.insert "phase" newPhase oscProps
  //           _ = StringKeyOrchestrator.insert (getNodeAutoId node) node graph
  //         in
  //           newValue
  //
  //       Adder func constantBaseProps dynamicBaseProps ->
  //         let
  //           inputs = constantBaseProps.inputs
  //           inputValues = updateInputValues uiModel statePool nodeState graph inputs
  //           newValue = -- damn, need to do sometin gabout this friggen tuple
  //             func inputValues
  //           _ = StringKeyOrchestrator.insert (getNodeAutoId node) node graph
  //         in
  //           newValue
  //
  //       Destination constantBaseProps dynamicBaseProps ->
  //         let
  //           inputs = constantBaseProps.inputs
  //           inputValues = updateInputValues uiModel statePool nodeState graph inputs
  //           newValue = (MutableArray.unsafeNativeGet 0 inputValues)
  //
  //           _ = GenericOrchestrator.insert "outputValue" newValue dynamicBaseProps
  //
  //           id = getNodeAutoId node  -- < 1%
  //           graph3 = StringKeyOrchestrator.insert id node graph   -- the dict insert adds ~ 5-10 %  -- this is so much faster now!!
  //         in
  //           newValue
  //
  //       _ -> Debug.crash("")
  //
  //
  // updateInputValues : ui -> StatePool -> GenericOrchestrator -> DictGraph ui -> InputsDict ui -> MutableArray Float
  // updateInputValues uiModel statePool nodeState graph inputsDict =
  //   let
  //     inputValues = GenericOrchestrator.unsafeNativeGet "inputValues" nodeState
  //     update inputName input index =
  //       let
  //         value = getInputValue uiModel statePool graph input
  //         _ = MutableArray.set index value inputValues  -- WTF.. this adds 10-15% for 10 oscillators???
  //       in
  //         index + 1
  //     _ = Dict.foldl update 0 inputsDict   -- wecan continue using dicts for the Input's
  //   in
  //     inputValues
  //
  //
  // getInputValue : ui -> StatePool -> DictGraph ui -> Input ui -> Float
  // getInputValue uiModel statePool graph input =
  //   case getInputHelper uiModel graph input of
  //     ValueInput value ->
  //       value
  //     ReferencedNodeInput node ->
  //       updateNode uiModel statePool graph node
  //
  //
  // getInputHelper : ui -> DictGraph ui -> Input ui
  //           -> InputHelper ui
  // getInputHelper ui graph input =
  //   case input of
  //     Value value ->
  //       ValueInput value
  //     Default ->
  //       ValueInput 0.0
  //     UI func ->
  //       ValueInput (func ui)
  //     AutoID id ->
  //       case StringKeyOrchestrator.get id graph of
  //         Just node ->
  //           ReferencedNodeInput node
  //         Nothing ->
  //           Debug.crash "This shouldn't happen. Could not find a node. The graph must not have been validated first"
  //     Node node ->
  //       Debug.crash "This shouldn't happen. The graph should have been flattened"
  //     ID id ->
  //       Debug.crash "This shouldn't happen. All ID inputs should have been converted to AutoID inputs"

	Elm.Native.Orchestrator.values = {
		updateGraph: F3(updateGraph),
	};

	return localRuntime.Native.Orchestrator.values = Elm.Native.Orchestrator.values;
};
