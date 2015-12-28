

testGraph =
    [ Generator
        { id = "squareA"
        , function = squareWave
        , state =
            { processed = False, outputValue = 0.0  }
        }
    , Destination
        { id = "destinationA"
        , input = ID "squareA"
        , state =
            { processed = False, outputValue = 0.0 }
        }
    ]



sin phase phaseOffset frequency =
    Math.sin



-- A

testGraph =
    [ Generator
        { id = "sin"
        , function = sin
        , inputs =
            [ ("frequency", "lfo1")
            , ("phase", "sin2")
            ]
        , state =
            { processed = False, outputValue = 0.0  }
        }
    ]


-- problem is that you need some way to map from the Dict to the actual arguments,
-- as there is no way to introspect functions. In this case, positional arguments
-- might be necessary. Luckily all args to signal functions are floats, so you
-- could just map each arg as an arg to the function. The positionalness really
-- sucks though. Do we want to make it easy for Node writers or node users? This
-- makes it easy for Node users, but annoying for writers.



testGraph =
    [ Generator
        { id = "sin"
        , function = sin
        , inputs =
            { frequency = "lfo1"
            , phase = "sin2"
            }
        , state =
            { processed = False, outputValue = 0.0  }
        }
    ]

-- this is not actually possible - it means all Generator's must take
-- frequency and phase as an argument.


testGraph =
    [ Sin
        { id = "sin"
        , function = sin
        , inputs =
            { frequency = "lfo1"
            , phase = "sin2"
            }
        , state =
            { processed = False, outputValue = 0.0 }
        }
    ]

-- This would be more like a "Contract" for a sin function. This could
-- easily be generalised to Oscillator.
-- I think this pattern breaks down when you want to add custom inputs, such
-- as pulse width.
-- Perhaps extensible records works for this?
-- The bigger problem is that Orchestrator needs to now in advance all possible
-- union types for any made up module. How can it know?
    -- is this possible at all? Does Elm stink a bit?

-- what are the goals?
--   wiring should be simple
--   writing node functions should be simple
--       simple if you get a record for the args
--            but this would remove curry potential.
--                I guess this is the big curry tradeoff? Hard to read, but power abstraction is possible (is it worth it?)
--   everything else can be provided by the library


-- EXECUTIVE DECISION:

--  let's go with an array for inputs. We can get something happening, then test basic FM synthesis.
--  and see if it's even possible to get more than 1 osciallator at the same time!
-- It's not that bad if AudioNode writers provide helper functions that take records. EG:
-- MEGA DOH! You still need an exact type def for the actual function definition.
-- So, new executive decision: Provide contracts for all collections of inputs. We'll have
-- to work out how to make new Node types later :(
--     perhaps functions must take dicts then?? How else can you let users supply their own nodes?
--        OR, for any custom signature, that's where you have to use dicts (the usual cases have pre-defined type signatures), and it's good enough for now
--    seems like you need to choose full type safety (but hardcode every interface into core) or no type safety with really annoying API. OR, you have
--        to manually implement some kind of type checker manually.


sin : ID -> {frequency: Input, phase: Input}
sin id {frequency, phase} =
     -- ////

usage:

testGraph =
    [ sin "carrier1" {frequency = ID "lfo1", phase = ID "carrier2"}
