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



updateNode : ui -> DictGraph ui -> AudioNode ui
  -> (Float, DictGraph ui)
updateNode uiModel graph node =
  case node of
    Oscillator props ->
      let
        inputs = props.inputs
        (inputValues, graph2) = getInputValues uiModel graph inputs
        (newValue, newPhase) =
          props.func
            (unsafeDictGet "frequency" inputValues)
            (unsafeDictGet "frequencyOffset" inputValues)
            (unsafeDictGet "phaseOffset" inputValues)
            props.phase
        newNode = Oscillator
          { props |
            phase = newPhase
          , outputValue = newValue
          }
        graph3 = Dict.insert (getNodeAutoId node) newNode graph2 -- TODO: get id
      in
        (newValue, graph)
    _ -> Debug.crash("")


getNodeAutoId : AudioNode ui -> Int
getNodeAutoId node =
  let
    handle props =
      Maybe.withDefault -1 props.autoId  -- this should only be called on a node that has been flattened and given an AutoID
  in
    case node of
      Dummy props ->
        handle props
      Oscillator props ->
        handle props


getInputValues : ui -> DictGraph ui -> InputsDict ui
                 -> (Dict String Float, DictGraph ui)
getInputValues uiModel graph inputs =
  let
    accInitial = (Dict.empty, graph)

    update inputName input acc =
      let
        (inputValues, graph2) = acc
        -- (value, graph3) = getInputValue ui graph2 input
        (value, graph3) = (0.0, graph2)
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
    Node node ->
      Debug.crash "The graph should have been flattened"
    AutoID id ->
      ReferencedNodeInput (unsafeDictGet id graph) -- assumes graph has been validated
    ID id ->
      Debug.crash "I'm not sure what to do here! Ideally we'd have converted all inputs first, so we don't have to handle this"
