module Orchestrator where

--------------------------------------------------------------------------------
-- EXTERNAL DEPENDENCIES
--------------------------------------------------------------------------------

-- import ElmTest exposing (..)
-- import Lib.MutableDict as MutableDict
import Lib.MutableArray as MutableArray
-- import Lib.Misc exposing (unsafeDictGet)
-- import Dict exposing (Dict)

import Lib.StringKeyMutableDict as StringKeyMutableDict
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
  updateNode uiModel graph (getDestinationNode graph)
  -- (0.0, graph)  -- 3% when updateGraph not called

getDestinationNode : DictGraph ui -> AudioNode ui
getDestinationNode graph =
  -- 3-6% when js object is used to look up destination
  StringKeyMutableDict.unsafeNativeGet "Destination" graph

updateNode : ui -> DictGraph ui -> AudioNode ui
  -> (Float, DictGraph ui)
updateNode uiModel graph node =
  case node of
    Oscillator (baseProps, oscProps) ->
      let
        -- _ = Debug.log "old phase" oscProps.phase
        inputs = baseProps.inputs
        _ = Debug.log "inputs" inputs
        (inputValues, graph2) = getInputValues uiModel graph inputs  -- this adds like 80%!!! Why???
        -- graph2 = graph

        -- This function seems to add 10%. But that's perhaps mostly the the dict gets?
        -- (newValue, newPhase) =
        --   oscProps.func
        --     (unsafeDictGet "frequency" inputValues)
        --     (unsafeDictGet "frequencyOffset" inputValues)
        --     (unsafeDictGet "phaseOffset" inputValues)
        --     oscProps.phase
        newValue = 0.0
        -- newPhase = 0.0

        -- newNode = Oscillator
        --   ( { baseProps | outputValue = newValue }
        --   , { oscProps | phase = newPhase }
        --   )
        newNode = node
        graph3 = StringKeyMutableDict.insert (getNodeAutoId node) newNode graph2
        -- _ = Debug.log "new phase" newPhase
        -- _ = Debug.log "new value" newValue
      in
        (newValue, graph3)
      -- (0.0, graph)

    Destination (baseProps, specificProps) ->
      let
        inputs = baseProps.inputs
        -- graph2 = graph
        (inputValues, graph2) = getInputValues uiModel graph inputs
        newValue = MutableArray.unsafeNativeGet 0 inputValues
        newNode = Destination
          ( { baseProps | outputValue = newValue }   -- and it's specifically the record update that does it (I think) ~ 5 - 10 %
          -- ( baseProps
          , specificProps
          )   -- this adds ~ 5 - 10 %
        -- creating a new node and a new tuple doesn't seem to add an appreciable amount
        -- newNode = node
        id = getNodeAutoId newNode  -- < 1%
        graph3 = StringKeyMutableDict.insert id newNode graph2   -- the dict insert adds ~ 5-10 %  -- this is so much faster now!!
        -- graph3 = graph2
      in
        (newValue, graph3)
      -- (0.0, graph)

      -- NOTE: just doing destination (ignoring inputs) seems to add 15% to cpu!
      -- why?
      --  - the Dict.insert
      --  - updating the tuple (?)
      --  -

    _ -> Debug.crash("")


-- getInputValues : ui -> DictGraph ui -> InputsList ui
--                  -> (Dict String Float, DictGraph ui)
-- getInputValues uiModel graph inputs =
--   let
--     accInitial = (inputs, graph)
--
--     update inputName input acc =
--       let
--         (inputValues, graph2) = acc
--         (value, graph3) = getInputValue uiModel graph2 input
--         inputValues2 = StringKeyMutableDict.insert inputName value inputValues   -- this is probably the big killer. First, lets change InputsList to StringKeyMutableDict
--       in
--         (inputValues2, graph3)
--   in
--     Dict.foldl update accInitial inputs   -- hmm, we need to implement foldl on a dict... This will be fun :/. Hang on, why aren't we using Map???? Maybe it's
--     -- even faster than a js object! And it might have a fold function.



getInputValues : ui -> DictGraph ui -> InputsList ui
                 -> (InputValuesArray, DictGraph ui)
getInputValues uiModel graph inputs =

  let
    _ = Debug.log "inputs" inputs
    inputValues = MutableArray.empty

    getInputValues' graph2 remainderInputs =
      case remainderInputs of
        [] ->
          graph2
        input :: rest ->
          let
            (value, graph3) = getInputValue uiModel graph2 input
            _ = MutableArray.push value inputValues -- it's mutable and doesn't return a value!
          in
            getInputValues' graph3 rest
    graph4 = getInputValues' graph inputs
    _ = Debug.log "inputs" inputs

  in
    (inputValues, graph4)



  -- This is were we get ***really dodgy***
  -- No need to foldl on the inputs, as inputs is a mutable dict, so
  -- we just mutate it, don't care about intermediatery dicts, and
  -- just return the original dict. Just like good old fashioned JS!

  -- However, we do have to Iterate the dict, and this means we must
  -- convert the object to a list of , and then to a

  -- let
  --   -- accInitial = (inputs, graph)
  --
  --   getInputValue' inputname input graph2 =
  --     let
  --       (value, graph3) = getInputValue uiModel graph2 input
  --       inputValues2 = StringKeyMutableDict.insert inputName value inputValues   -- this is probably the big killer. First, lets change InputsList to StringKeyMutableDict
  --     in
  --       remainderInputs
  -- in
  --   Dict.foldl update accInitial inputs   -- hmm, we need to implement foldl on a dict... This will be fun :/. Hang on, why aren't we using Map???? Maybe it's
  --   getInputValues'
  -- (MutableArray.empty, graph)



    -- this might be easier with recursion.
    -- even faster than a js object! And it might have a fold function.

    -- Process:
    -- - initialize a Mutable array with 0.0s for the size of the InputsList. This is the slowest part.
    -- - use recursion to update the inputs array.
    -- but

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
      case StringKeyMutableDict.get id graph of
        Just node ->
          ReferencedNodeInput node
        Nothing ->
          Debug.crash "This shouldn't happen. Could not find a node. The graph must not have been validated first"
    Node node ->
      Debug.crash "This shouldn't happen. The graph should have been flattened"
    ID id ->
      Debug.crash "This shouldn't happen. All ID inputs should have been converted to AutoID inputs"
