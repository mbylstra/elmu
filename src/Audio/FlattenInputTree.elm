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


type alias FlattenNodeState r ui =
  { props : BaseNodeProps r ui
  , lastId : Int
  , accNodes : AudioNodes ui
  }

flattenNode : AudioNode ui -> Int
            -> (Int, AudioNodes ui)
flattenNode node lastId =
  case node of
    -- geez. Maybe this works, but this crap here will need to be repeated for every node type!!
    Oscillator props ->
      let
        -- doInputs : List (String, Input ui) -> FlattenNodeState -> FlattenNodeState
        doInputs inputsList2 state2 =
          case inputsList2 of
            [] ->
              state2
            (inputName2, _) :: inputs ->
              let
                state3 = flattenInputTop
                  { inputName=inputName2, node=node, lastId=lastId, accNodes =accNodes }
              in
                doInputs inputs state3
        inputsList = Dict.toList props.inputs
        {props, lastId, accNodes} = doInputs inputsList {props = props, lastId = lastId, accNodes = accNodes}
        newNode = Oscillator props

      in
        (lastId, accNodes)

flattenInputTop : { inputName : String, node : AudioNode ui, lastId : Int, accNodes : AudioNodes ui}
                  -> { accNodes : AudioNodes ui, lastId : Int, node : AudioNode ui }
flattenInputTop { inputName, node, lastId, accNodes } =
  case node of
    Oscillator props ->
      let
        { props, accNodes, lastId} = flattenInputUpperMiddle
          { inputName = inputName
          , props = props
          , lastId = lastId
          , accNodes = accNodes
          }
        newNode = Oscillator props -- fark... this is the issue!!!
      -- oscillator specifically requires a Oscillator record,
      -- but this function might be given something that ISNT an oscillator
    -- accNodes' = [newNode] ++ accNodes
      in
        { accNodes = accNodes, lastId = lastId, node = newNode }

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
    -- newNode = Oscillator props2 -- fark... this is the issue!!!
      -- oscillator specifically requires a Oscillator record,
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
  case input of
    Node childNode ->
      let
        (childNodeId, accNodes) = flattenNode childNode lastId
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
  , inputs = Dict.fromList []
  , outputValue = 0.0
  , phase = 0.0
  , func = sinWave
  }
-- type alias BaseNodeProps r ui =
--   { r |
--       userId : Maybe String
--     , autoId : Maybe Int
--     , inputs : Dict String (Input ui)
--     , outputValue : Float
--   }
--
-- type alias OscillatorProps ui =
--   (BaseNodeProps
--     { phase: Float
--     , func: OscillatorF
--     }
--     ui
--   )

tests : Test
tests =
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
              (flattenInputLower
                { accNodes=[]
                , lastId=0
                , input= Node oscillator1
                }
              )
              Nothing
            )
        ]

main : Graphics.Element.Element
main =
    elementRunner tests
