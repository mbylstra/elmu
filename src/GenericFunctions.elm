add2Ints : Int -> Int -> Int
add2Ints a b = a + b


add3Ints : Int -> Int -> Int -> Int
add3Ints a b c = a + b + c


-- idea: a function that takes a list and either applies add2ints or add3Ints
-- depending on the lenght of the list


doSomething : Int -> Int -> a -> Int
doSomething i1 i2 func =
  func i1 i2
  -- 2
