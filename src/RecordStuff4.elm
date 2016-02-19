
type alias InstrumentBaseRecord r =
  { r |
    id : Int
  , yearsOld : Int
  }

type alias GuitarRecord = InstrumentBaseRecord { numStrings : Int }
type alias KeyboardRecord = InstrumentBaseRecord { numKeys : Int }
type alias TubaRecord = InstrumentBaseRecord { numValves : Int }

type Instrument
  = Guitar GuitarRecord
  | Keyboard KeyboardRecord
  | Tuba TubaRecord

guitarRecord1 : GuitarRecord
guitarRecord1 = { id = 1, yearsOld = 2, numStrings = 12}

guitar1 : Instrument
guitar1 = Guitar guitarRecord1

keyboardRecord1 : KeyboardRecord
keyboardRecord1 = { id = 2, yearsOld = 1, numKeys = 62 }

keyboard1 : Instrument
keyboard1 = Keyboard keyboardRecord1

getIdFromRecord : InstrumentBaseRecord r -> Int
getIdFromRecord r =
  r.id
-- this function is the same as the .id record accessor function

guitarId : Int
guitarId = getIdFromRecord guitarRecord1

keyboardId : Int
keyboardId = getIdFromRecord keyboardRecord1

-- this works, but is tedious to have to apply the
-- .id accessor to every union type.
getInstrumentId : Instrument -> Int
getInstrumentId instrument =
  case instrument of
    Guitar guitarRecord ->
      .id guitarRecord
    Keyboard keyboardRecord ->
      .id keyboardRecord
    Tuba tubaRecord ->
      .id tubaRecord


setInstrumentId : Int -> Instrument -> Instrument
setInstrumentId id instrument =
  case instrument of
    Guitar guitarRecord ->
      Guitar { guitarRecord | id = id }
    Keyboard keyboardRecord ->
      Keyboard { keyboardRecord | id = id }
    Tuba tubaRecord ->
      Tuba { tubaRecord | id = id }


incrementRecordAge : (InstrumentBaseRecord r -> InstrumentBaseRecord r)
incrementRecordAge record =
  { record | yearsOld = record.yearsOld + 1 }


incrementAge : Instrument -> Instrument
incrementAge instrument =
  case instrument of
    Guitar guitarRecord ->
      Guitar (incrementRecordAge guitarRecord)
    Keyboard keyboardRecord ->
      Keyboard (incrementRecordAge keyboardRecord)
    Tuba tubaRecord ->
      Tuba (incrementRecordAge tubaRecord)

updateInstrument : (InstrumentBaseRecord r -> InstrumentBaseRecord r) -> Instrument -> Instrument
updateInstrument updateFunction instrument =
  case instrument of
    Guitar guitarRecord ->
      let
        id = getIdFromRecord guitarRecord -- the getter works ok
        newRecord = incrementRecordAge guitarRecord -- the generic update function called directly works ok
        newRecord2 = updateFunction guitarRecord -- but you can't pass in an update function
      in
        Guitar guitarRecord
    _ ->
      Debug.crash ""
    -- Keyboard keyboardRecord ->
    --   Keyboard (updateFunction keyboardRecord)
    -- Tuba tubaRecord ->
    --   Tuba (updateFunction tubaRecord)


-- updateAge = updateInstrument updateRecordAge  -- done!
