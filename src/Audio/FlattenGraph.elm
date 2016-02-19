module Audio.FlattenGraph (flattenGraph) where

import Audio.MainTypes exposing (..)
import Dict exposing (Dict)
import ElmTest exposing (..)
import Graphics.Element
import Lib.Misc exposing (unsafeDictGet)

import Audio.Atoms.Sine exposing (sinWave)


flattenGraph : AudioNodes ui -> Dict Int (AudioNode ui)
flattenGraph graph =
  graph
  |> flattenNodeList
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
flattenNode node lastId accNodes =
  case node of
    Dummy props ->
      let
        inputNames = Dict.keys props.inputs
        {props, lastId, accNodes} =
          doInputs
            inputNames
            {props = props, lastId = lastId, accNodes = accNodes, node=node}
        id = lastId + 1
        newProps = { props | autoId = Just id }
        newNode = Dummy newProps

      in
        { lastId = id, nodes = accNodes ++ [newNode]}
    Oscillator props ->
      Debug.crash "todo"


doInputs :
  List String
  -> { props : BaseNodeProps r ui, lastId : Int, accNodes : AudioNodes ui, node : AudioNode ui }
  -> { props : BaseNodeProps r ui, lastId : Int, accNodes : AudioNodes ui}
doInputs currInputNames {props, lastId, accNodes, node} =
  case currInputNames of
    [] ->
      {props=props, lastId=lastId, accNodes=accNodes}
    inputName :: inputNamesTail ->
      let
        {props, lastId, accNodes} = flattenInputTop
          { inputName=inputName, node=node, lastId=lastId, accNodes = accNodes }
      in
        doInputs inputNamesTail
          { props = props
          , lastId = lastId
          , accNodes = accNodes
          , node = node
          }



flattenInputTop : { inputName : String, node : AudioNode ui, lastId : Int, accNodes : AudioNodes ui}
                  -> { accNodes : AudioNodes ui, lastId : Int, props : BaseNodeProps r ui }
flattenInputTop { inputName, node, lastId, accNodes } =
  case node of
    Dummy props ->
      let
        { props, accNodes, lastId} = flattenInputUpperMiddle
          { inputName = inputName
          , props = props
          , lastId = lastId
          , accNodes = accNodes
          }
      in
        { accNodes = accNodes, lastId = lastId, props = props }
    Oscillator props ->
      Debug.crash "todo"

flattenInputUpperMiddle :
  { inputName : String, props : BaseNodeProps r ui, lastId : Int, accNodes : AudioNodes ui }
  -> { props : BaseNodeProps r ui, accNodes : AudioNodes ui, lastId : Int }
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
    newProps = { props | inputs = inputs }
  in
    { props = newProps, accNodes = accNodes, lastId = lastId }

flattenInputMiddle :
  {  input : Input ui, inputName : String, inputs  : InputsDict ui
  , accNodes : AudioNodes ui,  lastId : Int
  }
  -> { lastId : Int, accNodes : AudioNodes ui, inputs : InputsDict ui }
flattenInputMiddle { accNodes, lastId, input, inputName, inputs } =
  case flattenInputLower { accNodes = accNodes, lastId = lastId, input = input} of
    Just {lastId, nodes} ->
      { lastId = lastId
      , accNodes = nodes
      , inputs = Dict.insert inputName (AutoID lastId) inputs  -- the input now points to an id, rather than an inline node
      }
    Nothing ->
      { lastId = lastId, accNodes = accNodes, inputs = inputs }


flattenInputLower :
  { accNodes : AudioNodes ui, lastId : Int, input : Input ui }
  -> Maybe {lastId : Int, nodes : AudioNodes ui}
flattenInputLower {accNodes, lastId, input} =
  let
    _ = Debug.log "start of flattenInputLower" 0
  in
    case input of
      Node childNode ->
        Just <| flattenNode childNode lastId accNodes
      _ ->
        Nothing


flatNodeListToDict : AudioNodes ui -> Dict Int (AudioNode ui)
flatNodeListToDict nodes =
  nodes
  |> List.map (\node -> (getNodeAutoId node, node))
  |> Dict.fromList

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


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


-- args1 : {accNodes:List (AudioNode ui), lastId:Int, input: Input ui}
-- args1 = {accNodes=[], lastId=0, input=Value 0.0}

