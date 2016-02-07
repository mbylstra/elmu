module Orchestrator where

--------------------------------------------------------------------------------
-- EXTERNAL DEPENDENCIES
--------------------------------------------------------------------------------

-- import ElmTest exposing (..)
import Lib.MutableDict as MutableDict
--------------------------------------------------------------------------------
-- INTERNAL DEPENDENCIES
--------------------------------------------------------------------------------

import Audio.MainTypes exposing (..)



--------------------------------------------------------------------------------
-- TYPE DEFINITIONS
--------------------------------------------------------------------------------

type alias ExternalState uiModel=
    { time : Float
    , externalInputState : uiModel
    }

{- the InputHelper type further groups the Input type into
  two types: NodeInput and ValueInput. This reduces concerns
  for this implemenetation code, without making the end user
  API for Input not annoylingly nested to be used as a DSL
-}
type InputHelper idType uiModel
  = InlineNodeInput (AudioNode idType uiModel)
  | ReferencedNodeInput idType (AudioNode idType uiModel)
  | ValueInput Float


--------------------------------------------------------------------------------
-- MAIN
--------------------------------------------------------------------------------

getNodeId : (AudioNode idType guiModel) -> Maybe idType
getNodeId node =
  case node of
    Oscillator props ->
      props.id
    FeedforwardProcessor props ->
      props.id
    Add props ->
      props.id
    Gain props ->
      props.id
    -- Destination props ->
    --   props.id
    Multiply node' ->
      node'.id
    -- we must fill this out for all node types, unless we use extensible records!


updateNode : uiModel -> DictGraph idType uiModel -> Maybe idType -> AudioNode idType uiModel
  -> (Float, DictGraph idType uiModel)
updateNode uiModel graph1 maybeNodeId node =
  case node of
    Oscillator props ->
      let
        inputs = props.inputs
        (frequencyValue, graph2) = getInputValue uiModel graph1 props.inputs.frequency
          -- frequency might be inline, which is challenging, as we actually need to
          -- updateing props.inputs.frequency as well as the graph
            -- do we?? I'm confused :( if getInputValue returns a graph, we're good right?
        (frequencyOffsetValue, graph3) = getInputValue uiModel graph2 props.inputs.frequencyOffset
        (phaseOffsetValue, graph4) = getInputValue uiModel graph3 props.inputs.phaseOffset
        (newValue, newPhase) = props.func frequencyValue frequencyOffsetValue phaseOffsetValue props.state.phase
        newState = {outputValue = newValue, phase = newPhase}
        newNode = Oscillator { props | state = newState }
        graph5 =
          case maybeNodeId of
            Just nodeId ->
              MutableDict.insert nodeId node graph4
            Nothing ->
              graph4
      in
        (newValue, graph5)
    _ -> Debug.crash("todo")


getInputValue : uiModel -> DictGraph idType uiModel -> Input idType uiModel
                -> (Float, DictGraph idType uiModel)
getInputValue uiModel graph input =
  case getInputHelper uiModel graph input of
    ValueInput value ->
      (value, graph)
    InlineNodeInput node ->
      updateNode uiModel graph Nothing node
    ReferencedNodeInput nodeId node ->
      updateNode uiModel graph (Just nodeId) node



{- this should only ever be run immediately after validateGraph has been run! -}
-- unsafeUpdateGraph : uiModel -> DictGraph idType uiMOdel -> Destination idTypeModel
--   -> (DictGraph idType uiMOdel, Destination idTypeModel)
-- unsafeUpdateGraph uiModel graph destination =


getInputHelper : uiModel -> DictGraph idType uiModel -> Input idType uiModel
          -> InputHelper idType uiModel
getInputHelper uiModel graph input =
  case input of
    Value value ->
      ValueInput value
    Default ->
      ValueInput 0.0
    UI func ->
      ValueInput (func uiModel)
    Node node ->
      InlineNodeInput node
    ID nodeId ->
      ReferencedNodeInput nodeId (MutableDict.unsafeGet nodeId graph) -- assumes graph has been validated
