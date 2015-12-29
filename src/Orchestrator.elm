module Orchestrator where

--------------------------------------------------------------------------------
-- EXTERNAL DEPENDENCIES
--------------------------------------------------------------------------------

import Dict exposing (Dict)
import ElmTest exposing (..)


--------------------------------------------------------------------------------
-- INTERNAL DEPENDENCIES
--------------------------------------------------------------------------------

import AudioNodes exposing
    ( squareWave
    , simpleLowPassFilter
    , sawWave
    , OscillatorType(Square, Saw, Triangle)
    , oscillator
    , sinWave
    , OscillatorF
    , gain
    , GainF
    )


--------------------------------------------------------------------------------
-- TYPE DEFINITIONS
--------------------------------------------------------------------------------

type Input = ID String | Value Float | Default   -- or it could be an AudioNode! Maybe?
    -- We could also consider conveniences like whether the unit is in hz, dbs, amps, or a "note" like C3
    -- eg: type NoteValue = A0 | B0 | C0 | D0 | E0 | F0 | G0 | A1 | A2 | etc
    -- eg : type Input = Note NoteValue | MidiNote Int |
    -- consider making ID NodeID instead, or just Node

type AudioNode =
    Oscillator
        { id : String
        , function : OscillatorF
        , inputs: OscillatorInputs
        , state :
            { phase: Float
            , outputValue : Float -- do we really need this? Is it just for feedback? Doesn't really hurt to keep as we need inputs anyway.
            }
        }
    | Gain
        { id : String
        , function : GainF
        , inputs: {signal: Input, gain: Input}
        , state :
            { outputValue : Float -- do we really need this? Is it just for feedback? Doesn't really hurt to keep as we need inputs anyway.
            }
        }
    | FeedforwardProcessor
        { id : String
        , input : Input
        , function : FeedforwardProcessorF -- this is the "update"
        , state :  -- this is the "model"
            { outputValue : Float
            , prevValues : List Float
            }
        }
    | Add
        { id : String
        , inputs : List Input
        , state :
            { outputValue : Float
            }
        }
    | Destination
        { id : String
        , input: Input
        , state :
            { outputValue : Float
            }
        }


-- an insteresting idea is explicitly putting in a delay, whenever you want feedback.
-- would this make inline functions possible??
--     Yeah, but it puts some responsiblity on the developer to avoid infinite loops.
--        - Seeing as it's a rare thing, it's ok for dev to know about it
--        - might  make Orchestrator a little more efficient, as it doesn't need to look for loops
--        - but crashes are pretty gross, and I don't think there's a way to avoid it.
--
--     could be interesting modulating the size of this feedback.. Is this how no input mixer works??



-- so are there any benefits to this "central state" architecture?
--     time travel debugging!!! FTW FUCK YEAH!!!
--            So cool... you play a sequence on a midi keyboard, then you can
--            tweak params, and hear the difference!! FUCKING AWESOME!!!
--                OK cool, but unless you made some music spefici TTDB interface, it would be kind of crappy?
--                And don't you just want to keep midi and controller events anyway? in which case
--                You could make specific software for this (just store events in local storate, and replay them), to achieve the same effect.
--                     Yeah, but the point is with TTDB, is that this state is always available to the TTDB. Otherwsie, you have to get the
--                     library author to expose the internal state. Eg: someone makes a nice knob widget. Unless the internal state is exposed,
--                    it makes it impossible (?) to replay the actions.
--                         still, is it that different from VST automation?
--                              I guess the difference is that VST might have internal state, and only exposed controls can be automated.
--                                  Is this not a good thing?? You only want to expose the user to meaningful controls. Some state might
--                                  be just to do with animation. Would be silly to expose that to the user - and if the TTDB has too much shit,
--                                  it's as good as worthless.

-- looking at Euterpea, I wonder if a big limitation with this (That maybe you get with Arrows), is that
--     you can't compose nodes with code, you can only do it with the clunky Dict Graph. Modularity is pretty screwed.
--     It's like it's fine with really basic examples, but can we think of more complex examples?
--        What do we need for a full dx27 emulation?
--            - four osciallators that can feedback into each other. TICK
--            - LFO, AM. Easy. Tick.
--            - Envelopes.. needs design decision on this one, but probably like FIlters in that they need state.

