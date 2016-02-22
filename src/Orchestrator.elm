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

-- What is so frickin slow???

-- candidates:
--  - pointless destination lookup
--  - use of immutable records
--  - having to look up input values from a dictionary (can we use a tuple instead??)
--  -   this can work, but the function has to accept a tuple as an argument, but that
--  -   sounds ok.
--  - all the general crap that has to be done (function calls are slow?)
--  - currying turns a function with 3 args into three functino calls! How can we avoid this??
--  - the immutable dict insert that happens for every input
--  - the two record updates that happend for every node


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
      -- (0.0, graph)

    Destination (baseProps, specificProps) ->
      let
        -- inputs = baseProps.inputs
        graph2 = graph
        -- (inputValues, graph2) = getInputValues uiModel graph inputs
        -- newValue = (unsafeDictGet "A" inputValues)
        newValue = 0.0
        -- newNode = Destination
        --   -- ( { baseProps | outputValue = newValue }   -- and it's specifically the record update that does it (I think) ~ 5 - 10 %
        --   ( baseProps
        --   , specificProps
        --   )   -- this adds ~ 5 - 10 %
        -- creating a new node and a new tuple doesn't seem to add an appreciable amount
        -- newNode = node
        -- id = getNodeAutoId newNode  -- < 1%
        -- graph3 = Dict.insert id newNode graph2   -- the dict insert adds ~ 5-10 %
        graph3 = graph2
      in
        (newValue, graph3)
      -- (0.0, graph)

      -- NOTE: just doing destination (ignoring inputs) seems to add 15% to cpu!
      -- why?
      --  - the Dict.insert
      --  - updating the tuple (?)
      --  -

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
