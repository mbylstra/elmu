
type alias BaseRecord a = { a | alpha : Int }

type alias ChildRecord1 = BaseRecord { beta : Int }
type alias ChildRecord2 = BaseRecord { gamma : Int }

childRecord1 : ChildRecord1
childRecord1 = { alpha = 1, beta = 1 }

childRecord2 : ChildRecord2
childRecord2 = { alpha = 1, gamma = 1 }

-- getAlpha : { a | alpha : Int} -> Int
-- getAlpha r =
--   r.alpha

getAlpha : BaseRecord a -> Int
getAlpha r =
  r.alpha

x : Int
x = getAlpha childRecord1

y : Int
y = getAlpha childRecord2

type OneOrTwo
  = One ChildRecord1
  | Two ChildRecord2

example : OneOrTwo
example = One { alpha = 1, beta = 1}

getRecord : OneOrTwo -> BaseRecord a
getRecord oneOrTwo =
  case oneOrTwo of
    One r -> r
    -- Two r -> r
    _ -> Debug.crash("")
