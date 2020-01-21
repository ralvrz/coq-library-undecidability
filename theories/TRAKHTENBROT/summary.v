(**************************************************************)
(*   Copyright Dominique Larchey-Wendling [*]                 *)
(*                                                            *)
(*                             [*] Affiliation LORIA -- CNRS  *)
(**************************************************************)
(*      This file is distributed under the terms of the       *)
(*         CeCILL v2 FREE SOFTWARE LICENSE AGREEMENT          *)
(**************************************************************)

Require Import List Arith Bool Lia Relations.

From Undecidability.Problems
  Require Import Reduction.

From Undecidability.Shared.Libs.DLW.Utils
  Require Import utils_tac utils_list utils_nat finite php.

From Undecidability.Shared.Libs.DLW.Vec 
  Require Import pos vec.

From Undecidability.Shared.Libs.DLW.Wf 
  Require Import wf_finite.

From Undecidability.TRAKHTENBROT
  Require Import notations bpcp 
                 fo_sig fol_ops fo_terms fo_logic fo_sat 
                 decidable enumerable discrete reln_hfs

                 BPCP_SigBPCP Sig_Sig_fin Sig_rem_syms Sig_uniform 
                 Sig_one_rel Sig_rem_cst Sig2_SigSSn1

                 red_utils red_enum red_dec red_undec
                 .

Set Implicit Arguments.

(** Summary of the definitions and results of the IJCAR submission *)

(* Definition 1 *)

About decidable. Print decidable.
Check decidable_bool_eq.
About opt_enum_t. Print opt_enum_t.
About type_enum_t. Print type_enum_t.
About discrete. Print discrete.

(* Definition 2 *)

About reduces. Print reduces.

(** Fact 3, established elsewhere, you need more code from the undec. library 
    but this particular one is easy, unlike the TM stuff below *)

(* Definition 4 *)

About pcp_hand. Print pcp_hand.
About BPCP_problem. Print BPCP_problem.

(* Fact 5, for the reduction for TM halting, you need much more code from the
   undec. library and that one is not trivial at all *)

About bpcp_hand_dec.
Print Assumptions bpcp_hand_dec.

(* Definition 6 *)

About finite_t. Print finite_t.

(* Theorem 7 *)

About PHP_rel.
Print Assumptions PHP_rel.

(* Fact 8 *)

About wf_strict_order_finite.
Print Assumptions wf_strict_order_finite.

(* Theorem 9 *)

About decidable_EQUIV_fin_quotient.
Print Assumptions decidable_EQUIV_fin_quotient.

(* Corollary 10 *)

Print bij_t.
About finite_t_discrete_bij_t_pos.
Print Assumptions finite_t_discrete_bij_t_pos.

(* Definition FOL *)

About fo_term. Print fo_term.
Print fo_signature.
Print fol_bop.
Print fol_qop.
About fol_form. Print fol_form.

(* Definition 11 *)

About fo_model. Print fo_model.
About fo_term_sem. Print fo_term_sem.
About fol_sem. Print fol_sem.

(* Fact 12 *)

About fol_sem_dec.
Print Assumptions fol_sem_dec.

(* Definition 13 *)

About fo_form_fin_dec_SAT_in.
Print fo_form_fin_dec_SAT_in.
Print fo_form_fin_dec_SAT.

About fo_form_fin_dec_eq_SAT_in.
Print fo_form_fin_dec_eq_SAT_in.
Print fo_form_fin_dec_eq_SAT.

(* Theorem 14 *)

About BPCP_FIN_DEC_EQ_SAT.
Print Assumptions BPCP_FIN_DEC_EQ_SAT.

(* Lemma 15 *)

About Σbpcp_encode_sound.

(* Lemma 16 *)

About Σbpcp_encode_complete.

(* Definition 17 *)

About fo_form_fin_discr_dec_SAT_in.
Print fo_form_fin_discr_dec_SAT_in.
Print fo_form_fin_discr_dec_SAT.

(* Definition 18 *)

About fo_bisimilar.
Print fo_bisimilar.

(* Theorem 19 *)

Print fo_congruence_upto.
About fo_bisimilar_dec_congr.
Print Assumptions fo_bisimilar_dec_congr.

(* Theorem 20 *)

About fo_form_fin_dec_SAT_discr_equiv.
Check FIN_DEC_SAT_FIN_DISCR_DEC_SAT.

(* Theorem 21 *)

About FIN_DEC_EQ_SAT_FIN_DEC_SAT.
Print Assumptions FIN_DEC_EQ_SAT_FIN_DEC_SAT.

(* Lemma 22 *)

About Σ_discrete_to_pos.
Print Assumptions Σ_discrete_to_pos.

(* Lemma 23 *)

Print Σnosyms.
About FSAT_Σnosyms.

(* Lemma 24 *)

Print Σrel.
About FSAT_REL_BOUNDED_ONE_REL.
Print Assumptions FSAT_REL_BOUNDED_ONE_REL.

(* Proposition 1 *)

Print Σunif.
About FSAT_UNIFORM.

Print Σone_rel.
About FSAT_ONE_REL.

Print Σrem_cst.
Check FSAT_NOCST.

(* Lemma 25 *)

About FIN_DISCR_DEC_nSAT_FIN_DEC_2SAT.
Print Assumptions FIN_DISCR_DEC_nSAT_FIN_DEC_2SAT.

(* Theorem 26 *)

About reln_hfs.
Print Assumptions reln_hfs.

(* Theorem 27 *)

About FSAT_REL_nto2.
Print Assumptions FSAT_REL_nto2.

(* Lemma 28 *)

Print Σn1.
About FSAT_REL2_to_FUNnREL1.
Print Assumptions FSAT_REL2_to_FUNnREL1.

(* Proposition 2 *)

(* Lemma 29 *)

(* Lemma 30 *)

(* Lemma 31 *)

(* Lemma 32 *)

(* Proposition 3 *)

(* Theorem 33 *)

About FSAT_rec_enum_t.
Print Assumptions FSAT_rec_enum_t.

About FSAT_opt_enum_t.
Print Assumptions FSAT_opt_enum_t.



(* Theorem 34 *)

About FULL_TRAKHTENBROT.
Print Assumptions FULL_TRAKHTENBROT.

(* Theorem 35 *)

About FULL_MONADIC.
Print Assumptions FULL_MONADIC.


