import Array exposing (Array)

-- mixer is a function that takes

-- graph =
--     [ ( mixer
--       , { a = (sine, { frequency = mix lfo actuallNote})
--         , b = (square, { frequency = mix lfo actuallNote})
--         }
--       )
--     , (mixer, mainOutput)
--     ]




-- modules are just functions that take inputs (best if they are named using records)
-- and return a result


-- some functions need to know the time of course. This is probably best
-- as the number of microseconds since the app begun. Amplify doesn't care.


amplify : Float -> Float -> Float
amplify multiplier value  =
    multiplier * value

-- shapeWave : Float -> WaveShaperCurve -> Float


-- currying works brilliantly for this!


-- source1Filtered = source1 |> lowPassFilter
-- source2Distorted = source2 |> waveShaper
-- source3Panned = source |> pan
-- destination = mix [source1Filtered, Source2Distorted, source3Panned]


-- dryOutput =
--     mix [ source1 |> lowPassFilter, source2 |> waveShaper, source3 |> pan ]

-- destination =
--     mix [ dryOutput |> dryGain, dryOutput |> convolutionReverb |> wetGain]
--     |> dynamicsCompressor

-- But I think



-- drySignal = mix3 source1Filtered

-- graph =
--     [
--     , (source1 |> lowPassFilter, ?)
--     , (source2 |> waveshaperDistortion, ?)
--     , (source3 |> panner, ?)
--     ]

-- source1
--     low pass filter
-- source2
--     waveshaper distortion
-- source3
--     panner

-- mix source1 source2 source3

-- put gain on those two endpoint
-- out reverb behind
-- mix the two outputs

-- compress


-- delays are where it gets pretty interesting
--    they totally need memory... (state?)22

pushRotateBuffer value buffer =
    Array.push value buffer
    |> Array.slice 1 ((Array.length buffer) + 1)
--     |> Array.slice 1 (Array.length buffer)


delay : Float -> Array Float -> Array Float
delay value buffer =
    pushRotateBuffer value buffer


tmp = delay 1.1 (Array.fromList [0.0, 0.0, 0.0])
    |> delay 2.2
    |> delay 3.3
    |> delay 4.4
    |> delay 5.5


-- no input mixer graph


mixer1node =
    { id = "mixer1"
      type' = "mixer"
      inputA = sin  -- this is an anonymous signal. name is automatically generated
      inputA = "mixer1" --named node is required for feedback, because recursive records not possible
    }

graph =
    [ (
    , (

    ]



 -- this would work, but a bit boilerplatey?
nodes =
    [ { id = "sin1"
      , func = sin
      , output = "mixer1.a"
      }
    , { id = "mixer1"
      , func = mix
      , output = "splitter"
      , inputNames = ["a", "b"]
      }
    , { id = "splitter"
      , func = splitter
      , outputA = "mainOutput"
      , outputB = "mixer1"
      }
    ]
-- with a little less boilerplate
nodes =
    [ sin "sin1" "mixer1.a"
    , mixer "mixer1" "splitter"
    , splitter
        { id = "splitter1"
        , outputA = "mainOutput"
        , outputB = "mixer1.b"
        }
    ]

-- perhaps manual id's are only necessary if you need a reference, so could do this:
nodes =
    [ sin "mixer1.a"
    , mixer "mixer1" "splitter"
    , splitter
        { outputA = "mainOutput"
        , outputB = "mixer1.b"
        }
    ]
-- But then you need ugly union types to actually do that :(


-- so what about chaining then? Example is sine |> delay |> phaser |> eq


nodes =
    [ { id = "sin1"
      , func = sin
      , output =
        { id = "delay"
        , func = delay
        , output =
          { id = "phaser"
          , func = "phaser"
          , output = "mixer1.a"
          }
        }
      }
    , { id = "mixer1"
      , func = mix
      , output = "splitter"
      , inputNames = ["a", "b"]
      }
    , { id = "splitter"
      , func = splitter
      , outputA = "mainOutput"
      , outputB = "mixer1"
      }
    ]


 -- using helper functions:


nodes =
    [ sin |> delay |> phaser "mixer1.a"
    , mixer "mixer1" "splitter"
    , splitter
        { outputA = "mainOutput"
        , outputB = "mixer1.b"
        }
    ]

-- hmm, not sure how that's actually possible!
-- perhaps a chain function?

nodes =
    [ chain [sin, delay, phaser] "mixer1.a"
    , mixer "mixer1" "splitter"
    , splitter
        { outputA = "mainOutput"
        , outputB = "mixer1.b"
        }
    ]

-- still, needs a lot of union types n shit!

-- how to deal with default ids:

type alias AutoID = Nothing
type alias ID = Just

nodes =
    [ chain [sin AutoID, delay AutoID, phaser AutoID] "mixer1.a"
    , mixer (ID "mixer1") "splitter"
    , splitter
        { outputA = "mainOutput"
        , outputB = "mixer1.b"
        }
    ]

-- why not just use records for named arguments?
----- because then you have to use records AND union types! It gets pretty verbose:

mixer {id=ID "mixer", output="mixer1.b"}

-- same with union types
mixer (ID "mixer") (Output "mixer1.b")
-- as you can see it's slightly shorter, mostly because the union type is needed

-- if the union type wasn't needed:1.b"}
mixer {id="mixer", output="mixer1.b"}  -- it's short again! And looks more like algol


-- some functions need to maintain state, therefor they must both take their state as in input, and output that state, as well as the output

-- some functions have multiple outputs (with different values), a crossfader is a good example
-- perhaps we can have statefulFunctions (delay, eq) and statelessFunctions (amplifier)
-- wiring this up should be fairly straightforward, as we have this big state tree and id's for each node, so
-- fairly easy to look up a value

-- Elm Signals?
-- perhaps we just have a few set signals (the ones you would actually need)
-- eg:
----- midi note
-- hmm, we need ones every time a new control is created right?
-- let's not worry about controls for now :)

-- Also need to think about how we handle gates/triggers
--  I suppose this would be part of the "Action"
----- So, the action would be either Nothing, or Retrigger
------- Also to distinguish between continously frequencies and "note on" events
---------- They are quite different things: hitting a marimba vs a sliding trombone sound


-- attempt at ports:

function logger(x) { console.log(x) }
elm.ports.bufferFilled.subscribe(function(data) {
});

scriptNode.onaudioprocess = function(audioProcessingEvent) {
  elm.ports.bufferRequest.send(true);   //we don't care about input data, so just send true as notification to generate more data
  //somehow here we wait for the next buffer function to be called!
}

