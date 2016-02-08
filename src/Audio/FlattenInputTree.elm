import Audio.MainTypes exposing (..)
-- import Lib.MutableDict as MutableDict


-- type InputHelper idType uiModel
--   = InlineNodeInput (AudioNode idType uiModel)
--   | ReferencedNodeInput idType (AudioNode idType uiModel)
--   | ValueInput Float
--
-- getInputHelper : uiModel -> DictGraph idType uiModel -> Input idType uiModel
--           -> InputHelper idType uiModel
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




flattenNode : FlattenResponse idType idModel -> FlattenResponse idType idModel
flattenNode (node1, accNodes1, lastId1) =
  case node1 of
    Oscillator props ->
      let
        (node2, accNodes2, id, lastId2) = flattenInput (node1, accNodes1, lastId1) props.frequency
        -- now we must update node.props.inputs.frequency .... oh dear, what a hassle, three levels deep!
        props2 = { props | frequency = Input (ID id)}  -- the input now points to an id, rather than an inline node
          -- now we need to introduce two input things though!

          -- Changed rootNode childNodes lastId ->
          --   (rootNode, childNodes, lastId)
          -- NotChange ->
          --   (node1, extraNodes1, lastId1)

        -- ugh, we need the "primary node" thing so we can create a new node,
        -- and point it to that
      in
        (node2, accNodes2, lastId2)
    _ -> Debug.crash ""



getNestedInputNode : Input idType uiModel -> Maybe (AudioNode idType uiModel)
getNestedInputNode input =
  case input of
    Node node ->
      Just node
    _ ->
      Nothing

type alias FlattenResponse idType uiModel
  = (AudioNode idType uiModel, List (AudioNode idType uiModel), Int)

-- flattenDictTreeGraph : (AudioNode idType uiModel, DictGraph idType uiModel)
--                        -> DictGraph idType uiModel
-- flattenDictTreeGraph (node, graph) =
--   case node of
--     Oscillator props ->
--       let
--         inputs = props.inputs
--       in
--         (newInput, graph) = flattenInput inputs.frequency

        -- ah, so this is fucked. after this we can no longer rely
        -- on props.inputs, because props is a copy of node.props, but
        -- node is now a new node, because on of it's inputs has changed?
        -- Not true. Ok this is how:
          -- doing flattenInput returns a LIST OF AUDIO NODES. It doesn't modify
          -- anything. Right at the top we have an unmodified audioGraph and a list
          -- of now flattened inputs. Now, either add those to the dictGraph, or
          -- replace an element in the graph if it has the same id. Phew.. i think
          -- that will work. Yikes. Confusing.
          -- I don't even think the flatten Dict graph needs to know about graph, which is nice!

-- type FlattenResponse  idType uiModel
--   = NotChanged
--   | Changed (AudioNode idType uiModel, List (AudioNode idType uiModel), Int)



flattenInput : FlattenResponse idType uiModel -> Input idType uiModel -> FlattenResponse idType uiModel
flattenInput (node, accNodes, lastId) input =
  case getNestedInputNode input of
    Nothing ->
      -- nothing has change, just return the inputs supplied
      (node, accNodes, lastId)
    Just node ->
      flattenNode (node, accNodes, lastId)
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
