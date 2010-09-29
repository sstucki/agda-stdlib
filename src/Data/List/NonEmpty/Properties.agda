------------------------------------------------------------------------
-- Properties of non-empty lists
------------------------------------------------------------------------

{-# OPTIONS --universe-polymorphism #-}

module Data.List.NonEmpty.Properties where

open import Algebra
open import Category.Monad
open import Function
open import Data.Product
open import Data.List as List using (List; []; _∷_; _++_)
open RawMonad List.monad using () renaming (_>>=_ to _⋆>>=_)
private module LM {a} {A : Set a} = Monoid (List.monoid A)
open import Data.List.NonEmpty as List⁺
open RawMonad List⁺.monad
open import Relation.Binary.PropositionalEquality
open ≡-Reasoning

η : ∀ {ℓ} {A : Set ℓ} (xs : List⁺ A) → head xs ∷ tail xs ≡ List⁺.toList xs
η [ x ]    = refl
η (x ∷ xs) = refl

toList-fromList : ∀ {ℓ} {A : Set ℓ} x (xs : List A) →
                  x ∷ xs ≡ List⁺.toList (List⁺.fromList x xs)
toList-fromList x []       = refl
toList-fromList x (y ∷ xs) = cong (_∷_ x) (toList-fromList y xs)

toList-⁺++ : ∀ {ℓ} {A : Set ℓ} (xs : List⁺ A) ys →
             List⁺.toList xs ++ ys ≡
             List⁺.toList (xs ⁺++ ys)
toList-⁺++ [ x ]    ys = toList-fromList x ys
toList-⁺++ (x ∷ xs) ys = cong (_∷_ x) (toList-⁺++ xs ys)

toList-⁺++⁺ : ∀ {ℓ} {A : Set ℓ} (xs ys : List⁺ A) →
              List⁺.toList xs ++ List⁺.toList ys ≡
              List⁺.toList (xs ⁺++⁺ ys)
toList-⁺++⁺ [ x ]    ys = refl
toList-⁺++⁺ (x ∷ xs) ys = cong (_∷_ x) (toList-⁺++⁺ xs ys)

-- FIXME <dbrown> Can't make ℓ work here...
toList->>= : ∀ {A B} (f : A → List⁺ B) (xs : List⁺ A) →
             (List⁺.toList xs ⋆>>= List⁺.toList ∘ f) ≡
             (List⁺.toList (xs >>= f))
toList->>= f [ x ]    = proj₂ LM.identity _
toList->>= f (x ∷ xs) = begin
  List⁺.toList (f x) ++ (List⁺.toList xs ⋆>>= List⁺.toList ∘ f) ≡⟨ cong (_++_ (List⁺.toList (f x))) (toList->>= f xs) ⟩
  List⁺.toList (f x) ++ List⁺.toList (xs >>= f)                 ≡⟨ toList-⁺++⁺ (f x) (xs >>= f) ⟩
  List⁺.toList (f x ⁺++⁺ (xs >>= f))                            ∎
