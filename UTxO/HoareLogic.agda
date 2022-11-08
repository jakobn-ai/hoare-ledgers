{-# OPTIONS --allow-unsolved-metas #-}
---------------------------
-- ** Axiomatic semantics

module UTxO.HoareLogic where

open import Prelude.Init; open SetAsType
open import Prelude.General
open import Prelude.DecEq
open import Prelude.Decidable
open import Prelude.Sets hiding (_↦_)
open import Prelude.Apartness

open import UTxO.UTxO
open import UTxO.Ledger


-- ** Deeply embedded formulas/propositions for our logic.
-- NB: this is necessary, in order to inspect the referenced participants later on.
data Assertion : Type₁ where
  `emp : Assertion                          -- ^ holds for the empty ledger
  _`↦_ : Address → Value → Assertion        -- ^ holds for the singleton UTXO { A ↦ v }
  _`∗_ : Assertion → Assertion → Assertion  -- ^ separating conjuction
  _`∘⟦_⟧ : Assertion → L → Assertion        -- ^ holds for a ledger that is first transformed using ⟦ t₁⋯tₙ ⟧

infixl 9 _`∘⟦_⟧
infixr 10 _`∗_
infix 11 _`↦_

variable P P′ P₁ P₂ Q Q′ Q₁ Q₂ R : Assertion

⟨_⊎_⟩≡_ : S → S → S → Type
⟨ s ⊎ s′ ⟩≡ s″ = (s ♯ s′) × ((s ∪ s′) ≈ˢ s″)

_[_↦_] : S → Address → Value → Type
s [ addr ↦ v ] = ∃ λ or → record {outRef = or; out = v at addr} ∈ˢ s

_[_↦_]∅ : S → Address → Value → Type
s [ addr ↦ v ]∅ = s [ addr ↦ v ]
                × ∃ λ or → s ≈ˢ singleton (record {outRef = or; out = v at addr})

-- We denote assertions as predicates over ledger states.
private
  emp : Pred₀ S
  emp m = ∀ x → x ∉ˢ m
  -- emp = _≈ˢ ∅

  _∗_ : Pred₀ S → Pred₀ S → Pred₀ S
  (P ∗ Q) s = ∃ λ s₁ → ∃ λ s₂ → (⟨ s₁ ⊎ s₂ ⟩≡ s) × P s₁ × Q s₂

⟦_⟧ᵖ : Assertion → Pred₀ S
⟦ `emp      ⟧ᵖ = emp
⟦ addr `↦ v ⟧ᵖ = _[ addr ↦ v ]∅
⟦ P `∗ Q    ⟧ᵖ = ⟦ P ⟧ᵖ ∗ ⟦ Q ⟧ᵖ
⟦ P `∘⟦ l ⟧ ⟧ᵖ = ⟦ P ⟧ᵖ ∘ ⟦ l ⟧

-- Convenient notation for working with assertions instead of predicates.
infixl 9 _`∘⟦_⟧ₜ
_`∘⟦_⟧ₜ : Assertion → Tx → Assertion
P `∘⟦ t ⟧ₜ = P `∘⟦ [ t ] ⟧

infix 1 _`⊢_
_`⊢_ : Assertion → Assertion → Type
P `⊢ Q = ⟦ P ⟧ᵖ ⊢ ⟦ Q ⟧ᵖ

_∙_ : Assertion → S → Type
P ∙ s = ⟦ P ⟧ᵖ s

-- ** Hoare triples: both strengthening/weakening are captured by consequence.
data ⟨_⟩_⟨_⟩ : Assertion → L → Assertion → Type₁ where

  base :
    --------------
    ⟨ P ⟩ [] ⟨ P ⟩

  step :
      ⟨ P ⟩ l ⟨ R ⟩
      --------------------------
    → ⟨ P `∘⟦ t ⟧ₜ ⟩ t ∷ l ⟨ R ⟩

  consequence :
      P′ `⊢ P          -- ^ weakening the pre-condition
    → Q  `⊢ Q′         -- ^ strengthening the post-condition
    → ⟨ P  ⟩ l ⟨ Q  ⟩
      ---------------
    → ⟨ P′ ⟩ l ⟨ Q′ ⟩

-- Utilities for Hoare triples.
weaken : P′ `⊢ P → ⟨ P ⟩ l ⟨ Q ⟩ → ⟨ P′ ⟩ l ⟨ Q ⟩
weaken H = consequence H id

strengthen : Q `⊢ Q′ → ⟨ P ⟩ l ⟨ Q ⟩ → ⟨ P ⟩ l ⟨ Q′ ⟩
strengthen H = consequence id H

axiom-base⋆ : ⟨ P `∘⟦ l ⟧ ⟩ l ⟨ P ⟩
axiom-base⋆ {P = P} {l = []}    = consequence {P = P} id id base
axiom-base⋆ {P = P} {l = t ∷ l} = consequence {P = P `∘⟦ l ⟧ `∘⟦ t ⟧ₜ} {Q = P} id id (step axiom-base⋆)

-- ** Correspondence with denotational semantics.
axiom⇒denot : ⟨ P ⟩ l ⟨ Q ⟩ → (P `⊢ Q `∘⟦ l ⟧)
axiom⇒denot base = id
axiom⇒denot (step PlQ) = axiom⇒denot PlQ
axiom⇒denot (consequence P⊢P′ Q′⊢Q PlQ) = Q′⊢Q ∘ axiom⇒denot PlQ ∘ P⊢P′

denot⇒axiom : (P `⊢ Q `∘⟦ l ⟧) → ⟨ P ⟩ l ⟨ Q ⟩
denot⇒axiom {P = P} {Q = Q} {l = []} H =
  strengthen {Q = P} {Q′ = Q} H base
denot⇒axiom {P = P} {Q = Q} {l = t ∷ l} H =
  weaken {P′ = P} {P = Q `∘⟦ t ∷ l ⟧} H (axiom-base⋆ {P = Q} {l = t ∷ l})

axiom⇔denot : ⟨ P ⟩ l ⟨ Q ⟩ ⇔ (P `⊢ Q `∘⟦ l ⟧)
axiom⇔denot = axiom⇒denot , denot⇒axiom

-- Derived alternative formulation for step, using list concatenation.
step′ :
    ⟨ P ⟩ l  ⟨ Q ⟩
  → ⟨ Q ⟩ l′ ⟨ R ⟩
    -------------------
  → ⟨ P ⟩ l ++ l′ ⟨ R ⟩
step′ {P} {[]} {Q} {l′} {R} PlQ QlR = weaken (axiom⇒denot PlQ) QlR
step′ {.(_ `∘⟦ t ⟧ₜ)} {t ∷ l} {Q} {l′} {R} (step PlQ) QlR = step (step′ PlQ QlR)
step′ {P} {t ∷ l} {Q} {l′} {R} (consequence {P = P′}{Q = Q′} pre post PlQ) QlR = weaken pre p
  where
    p : ⟨ P′ ⟩ t ∷ l ++ l′ ⟨ R ⟩
    p = step′ PlQ (weaken post QlR)

