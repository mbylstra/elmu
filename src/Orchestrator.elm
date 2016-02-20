module Orchestrator where

--------------------------------------------------------------------------------
-- EXTERNAL DEPENDENCIES
--------------------------------------------------------------------------------

-- import ElmTest exposing (..)
-- import Lib.MutableDict as MutableDict
import Lib.Misc exposing (unsafeDictGet)
import Dict exposing (Dict)
--------------------------------------------------------------------------------
-- INTERNAL DEPENDENCIES
--------------------------------------------------------------------------------

import Audio.MainTypes exposing (..)



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

updateGraph : ui -> DictGraph ui -> (Float, DictGraph ui)
updateGraph uiModel graph =
  let
    destinationNode = getDestinationNode graph
  in
    updateNode uiModel graph destinationNode

getDestinationNode : DictGraph ui -> AudioNode ui
getDestinationNode graph =
  unsafeDictGet 0 graph


updateNode : ui -> DictGraph ui -> AudioNode ui
  -> (Float, DictGraph ui)
updateNode uiModel graph node =
  case node of
    Oscillator (baseProps, oscProps) ->
      let
        inputs = baseProps.inputs
        (inputValues, graph2) = getInputValues uiModel graph inputs
        (newValue, newPhase) =
          oscProps.func
            (unsafeDictGet "frequency" inputValues)
            (unsafeDictGet "frequencyOffset" inputValues)
            (unsafeDictGet "phaseOffset" inputValues)
            oscProps.phase
        newNode = Oscillator
          ( { baseProps | outputValue = newValue }
          , { oscProps | phase = newPhase }
          )
        graph3 = Dict.insert (getNodeAutoId node) newNode graph2
      in
        (newValue, graph)
    _ -> Debug.crash("")


getInputValues : ui -> DictGraph ui -> InputsDict ui
                 -> (Dict String Float, DictGraph ui)
getInputValues uiModel graph inputs =
  let
    accInitial = (Dict.empty, graph)

    update inputName input acc =
      let
        (inputValues, graph2) = acc
        (value, graph3) = getInputValue uiModel graph2 input
        inputValues2 = Dict.insert inputName value inputValues
      in
        (inputValues2, graph3)
  in
    Dict.foldl update accInitial inputs


getInputValue : ui -> DictGraph ui -> Input ui
                -> (Float, DictGraph ui)
getInputValue uiModel graph input =
  case getInputHelper uiModel graph input of
    ValueInput value ->
      (value, graph)
    ReferencedNodeInput node ->
      updateNode uiModel graph node


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
      case Dict.get id graph of
        Just node ->
          ReferencedNodeInput node
        Nothing ->
          Debug.crash "This shouldn't happen. Could not find a node. The graph must not have been validated first"
    Node node ->
      Debug.crash "This shouldn't happen. The graph should have been flattened"
    ID id ->
      Debug.crash "This shouldn't happen. All ID inputs should have been converted to AutoID inputs"
