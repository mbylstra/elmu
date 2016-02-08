import Audio.MainTypes exposing (..)
-- import Lib.MutableDict as MutableDict


-- type InputHelper uiModel
--   = InlineNodeInput (AudioNode uiModel)
--   | ReferencedNodeInput (AudioNode uiModel)
--   | ValueInput Float
--
-- getInputHelper : uiModel -> DictGraph uiModel -> Input uiModel
--           -> InputHelper uiModel
-- getInputHelper uiModel graph input =
--   case input of
--     Value value ->
--       ValueInput value
--     Default ->
--       ValueInput 0.0
--     UI func ->
--       ValueInput (func uiModel)
--     Node node ->
--       InlineNodeInput node
--     ID nodeId ->
--       ReferencedNodeInput nodeId (MutableDict.unsafeGet nodeId graph) -- assumes graph has been validated


type alias FlattenResponse uiModel
  = (AudioNode uiModel, List (AudioNode uiModel), Int)


flattenNode : (AudioNode uiModel, List (AudioNode uiModel), Int) -> (Int, List (AudioNode uiModel))
flattenNode (node, accNodes, lastId) =
  case node of
    Oscillator props ->
      let

        (lastId3, accNodes3, props3) =
          case flattenInput accNodes lastId props.frequency of
            Just (lastId2, accNodes2) ->
              (lastId2, accNodes2, { props | frequency = AutoID lastId2})  -- the input now points to an id, rather than an inline node
            Nothing ->
              -- Nothing needs to be changed, so values stay the same
              (lastId, accNodes, props)

        -- It's annoying that there's so much boilerplate, but things
        -- started getting really crazy (was it even possible??) using
        -- "getters and setters"

        -- node3

        -- (node3, accNodes3, lastId3) = flattenInput accNodes2 lastId2 props2.frequencyOffset
        -- props3 = { props2 | frequencyOffset = AutoID lastId3}  -- the input now points to an id, rather than an inline node


        -- TODO: phaseOffset

        -- new


          -- Changed rootNode childNodes lastId ->
          --   (rootNode, childNodes, lastId)
          -- NotChange ->
          --   (node1, extraNodes1, lastId1)

        -- ugh, we need the "primary node" thing so we can create a new node,
        -- and point it to that
      in
        (lastId3, accNodes3)
    -- _ -> Debug.crash ""



getNestedInputNode : Input uiModel -> Maybe (AudioNode uiModel)
getNestedInputNode input =
  case input of
    Node node ->
      Just node
    _ ->
      Nothing

flattenInput : List (AudioNode uiModel) -> Int -> Input uiModel
               -> Maybe (Int, List (AudioNode uiModel))
flattenInput accNodes lastId input =
  case getNestedInputNode input of
    Nothing ->
      Nothing
    Just childNode ->
      let
        (childNodeId, accNodes2) = flattenNode (childNode, accNodes, lastId)
      in
        Just (childNodeId + 1, accNodes2)
      -- Debug.crash "asdf"

      -- in
      --   Debug.crash "TODO"
    --     -- (nodes, lastId') = flattenNode
    --   -- id
    --   -- we must
    --   --   make an id
    --   --   somehow update the parent with this new id
    --   --   insert into the dictgraph


-- How the F do we do this?
  -- We are at a leaf if none of the inputs are inlined
  -- we can detect a leaf by getting all inputs of a node (using getInputsList)
    -- and return true if none of them are inline inputs.
    -- If they are all leafs, then we don't have to do anyting at this level,
    --   If any of them aren't leafs, then we run flattenDict on them, and
    -- update them.
      -- and record makes this really difficult!
        -- perhaps a dict of inputs is MUCH easier to work with, but not type safe
    -- what we can do is run FlattenInput on any input, the function will then
      -- take care of whether it needs to do anyting
