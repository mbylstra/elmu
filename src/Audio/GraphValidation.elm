import Audio.MainTypes exposing (..)
import Lib.MutableDict as MutableDict


{-
  This should be run any time the graph layout is updated, and before
  unsafeUpdateGraph is run. unsafeUpdateGraph assumes the graph has
  been validated and uses unsafe methods for graph look up which
  assume valid data.
-}
validateGraph : uiModel -> DictGraph idType uiModel -> Destination idType uiModel
                -> Result String Bool
validateGraph uiModel graph destination =
  validateInput uiModel graph destination.input


validateInput : uiModel -> DictGraph idType uiModel -> Input idType uiModel -> Result String Bool
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


getInputForValidation : uiModel -> Input idType uiModel -> DictGraph idType uiModel
          -> Result String (Maybe (AudioNode  idType uiModel))
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
      Ok (Nothing) -- Nodes with an AutoID and their children were automatically
        -- generated. So there's no need to validate them or their children.

getNodeInputsList : AudioNode idType uiModel -> List (Input idType uiModel)
getNodeInputsList node =
  case node of
    Oscillator props ->
      [props.frequency, props.frequencyOffset, props.phaseOffset]
    _ -> Debug.crash "todo"
