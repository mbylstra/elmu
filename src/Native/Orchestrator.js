Elm.Native.Orchetstrator = {};
Elm.Native.Orchetstrator.make = function(localRuntime) {

	localRuntime.Native = localRuntime.Native || {};
	localRuntime.Native.Orchetstrator = localRuntime.Native.Orchetstrator || {};
	if (localRuntime.Native.Orchetstrator.values)
	{
		return localRuntime.Native.Orchetstrator.values;
	}
	if ('values' in Elm.Native.Orchetstrator)
	{
		return localRuntime.Native.Orchetstrator.values = Elm.Native.Orchetstrator.values;
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
  // import Lib.GenericOrchetstrator as GenericOrchetstrator exposing (GenericOrchetstrator)
  // import Lib.StringKeyOrchetstrator as StringKeyOrchetstrator
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


  var updateGraph = function(uiModel, statePool, graph) {
    var destinationNode = graph.Destination;
    return updateNode(uiModel, statePool, graph, destinationNode);
  }

  var updateNode = function(uiModel, statePool, graph, node) {
    var nodeId = getNodeAutoId(node); //TODO
    var nodeState = statePool[nodeId];
    switch (node.ctor) {
      case "Oscillator":
        ? what do constructor args look like in Native?
    }
  }

  // updateNode : ui -> StatePool -> DictGraph ui -> AudioNode ui -> Float
  // updateNode uiModel statePool graph node =
  //
  //   let
  //     nodeId = getNodeAutoId node
  //     nodeState = StringKeyOrchetstrator.unsafeNativeGet nodeId statePool

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
  //           prevPhase = (GenericOrchetstrator.unsafeNativeGet "phase" oscProps)
  //           (newValue, newPhase) = -- damn, need to do sometin gabout this friggen tuple
  //             func frequency frequencyOffset phaseOffset prevPhase
  //           _ = GenericOrchetstrator.insert "outputValue" newValue dynamicBaseProps
  //           _ = GenericOrchetstrator.insert "phase" newPhase oscProps
  //           _ = StringKeyOrchetstrator.insert (getNodeAutoId node) node graph
  //         in
  //           newValue
  //
  //       Adder func constantBaseProps dynamicBaseProps ->
  //         let
  //           inputs = constantBaseProps.inputs
  //           inputValues = updateInputValues uiModel statePool nodeState graph inputs
  //           newValue = -- damn, need to do sometin gabout this friggen tuple
  //             func inputValues
  //           _ = StringKeyOrchetstrator.insert (getNodeAutoId node) node graph
  //         in
  //           newValue
  //
  //       Destination constantBaseProps dynamicBaseProps ->
  //         let
  //           inputs = constantBaseProps.inputs
  //           inputValues = updateInputValues uiModel statePool nodeState graph inputs
  //           newValue = (MutableArray.unsafeNativeGet 0 inputValues)
  //
  //           _ = GenericOrchetstrator.insert "outputValue" newValue dynamicBaseProps
  //
  //           id = getNodeAutoId node  -- < 1%
  //           graph3 = StringKeyOrchetstrator.insert id node graph   -- the dict insert adds ~ 5-10 %  -- this is so much faster now!!
  //         in
  //           newValue
  //
  //       _ -> Debug.crash("")
  //
  //
  // updateInputValues : ui -> StatePool -> GenericOrchetstrator -> DictGraph ui -> InputsDict ui -> MutableArray Float
  // updateInputValues uiModel statePool nodeState graph inputsDict =
  //   let
  //     inputValues = GenericOrchetstrator.unsafeNativeGet "inputValues" nodeState
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
  //       case StringKeyOrchetstrator.get id graph of
  //         Just node ->
  //           ReferencedNodeInput node
  //         Nothing ->
  //           Debug.crash "This shouldn't happen. Could not find a node. The graph must not have been validated first"
  //     Node node ->
  //       Debug.crash "This shouldn't happen. The graph should have been flattened"
  //     ID id ->
  //       Debug.crash "This shouldn't happen. All ID inputs should have been converted to AutoID inputs"

	Elm.Native.Orchetstrator.values = {
		updateGraph: F4(updateGraph),
	};

	return localRuntime.Native.Orchetstrator.values = Elm.Native.Orchetstrator.values;
};
