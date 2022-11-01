module ValueSepUTxO.AbstractExample where

open import Prelude.Init
open import Prelude.General
open import Prelude.DecEq
open import Prelude.Decidable
open import Prelude.Sets hiding (_↦_)
open import Prelude.Lists hiding (_↦_)
open import Prelude.DecLists

open import Prelude.Bags
open import ValueSepUTxO.AbstractUTxO
open import ValueSepUTxO.AbstractLedger
open import ValueSepUTxO.AbstractHoareLogic
open import ValueSepUTxO.AbstractSL
open import ValueSepUTxO.AbstractCSL

-- t₁ = A —→⟨ 1 ⟩ B; t₂ = D —→⟨ 1 ⟩ C; t₃ = B —→⟨ 1 ⟩ A; t₄ = C —→⟨ 1 ⟩ D
-- t₁-₄ = L ∋ t₁ ∷ t₂ ∷ t₃ ∷ t₄ ∷ []

-- open HoareReasoning

-- -- 1a) proof using only SL.[FRAME]
-- _ : ⟨ A ↦ 1 ∗ B ↦ 0 ∗ C ↦ 0 ∗ D ↦ 1 ⟩
--     t₁-₄
--     ⟨ A ↦ 1 ∗ B ↦ 0 ∗ C ↦ 0 ∗ D ↦ 1 ⟩
-- _ = begin A ↦ 1 ∗ B ↦ 0 ∗ C ↦ 0 ∗ D ↦ 1   ~⟪ ∗↝ {A ↦ 1} {B ↦ 0} {C ↦ 0 ∗ D ↦ 1} ⟩
--           (A ↦ 1 ∗ B ↦ 0) ∗ C ↦ 0 ∗ D ↦ 1 ~⟨ t₁ ∶- ℝ[FRAME] (C ↦ 0 ∗ D ↦ 1) (mkℝ A ↝⁰ B) ⟩
--           (A ↦ 0 ∗ B ↦ 1) ∗ C ↦ 0 ∗ D ↦ 1 ~⟪ ∗↔ {A ↦ 0 ∗ B ↦ 1} {C ↦ 0 ∗ D ↦ 1} ⟩
--           (C ↦ 0 ∗ D ↦ 1) ∗ A ↦ 0 ∗ B ↦ 1 ~⟨ t₂ ∶- ℝ[FRAME] (A ↦ 0 ∗ B ↦ 1) (mkℝ C ↜⁰ D) ⟩
--           (C ↦ 1 ∗ D ↦ 0) ∗ A ↦ 0 ∗ B ↦ 1 ~⟪ ∗↔ {C ↦ 1 ∗ D ↦ 0} {A ↦ 0 ∗ B ↦ 1} ⟩
--           (A ↦ 0 ∗ B ↦ 1) ∗ C ↦ 1 ∗ D ↦ 0 ~⟨ t₃ ∶- ℝ[FRAME] (C ↦ 1 ∗ D ↦ 0) (mkℝ A ↜⁰ B) ⟩
--           (A ↦ 1 ∗ B ↦ 0) ∗ C ↦ 1 ∗ D ↦ 0 ~⟪ ∗↔ {A ↦ 1 ∗ B ↦ 0} {C ↦ 1 ∗ D ↦ 0} ⟩
--           (C ↦ 1 ∗ D ↦ 0) ∗ A ↦ 1 ∗ B ↦ 0 ~⟨ t₄ ∶- ℝ[FRAME] (A ↦ 1 ∗ B ↦ 0) (mkℝ C ↝⁰ D) ⟩
--           (C ↦ 0 ∗ D ↦ 1) ∗ A ↦ 1 ∗ B ↦ 0 ~⟪ ∗↔ {C ↦ 0 ∗ D ↦ 1} {A ↦ 1 ∗ B ↦ 0} ⟩
--           (A ↦ 1 ∗ B ↦ 0) ∗ C ↦ 0 ∗ D ↦ 1 ~⟪ ↜∗ {A ↦ 1} {B ↦ 0} {C ↦ 0 ∗ D ↦ 1} ⟩
--           A ↦ 1 ∗ B ↦ 0 ∗ C ↦ 0 ∗ D ↦ 1   ∎

