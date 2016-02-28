module Audio.FlattenGraph (flattenGraph, convertUserIdInputs, flattenNodeList) where

import Audio.MainTypes exposing (..)
import Dict exposing (Dict)
import Lib.Misc exposing (unsafeDictGet)

import Lib.ListExtra as ListExtra

import PrettyDebug

import Lib.StringKeyMutableDict as StringKeyMutableDict exposing (StringKeyMutableDict)

-- import Audio.Atoms.Sine exposing (sinWave)


{-
  This could probably be cleaned up now that we've moved to "tuple inheritance"
-}

flattenGraph : AudioNodes ui -> StringKeyMutableDict (AudioNode ui)
flattenGraph graph =
  graph
  |> flattenNodeList
  |> convertUserIdInputs
  |> updateDestinationNode
  |> flatNodeListToDict


flattenNodeList : AudioNodes ui -> AudioNodes ui
flattenNodeList nodes =
  let

    flattenNodeList' : AudioNodes ui -> AudioNodes ui -> Int
      -> (Int, AudioNodes ui)
    flattenNodeList' remainderNodes outputNodes lastId =
      case remainderNodes of
        [] ->
          (lastId, outputNodes)
        node :: remainderRemainderNodes ->
          let
            r = flattenNode node lastId []
            (lastId2, outputNodes2) = (r.lastId, outputNodes ++ r.nodes)
          in
            flattenNodeList' remainderRemainderNodes outputNodes2 lastId2

    (_, outputNodes3) = flattenNodeList' nodes [] 0

  in
    outputNodes3


flattenNode : AudioNode ui -> Int -> AudioNodes ui
              -> {lastId: Int, nodes : AudioNodes ui}
flattenNode node oldLastId oldAccNodes =

  let
    updateConstantBasePropsFunc oldProps =
      let
        -- _ = Debug.log "AAA" oldProps
        _ = "AAA"
        debugOldInputs = Dict.toList oldProps.inputs
        -- _ = Debug.log "debugOldInputs" debugOldInputs
        inputNames = Dict.keys oldProps.inputs
        {props, lastId, accNodes} =
          doInputs
            inputNames
            {props = oldProps, lastId = oldLastId, accNodes = oldAccNodes, node=node}
        debugNewInputs = Dict.keys props.inputs
        -- _ = Debug.log "debugNewInputs" debugNewInputs
        id = lastId + 1
      in
        ({ props | autoId = Just <| toString id }, (accNodes, id))

    (newNode, (accNodes2, id)) = updateConstantBasePropsCollectExtra updateConstantBasePropsFunc node
  in
    { lastId = id, nodes = accNodes2 ++ [newNode]}


doInputs :
  List String
  -> { props : ConstantBaseProps ui, lastId : Int, accNodes : AudioNodes ui, node : AudioNode ui }
  -> { props : ConstantBaseProps ui, lastId : Int, accNodes : AudioNodes ui}
doInputs currInputNames {props, lastId, accNodes, node} =
  -- perhaps the props at the top here is shadowed by the props in the let?
  case currInputNames of
    [] ->
      {props=props, lastId=lastId, accNodes=accNodes}
    inputName :: inputNamesTail ->
      let
        flattenInputTopResult = flattenInputTop
          { inputName=inputName, props=props, lastId=lastId, accNodes = accNodes }
        props2 = flattenInputTopResult.props
        _ = PrettyDebug.log "doInputs props2" props2
        lastId2 = flattenInputTopResult.lastId
        accNodes2 = flattenInputTopResult.accNodes
        -- node2 = flattenInputTopResult.node
      in
        doInputs inputNamesTail
          { props = props2
          , lastId = lastId2
          , accNodes = accNodes2
          , node = node
          }



flattenInputTop : { inputName : String, props : ConstantBaseProps ui, lastId : Int, accNodes : AudioNodes ui}
                  -> { accNodes : AudioNodes ui, lastId : Int, props : ConstantBaseProps ui }
flattenInputTop { inputName, props, lastId, accNodes } =
  let
    -- oldProps = getConstantBaseProps node
    _ = PrettyDebug.log "flattenInputTop oldProps" props -- Old props is *always* the original props. THat is the problem maybe
  in
      let
        { props, accNodes, lastId} = flattenInputUpperMiddle
          { inputName = inputName
          , props = props
          , lastId = lastId
          , accNodes = accNodes
          }
      in
        { accNodes = accNodes, lastId = lastId, props = props }