-- Triggers & Envelopes
-- -----------------------
-- We need to be able to do envelopes.
-- They could be potentially be triggered by signal processing (not necessarily GUI events)
-- An example would be a pulse signal. Whenever the signal is 1, re-trigger.
-- Envelopes need state:
--  At what stage is it at?
-- Most basic example is a sound that plays for 100 samples, then turns off.
--    So it's in two states. NOTE ON (counter) and NOTE OFF. When it's nNOTE OFF, just return 0,
--   When it's NOTE ON, output 1 and decrement the counter. How do we generalize this stuff?
--       you don't really need the union types. Can do, if counter = 0, output = 0, else output 1 and decrement counter.
--        Somehow the thing needs to listen for NOTE ON events. This could just be a pulse signal (makes sense).
--
--
-- Second most basic example is a ramp envelope.
--   same as first example but output is a fraction of the counter
-- Ideas:
--
--
--
--
-- square frequencyInputFunc time =

-- s1 = square (delay 1 square) 0.0   -- hmm, I guess it *is* possible then??
    -- BIG BUT: you must pass the dealy state to delay! (so the orchestrator really needs to manage this)


-- Update functions
type alias ProcessorF = TimeFloat -> ValueFloat -> ValueFloat
type alias FeedforwardProcessorF = Float -> List ValueFloat -> ValueFloat


type alias OscillatorInputs =
    { frequency : Input
    , frequencyOffset : Input
    , phaseOffset : Input
    }

-- aliases for readability
type alias ValueFloat = Float
type alias TimeFloat = Float
type alias ListGraph = List AudioNode
type alias DictGraph = Dict String AudioNode



--------------------------------------------------------------------------------
-- MAIN
--------------------------------------------------------------------------------


updateGraph graph time =
{-     let
        _ = Debug.log "time" time
    in -}
    updateGraphNode graph time (getDestinationNode graph)

{- updateGraph graph time =
    (graph, time) -}


{- this naming is pretty gross! Difference is it takes an Input rather than an AudioNode -}
updateGraphNode' : DictGraph -> TimeFloat -> Input -> (DictGraph, Float)
updateGraphNode' graph time input =
    case input of
        ID id ->
            updateGraphNode graph time (getInputNode graph id)
        Value v ->
            (graph, v)
        Default ->
            (graph, 0.0) -- need to work out how to send defaults around


updateGraphNode : DictGraph -> TimeFloat -> AudioNode -> (DictGraph, Float)
updateGraphNode graph time node =

    case node of

        -- this requires a lot of rework to support inputs!
        -- it will be much easier with an actuall record for inputs
        Oscillator props ->
            let
                -- phaseOffsetInput = props.inputs.phaseOffsetInput (just ignore this one for now)

--                 frequencyInputNode = getInputNode graph frequencyInput
                    -- this should be abstracted into a function that just gets the value and updates the graph at the same time (regardless of input type etc)
--                 _ = Debug.log "------------------------" True
                (graph2, frequencyValue) = updateGraphNode' graph time props.inputs.frequency
                (graph3, frequencyOffsetValue) = updateGraphNode' graph2 time props.inputs.frequencyOffset
                (graph4, phaseOffsetValue) = updateGraphNode' graph3 time props.inputs.phaseOffset
--                 _ = Debug.log "phaseOffsetValue" phaseOffsetValue
                (newValue, newPhase) = props.function frequencyValue frequencyOffsetValue phaseOffsetValue props.state.phase -- this function should start accepting frequency
{-                 _ = Debug.log "newValue" newValue
                _ = Debug.log "newPhase" newPhase -}
                newState = {outputValue = newValue, phase = newPhase}
                newNode = Oscillator { props | state = newState }

