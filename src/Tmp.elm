import String as String' exposing (..)

type A = A

funky : A -> Bool
funky x = True


-- b = True == funky A


-- What I've realised:
--  Type constructors can be the same name as types, because types
--  are never used in definitions, and type constructors are never
-- used in declarations. Makes sense!

-- How does destructuring work?

type BrazilFlagColour = Yellow | Blue

type Numeric = Int Int | Float Float -- wow, you can actually do this!

adder : Numeric -> Numeric
adder a =
  case a of
    Int a' -> Float (Basics.toFloat a')
    _ -> Float 0.0


-- type constructor destructuring

type SingleIntType = SingleIntTypeConstructor Int

destructuring : SingleIntType -> Int
destructuring (SingleIntTypeConstructor n) = n




-- This won't work. If yo have a type variable, you *must* provide a
--   constructor for it
-- type NoConstructor a = a

-- This will work:
type Something = Whatever
-- but you can't pass a type to it!
