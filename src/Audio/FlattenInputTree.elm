import Audio.MainTypes exposing (..)
import Dict exposing (Dict)
import ElmTest exposing (..)
import Graphics.Element

import Audio.Atoms.Sine exposing (sinWave)



unsafeDictGet : comparable -> Dict comparable value -> value
unsafeDictGet key dict =
  case Dict.get key dict of
    Just value ->
      value
    Nothing ->
      Debug.crash("Dict.get returned Nothing from within usafeDictGet")


flattenNode : AudioNode ui -> Int -> AudioNodes ui
              -> (Int, AudioNodes ui)
flattenNode node lastId accNodes =

  let
    _ = Debug.log "flattenNode" 0
  in
    case node of
      -- geez. Maybe this works, but this crap here will need to be repeated for every node type!!
      Dummy props ->
        let
          _ = Debug.log "end of Dummy props" (lastId, accNodes)
          inputNames = Dict.keys props.inputs
          {props, lastId, accNodes} =  doInputs inputNames {props = props, lastId = lastId, accNodes = accNodes, node=node}
          newNode = Dummy props
          _ = Debug.log "start of Dummy props" props.inputs

        in
          (lastId, accNodes ++ [newNode])
      Oscillator props ->
        Debug.crash "todo"


doInputs : List String -> { props : BaseNodeProps r ui, lastId : Int, accNodes : AudioNodes ui, node : AudioNode ui }
  -> { props : BaseNodeProps r ui, lastId : Int, accNodes : AudioNodes ui}
doInputs currInputNames {props, lastId, accNodes, node} =
  let
    _ = Debug.log "currInputNames" currInputNames
    -- _ = Debug.log "inputNames" inputNames
  in
    -- state2
    case currInputNames of
      [] ->
        {props=props, lastId=lastId, accNodes=accNodes}
      -- _ -> Debug.crash ""
      -- _ ->
      --   state2
      inputName :: inputNamesTail ->
        -- state2
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
        -- newNode = Dummy props -- fark... this is the issue!!!
      -- oscillator specifically requires a Dummy record,
      -- but this function might be given something that ISNT an oscillator
    -- accNodes' = [newNode] ++ accNodes
      in
        { accNodes = accNodes, lastId = lastId, props = props }
    Oscillator props ->
      Debug.crash "todo"

flattenInputUpperMiddle : { inputName : String, props : BaseNodeProps r ui, lastId : Int, accNodes : AudioNodes ui }
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
    -- newNode = Dummy props2 -- fark... this is the issue!!!
      -- oscillator specifically requires a Dummy record,
      -- but this function might be given something that ISNT an oscillator

    -- accNodes' = [newNode] ++ accNodes
    -- accNodes' = [newNode] ++ accNodes
  in
    { props = newProps, accNodes = accNodes, lastId = lastId }
    -- 0

flattenInputMiddle :
  {  input : Input ui, inputName : String, inputs  : InputsDict ui
  , accNodes : AudioNodes ui,  lastId : Int
  }
  -> { lastId : Int, accNodes : AudioNodes ui, inputs : InputsDict ui }
flattenInputMiddle { accNodes, lastId, input, inputName, inputs } =
  case flattenInputLower { accNodes = accNodes, lastId = lastId, input = input} of
    Just (lastId, accNodes) ->
      { lastId = lastId
      , accNodes = accNodes
      , inputs = Dict.insert inputName (AutoID lastId) inputs  -- the input now points to an id, rather than an inline node
      }
    Nothing ->
      { lastId = lastId, accNodes = accNodes, inputs = inputs }


flattenInputLower :
  { accNodes : AudioNodes ui, lastId : Int, input : Input ui }
  -> Maybe (Int, AudioNodes ui)
flattenInputLower {accNodes, lastId, input} =
  let
    _ = Debug.log "start of flattenInputLower" 0
  in
    case input of
      Node childNode ->
        let
          (childNodeId, accNodes) = flattenNode childNode lastId accNodes
          _ = Debug.log "'start' of Node childNode"  0
        in
          Just (childNodeId + 1, accNodes)
      _ ->
        Nothing


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


-- args1 : {accNodes:List (AudioNode ui), lastId:Int, input: Input ui}
-- args1 = {accNodes=[], lastId=0, input=Value 0.0}

oscillator1 : AudioNode ui
oscillator1 = Oscillator
  { userId = Nothing
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
  { userId = Nothing
  , autoId = Nothing
  , inputs = Dict.fromList
    [("frequency", Value 440.0)
    ,("frequencyOffset", Value 0.0)
    ,("phaseOffset", Value 0.0)
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
        , test ""
            (assertEqual
              1
              (
                let
                  result = flattenInputLower
                    { accNodes=[]
                    , lastId=0
                    , input= Node dummy1
                    }
                  _ = Debug.log "result" result
                  justResult = Maybe.withDefault (0, []) result
                  _ = Debug.log "justResult" justResult
                  nodes = snd justResult
                  _ = Debug.log "nodes"  nodes
                  _ = Debug.log "head of nodes" (List.head nodes)
                in
                  result
                    |> Maybe.withDefault (0, [])
                    |> snd
                    |> List.length
              )
            )
        ]

main : Graphics.Element.Element
main =
    elementRunner tests