-- -- 1b) proof using CSL.[INTERLEAVE]
-- _ : ⟨ A ↦ 1 ∗ B ↦ 0 ∗ C ↦ 0 ∗ D ↦ 1 ⟩
--      t₁-₄
--      ⟨ A ↦ 1 ∗ B ↦ 0 ∗ C ↦ 0 ∗ D ↦ 1 ⟩
-- _ = begin A ↦ 1 ∗ B ↦ 0 ∗ C ↦ 0 ∗ D ↦ 1   ~⟪ ∗↝ {A ↦ 1} {B ↦ 0} {C ↦ 0 ∗ D ↦ 1} ⟩
--           (A ↦ 1 ∗ B ↦ 0) ∗ C ↦ 0 ∗ D ↦ 1 ~⟨ t₁-₄ ∶- ℝ[PAR] auto H₁ H₂ ⟩++
--           (A ↦ 1 ∗ B ↦ 0) ∗ C ↦ 0 ∗ D ↦ 1 ~⟪ ↜∗ {A ↦ 1} {B ↦ 0} {C ↦ 0 ∗ D ↦ 1} ⟩
--           A ↦ 1 ∗ B ↦ 0 ∗ C ↦ 0 ∗ D ↦ 1   ∎
--   where
--     H₁ : ℝ⟨ A ↦ 1 ∗ B ↦ 0 ⟩ t₁ ∷ t₃ ∷ [] ⟨ A ↦ 1 ∗ B ↦ 0 ⟩
--     H₁ = A ↦ 1 ∗ B ↦ 0 ~⟨ t₁ ∶- mkℝ A ↝⁰ B ⟩
--         A ↦ 0 ∗ B ↦ 1 ~⟨ t₃ ∶- mkℝ A ↜⁰ B ⟩
--         A ↦ 1 ∗ B ↦ 0 ∎

--     H₂ : ℝ⟨ C ↦ 0 ∗ D ↦ 1 ⟩ t₂ ∷ t₄ ∷ [] ⟨ C ↦ 0 ∗ D ↦ 1 ⟩
--     H₂ = C ↦ 0 ∗ D ↦ 1 ~⟨ t₂ ∶- mkℝ C ↜⁰ D ⟩
--               C ↦ 1 ∗ D ↦ 0 ~⟨ t₄ ∶- mkℝ C ↝⁰ D ⟩
--               C ↦ 0 ∗ D ↦ 1 ∎

-- -- 2) overlapping proof
-- t₁′ = A —→⟨ 1 ⟩ B; t₂′ = C —→⟨ 1 ⟩ A
-- t₁₂ = L ∋ t₁′ ∷ t₂′ ∷ []

-- _ : ⟨ A ↦ 1 ∗ B ↦ 0 ∗ C ↦ 1 ∗ A ↦ 0 ⟩
--      t₁₂
--      ⟨ A ↦ 0 ∗ B ↦ 1 ∗ C ↦ 0 ∗ A ↦ 1 ⟩
-- _ = begin A ↦ 1 ∗ B ↦ 0 ∗ C ↦ 1 ∗ A ↦ 0     ~⟪ ∗↝ {A ↦ 1} {B ↦ 0} {C ↦ 1 ∗ A ↦ 0} ⟩
--           (A ↦ 1 ∗ B ↦ 0) ∗ (C ↦ 1 ∗ A ↦ 0) ~⟨ t₁₂ ∶- ℝ[PAR] auto H₁ H₂ ⟩++
--           (A ↦ 0 ∗ B ↦ 1) ∗ (C ↦ 0 ∗ A ↦ 1) ~⟪ ↜∗ {A ↦ 0} {B ↦ 1} {C ↦ 0 ∗ A ↦ 1} ⟩
--           A ↦ 0 ∗ B ↦ 1 ∗ C ↦ 0 ∗ A ↦ 1     ∎
--   where
--     H₁ : ℝ⟨ A ↦ 1 ∗ B ↦ 0 ⟩ [ t₁′ ] ⟨ A ↦ 0 ∗ B ↦ 1 ⟩
--     H₁ = mkℝ A ↝⁰ B

--     H₂ : ℝ⟨ C ↦ 1 ∗ A ↦ 0 ⟩ [ t₂′ ] ⟨ C ↦ 0 ∗ A ↦ 1 ⟩
--     H₂ = mkℝ C ↝⁰ A

