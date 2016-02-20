import Audio.MainTypes exposing (..)
import Lib.MutableDict as MutableDict
import Dict


-- Note, we basically aren't bothering with this at the moment! It needs
-- to be done though.

{-
  This should be run any time the graph layout is updated, and before
  unsafeUpdateGraph is run. unsafeUpdateGraph assumes the graph has
  been validated and uses unsafe methods for graph look up which
  assume valid data.
-}
validateGraph : uiModel -> DictGraph uiModel -> Destination uiModel
                -> Result String Bool
validateGraph uiModel graph destination =
  validateInput uiModel graph destination.input


validateInput : uiModel -> DictGraph uiModel -> Input uiModel -> Result String Bool
validateInput uiModel graph input =
  case getInputForValidation uiModel input graph of
    Ok maybeNode ->
      case maybeNode of
        Nothing ->
          Ok True
        Just node ->
          -- Ok True
          let
            isErr : Result error value -> Bool
            isErr result =
              case result of
                Ok _ -> False
                Err _ -> True
            results = List.map (validateInput uiModel graph) (getNodeInputsList node)
            errors : List (Result String Bool)
            errors = List.filter isErr results
          in
            Maybe.withDefault (Ok True) (List.head errors)  -- interesting used of withDefault! Default to OK if no errors in list, or get hte first one
    Err msg ->
      Err msg


getInputForValidation : uiModel -> Input uiModel -> DictGraph uiModel
          -> Result String (Maybe (AudioNode  uiModel))
getInputForValidation uiModel input graph =
  case input of
    Value value ->
      Ok (Nothing)
    Default ->
      Ok (Nothing)
    UI func ->
      Ok (Nothing) -- for now, assume we can only get valid inputs from UI
    Node node ->
      Ok (Just node)
    ID nodeId ->
      case MutableDict.get nodeId graph of
        Just node ->
          Ok (Just node)
        Nothing ->
          Err ("There are no nodes in the graph with ID `" ++ toString(nodeId) ++ "`")
    AutoID nodeId ->
      Ok (Nothing)

getNodeInputsList : AudioNode uiModel -> List (Input uiModel)
getNodeInputsList node =
  case node of
    Oscillator props ->
      Dict.values props.inputs
    -- _ -> Debug.crash "todo"