oscillator1 : AudioNode ui
oscillator1 = Oscillator
  { userId = Just "osc1"
  , autoId = Nothing
  , inputs = Dict.fromList
    [("frequency", Value 440.0)
    ,("frequencyOffset", Value 0.0)
    ,("phaseOffset", Value 0.0)
    ]
  , outputValue = 0.0
  , phase = 0.0
  , func = sinWave
  }

dummy1 : AudioNode ui
dummy1 = Dummy
  { userId = Just "dummy1"
  , autoId = Nothing
  , inputs = Dict.fromList
    [("inputA", Value 440.0)]
  , outputValue = 0.0
  , func = 0.0
  }


-- dummy 3 points to dummy 4, dummy 2 points to dummy 3

dummy2 : AudioNode ui
dummy2 = Dummy
  { userId = Just "dummy2"
  , autoId = Nothing
  , inputs = Dict.fromList
    [ ( "inputA"
      , Node
        ( Dummy
          { userId = Just "dummy3"
          , autoId = Nothing
          , inputs = Dict.fromList
            [ ( "inputA"
              , Node
                ( Dummy
                  { userId = Just "dummy4"
                  , autoId = Nothing
                  , inputs = Dict.fromList
                    [ ( "inputA"
                      , Value 1.0
                      )
                    ]
                  , outputValue = 0.0
                  , func = 0.0
                  }
                )
              )
            ]
          , outputValue = 0.0
          , func = 0.0
          }
        )
      )
    ]
  , outputValue = 0.0
  , func = 0.0
  }
-- dummy1
-- type alias BaseNodeProps r ui =
--   { r |
--       userId : Maybe String
--     , autoId : Maybe Int
--     , inputs : Dict String (Input ui)
--     , outputValue : Float
--   }
--
-- type alias DummyProps ui =
--   (BaseNodeProps
--     { phase: Float
--     , func: DummyF
--     }
--     ui
--   )

tests : Test
tests =
  let
    _ = Debug.log "start of tests" 0
  in
    suite ""
        [
          test ""
            (assertEqual
              (flattenInputLower
                {accNodes=[], lastId=0, input=(Value 0.0)}
              )
              Nothing
            )
        -- , test ""
        --     (assertEqual
        --       1
        --       (
        --         let
        --           result = flattenInputLower
        --             { accNodes=[]
        --             , lastId=0
        --             , input= Node dummy1
        --             }
        --         in
        --           result
        --             |> Maybe.withDefault (0, 0, [])
        --             |> snd
        --             |> List.length
        --       )
        --     )
        , test ""
            (assertEqual
              3
              (
                let
                  result = flattenNode dummy2 0 []
                  _ = Debug.log "result" result
                in
                  result
                    |> \{lastId, nodes} -> nodes
                    |> List.length
              )
            )
        , test ""
            (assertEqual
              4
              (
                let
                  result = flattenNodeList [dummy1, dummy2]
                  _ = Debug.log "result" result
                in
                  List.length result
                  -- result
                  --   |> \{lastId, nodes} -> nodes
                  --   |> List.length
              )
            )
        ]

main : Graphics.Element.Element
main =
    elementRunner tests


-- result: [Dummy { userId = Just "dummy1", autoId = Just NaN, inputs = Dict.fromList [("inputA",Value 440)], outputValue = 0, func = 0 },
-- Dummy { userId = Just "dummy4", autoId = Just NaN, inputs = Dict.fromList [("inputA",Value 1)], outputValue = 0, func = 0 },
-- Dummy { userId = Just "dummy3", autoId = Just NaN, inputs = Dict.fromList [("inputA",AutoID NaN)], outputValue = 0, func = 0 },Dummy { userId = Just "dummy2", autoId = Just NaN, inputs = Dict.fromList [("inputA",AutoID NaN)], outputValue = 0, func = 0 }]


-- result:
-- [Dummy { userId = Just "dummy1", autoId = Just 1, inputs = Dict.fromList [("inputA",Value 440)], outputValue = 0, func = 0 },
-- Dummy { userId = Just "dummy4", autoId = Just 2, inputs = Dict.fromList [("inputA",Value 1)], outputValue = 0, func = 0 },
-- Dummy { userId = Just "dummy3", autoId = Just 3, inputs = Dict.fromList [("inputA",AutoID 2)], outputValue = 0, func = 0 },
-- Dummy { userId = Just "dummy2", autoId = Just 4, inputs = Dict.fromList [("inputA",AutoID 3)], outputValue = 0, func = 0 }]
