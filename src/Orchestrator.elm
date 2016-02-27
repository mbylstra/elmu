module Orchestrator where

--------------------------------------------------------------------------------
-- EXTERNAL DEPENDENCIES
--------------------------------------------------------------------------------

-- import ElmTest exposing (..)
-- import Lib.MutableDict as MutableDict
-- import Lib.Misc exposing (unsafeDictGet)
import Lib.MutableArray as MutableArray exposing (MutableArray)
import Lib.GenericMutableDict as GenericMutableDict exposing (GenericMutableDict)
import Dict exposing (Dict)

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
  let
    -- _ = Debug.log "updateGraph" graph
    destinationNode = getDestinationNode graph
    -- _ = Debug.log "destinationNode" destinationNode
    -- _ = Debug.log "graph" destinationNode
    -- _ = Debug.log "uiModel" uiModel
    -- _ = Debug.log "updateNode" updateNode
  in
    updateNode uiModel graph destinationNode
  -- (0.0, graph)  -- 3% when updateGraph not called

getDestinationNode : DictGraph ui -> AudioNode ui
getDestinationNode graph =
  -- 3-6% when js object is used to look up destination
  StringKeyMutableDict.unsafeNativeGet "Destination" graph

updateNode : ui -> DictGraph ui -> AudioNode ui
  -> (Float, DictGraph ui)
updateNode uiModel graph node =

  let
      -- gdict = GenericMutableDict.empty ()
      -- _ = GenericMutableDict.insert "hello" 5 gdict  -- I think it works!!!!!
      -- _ = GenericMutableDict.insert "hello" "string" gdict  -- I think it works!!!!! Fuck yeah!
    -- _ = Debug.log "In updateGraph"
    _ = 1
  in
    case node of
      Oscillator func constantBaseProps dynamicBaseProps oscProps ->
        let
          -- _ = Debug.log "old phase" oscProps.phase
          _ = Debug.log "oscPropsStart" oscProps
          inputs = constantBaseProps.inputs
          (inputValues, graph2) = getInputValues uiModel graph inputs
          _ = Debug.log "inputValues" inputValues

          frequency = (MutableArray.unsafeNativeGet 0 inputValues)
          _ = Debug.log "frequency" frequency
          frequencyOffset = (MutableArray.unsafeNativeGet 1 inputValues)
          _ = Debug.log "frequencyOffset" frequencyOffset
          phaseOffset = (MutableArray.unsafeNativeGet 2 inputValues)
          prevPhase = (GenericMutableDict.unsafeNativeGet "phase" oscProps)
          _ = Debug.log "prevPhase" prevPhase  -- this is wrong!! Why is it "internal data structure" ??
          (newValue, newPhase) = -- damn, need to do sometin gabout this friggen tuple
            func frequency frequencyOffset phaseOffset prevPhase
          -- newValue = 0.0
          -- newPhase = 0.0

          -- Fuck yeah, we don't have to do this any more!
          -- newNode = Oscillator
          --   ( { dynamicBaseProps | outputValue = newValue }
          --   , { oscProps | phase = newPhase }
          --   )
          _ = GenericMutableDict.insert "outputValue" newValue dynamicBaseProps
          _ = GenericMutableDict.insert "phase" newPhase oscProps
          -- _ = Debug.log "oscProps" oscProps

          graph3 = StringKeyMutableDict.insert (getNodeAutoId node) node graph2
            -- note that we can just pass in the original node, as it's only things it references that have been updated
            -- also, when working with mutable data structures, I think it's best to not return anything (it makes it clearer that the input has been mutated)
          -- _ = Debug.log "new phase" newPhase
          -- _ = Debug.log "new value" newValue
          -- _ = Debug.log "oscPropsEnd" oscProps
        in
          (newValue, graph3) -- we need to do something about this! (this could be pretty annoying to handle)
            -- actually, if graph is mutable, then there's no need to return it right? We can just return newValue, so no tuple (js object) is required
        -- (0.0, graph)

      Destination constantBaseProps dynamicBaseProps ->
        let
          _ = Debug.log "Destination" 0
          inputs = constantBaseProps.inputs
          -- graph2 = graph
          (inputValues, graph2) = getInputValues uiModel graph inputs
          newValue = (MutableArray.unsafeNativeGet 0 inputValues)

          _ = GenericMutableDict.insert "outputValue" newValue dynamicBaseProps


          -- creating a new node and a new tuple doesn't seem to add an appreciable amount
          -- newNode = node
          id = getNodeAutoId node  -- < 1%
          graph3 = StringKeyMutableDict.insert id node graph2   -- the dict insert adds ~ 5-10 %  -- this is so much faster now!!
          -- _ = Debug.log "Destination" 0
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


getInputValues : ui -> DictGraph ui -> InputsDict ui
                 -> (MutableArray Float, DictGraph ui)
getInputValues uiModel graph inputs =
  let
    accInitial = (MutableArray.empty (), graph)
      -- it's the dict updates for every input that's slow.
      -- make this a mutable Array instead


    update inputName input acc =
      let
        (inputValues, graph2) = acc
        (value, graph3) = getInputValue uiModel graph2 input
        inputValues2 = MutableArray.push value inputValues
      in
        (inputValues2, graph3)
  in
    Dict.foldl update accInitial inputs   -- wecan continue using dicts for the Input's


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
