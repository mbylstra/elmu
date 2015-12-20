module AudioNodeTree where

import Dict exposing (Dict)
import String
import Graphics.Element exposing (Element, show)
import ElmTest exposing (..)

import Orchestrator exposing
    ( AudioNode (Generator, FeedforwardProcessor, Destination, Mixer)
    , NodeGraph
    , Input (ID)
    , NodeGraphDict
    )
import AudioNodes exposing
    ( squareWave
    , simpleLowPassFilter
    , sawWave
    , OscillatorType(Square, Saw, Triangle)
    , oscillator
    )

type alias TreeNodeValue =
    { children: List AudioNodeTree
    , audioNode: AudioNode
    }


type AudioNodeTree
    = TreeNode TreeNodeValue
    | Leaf AudioNode


dummyAudioNode1 =
    Generator
        { id = "square1"
        , function = oscillator Saw 440.0
        , state =
            { outputValue = Nothing  }
        }

dummyAudioNode2 =
    FeedforwardProcessor
        { id = "lowpass"
        , input = ID "square1"
        , function = simpleLowPassFilter
        , state =
            { outputValue = Nothing
            , prevValues = [0.0]
            }
        }

-- dummyAudioNode3 =
--     Generator
--         { function = squareWave
--         , state =
--             { outputValue = Nothing  }
--         }

testTree : AudioNodeTree
testTree = Leaf <| dummyAudioNode1


testTree2 : AudioNodeTree
testTree2 = TreeNode
    { children =
        [ Leaf dummyAudioNode1
        ]
    , audioNode = dummyAudioNode2
    }


testGraph : NodeGraph
testGraph =
    [ Generator
        { id = "square1"
        , function = squareWave
        , state =
            { outputValue = Nothing  }
        }
    , FeedforwardProcessor
        { id = "lowpass"
        , input = ID "square1"
        , function = simpleLowPassFilter
        , state =
            { outputValue = Nothing
            , prevValues = [0.0]
            }
        }
    , Destination
        { id = "destination"
        , input = ID "lowpass"
        , state =
            { outputValue = Nothing }
        }
    ]

-- #1 traverse the tree, print something (anything!).



getInputNodes : AudioNode -> NodeGraphDict -> List AudioNode
getInputNodes node graph =
    let

        getInputNode' : Input -> AudioNode
        getInputNode' input =
            case input of
                ID id ->
                    case (Dict.get id graph) of
                        Just node -> node
                        Nothing -> Debug.crash("Can't find node")

        getInputNodes' : List Input -> List AudioNode
        getInputNodes' inputs =
            List.map getInputNode' inputs
    in
        case node of
            FeedforwardProcessor props ->
                [getInputNode' props.input]
            Destination props ->
                [getInputNode' props.input]
            Mixer props ->
                getInputNodes' props.inputs
            _ ->
                Debug.crash("does not have an input node")




toDict : NodeGraph -> NodeGraphDict
toDict nodeGraph =
    let
        createTuple node =
            case node of
                Destination props ->
                    (props.id, node)
                Generator props ->
                    (props.id, node)
                FeedforwardProcessor props ->
                    (props.id, node)
                Mixer props ->
                    (props.id, node)
        tuples = List.map createTuple nodeGraph
    in
        Dict.fromList tuples

-- updateGraphState graphState =
--     let
--         nodeGraphDict : Dict String AudioNode
--         nodeGraphDict = Dict.fromList graphState
--         destinationNode = getDestinationNode nodeGraphDict
--         nextNode = getInputNode destinationNode nodeGraphDict
--     in
--         -- maybe we need to be building a stack here?
--         case nextNode of
--             Generator data ->

--             _ ->
--                 graphstate



addChild : AudioNode -> TreeNodeValue -> AudioNodeTree
addChild audioNode tree =
    let
        addChild' : TreeNodeValue -> TreeNodeValue
        addChild' treeNodeValue childNodeTree=
            { treeNodeValue |
              children = treeNodeValue.children ++ [childNodeTree]
            }
    in
        case audioNode of
            Generator _ ->
                addChild' tree (Leaf audioNode)
            Mixer {id, inputs, state} ->

                -- for each child, build a tree with it

                let
                    children = List.map buildAudioTreeGraph inputs


                addChild' tree (TreeNode {audioNode=audioNode, children=[]})
                -- here we need to get the children of the audioNode, rather
                -- than just return an empty list
            _ -> Debug.crash("nothing else implemented")


buildAudioTree graph

buildAudioTree graph =
    let
        graphDict = toDict graph
        destinationNode = getDestinationNode graphDict
        rootNode =
            case getInputNodes destinationNode graphDict of
                [] -> Debug.crash("desintation is not connected to anything!")
                [rootNode] -> rootNode
                rootNodes -> Debug.crash("destination should not have multiple inputs")

        initialTree = TreeNode
            { children = []
            , audioNode = rootNode
            }


        initialTree' =
            let
                inputNodes = getInputNodes rootNode graphDict
                newTree = List.foldl addChild initialTree inputNodes
            in
                newTree
                -- so the next step is a bit of a headfuck. I think you need to
                -- carry the parent node along, and call add children, which is
                -- actually a recursive function. For the current AudioNode it is
                -- dealing with, it should check if it has any children, if not
                -- then return a AudioNodeLeaf, the function above just adds that
                -- to the list of children for the current node.


        buildAudioTree' graphDict audioTree =
            ""
    in
        buildAudioTree' graphDict rootNode



-- I think building the audio graph first is a bit crazy, let's have a go
-- at updating state as we traverse the graph. As long as we have a record of
-- what nodes we've visited, we won't get into infinite loops
-- we do want to convert to a Dict first though, and we do want to start from
-- the first input to Destination






printTreeNodes : AudioNodeTree -> Bool
printTreeNodes tree =
    case tree of
        Leaf _ ->
            Debug.log "I am a leaf" True
        TreeNode node ->
            let
                _ = Debug.log "I am a node" True
                _ = List.map printTreeNodes node.children
            in
                True


treeToList : AudioNodeTree -> List String
treeToList tree =
    let
        treeToList' : AudioNodeTree -> List String -> List String
        treeToList' tree accList =
            case tree of
                Leaf _ ->
                    accList ++ ["leaf"]
                TreeNode node ->
                    let
                        lists = List.map treeToList node.children
                    in
                        ["node"] ++ (List.foldl (++) [] lists)
    in
        treeToList' tree []


getNextSample : Float -> AudioNodeTree -> Float
getNextSample time tree =
    case tree of
        Leaf node ->
            case node of
                Generator audioNode ->
                    Debug.log "generator val" (audioNode.function time)
                _ ->
                    Debug.crash("Leaf must be a Generator")
        TreeNode {children, audioNode} ->
            case audioNode of
                FeedforwardProcessor props ->
                    List.map (getNextSample time) children
                    |> List.sum
                _ ->
                    Debug.crash("TreeNode must be a FeedforwardProcessor")





tests : Test
tests =
    suite "A Test Suite"
        [ test "printTreeNodes" (assertEqual True (printTreeNodes testTree2))
        , test "treeToList" (assertEqual ["node", "leaf"] (treeToList testTree2))
        , test "getNextSample" (assertEqual 1.3 (getNextSample 2340.432 testTree2))
        ]

main : Element
main =
    elementRunner tests
