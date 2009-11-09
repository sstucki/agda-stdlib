------------------------------------------------------------------------
-- Morphisms between algebraic structures
------------------------------------------------------------------------

module Algebra.Morphism where

open import Relation.Binary
open import Algebra
open import Algebra.FunctionProperties
import Algebra.Props.Group as GroupP
open import Data.Function
open import Data.Product
import Relation.Binary.EqReasoning as EqR

------------------------------------------------------------------------
-- Basic definitions

module Definitions (From To : Set) (_≈_ : Rel To) where
  Morphism : Set
  Morphism = From → To

  Homomorphic₀ : Morphism → From → To → Set
  Homomorphic₀ ⟦_⟧ ∙ ∘ = ⟦ ∙ ⟧ ≈ ∘

  Homomorphic₁ : Morphism → Fun₁ From → Op₁ To → Set
  Homomorphic₁ ⟦_⟧ ∙_ ∘_ = ∀ x → ⟦ ∙ x ⟧ ≈ ∘ ⟦ x ⟧

  Homomorphic₂ : Morphism → Fun₂ From → Op₂ To → Set
  Homomorphic₂ ⟦_⟧ _∙_ _∘_ =
    ∀ x y → ⟦ x ∙ y ⟧ ≈ (⟦ x ⟧ ∘ ⟦ y ⟧)

------------------------------------------------------------------------
-- An example showing how a morphism type can be defined

-- Ring homomorphisms.

record _-Ring⟶_ (From To : Ring) : Set where
  private
    module F = Ring From
    module T = Ring To
  open Definitions F.carrier T.carrier T._≈_

  field
    ⟦_⟧       : Morphism
    ⟦⟧-pres-≈ : ⟦_⟧ Preserves F._≈_ ⟶ T._≈_
    +-homo    : Homomorphic₂ ⟦_⟧ F._+_ T._+_
    *-homo    : Homomorphic₂ ⟦_⟧ F._*_ T._*_
    1-homo    : Homomorphic₀ ⟦_⟧ F.1#  T.1#

  open EqR T.setoid

  0-homo : Homomorphic₀ ⟦_⟧ F.0# T.0#
  0-homo =
    GroupP.left-identity-unique T.+-group ⟦ F.0# ⟧ ⟦ F.0# ⟧ (begin
      T._+_ ⟦ F.0# ⟧ ⟦ F.0# ⟧ ≈⟨ T.sym (+-homo F.0# F.0#) ⟩
      ⟦ F._+_ F.0# F.0# ⟧     ≈⟨ ⟦⟧-pres-≈ (proj₁ F.+-identity F.0#) ⟩
      ⟦ F.0# ⟧                ∎)

  -‿homo : Homomorphic₁ ⟦_⟧ F.-_ T.-_
  -‿homo x =
    GroupP.left-inverse-unique T.+-group ⟦ F.-_ x ⟧ ⟦ x ⟧ (begin
      T._+_ ⟦ F.-_ x ⟧ ⟦ x ⟧ ≈⟨ T.sym (+-homo (F.-_ x) x) ⟩
      ⟦ F._+_ (F.-_ x) x ⟧   ≈⟨ ⟦⟧-pres-≈ (proj₁ F.-‿inverse x) ⟩
      ⟦ F.0# ⟧               ≈⟨ 0-homo ⟩
      T.0#                   ∎)