-- ** Reasoning syntax for Hoare triples.
module HoareReasoning where

  -- Reasoning newtype (for better type inference).
  record ℝ⟨_⟩_⟨_⟩ (P : Assertion) (l : L) (Q : Assertion) : Type₁ where
    constructor mkℝ_
    field begin_ : ⟨ P ⟩ l ⟨ Q ⟩
    infix -2 begin_
  open ℝ⟨_⟩_⟨_⟩ public
  infix  -2 mkℝ_
  infixr -1 _~⟪_⟩_ _~⟨_⟫_ _~⟨_∶-_⟩_ _~⟨_∶-_⟩++_
  infix  0  _∎

  -- weakening syntax
  _~⟪_⟩_ : ∀ P′ → P′ `⊢ P  → ℝ⟨ P ⟩ l ⟨ R ⟩ → ℝ⟨ P′ ⟩ l ⟨ R ⟩
  _ ~⟪ H ⟩ PlR = mkℝ weaken H (begin PlR)

  -- strengthening syntax
  _~⟨_⟫_ : ∀ R′ → R `⊢ R′  → ℝ⟨ P ⟩ l ⟨ R ⟩ → ℝ⟨ P ⟩ l ⟨ R′ ⟩
  _ ~⟨ H ⟫ PlR = mkℝ strengthen H (begin PlR)

  -- step syntax
  _~⟨_∶-_⟩_ : ∀ P′ (t : Tx) → ℝ⟨ P′ ⟩ [ t ] ⟨ P ⟩ → ℝ⟨ P ⟩ l ⟨ R ⟩ → ℝ⟨ P′ ⟩ t ∷ l ⟨ R ⟩
  P′ ~⟨ t ∶- H ⟩ PlR = P′ ~⟪ axiom⇒denot (begin H) ⟩ (mkℝ step {t = t} (begin PlR))

  -- step′ syntax
  _~⟨_∶-_⟩++_ : ∀ P′ (l : L) → ℝ⟨ P′ ⟩ l ⟨ P ⟩ → ℝ⟨ P ⟩ l′ ⟨ R ⟩ → ℝ⟨ P′ ⟩ l ++ l′ ⟨ R ⟩
  P′ ~⟨ l ∶- H ⟩++ PlR = mkℝ step′ {l = l} (begin H) (begin PlR)

  _∎ : ∀ P → ℝ⟨ P ⟩ [] ⟨ P ⟩
  p ∎ = mkℝ base {P = p}

-- ** Lemmas about separating conjunction.

postulate
  -- commutativity
  ∗↔ : P `∗ Q `⊢ Q `∗ P
  -- associativity
  ∗↝ : P `∗ Q `∗ R `⊢ (P `∗ Q) `∗ R
  ↜∗ : (P `∗ Q) `∗ R `⊢ P `∗ Q `∗ R
