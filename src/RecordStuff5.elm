
type alias InstrumentCommon =
  { id : Int
  , yearsOld : Int
  }

type InstrumentSpecific
  = Guitar { numStrings : Int }
  | Keyboard { numKeys : Int }
  | Tuba { numValves : Int }

type alias Instrument = (InstrumentSpecific, InstrumentCommon)

guitar1 : Instrument
guitar1 = (Guitar {numStrings = 12}, { id = 1, yearsOld = 50})

keyboard1 : Instrument
keyboard1 = (Keyboard {numKeys = 64}, { id = 2, yearsOld = 30})

getInstrumentId : Instrument -> Int
getInstrumentId instrument =
  case instrument of
    (_, commonData) -> commonData.id


incrementInstrumentAge' : Instrument -> Instrument
incrementInstrumentAge' (specificData, commonData) =
    (specificData, { commonData | yearsOld = commonData.yearsOld + 1 })

-- udpateInstrumentCommonData : Instrument -> Instrument

incrementAge : InstrumentCommon -> InstrumentCommon
incrementAge r =
  { r | yearsOld = r.yearsOld + 1 }

updateInstrumentCommonData : (InstrumentCommon -> InstrumentCommon) -> Instrument -> Instrument
updateInstrumentCommonData updateFunction (specific, common) =
  (specific, updateFunction common)

-- this function would have been a gnarly 3 Case statement function. Now it's a two liner.
incrementInstrumentAge : Instrument -> Instrument
incrementInstrumentAge instrument =
    updateInstrumentCommonData incrementAge instrument

getNumberOfFingerControls : Instrument -> Int
getNumberOfFingerControls (instrumentSpecific, _) =
  case instrumentSpecific of
    Guitar g ->
      g.numStrings
    Keyboard k ->
      k.numKeys
    Tuba t ->
      t.numValves


instrumentToString : Instrument -> String
instrumentToString (instrumentSpecific, common) =
  let
    commonString =
      "id: " ++ toString common.id ++ "\n years old: " ++ toString common.yearsOld
  in
    case instrumentSpecific of
      Guitar g ->
        "type: Guitar, " ++ commonString ++ "\nno. strings: " ++  (toString g.numStrings)
      Keyboard k ->
        "type: Keyboard, " ++ commonString ++ "\nno. keys: " ++  (toString k.numKeys)
      Tuba t ->
        "type: Tuba, " ++ commonString ++ "\nno. valves: " ++  (toString t.numValves)