{-
{-# OPTIONS --rewriting #-}
module UTxO.Example where

open import Agda.Builtin.Equality.Rewrite

open import Prelude.Init

open import Prelude.DecEq
open import Prelude.Decidable
open import Prelude.Sets
open import Prelude.Lists
open import Prelude.Apartness

open import UTxO.UTxO
open import UTxO.Ledger
open import UTxO.HoareLogic
open import UTxO.SL
open import UTxO.CSL

A B C D : Address
A = 111; B = 222; C = 333; D = 444

postulate t₀ : Tx
t₀₀ = (t₀ ♯) indexed-at 0
t₀₁ = (t₀ ♯) indexed-at 1

postulate
  mkValidator : TxOutputRef → (TxInfo → DATA → Bool)
  in₁ : (mkValidator t₀₀) ♯ ≡ A
  in₂ : (mkValidator t₀₁) ♯ ≡ D
{-# REWRITE in₁ #-}
{-# REWRITE in₂ #-}

_—→⟨_∣_⟩_ : Address → Value → TxOutputRef → Address → Tx
A —→⟨ v ∣ or ⟩ B = record
  { inputs  = [ record { outputRef = or ; validator = mkValidator or; redeemer = 0 } ]
  ; outputs = [ 1 at B ]
  ; forge   = 0
  }

t₁ t₂ t₃ t₄ : Tx
-- t₀ = record {inputs = []; outputs = 1 at A ∷ 1 at D ∷ []; forge = 2}
t₁ = A —→⟨ 1 ∣ t₀₀ ⟩ B
t₂ = D —→⟨ 1 ∣ t₀₁ ⟩ C

t₁₀ = (t₁ ♯) indexed-at 0
t₂₀ = (t₂ ♯) indexed-at 0
postulate
  in₃ : (mkValidator t₁₀) ♯ ≡ B
  in₄ : (mkValidator t₂₀) ♯ ≡ C
{-# REWRITE in₃ #-}
{-# REWRITE in₄ #-}

t₃ = B —→⟨ 1 ∣ t₁₀ ⟩ A
t₄ = C —→⟨ 1 ∣ t₂₀ ⟩ D

t₁-₄ : L
t₁-₄ = t₁ ∷ t₂ ∷ t₃ ∷ t₄ ∷ []

open HoareReasoning
private variable v v′ : Value
postulate
  _↝_∶-_ : ∀ A B {or} → A ≢ B → ⟨ A `↦ v `∗ B `↦ v′ ⟩ [ A —→⟨ v ∣ or ⟩ B ] ⟨ A `↦ 0 `∗ B `↦ (v′ + v) ⟩
  _↜_∶-_ : ∀ A B {or} → A ≢ B → ⟨ A `↦ v′ `∗ B `↦ v ⟩ [ B —→⟨ v ∣ or ⟩ A ] ⟨ A `↦ (v′ + v) `∗ B `↦ 0 ⟩

-- proof using only SL.[FRAME]
h : ⟨ A `↦ 1 `∗ B `↦ 0 `∗ C `↦ 0 `∗ D `↦ 1 ⟩
    t₁-₄
    ⟨ A `↦ 1 `∗ B `↦ 0 `∗ C `↦ 0 `∗ D `↦ 1 ⟩
h = begin A `↦ 1 `∗ B `↦ 0 `∗ C `↦ 0 `∗ D `↦ 1   ~⟪ (λ {x} → ∗↝ {A `↦ 1} {B `↦ 0} {C `↦ 0 `∗ D `↦ 1} {x}) ⟩
          (A `↦ 1 `∗ B `↦ 0) `∗ C `↦ 0 `∗ D `↦ 1 ~⟨ t₁ ∶- ℝ[FRAME] (C `↦ 0 `∗ D `↦ 1) p₁ (A ↝ B ∶- auto) ⟩
          (A `↦ 0 `∗ B `↦ 1) `∗ C `↦ 0 `∗ D `↦ 1 ~⟪ (λ {x} → ∗↔ {A `↦ 0 `∗ B `↦ 1} {C `↦ 0 `∗ D `↦ 1} {x}) ⟩
          (C `↦ 0 `∗ D `↦ 1) `∗ A `↦ 0 `∗ B `↦ 1 ~⟨ t₂ ∶- ℝ[FRAME] (A `↦ 0 `∗ B `↦ 1) p₂ (C ↜ D ∶- auto) ⟩
          (C `↦ 1 `∗ D `↦ 0) `∗ A `↦ 0 `∗ B `↦ 1 ~⟪ (λ {x} → ∗↔ {C `↦ 1 `∗ D `↦ 0} {A `↦ 0 `∗ B `↦ 1} {x}) ⟩
          (A `↦ 0 `∗ B `↦ 1) `∗ C `↦ 1 `∗ D `↦ 0 ~⟨ t₃ ∶- ℝ[FRAME] (C `↦ 1 `∗ D `↦ 0) p₃ (A ↜ B ∶- auto) ⟩
          (A `↦ 1 `∗ B `↦ 0) `∗ C `↦ 1 `∗ D `↦ 0 ~⟪ (λ {x} → ∗↔ {A `↦ 1 `∗ B `↦ 0} {C `↦ 1 `∗ D `↦ 0} {x}) ⟩
          (C `↦ 1 `∗ D `↦ 0) `∗ A `↦ 1 `∗ B `↦ 0 ~⟨ t₄ ∶- ℝ[FRAME] (A `↦ 1 `∗ B `↦ 0) p₄ (C ↝ D ∶- auto) ⟩
          (C `↦ 0 `∗ D `↦ 1) `∗ A `↦ 1 `∗ B `↦ 0 ~⟪ (λ {x} → ∗↔ {C `↦ 0 `∗ D `↦ 1} {A `↦ 1 `∗ B `↦ 0} {x}) ⟩
          (A `↦ 1 `∗ B `↦ 0) `∗ C `↦ 0 `∗ D `↦ 1 ~⟪ (λ {x} → ↜∗ {A `↦ 1} {B `↦ 0} {C `↦ 0 `∗ D `↦ 1} {x}) ⟩
          A `↦ 1 `∗ B `↦ 0 `∗ C `↦ 0 `∗ D `↦ 1   ∎
  where
    postulate
      p₁ : [ t₁ ] ♯ (C `↦ 0 `∗ D `↦ 1)
      p₂ : [ t₂ ] ♯ (A `↦ 0 `∗ B `↦ 1)
      p₃ : [ t₃ ] ♯ (C `↦ 1 `∗ D `↦ 0)
      p₄ : [ t₄ ] ♯ (A `↦ 1 `∗ B `↦ 0)

-- -- 2) proof using CSL.[INTERLEAVE]
-- h₁ : ℝ⟨ A `↦ 1 `∗ B `↦ 0 ⟩ t₁ ∷ t₃ ∷ [] ⟨ A `↦ 1 `∗ B `↦ 0 ⟩
-- h₁ = begin A `↦ 1 `∗ B `↦ 0 ~⟨ t₁ ∶- A ↝ B ∶- auto ⟩
--            A `↦ 0 `∗ B `↦ 1 ~⟨ t₃ ∶- A ↜ B ∶- auto ⟩
--            A `↦ 1 `∗ B `↦ 0 ∎

-- h₂ : ℝ⟨ C `↦ 0 `∗ D `↦ 1 ⟩ t₂ ∷ t₄ ∷ [] ⟨ C `↦ 0 `∗ D `↦ 1 ⟩
-- h₂ = begin C `↦ 0 `∗ D `↦ 1 ~⟨ t₂ ∶- C ↜ D ∶- auto ⟩
--            C `↦ 1 `∗ D `↦ 0 ~⟨ t₄ ∶- C ↝ D ∶- auto ⟩
--            C `↦ 0 `∗ D `↦ 1 ∎

-- h′ : ℝ⟨ A `↦ 1 `∗ B `↦ 0 `∗ C `↦ 0 `∗ D `↦ 1 ⟩
--      t₁-₄
--      ⟨ A `↦ 1 `∗ B `↦ 0 `∗ C `↦ 0 `∗ D `↦ 1 ⟩
-- h′ = begin A `↦ 1 `∗ B `↦ 0 `∗ C `↦ 0 `∗ D `↦ 1   ~⟪ ∗↝ {A `↦ 1} {B `↦ 0} {C `↦ 0 `∗ D `↦ 1} ⟩
--            (A `↦ 1 `∗ B `↦ 0) `∗ C `↦ 0 `∗ D `↦ 1 ~⟨ t₁-₄ ∶- [PAR] inter h₁ h₂ p₁ p₂         ⟩++
--            (A `↦ 1 `∗ B `↦ 0) `∗ C `↦ 0 `∗ D `↦ 1 ~⟪ ↜∗ {A `↦ 1} {B `↦ 0} {C `↦ 0 `∗ D `↦ 1} ⟩
--            A `↦ 1 `∗ B `↦ 0 `∗ C `↦ 0 `∗ D `↦ 1   ∎
--      where
--        inter : (t₁ ∷ t₃ ∷ []) ∥ (t₂ ∷ t₄ ∷ []) ≡ t₁-₄
--        inter = keepˡ $′ keepʳ $′ keepˡ $′ keepʳ []

--        postulate
--          p₁ : (t₁ ∷ t₃ ∷ []) ♯ (C `↦ 0 `∗ D `↦ 1)
--          p₂ : (t₂ ∷ t₄ ∷ []) ♯ (A `↦ 1 `∗ B `↦ 0)
-}
