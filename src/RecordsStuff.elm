type alias ExampleRecord = { alpha : Int, beta : Int, gamma : Int }

widthAccessor : { a | width : Int} -> Int
widthAccessor = .width

accessors : List ({ a | alpha : Int, beta : Int, gamma : Int } -> Int)
accessors = [.alpha, .beta, .gamma]

example : ExampleRecord
example = {alpha=0, beta=0, gamma=0}


sumOfExample : Int
sumOfExample = List.foldl (\accessor total -> total + (accessor example)) 0 accessors

-- vs

sensibleSumOfExample : Int
sensibleSumOfExample = (.alpha example) + (.beta example) + (.gamma example)



-- what's the most concise way to update a record field?

recordB1 = { a = 1, b = 2, c = 3}

-- say we want to update a, this is the only way
recordB2 = { recordB1 | a = 2 }
--

recordB3 = { recordB1 | a = 2, b = 2 }  -- if we want to do more than one at a time


updateA transformFunc record =
  { record | a = (transformFunc record.a) }


-- there's no way to automatically generate this stuff. It must be hand typed!
-- would be great if you dynamically generate a list of field to update, with their
-- values2




-- List.foldl
-- List.foldl






-- applyAccessor
-- applyAccessor accessor record =
--   accessor record

-- x = List.map (\accessor ->
