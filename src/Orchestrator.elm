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
    destinationNode =
      case getDestinationNode graph of
        Just node ->
          node
        Nothing ->
          Debug.crash (
            "the DictGraph does not have a destination node. This is the audioGraph: "
            ++ toString graph
          )
  in
    updateNode uiModel graph destinationNode

getDestinationNode : DictGraph ui -> Maybe (AudioNode ui)
getDestinationNode graph =
  graph
  |> Dict.values
  |> List.filter
            ( \node ->
                case node of
                  Destination _-> True
                  _ -> False
            )
  |> List.head

updateNode : ui -> DictGraph ui -> AudioNode ui
  -> (Float, DictGraph ui)
updateNode uiModel graph node =
  case node of
    Oscillator (baseProps, oscProps) ->
      let
        -- _ = Debug.log "old phase" oscProps.phase
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
        -- _ = Debug.log "new phase" newPhase
        -- _ = Debug.log "new value" newValue
      in
        (newValue, graph3)

    Destination (baseProps, specificProps) ->
      let
        inputs = baseProps.inputs
        (inputValues, graph2) = getInputValues uiModel graph inputs
        newValue = (unsafeDictGet "A" inputValues)
        newNode = Destination
          ( { baseProps | outputValue = newValue }
          , specificProps
          )
        graph3 = Dict.insert (getNodeAutoId node) newNode graph2
      in
        (newValue, graph3)

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
