module Orchestrator where

--------------------------------------------------------------------------------
-- EXTERNAL DEPENDENCIES
--------------------------------------------------------------------------------

import Dict exposing (Dict)

--------------------------------------------------------------------------------
-- INTERNAL DEPENDENCIES
--------------------------------------------------------------------------------

import Lib.MutableArray as MutableArray exposing (MutableArray)
import Lib.GenericMutableDict as GenericMutableDict exposing (GenericMutableDict)
import Lib.StringKeyMutableDict as StringKeyMutableDict
import Audio.StatePool as StatePool exposing (StatePool)
import Audio.MainTypes exposing (AudioNode(Destination, Oscillator, Adder), getNodeAutoId, DictGraph, InputsDict, Input(Value, Default, UI, AutoID, Node, ID))

--------------------------------------------------------------------------------
-- TYPE DEFINITIONS
--------------------------------------------------------------------------------

type alias ExternalState ui=
    { time : Float
    , externalInputState : ui
    }

{- the InputHelper type further groups the Input type into
  two types: NodeInput and ValueInput. This reduces concerns
  for this implemenetation code, without making the end user
  API for Input not annoylingly nested to be used as a DSL
-}
type InputHelper ui
  = ReferencedNodeInput (AudioNode ui)
  | ValueInput Float


--------------------------------------------------------------------------------
-- MAIN
--------------------------------------------------------------------------------

updateGraph : ui -> StatePool -> DictGraph ui  -> (Float, DictGraph ui)
updateGraph uiModel statePool graph  =
  let
    destinationNode = getDestinationNode graph
  in
    (updateNode uiModel statePool graph destinationNode, graph) -- a tuple is OK here beacuse it's only created once


getDestinationNode : DictGraph ui -> AudioNode ui
getDestinationNode graph =
  StringKeyMutableDict.unsafeNativeGet "Destination" graph


updateNode : ui -> StatePool -> DictGraph ui -> AudioNode ui -> Float
updateNode uiModel statePool graph node =

  let
    nodeId = getNodeAutoId node
    nodeState = StringKeyMutableDict.unsafeNativeGet nodeId statePool
  in
    case node of
      Oscillator func constantBaseProps dynamicBaseProps oscProps ->
        let
          inputs = constantBaseProps.inputs
          inputValues = updateInputValues uiModel statePool nodeState graph inputs
          frequency = (MutableArray.unsafeNativeGet 0 inputValues)
          frequencyOffset = (MutableArray.unsafeNativeGet 1 inputValues)
          phaseOffset = (MutableArray.unsafeNativeGet 2 inputValues)
          prevPhase = (GenericMutableDict.unsafeNativeGet "phase" oscProps)
          (newValue, newPhase) = -- damn, need to do sometin gabout this friggen tuple
            func frequency frequencyOffset phaseOffset prevPhase
          _ = GenericMutableDict.insert "outputValue" newValue dynamicBaseProps
          _ = GenericMutableDict.insert "phase" newPhase oscProps
          _ = StringKeyMutableDict.insert (getNodeAutoId node) node graph
        in
          newValue

      Adder func constantBaseProps dynamicBaseProps ->
        let
          inputs = constantBaseProps.inputs
          inputValues = updateInputValues uiModel statePool nodeState graph inputs
          newValue = -- damn, need to do sometin gabout this friggen tuple
            func inputValues
          _ = StringKeyMutableDict.insert (getNodeAutoId node) node graph
        in
          newValue

      Destination constantBaseProps dynamicBaseProps ->
        let
          inputs = constantBaseProps.inputs
          inputValues = updateInputValues uiModel statePool nodeState graph inputs
          newValue = (MutableArray.unsafeNativeGet 0 inputValues)

          _ = GenericMutableDict.insert "outputValue" newValue dynamicBaseProps

          id = getNodeAutoId node  -- < 1%
          graph3 = StringKeyMutableDict.insert id node graph   -- the dict insert adds ~ 5-10 %  -- this is so much faster now!!
        in
          newValue

      _ -> Debug.crash("")


updateInputValues : ui -> StatePool -> GenericMutableDict -> DictGraph ui -> InputsDict ui -> MutableArray Float
updateInputValues uiModel statePool nodeState graph inputsDict =
  let
    inputValues = GenericMutableDict.unsafeNativeGet "inputValues" nodeState
    update inputName input index =
      let
        value = getInputValue uiModel statePool graph input
        _ = MutableArray.set index value inputValues  -- WTF.. this adds 10-15% for 10 oscillators???
      in
        index + 1
    _ = Dict.foldl update 0 inputsDict   -- wecan continue using dicts for the Input's
  in
    inputValues


getInputValue : ui -> StatePool -> DictGraph ui -> Input ui -> Float
getInputValue uiModel statePool graph input =
  case getInputHelper uiModel graph input of
    ValueInput value ->
      value
    ReferencedNodeInput node ->
      updateNode uiModel statePool graph node


getInputHelper : ui -> DictGraph ui -> Input ui
          -> InputHelper ui
getInputHelper ui graph input =
  case input of
    Value value ->
      ValueInput value
    Default ->
      ValueInput 0.0
    UI func ->
      ValueInput (func ui)
    AutoID id ->
      case StringKeyMutableDict.get id graph of
        Just node ->
          ReferencedNodeInput node
        Nothing ->
          Debug.crash "This shouldn't happen. Could not find a node. The graph must not have been validated first"
    Node node ->
      Debug.crash "This shouldn't happen. The graph should have been flattened"
    ID id ->
      Debug.crash "This shouldn't happen. All ID inputs should have been converted to AutoID inputs"
