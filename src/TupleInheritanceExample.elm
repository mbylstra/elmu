
type alias InstrumentCommon =
  { id : Int
  , yearsOld : Int
  }

type Instrument
  = Guitar (InstrumentCommon, { numStrings : Int })
  | Keyboard (InstrumentCommon, { numKeys : Int })
  | Tuba (InstrumentCommon, { numValves : Int })

guitar1 : Instrument
guitar1 = Guitar ({ id = 1, yearsOld = 50}, {numStrings = 12})

keyboard1 : Instrument
keyboard1 = Keyboard ({ id = 2, yearsOld = 30}, {numKeys = 64})





getInstrumentCommon : Instrument -> InstrumentCommon
getInstrumentCommon instrument =
  case instrument of
    Guitar (c, _) -> c
    Keyboard (c, _) -> c
    Tuba (c, _) -> c

getInstrumentId : Instrument -> Int
getInstrumentId instrument =
  .id (getInstrumentCommon instrument)


-- This would be definined in a module that contains only instruments.
-- and could be called like this:
-- Instrument.mapCommonData .id guitar1
mapCommon : (InstrumentCommon -> b) -> Instrument -> a
mapCommon func instrument =
  case instrument of
    Guitar (common, _) -> func common
    Keyboard (common, _) -> func common
    Tuba (common, _) -> func common

guitar1id : Int
guitar1id = mapCommon .id guitar1 -- no need to define a function for each property, just pass the accessor funcion (such as .id) to mapCommon

updateInstrumentCommon : (InstrumentCommon -> InstrumentCommon) -> Instrument -> Instrument
updateInstrumentCommon updateFunc instrument =
  case instrument of
    Guitar (common, specific) -> Guitar (updateFunc common, specific)
    Keyboard (common, specific) -> Keyboard (updateFunc common, specific)
    Tuba (common, specific) -> Tuba (updateFunc common, specific)



incrementInstrumentAge : Instrument -> Instrument
incrementInstrumentAge instrument =
  updateInstrumentCommon
    (\common -> {common | yearsOld = common.yearsOld + 1})
    instrument

getNumberOfFingerControls : Instrument -> Int
getNumberOfFingerControls instrument =
  case instrument of
    Guitar (_, g) ->
      g.numStrings
    Keyboard (_, k) ->
      k.numKeys
    Tuba (_, t) ->
      t.numValves

instrumentToString : Instrument -> String
instrumentToString instrument =
  let
    commonString common =
      "id: " ++ toString common.id
      ++ "\n years old: " ++ toString common.yearsOld
  in
    case instrument of
      Guitar (common, g) ->
        "type: Guitar, " ++ commonString common ++ "\nno. strings: " ++  (toString g.numStrings)
      Keyboard (common, k) ->
        "type: Keyboard, " ++ commonString common ++ "\nno. keys: " ++  (toString k.numKeys)
      Tuba (common, t) ->
        "type: Tuba, " ++ commonString common ++ "\nno. valves: " ++  (toString t.numValves)
