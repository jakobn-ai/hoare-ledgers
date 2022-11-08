---------------------------------------
-- ** Concurrent separation logic (CSL)

module ValueSepUTxO.CSL where

open import Prelude.Init
open import Prelude.DecEq
open import Prelude.Decidable
open import Prelude.Lists
open import Prelude.InferenceRules

open import Prelude.Bags
open import ValueSepUTxO.UTxO
open import ValueSepUTxO.Ledger
open import ValueSepUTxO.HoareLogic
open import ValueSepUTxO.SL

◇-interleave :
  ∙ (l₁ ∥ l₂ ≡ l)
  ∙ ⟨ s₁ ◇ s₂ ⟩≡ s
  ∙ ⟦ l₁ ⟧ s₁ ≡ just s₁′
  ∙ ⟦ l₂ ⟧ s₂ ≡ just s₂′
    ───────────────────────────
    ∃ λ s′ → (⟦ l ⟧ s ≡ just s′)
           × (⟨ s₁′ ◇ s₂′ ⟩≡ s′)
◇-interleave {.[]}    {.[]}    {.[]}    {s₁} {s₂} {s} {.s₁} {.s₂} []         ≡s refl refl
  = s , refl , ≡s
◇-interleave {t ∷ l₁} {l₂}     {.t ∷ l} {s₁} {s₂} {s} {s₁′} {s₂′} (keepˡ ≡l) ≡s ls₁  ls₂
  with ⟦ t ⟧ s₁ in ⟦t⟧s≡
... | just ⟦t⟧s₁
  with ⟦ t ⟧ s | ◇-⟦⟧ᵗ {t}{s₁}{s₂}{s} ⟦t⟧s₁ ⟦t⟧s≡ ≡s
... | just ⟦t⟧s | ret↑ ≡s′
  = ◇-interleave ≡l ≡s′ ls₁ ls₂
◇-interleave {l₁}     {t ∷ l₂} {.t ∷ l} {s₁} {s₂} {s} {s₁′} {s₂′} (keepʳ ≡l) ≡s ls₁  ls₂
  with ⟦ t ⟧ s₂ in ⟦t⟧s≡
... | just ⟦t⟧s₂
  with ⟦ t ⟧ s | ◇-⟦⟧ᵗ˘ {t}{s₂}{s₁}{s} ⟦t⟧s₂ ⟦t⟧s≡ ≡s
... | just ⟦t⟧s | ret↑ ≡s′
  = ◇-interleave ≡l ≡s′ ls₁ ls₂

-- ** Proof of CSL's [PAR] rule, which allows for modular reasoning.
[PAR] :
  ∙ l₁ ∥ l₂ ≡ l
  ∙ ⟨ P₁ ⟩ l₁ ⟨ Q₁ ⟩
  ∙ ⟨ P₂ ⟩ l₂ ⟨ Q₂ ⟩
    ─────────────────────────
    ⟨ P₁ ∗ P₂ ⟩ l ⟨ Q₁ ∗ Q₂ ⟩
[PAR] {l₁} {l₂} {l} ≡l Pl₁Q Pl₂Q {s} (s₁ , s₂ , ≡s , Ps₁ , Ps₂)
  with ⟦ l₁ ⟧ s₁ in ls₁ | Pl₁Q Ps₁
... | just s₁′ | M.Any.just Qs₁′
  with ⟦ l₂ ⟧ s₂ in ls₂ | Pl₂Q Ps₂
... | just s₂′ | M.Any.just Qs₂′
  with s′ , ls , ≡s′ ← ◇-interleave {s = s} ≡l ≡s ls₁ ls₂
  rewrite ls
  = M.Any.just (s₁′ , s₂′ , ≡s′ , Qs₁′ , Qs₂′)

open HoareReasoning
ℝ[PAR] :
  ∙ l₁ ∥ l₂ ≡ l
  ∙ ℝ⟨ P₁ ⟩ l₁ ⟨ Q₁ ⟩
  ∙ ℝ⟨ P₂ ⟩ l₂ ⟨ Q₂ ⟩
    ─────────────────────────
    ℝ⟨ P₁ ∗ P₂ ⟩ l ⟨ Q₁ ∗ Q₂ ⟩
ℝ[PAR] ≡l PlQ PlQ′ = mkℝ [PAR] ≡l (begin PlQ) (begin PlQ′)
