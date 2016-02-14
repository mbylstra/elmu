type InstrumentType = Guitar | Keyboard

type alias Identifiable a = { a | id : Int, type' : InstrumentType }

type alias GuitarR = Identifiable { numStrings : Int }
type alias KeyboardR = Identifiable { numKeys : Int }

guitar1 : GuitarR
guitar1 = { id = 0, type' = Guitar, numStrings = 12}

keyboard1 : KeyboardR
keyboard1 = { id = 1, type' = Keyboard, numKeys = 62}


-- getId : Identifiable a -> Int
-- getId r =
--   r.id
--
-- getType : Identifiable a -> InstrumentType
-- getType r =
--   r.type'
--
-- guitarId : Int
-- guitarId = getId guitar1
--
-- keyboardType : InstrumentType
-- keyboardType  = getType keyboard1


-- you can't put different records in the one list! (That's even if you make it a list of a sub record)
-- On top of that there's a compiler error saying that the second element has the
-- same type as the first
-- I'm kind of glad this isn't a solution, as having a record property named type' is
 -- super ugly!!
instruments : List (Identifiable a)
-- instruments = [guitar1, keyboard1]
instruments = [guitar1, guitar1]
