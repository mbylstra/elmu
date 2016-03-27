module Audio.StatePool where

import Lib.StringKeyMutableDict as StringKeyMutableDict exposing (StringKeyMutableDict)
import Lib.GenericMutableDict as GenericMutableDict exposing (GenericMutableDict)
import Audio.MainTypes exposing (DictGraph, AudioNode(Oscillator, Destination, Adder, Dummy))
import Lib.MutableArray as MutableArray

-- flattenGraph : AudioNodes ui -> StringKeyMutableDict (AudioNode ui)

type alias StatePool = StringKeyMutableDict GenericMutableDict

initialiseStatePool : DictGraph ui -> StatePool
initialiseStatePool graph =
  let
    -- pool = GenericMutableDict.empty ()
    pool = StringKeyMutableDict.empty ()
    graphList = StringKeyMutableDict.toList graph
    stateTuples = List.map convertGraphTuple graphList
    -- then we fold over the tuples and insert them into StatePool

    insertNodeState (id, nodeState) =
      StringKeyMutableDict.insert id nodeState pool
    _ = List.map insertNodeState stateTuples

  in

    -- first turn DictGraph into a list of (id, AudioNode), so we can
    -- easily map over it (or implement map for StringKeyMutableDict)
    pool


convertGraphTuple : (String, AudioNode ui) -> (String, GenericMutableDict)
convertGraphTuple (id, node) =
  (id, nodeToStateDict node)


nodeToStateDict : AudioNode ui -> GenericMutableDict
nodeToStateDict node =
  case node of
    Oscillator _ _ _ _ ->
      let
        dict = GenericMutableDict.empty ()
        _ = GenericMutableDict.insert "value" 0.0 dict
        _ = GenericMutableDict.insert
              "inputValues"
              (MutableArray.repeat 3 0.0)
              dict
        _ = GenericMutableDict.insert "phase" 0.0 dict
      in
        dict
    Adder _ _ _ ->
      let
        dict = GenericMutableDict.empty ()
        _ = GenericMutableDict.insert "value" 0.0 dict
        _ = GenericMutableDict.insert
              "inputValues"
              (MutableArray.repeat 100 0.0) -- this will allow up to 100 nodes to be connected
              dict
      in
        dict
    Destination _ _ _ ->
      let
        dict = GenericMutableDict.empty ()
        _ = GenericMutableDict.insert "value" 0.0 dict
        _ = GenericMutableDict.insert
              "inputValues"
              (MutableArray.repeat 100 0.0) -- this will allows up to 100 nodes to be connected
              dict
      in
        dict
    Dummy _ _ ->
      let
        dict = GenericMutableDict.empty ()
        _ = GenericMutableDict.insert "value" 0.0
      in
        dict