{-                 _ = Debug.log "time" time
                _ = Debug.log "frequencyInputValue" frequencyInputValue
                _ = Debug.log "newValue" newValue -}

            in
                (replaceGraphNode newNode graph3, newValue)

        FeedforwardProcessor props ->
            case getInputNodes node graph of
                Just [inputNode] ->
                    let
                        (newGraph, inputValue) = updateGraphNode graph time inputNode
                        newValue = props.function inputValue props.state.prevValues
                        newPrevValues = rotateList props.state.outputValue props.state.prevValues
                        newState = {outputValue = newValue, prevValues = newPrevValues }
                        newNode = FeedforwardProcessor { props | state = newState }
                    in
                        (replaceGraphNode newNode newGraph, newValue)
                Just inputNodes ->
                    Debug.crash("multiple inputs not supported yet")
                Nothing ->
                    Debug.crash("no input nodes!")

        Destination props ->
            case getInputNodes node graph of
                Just [inputNode] ->
                    let
                        (newGraph, inputValue) = updateGraphNode graph time inputNode
                        newState = { outputValue = inputValue }
                        newNode =  Destination { props | state = newState }
                    in
                        (replaceGraphNode newNode newGraph, inputValue)
                Just inputNodes ->
                    Debug.crash("multiple inputs not supported yet")
                Nothing ->
                    Debug.crash("no input nodes!")

        Add props ->
            let
                updateFunc input (graph, accValue) =
                    let
                        (newGraph, inputValue) = updateGraphNode' graph time input
                    in
                        (replaceGraphNode newNode newGraph, accValue + inputValue)

                (newGraph, newValue) = List.foldl updateFunc (graph, 0) props.inputs
                newState = { outputValue = newValue }
                newNode = Add { props | state = newState }
            in
                (replaceGraphNode newNode newGraph, newValue)

        Gain props ->
            let
                -- phaseOffsetInput = props.inputs.phaseOffsetInput (just ignore this one for now)

--                 frequencyInputNode = getInputNode graph frequencyInput
                    -- this should be abstracted into a function that just gets the value and updates the graph at the same time (regardless of input type etc)
--                 _ = Debug.log "------------------------" True
                (graph2, signalValue) = updateGraphNode' graph time props.inputs.signal
                (graph3, gainValue) = updateGraphNode' graph2 time props.inputs.gain
--                 _ = Debug.log "phaseOffsetValue" phaseOffsetValue
                newValue = props.function signalValue gainValue -- this function should start accepting frequency
{-                 _ = Debug.log "newValue" newValue
                _ = Debug.log "newPhase" newPhase -}
                newState = {outputValue = newValue}
                newNode = Gain { props | state = newState }

{-                 _ = Debug.log "time" time
                _ = Debug.log "frequencyInputValue" frequencyInputValue
                _ = Debug.log "newValue" newValue -}

            in
                (replaceGraphNode newNode graph3, newValue)

getInputNode : DictGraph -> String -> AudioNode
getInputNode graph id =
    case (Dict.get id graph) of
        Just node -> node
        Nothing -> Debug.crash("Can't find node: " ++ (toString id))

getInputNode' : DictGraph -> Input -> AudioNode
getInputNode' graph input =
    case input of
        ID id ->
            getInputNode graph id
        Value _ ->
            Debug.crash("see getInputNodes")
        Default ->
            Debug.crash("see getInputNodes")




