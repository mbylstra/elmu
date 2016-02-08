import Audio.MainTypes exposing (..)
-- import Lib.MutableDict as MutableDict


import Audio.AudioNodeTypes.Oscillator as Osc


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
  = (AudioNode uiModel, List (AudioNode uiModel), Int, Identifiable) -- I think not given the full type for props is where shit will hit the fan!



-- flattenNode : FlattenResponse idModel -> FlattenResponse idModel
-- flattenNode (node1, accNodes1, lastId1) =
--   case node1 of
--     Oscillator props ->
--       let
--         (node2, accNodes2, lastId2, props2) = flattenInput getter setter (node1, accNodes1, lastId1, props)
--         props2 = { props | frequency = AutoID lastId2}  -- the input now points to an id, rather than an inline node
--         -- List.map
--         --   (\(getter, setter) -> Osc.accessors )
--         --   Osc.accessors
--
--
--         getFrequency = Osc.accessors[0][0]  -- imaginary
--         setFrequency = Osc.accessors[0][1]  -- imaginary
--
--         flattenInput getter setter (no
--
--
--
--
--
--         -- how can we reduce this boilerplate?
--         -- can we make a function that just takes an accessor function, and a 4-tuple,
--         -- and returns a 4 tuple, and even use the pipe operater, or map
--         -- over a list of accessors?, or even automatically get a list of type accessors from
--         -- a record?
--         (node3, accNodes3, lastId3) = flattenInput (node2, accNodes2, lastId2) props.frequencyOffset
--         props3 = { props2 | frequency = AutoID lastId3}  -- the input now points to an id, rather than an inline node
--
--
--
--
--           -- Changed rootNode childNodes lastId ->
--           --   (rootNode, childNodes, lastId)
--           -- NotChange ->
--           --   (node1, extraNodes1, lastId1)
--
--         -- ugh, we need the "primary node" thing so we can create a new node,
--         -- and point it to that
--       in
--         (node2, accNodes2, lastId2)
--     -- _ -> Debug.crash ""



getNestedInputNode : Input uiModel -> Maybe (AudioNode uiModel)
getNestedInputNode input =
  case input of
    Node node ->
      Just node
    _ ->
      Nothing


-- flattenDictTreeGraph : (AudioNode uiModel, DictGraph uiModel)
--                        -> DictGraph uiModel
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

-- type FlattenResponse  uiModel
--   = NotChanged
--   | Changed (AudioNode uiModel, List (AudioNode uiModel), Int)



-- flattenInput : FlattenResponse uiModel -> Input uiModel -> FlattenResponse uiModel
flattenInput getter setter (node, accNodes, lastId, props) =
  case getNestedInputNode input of
    Nothing ->
      -- nothing needs to be changed, so just return the data as supplied
      (node, accNodes, lastId, props)
    Just innerNode ->
      -- now we have the node that input is referencing.
      -- that node may have children, so we must run flattenNode on it
      let
        -- (flattenedInnerNode, accNodes2, lastId2) = flattenNode (innerNode, accNodes, lastId)
        (flattenedInnerNode, accNodes2, lastId2) = (innerNode, accNodes, lastId)
        nodeId = lastId2 + 1
        newProps = setter (AutoID nodeId) props
      in
        (extractedNode, accNodes2, nodeId, newProps)


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