flattenInputUpperMiddle :
  { inputName : String, props : ConstantBaseProps ui, lastId : Int, accNodes : AudioNodes ui }
  -> { props : ConstantBaseProps ui, accNodes : AudioNodes ui, lastId : Int }
flattenInputUpperMiddle { inputName, props, lastId, accNodes } =
  let
    { lastId, accNodes, inputs } =
      flattenInputMiddle
        { accNodes = accNodes
        , lastId = lastId
        , input = unsafeDictGet inputName props.inputs  -- this assumes the inputName as already been validated
        , inputName = inputName
        , inputs = props.inputs
        }
    _ = PrettyDebug.log "flattenInputUpperMiddle inputs" inputs
    newProps = { props | inputs = inputs }
  in
    { props = newProps, accNodes = accNodes, lastId = lastId }

flattenInputMiddle :
  {  input : Input ui, inputName : String, inputs  : InputsDict ui
  , accNodes : AudioNodes ui,  lastId : Int
  }
  -> { lastId : Int, accNodes : AudioNodes ui, inputs : InputsDict ui }
flattenInputMiddle { accNodes, lastId, input, inputName, inputs } =
  let
    _ = 0
    -- _ = Debug.log "flattenInputMiddle inputs" inputs
  in
    case flattenInputLower { accNodes = accNodes, lastId = lastId, input = input} of
      Just {lastId, nodes} ->
        let
          _ = PrettyDebug.log "flattenInputMiddle newInputs" newInputs
          -- _ = Debug.log "flattenInputMiddle iputName" inputName
          newInputs = Dict.insert inputName (AutoID <| toString lastId) inputs  -- the input now points to an id, rather than an inline node
        in
          { lastId = lastId
          , accNodes = nodes
          , inputs = newInputs
          }
      Nothing ->
        { lastId = lastId, accNodes = accNodes, inputs = inputs }


flattenInputLower :
  { accNodes : AudioNodes ui, lastId : Int, input : Input ui }
  -> Maybe {lastId : Int, nodes : AudioNodes ui}
flattenInputLower {accNodes, lastId, input} =
  case input of
    Node childNode ->
      Just <| flattenNode childNode lastId accNodes
    _ ->
      Nothing


flatNodeListToDict : AudioNodes ui -> StringKeyMutableDict (AudioNode ui)
flatNodeListToDict nodes =
  nodes
  |> List.map (\node -> (getNodeAutoId node, node))
  |> StringKeyMutableDict.fromList




convertUserIdInputs : AudioNodes ui -> AudioNodes ui
convertUserIdInputs nodes =
  let
    getAutoIdForUserId userId =
      let
        filter node =
          let
            currMaybeUserId = .userId (getConstantBaseProps node)
          in
            case currMaybeUserId of
              Just currUserId ->
                currUserId == userId
              Nothing ->
                False
        foundNode = ListExtra.unsafeHead (List.filter filter nodes)
      in
        -- Maybe.withDefault "Nothing" (.autoId (getConstantBaseProps foundNode))
        Maybe.withDefault "Nothing" (.autoId (getConstantBaseProps foundNode))

    convertInput inputTuple =
      case inputTuple of
        (inputName, ID userId) ->
          (inputName, AutoID <| getAutoIdForUserId userId)
        _ ->
          inputTuple

    convertUserIdInputs' baseProps =
      { baseProps |
        inputs =
          baseProps.inputs
          |> Dict.toList
          |> List.map convertInput
          |> Dict.fromList
      }

    convertNodeUserIdInputs node =
      updateConstantBaseProps convertUserIdInputs' node

  in
    List.map convertNodeUserIdInputs nodes


updateDestinationNode : AudioNodes ui -> AudioNodes ui
updateDestinationNode nodes =
  let
    updateDestinationNode' prevNodes remainderNodes =
      case remainderNodes of
        [] ->
          Debug.crash "no nodes of type Destination were found"
        node :: remainderRemainderNodes ->
          case node of
            Destination constantBaseProps dynamicBaseProps ->
              let
                newConstantBaseProps = { constantBaseProps | autoId = Just "Destination" }
                newNode = Destination newConstantBaseProps dynamicBaseProps
              in
                prevNodes ++ [newNode] ++ remainderRemainderNodes
            _ ->
              updateDestinationNode' (prevNodes ++ [node]) remainderRemainderNodes
  in
    updateDestinationNode' [] nodes