getInputNodes : AudioNode -> DictGraph -> Maybe (List AudioNode)
getInputNodes node graph =
    let
        getInputNodes' : List Input -> List AudioNode
        getInputNodes' inputs =
            List.map (getInputNode' graph)  inputs
    in
        case node of
            FeedforwardProcessor props ->
                Just [getInputNode' graph props.input]
            Destination props ->
                Just [getInputNode' graph props.input]
            _ ->
                Nothing


-- let's just do this inline


{- updateNodeState : AudioNode -> Float -> AudioNode
updateNodeState node newValue =
    case node of
        Oscillator props ->
            let
                oldState = props.state
                newState = { oldState | outputValue = newValue }
            in
                Oscillator  { props | state = newState }

        Add props ->
            let
                oldState = props.state
                newState = { oldState | outputValue = newValue }
            in
                Add { props | state = newState }

        FeedforwardProcessor props ->
            let
                oldState = props.state
                newPrevValues = rotateList props.state.outputValue props.state.prevValues
                newState =
                    { oldState |
                      outputValue = newValue
                    , prevValues = newPrevValues
                    }
--                 _ = Debug.log "newState" newState
            in
                FeedforwardProcessor { props | state = newState }

        Destination props ->
            let
                oldState = props.state
                newState = { oldState | outputValue = newValue }
            in
                Destination { props | state = newState } -}


toDict : ListGraph -> DictGraph
toDict listGraph =
    let
        createTuple node =
            case node of
                Destination props ->
                    (props.id, node)
                Oscillator props ->
                    (props.id, node)
                FeedforwardProcessor props ->
                    (props.id, node)
                Add props ->
                    (props.id, node)
                Gain props ->
                    (props.id, node)
        tuples = List.map createTuple listGraph
    in
        Dict.fromList tuples


getDestinationNode : DictGraph -> AudioNode
getDestinationNode graph =
    let
        nodes = Dict.values graph
        isDestinationNode node =
            case node of
                Destination _ ->
                    True
                _ ->
                    False
        destinationNodes = List.filter isDestinationNode nodes
    in
        case List.head destinationNodes of
            Just node
                -> node
            _
                -> Debug.crash("There aren't any nodes of type Destination!")


replaceGraphNode : AudioNode -> DictGraph -> DictGraph
replaceGraphNode node graph =
    Dict.insert (getNodeId node) node graph


getNodeId : AudioNode -> String
getNodeId node =
    case node of
        Destination props -> props.id
        Oscillator props -> props.id
        FeedforwardProcessor props -> props.id
        Add props -> props.id
        Gain props -> props.id



-- rotateArray : Array -> Array

--------------------------------------------------------------------------------
-- TESTS
--------------------------------------------------------------------------------

-- A

squareA =
    Oscillator
        { id = "squareA"
        , function = sinWave
        , inputs = { frequency = Value 440.0, phaseOffset = Default, frequencyOffset = Default }
        , state =
            { outputValue = 0.0, phase = 0.0  }
        }

destinationA =
    Destination
        { id = "destinationA"
        , input = ID "squareA"
        , state =
            { outputValue = 0.0 }
        }

squareAT1 =
    Oscillator
        { id = "squareA"
        , inputs = { frequency = Value 440.0, phaseOffset = Default, frequencyOffset = Default }
        , function = sinWave
        , state =
            { outputValue = 1.0, phase = 0.0  }
        }

destinationAT1 =
    Destination
        { id = "destinationA"
        , input = ID "squareA"
        , state =
            { outputValue = 1.0 }
        }

testGraph : ListGraph
testGraph =
    [ squareA
    , destinationA
    ]

testDictGraph : DictGraph
testDictGraph = toDict testGraph

-- B

{- squareB =
    Oscillator
        { id = "squareB"
        , function = sinWave
        , inputs = [Value 440.0, Default]
        , state =
            { outputValue = 0.0  }
        }


lowpassB =
    FeedforwardProcessor
        { id = "lowpassB"
        , input = ID "squareB"
        , function = simpleLowPassFilter
        , state =
            { outputValue = 0.0
            , prevValues = [0.0, 0.0, 0.0]
            }
        }

destinationB =
    Destination
        { id = "destinationB"
        , input = ID "lowpassB"
        , state =
            { outputValue = 0.0 }
        }

{- squareAT1 =
    Oscillator
        { id = "squareA"
        , function = squareWave
        , state =
            { outputValue = Just 1.0  }
        }

destinationAT1 =
    Destination
        { id = "destinationA"
        , input = ID "squareA"
        , state =
            { outputValue = Just 1.0 }
        } -}

testGraphB : ListGraph
testGraphB =
    [ squareB
    , lowpassB
    , destinationB
    ]

testDictGraphB = toDict testGraphB -}




feetless : List a -> List a
feetless list =
    List.take ((List.length list) - 1) list


rotateList : a -> List a -> List a
rotateList value list  =
  [value] ++ feetless list

tests : Test
tests =
    suite "A Test Suite"
        [
{-           test "getInputNodes"
            (assertEqual
                (Just [squareA])
                (getInputNodes  destinationA testDictGraph)
            )
        , test "getInputNodes"
            (assertEqual
                Nothing
                (getInputNodes squareA testDictGraph)
            )
        , test "getNextSample"
            (assertEqual
                (toDict [squareAT1, destinationAT1], 1.0)
                (updateGraph testDictGraph 0.0)
            ) -}
          test "rotateList"
            (assertEqual
                [4, 3, 2]
                (rotateList 4 [3, 2, 1])
            )
{-         , test "getNextSample"
            (assertEqual
                (toDict [squareAT1, destinationAT1], 1.0)
                (updateGraph testDictGraphB 0.0)
            ) -}
        ]


{- (Dict.fromList
    [ ("destination", Destination
        { id = "destination"
        , input = ID "square1"
        , state = { outputValue = Nothing }
        }
       )
    , ( "square1", Generator
        { id = "square1",
        , $function = <function>,
        , state = { outputValue = Just -1 }
        }
        )
    ]
    , -1
) -}

main =
    elementRunner tests
