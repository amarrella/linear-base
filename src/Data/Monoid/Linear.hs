{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DerivingVia #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE LinearTypes #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE StandaloneDeriving #-}

-- | This module provides linear versions of 'Monoid' and related classes.
--
-- To learn about how these classic monoids work, go to this school of haskell
-- [post](https://www.schoolofhaskell.com/user/mgsloan/monoids-tour).

module Data.Monoid.Linear
  ( -- * Monoids and related classes
    Semigroup(..)
  , Monoid(..)
  -- * Endo
  , Endo(..), appEndo
  , NonLinear(..)
  , All(All), getAll
  , Any(Any), getAny
  , Dual(Dual), getDual
  )
  where

import Prelude.Linear.Internal.Simple
import Data.Semigroup (All(All), Any(Any), Dual(Dual))

import GHC.Types hiding (Any)
import qualified Prelude

-- | A linear semigroup @a@ is a type with an associative binary operation @<>@
-- that linearly consumes two @a@s.
class Prelude.Semigroup a => Semigroup a where
  (<>) :: a #-> a #-> a

-- | A linear monoid is a linear semigroup with an identity on the binary
-- operation.
class (Semigroup a, Prelude.Monoid a) => Monoid a where
  {-# MINIMAL #-}
  mempty :: a
  mempty = Prelude.mempty
  -- convenience redefine

---------------
-- Instances --
---------------

instance Semigroup () where
  () <> () = ()

-- | An @Endo a@ is just a linear function of type @a #-> a@.
-- This has a classic monoid definition with 'id' and '(.)'.
newtype Endo a = Endo (a #-> a)
  deriving (Prelude.Semigroup) via NonLinear (Endo a)

-- TODO: have this as a newtype deconstructor once the right type can be
-- correctly inferred
-- | A linear application of an 'Endo'.
appEndo :: Endo a #-> a #-> a
appEndo (Endo f) = f

instance Semigroup (Endo a) where
  Endo f <> Endo g = Endo (f . g)
instance Prelude.Monoid (Endo a) where
  mempty = Endo id
instance Monoid (Endo a)

instance (Semigroup a, Semigroup b) => Semigroup (a,b) where
  (a,x) <> (b,y) = (a <> b, x <> y)
instance (Monoid a, Monoid b) => Monoid (a,b)

getDual :: Dual a #-> a
getDual (Dual a) = a

instance Semigroup a => Semigroup (Dual a) where
  Dual x <> Dual y = Dual (y <> x)
instance Monoid a => Monoid (Dual a)

getAll :: All #-> Bool
getAll (All a) = a

instance Semigroup All where
  All False <> All False = All False
  All False <> All True = All False
  All True  <> All False = All False
  All True  <> All True = All True

getAny :: Any #-> Bool
getAny (Any a) = a

instance Semigroup Any where
  Any False <> Any False = Any False
  Any False <> Any True = Any True
  Any True  <> Any False = Any True
  Any True  <> Any True = Any True

-- | DerivingVia combinator for Prelude.Semigroup given (linear) Semigroup.
-- For linear monoids, you should supply a Prelude.Monoid instance and either
-- declare an empty Monoid instance, or use DeriveAnyClass. For example:
--
-- > newtype Endo a = Endo (a #-> a)
-- >   deriving (Prelude.Semigroup) via NonLinear (Endo a)
newtype NonLinear a = NonLinear a

instance Semigroup a => Prelude.Semigroup (NonLinear a) where
  NonLinear a <> NonLinear b = NonLinear (a <> b)
