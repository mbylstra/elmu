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
  = InlineNodeInput (AudioNode ui)
  | ReferencedNodeInput (AudioNode ui)
  | ValueInput Float


--------------------------------------------------------------------------------
-- MAIN
--------------------------------------------------------------------------------

-- getNodeId : (AudioNode gui) -> Maybe idType
-- getNodeId node =
--   case node of
--     Oscillator props ->
--       props.id
--     -- FeedforwardProcessor props ->
--     --   props.id
--     -- Add props ->
--     --   props.id
--     -- Gain props ->
--     --   props.id
--     -- -- Destination props ->
--     -- --   props.id
--     -- Multiply node' ->
--     --   node'.id
--     -- we must fill this out for all node types, unless we use extensible records!


-- updateNode : ui -> DictGraph ui -> Maybe -> AudioNode ui
--   -> (Float, DictGraph ui)
-- updateNode ui graph maybeNodeId node =
--   case node of
--     Oscillator props ->
--       let
--         inputs = props.inputs
--
--         (newInputs, graph2) = getInputValues props.inputs graph
--
--         newNode = Oscillator { props | inputs =  newInputs}
--
--         graph3 = Dict.update (getNodeId newNode) graph2
--
--           -- frequency might be inline, which is challenging, as we actually need to
--           -- updateing props.inputs.frequency as well as the graph
--             -- do we?? I'm confused :( if getInputValue returns a graph, we're good right?
--           -- I doubt this is working. Really we need to update a tree, rather than a list,
--           -- and updating a tree is MUCH harder!! fuckk.
--
--           -- the problem is that props.inputs.frequency is just a copy of that value from the DictGraph, and
--           -- although we get the new value, in the graph returned, the value in the tree path is never
--           -- actually updated! On man, trees really suck with immutable data structures!
--           -- Must we introduct mutable tree?? LOL. I guess it makes a bit of sense
--           -- I have a bad feeling this mutable stuff is going to introduce some really weird bugs!!
--
--           -- maybe the Lens library is useful here?
--
--
--         -- (frequencyOffsetValue, graph3) = getInputValue ui graph2 props.inputs.frequencyOffset
--         -- (phaseOffsetValue, graph4) = getInputValue ui graph3 props.inputs.phaseOffset
--         -- (newValue, newPhase) = props.func frequencyValue frequencyOffsetValue phaseOffsetValue props.state.phase
--         -- newState = {outputValue = newValue, phase = newPhase}
--         -- newNode = Oscillator { props | state = newState }
--         -- graph5 =
--         --   case maybeNodeId of
--         --     Just nodeId ->
--         --       MutableDict.insert nodeId node graph4
--         --     Nothing ->
--         --       graph4
--       in
--         (newValue, graph5)
--     _ -> Debug.crash("todo")

-- updateInput : ??
-- updateInput input =
--   case getInputValue ui graph input of
--   -- (frequencyValue, graph2) = getInputValue ui graph1 props.inputs.frequency
--
--   (graph, ?)

type alias InputValuesDict = Dict String Float

getInputValues : ui -> DictGraph ui -> InputsDict ui
                 -> (InputValuesDict, DictGraph ui)
getInputValues uiModel graph inputs =
  let
    -- accInitial : (InputValuesDict, DictGraph ui)
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
getInputValue ui graph input =
  case getInputHelper ui graph input of
    ValueInput value ->
      (value, graph)
    ReferencedNodeInput node ->
      updateNode ui graph (Just nodeId) node



{- this should only ever be run immediately after validateGraph has been run! -}
-- unsafeUpdateGraph : ui -> DictGraph uiMOdel -> Destination idTypeModel
--   -> (DictGraph uiMOdel, Destination idTypeModel)
-- unsafeUpdateGraph ui graph destination =


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
    -- ID nodeId ->
      ReferencedNodeInput (unsafeDictGet id graph) -- assumes graph has been validated
    ID id ->
      Debug.crash "I'm not sure what to do here! Ideally we'd have converted all inputs first, so we don't have to handle this"
