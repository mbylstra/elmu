import Audio.MainTypes exposing (..)
import Dict exposing (Dict)

unsafeDictGet : comparable -> Dict comparable value -> value
unsafeDictGet key dict =
  case Dict.get key dict of
    Just value ->
      value
    Nothing ->
      Debug.crash("Dict.get returned Nothing from within usafeDictGet")


-- flattenNode node =
--   case



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
        -- (childNodeId, accNodes2) = flattenNode (childNode, accNodes, lastId)
        (childNodeId, accNodes2) = (lastId, accNodes)
      in
        Just (childNodeId + 1, accNodes2)
    _ ->
      Nothing
