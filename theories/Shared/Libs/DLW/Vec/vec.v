(**************************************************************)
(*   Copyright Dominique Larchey-Wendling [*]                 *)
(*                                                            *)
(*                             [*] Affiliation LORIA -- CNRS  *)
(**************************************************************)
(*      This file is distributed under the terms of the       *)
(*         CeCILL v2 FREE SOFTWARE LICENSE AGREEMENT          *)
(**************************************************************)

Require Import Arith Lia List Permutation. 
Require Vector.

From Undecidability.Shared.Libs.DLW.Utils 
  Require Import utils. 

From Undecidability.Shared.Libs.DLW.Vec 
  Require Import pos.

Set Implicit Arguments.
Set Default Goal Selector "!".

Notation vec_nil := (@Vector.nil _).
Notation "x ## v" := (@Vector.cons _ x _ v) (at level 60, right associativity).

Section vector.

  Variable X : Type.

  Notation vec := (@Vector.t X).

(* @DLW: former definition

  Inductive vec : nat -> Type :=
    | vec_nil  : vec 0
    | vec_cons : forall n, X -> vec n -> vec (S n).
*)

  Let vec_decomp_type n := 
    match n with
      | 0   => Prop
      | S n => (X * vec n)%type
    end.

  Definition vec_decomp n (v : vec n) :=
    match v in Vector.t _ k return vec_decomp_type k with
      | vec_nil => False
      | x ## v  => (x,v)
    end.
    
  Definition vec_head n (v : vec (S n)) := match v with x ## _ => x end.
  Definition vec_tail n (v : vec (S n)) := match v with _ ## w => w end.

  Let vec_head_tail_type n : vec n -> Prop := 
    match n with
      | 0   => fun v => v = vec_nil
      | S n => fun v => v = vec_head v ## vec_tail v
    end.

  Let vec_head_tail_prop n v :  @vec_head_tail_type n v.
  Proof. induction v; simpl; auto. Qed.

  Fact vec_0_nil (v : vec 0) : v = vec_nil.
  Proof. apply (vec_head_tail_prop v). Qed.

  Fact vec_head_tail n (v : vec (S n)) : v = vec_head v ## vec_tail v.
  Proof. apply (vec_head_tail_prop v). Qed.

  Fact vec_cons_inv n x y (v w : vec n) : x ## v = y ## w -> x = y /\ v = w.
  Proof.
    intros H1; generalize H1; intros H2.
    apply f_equal with (f := @vec_head _) in H1.
    apply f_equal with (f := @vec_tail _) in H2.
    auto.
  Qed.

  Fixpoint vec_pos n (v : vec n) : pos n -> X.
  Proof.
    refine (match v with
      | vec_nil => fun p => _
      | x ## v => fun p => _
    end); invert pos p.
    + exact x.
    + exact (vec_pos _ v p).
  Defined.

  Fact vec_pos0 n (v : vec (S n)) : vec_pos v pos0 = vec_head v.
  Proof. 
    rewrite (vec_head_tail v).
    reflexivity.
  Qed.
  
  Fact vec_pos_tail n (v : vec (S n)) p : vec_pos (vec_tail v) p = vec_pos v (pos_nxt p).
  Proof.
    rewrite vec_head_tail at 2; simpl; auto.
  Qed.
  
  Fact vec_pos1 n (v : vec (S (S n))) : vec_pos v pos1 = vec_head (vec_tail v).
  Proof.
    rewrite <- vec_pos0, vec_pos_tail; auto.
  Qed.

  Fact vec_pos_ext n (v w : vec n) : (forall p, vec_pos v p = vec_pos w p) -> v = w.
  Proof.
    revert v w; induction n as [ | n IHn ]; intros v w H.
    1: rewrite (vec_0_nil v), (vec_0_nil w); auto.
    revert H; rewrite (vec_head_tail v), (vec_head_tail w); f_equal.
    intros H; f_equal.
    + apply (H pos0).
    + apply IHn.
      intros p; apply (H (pos_nxt p)).
  Qed.

  Fixpoint vec_set_pos n : (pos n -> X) -> vec n :=
    match n return (pos n -> X) -> vec n with 
      | 0   => fun _ => vec_nil
      | S n => fun g => g pos0 ## vec_set_pos (fun p => g (pos_nxt p))
    end.

  Fact vec_pos_set n (g : pos n -> X) p : vec_pos (vec_set_pos g) p = g p. 
  Proof.
    revert g p; induction n as [ | n IHn ]; intros g p; pos_inv p; auto.
    apply IHn.
  Qed.

  Fixpoint vec_change n (v : vec n) : pos n -> X -> vec n.
  Proof.
    refine (match v with
      | vec_nil => fun _ _ => vec_nil
      | y ## v  => fun p x => _
    end).
    pos_inv p.
    + exact (x ## v).
    + exact (y ## vec_change _ v p x).
  Defined.

  Fact vec_change_eq n v p q x : p = q -> vec_pos (@vec_change n v p x) q = x.
  Proof. 
    intro; subst q; revert p x.
    induction v; intros p ?; invert pos p; auto.
  Qed.

  Fact vec_change_neq n v p q x : p <> q -> vec_pos (@vec_change n v p x) q = vec_pos v q.
  Proof. 
    revert p q x.
    induction v as [ | n y v IH ]; intros p q x H; invert pos p; invert pos q; auto.
    + destruct H; auto.
    + apply IH; contradict H; subst; auto.
  Qed.

  Fact vec_change_idem n v p x y : vec_change (@vec_change n v p x) p y = vec_change v p y.
  Proof.
    apply vec_pos_ext; intros q.
    destruct (pos_eq_dec p q).
    + repeat rewrite vec_change_eq; auto.
    + repeat rewrite vec_change_neq; auto.
  Qed.

  Fact vec_change_same n v p : @vec_change n v p (vec_pos v p) = v.
  Proof.
    apply vec_pos_ext; intros q.
    destruct (pos_eq_dec p q).
    + repeat rewrite vec_change_eq; subst; auto.
    + repeat rewrite vec_change_neq; auto.
  Qed.

  Variable eq_X_dec : forall x y : X, { x = y } + { x <> y }.

  Fixpoint vec_eq_dec n (u v : vec n) : { u = v } + { u <> v }.
  Proof using eq_X_dec.
    destruct u as [ | x n u ].
    + left.
      rewrite vec_0_nil; trivial.
    + destruct (eq_X_dec x (vec_head v)) as [ E1 | D ].
      * destruct (vec_eq_dec _ u (vec_tail v)) as [ E2 | D ].
        - left; subst; rewrite <- vec_head_tail; auto.
        - right; contradict D; subst; rewrite <- D; auto.
      * right; contradict D; subst; auto.
  Defined.
  
  Fixpoint vec_list n (v : vec n) := 
    match v with  
      | vec_nil => nil
      | x ## v  => x::vec_list v
    end.

  Fact vec_list_In n v p : In (vec_pos v p) (@vec_list n v).
  Proof.
    revert p; induction v; intros p; invert pos p; auto.
  Qed.

  Fact vec_list_vec_set_pos n f : vec_list (@vec_set_pos n f) = map f (pos_list n).
  Proof.
    revert f; induction n as [ | n IHn ]; intros f; simpl; f_equal; auto.
    rewrite IHn, map_map; auto.
  Qed.

  Fact map_pos_list_vec n f : map f (pos_list n) = vec_list (@vec_set_pos n f).
  Proof. rewrite vec_list_vec_set_pos; auto. Qed.
    
  Fact vec_list_length n v : length (@vec_list n v) = n.
  Proof. induction v; simpl; f_equal; auto. Defined.

  Fixpoint list_vec (l : list X) : vec (length l) := 
    match l with 
      | nil  => vec_nil
      | x::l => x ## list_vec l
    end.

  Fact list_vec_iso l : vec_list (list_vec l) = l.
  Proof. induction l; simpl; f_equal; auto. Qed.

  (* The other part needs a transport *)

  Fact vec_list_iso n v : list_vec (@vec_list n v) = eq_rect_r _ v (vec_list_length v).
  Proof. 
    induction v; simpl; f_equal; auto.
    rewrite IHv; unfold eq_rect_r; simpl.
    generalize (length (vec_list v)) (vec_list_length v).
    intros; subst; cbv; auto.
  Qed.

  Definition list_vec_full l : { v : vec (length l) | vec_list v = l }.
  Proof. exists (list_vec l); apply list_vec_iso. Qed.

  Fact vec_list_inv n v x : In x (@vec_list n v) -> exists p, x = vec_pos v p.
  Proof.
    induction v as [ | n y v IHl ].
    1: intros [].
    intros [ H | H ]; subst.
    + exists pos0; auto.
    + destruct IHl as (p & Hp); auto.
      subst; exists (pos_nxt p); auto.
  Qed.
 
  Fact vec_list_In_iff n v x : In x (@vec_list n v) <-> exists p, x = vec_pos v p.
  Proof.
    split.
    + apply vec_list_inv.
    + intros (p & ->); apply vec_list_In.
  Qed.

  Variable x : X.

  Fixpoint in_vec n (v : vec n) : Prop :=
    match v with
      | vec_nil => False
      | y ## v  => y = x \/ in_vec v
    end.

  Fact in_vec_list n v : @in_vec n v <-> In x (vec_list v).
  Proof. induction v; simpl; tauto. Qed.

End vector.

Notation vec := Vector.t.
Notation vec_cons := (fun x => @Vector.cons _ x _).

Fact in_vec_pos X n (v : vec X n) p : in_vec (vec_pos v p) v.
Proof. revert p; induction v; intros p; invert pos p; auto. Qed.

Fact in_vec_inv X n (v : vec X n) x : in_vec x v -> exists p, vec_pos v p = x.
Proof.
  induction v as [ | n y v IHv ]; simpl in_vec; try tauto.
  intros [ -> | H ].
  + exists pos0; auto.
  + destruct (IHv H) as (p & <-).
    exists (pos_nxt p); auto.
Qed.

Fact in_vec_dec_inv X n (v : vec X n) : 
        (forall x y : X, { x = y } + { x <> y })
     -> forall x, in_vec x v -> { p | vec_pos v p = x }.
Proof.
  intros dec.
  induction v as [ | x n v IHv ].
  + intros _ [].
  + intros y Hy.
    destruct (dec x y) as [ H | H ].
    * exists pos0; auto.
    * destruct (IHv y) as (p & Hp).
      - destruct Hy; tauto.
      - exists (pos_nxt p); auto.
Qed.

(* notations *)

Section vec_app_split.

  Variable (X : Type) (n m : nat).

  Definition vec_app (v : vec X n) (w : vec X m) : vec X (n+m).
  Proof. 
    apply vec_set_pos; intros p.
    destruct (pos_both _ _ p) as [ q | q ]; refine (vec_pos _ q); assumption.
  Defined.

  Definition vec_split (v : vec X (n+m)) : vec X n * vec X m.
  Proof.
    split; apply vec_set_pos; intros p; refine (vec_pos v _).
    + apply pos_left, p.
    + apply pos_right, p.
  Defined.

  Fact vec_app_split u : let (v,w) := vec_split u in vec_app v w = u.
  Proof.
    case_eq (vec_split u); intros v w; unfold vec_split, vec_app; intros H.
    injection H; clear H; intros Hw Hv.
    apply vec_pos_ext; unfold vec_app; simpl.
    intros p; rewrite vec_pos_set. 
    case_eq (pos_both n m p); intros q Hq.
    + rewrite <- Hv, vec_pos_set; f_equal.
      apply f_equal with (f := @pos_lr _ _) in Hq.
      simpl in Hq; rewrite <- Hq; apply pos_lr_both.
    + rewrite <- Hw, vec_pos_set; f_equal.
      apply f_equal with (f := @pos_lr _ _) in Hq.
      simpl in Hq; rewrite <- Hq; apply pos_lr_both.
  Qed.

  Fact vec_split_app v w : vec_split (vec_app v w) = (v,w).
  Proof.
    unfold vec_split, vec_app; f_equal; apply vec_pos_ext; intros p; repeat rewrite vec_pos_set.
    + rewrite pos_both_left; auto.
    + rewrite pos_both_right; auto.
  Qed.

  Fact vec_pos_app_left v w i : vec_pos (vec_app v w) (pos_left _ i) = vec_pos v i.
  Proof. unfold vec_app; rewrite vec_pos_set, pos_both_left; auto. Qed.

  Fact vec_pos_app_right v w i : vec_pos (vec_app v w) (pos_right _ i) = vec_pos w i.
  Proof. unfold vec_app; rewrite vec_pos_set, pos_both_right; auto. Qed.

End vec_app_split.

Fact vec_app_nil X n v : @vec_app X 0 n vec_nil v = v.
Proof.
  apply vec_pos_ext; unfold vec_app; simpl; intros p.
  rewrite vec_pos_set; auto.
Qed.

Fact vec_app_cons X n m x v w : @vec_app X (S n) m (x##v) w = x##vec_app v w.
Proof.
  apply vec_pos_ext; unfold vec_app; intros p.
  rewrite vec_pos_set; simpl in p.
  analyse pos p.
  + simpl; auto.
  + simpl vec_pos at 3; rewrite vec_pos_set.
    simpl pos_both.
    destruct (pos_both n m p); auto.
Qed.

Section vec_map.

  Variable (X Y : Type).

  Section vec_map_def.

    Variable (f : X -> Y).

    Fixpoint vec_map n (v : vec X n) :=
      match v with 
        | vec_nil => vec_nil
        | x ## v  => f x ## vec_map v 
      end.

  End vec_map_def.

  Fixpoint vec_in_map n v : (forall x, @in_vec X x n v -> Y) -> vec Y n.
  Proof.
    refine (match v with
      | vec_nil  => fun _ => vec_nil
      | x##v     => fun f => f x _ ## @vec_in_map _ v _
    end).
    + left; auto.
    + intros y Hy; apply (f y); right; auto.
  Defined.

  Fact vec_in_map_vec_map_eq f n v : @vec_in_map n v (fun x _ => f x) = vec_map f v.
  Proof. induction v; simpl; f_equal; auto. Qed.

  Fact vec_in_map_ext n v f g : (forall x Hx, @f x Hx = @g x Hx) 
                             -> @vec_in_map n v f = vec_in_map v g.
  Proof. revert f g; induction v; simpl; intros; f_equal; auto. Qed.

  Fact vec_map_ext f g n v : (forall x, in_vec x v -> f x = g x) 
                          -> @vec_map f n v = vec_map g v.
  Proof.
    intros H.
    do 2 rewrite <- vec_in_map_vec_map_eq.
    apply vec_in_map_ext, H.
  Qed.

  Fact vec_list_vec_map (f : X -> Y) n v : vec_list (@vec_map f n v) = map f (vec_list v).
  Proof. induction v; simpl; f_equal; auto. Qed.

End vec_map.

Fact vec_map_map X Y Z (f : X -> Y) (g : Y -> Z) n (v : vec _ n) :
          vec_map g (vec_map f v) = vec_map (fun x => g (f x)) v.
Proof. induction v; simpl; f_equal; auto. Qed. 

Section vec_map2.

  (* Definitions taken from stdlib *)
  
  Definition case0 {A} (P:vec A 0 -> Type) (H:P (@Vector.nil A)) v:P v :=
    match v with
    |vec_nil => H
    |_ => fun devil => False_ind (@IDProp) devil (* subterm !!! *)
    end.

  Definition caseS' {A} {n : nat} (v : vec A (S n)) : forall (P : vec A (S n) -> Type)
                                                      (H : forall h t, P (h ## t)), P v :=
    match v with
    | h ## t => fun P H => H h t
    | _ => fun devil => False_rect (@IDProp) devil
    end.

  Definition rect2 {A B} (P:forall {n}, vec A n -> vec B n -> Type)
             (bas : P vec_nil vec_nil) (recvec : forall {n v1 v2}, P v1 v2 ->
                                                              forall a b, P (a ## v1) (b ## v2)) :=
    fix rect2_fix {n} (v1 : vec A n) : forall v2 : vec B n, P v1 v2 :=
      match v1 with
      | vec_nil  => fun v2 => case0 _ bas v2
      | h1 ## t1 => fun v2 => caseS' v2 (fun v2' => P (h1##t1) v2') (fun h2 t2 => recvec (rect2_fix t1 t2) h1 h2)
      end.

  Definition vec_map2 {A B C} (g:A -> B -> C) :
    forall (n : nat), vec A n -> vec B n -> vec C n :=
    @rect2 _ _ (fun n _ _ => vec C n) vec_nil (fun _ _ _ H a b => (g a b) ## H).

  Global Arguments vec_map2 {A B C} g {n} v1 v2.

End vec_map2.

Fact vec_pos_map X Y (f : X -> Y) n (v : vec X n) p : vec_pos (vec_map f v) p = f (vec_pos v p).
Proof.
  revert p; induction v; intros p; pos_inv p; simpl; auto.
Qed.

Fact vec_map_set_pos X Y f n s : @vec_map X Y f _ (@vec_set_pos _ n s)
                               = vec_set_pos (fun p => f (s p)).
Proof.
  apply vec_pos_ext; intros p.
  rewrite vec_pos_map, vec_pos_set, vec_pos_set; auto.
Qed.

Section vec_plus.

  Variable n : nat.

  Definition vec_plus (v w : vec nat n) := vec_set_pos (fun p => vec_pos v p + vec_pos w p).
  Definition vec_zero : vec nat n := vec_set_pos (fun _ => 0).
  
  Fact vec_pos_plus v w p : vec_pos (vec_plus v w) p = vec_pos v p + vec_pos w p.
  Proof.
    unfold vec_plus; rewrite vec_pos_set; auto.
  Qed.

  Fact vec_zero_plus v : vec_plus vec_zero v = v.
  Proof. 
    apply vec_pos_ext.
    intros p; unfold vec_zero, vec_plus. 
    repeat rewrite vec_pos_set; auto.
  Qed.
  
  Fact vec_zero_spec p : vec_pos vec_zero p = 0.
  Proof. unfold vec_zero; rewrite vec_pos_set; trivial. Qed.

  Fact vec_plus_comm v w : vec_plus v w = vec_plus w v.
  Proof.
    apply vec_pos_ext.
    intros p; unfold vec_zero, vec_plus.
    repeat rewrite vec_pos_set; lia.
  Qed.

  Fact vec_plus_assoc u v w : vec_plus u (vec_plus v w) = vec_plus (vec_plus u v) w.
  Proof.
    apply vec_pos_ext.
    intros p; unfold vec_zero, vec_plus.
    repeat rewrite vec_pos_set; lia.
  Qed.

  Fact vec_plus_is_zero u v : vec_zero = vec_plus u v -> u = vec_zero /\ v = vec_zero.
  Proof.
   unfold vec_zero, vec_plus; intros H; split; apply vec_pos_ext;
   intros p; apply f_equal with (f := fun v => vec_pos v p) in H;
   repeat rewrite vec_pos_set in * |- *; lia.
  Qed.
  
  Definition vec_one p : vec _ n := vec_set_pos (fun q => if pos_eq_dec p q then 1 else 0).
  
  Fact vec_one_spec_eq p q : p = q -> vec_pos (vec_one p) q = 1.
  Proof.
    intros [].
    unfold vec_one; rewrite vec_pos_set.
    destruct (pos_eq_dec p p) as [ | [] ]; auto.
  Qed.
  
  Fact vec_one_spec_neq p q : p <> q -> vec_pos (vec_one p) q = 0.
  Proof.
    intros H.
    unfold vec_one; rewrite vec_pos_set.
    destruct (pos_eq_dec p q) as [ | ]; auto.
    destruct H; auto.
  Qed.
  
End vec_plus.

Arguments vec_plus {n}.
Arguments vec_zero {n}.
Arguments vec_one {n}.

Reserved Notation " e '#>' x " (at level 58, format "e #> x").
Reserved Notation " e [ v / x ] " (at level 57, v at level 0, x at level 0, 
                                   left associativity, format "e [ v / x ]").

Local Notation " e '#>' x " := (vec_pos e x).
Local Notation " e [ v / x ] " := (vec_change e x v).

Tactic Notation "rew" "vec" :=
  repeat lazymatch goal with 
    |              |- context[ _[_/?x]#>?x ] => rewrite vec_change_eq with (p := x) (1 := eq_refl)
    | _ : ?x = ?y  |- context[ _[_/?x]#>?y ] => rewrite vec_change_eq with (p := x) (q := y)
    | _ : ?y = ?x  |- context[ _[_/?x]#>?y ] => rewrite vec_change_eq with (p := x) (q := y)
    | _ : ?x <> ?y |- context[ _[_/?x]#>?y ] => rewrite vec_change_neq with (p := x) (q := y)
    | _ : ?y <> ?x |- context[ _[_/?x]#>?y ] => rewrite vec_change_neq with (p := x) (q := y)
    |              |- context[ vec_pos vec_zero ?x ] => rewrite vec_zero_spec with (p := x)
    |              |- context[ vec_pos (vec_one ?x) ?x ] => rewrite vec_one_spec_eq with (p := x) (1 := eq_refl)
    | _ : ?x = ?y  |- context[ vec_pos (vec_one ?x) ?y ] => rewrite vec_one_spec_eq with (p := x) (q := y)
    | _ : ?y = ?x  |- context[ vec_pos (vec_one ?x) ?y ] => rewrite vec_one_spec_eq with (p := x) (q := y)
    | _ : ?x <> ?y |- context[ vec_pos (vec_one ?x) ?y ] => rewrite vec_one_spec_neq with (p := x) (q := y)
    | _ : ?y <> ?x |- context[ vec_pos (vec_one ?x) ?y ] => rewrite vec_one_spec_neq with (p := x) (q := y)
    | |- context[ _[_/?x][_/?x] ] => rewrite vec_change_idem with (p := x) 
    | |- context[ ?v[(?v#>?x)/?x] ] => rewrite vec_change_same with (p := x)
    | |- context[ _[_/?x]#>?y ] => rewrite vec_change_neq with (p := x) (q := y); [ | discriminate ]
    | |- context[ vec_plus vec_zero ?x ] => rewrite vec_zero_plus with (v := x)
    | |- context[ vec_plus ?x vec_zero ] => rewrite (vec_plus_comm x vec_zero); rewrite vec_zero_plus with (v := x)
    | |- context[ (vec_set_pos ?f) #> ?p ] => rewrite (vec_pos_set f p)
    | |- context[ (vec_map ?f ?v) #> ?p ] => rewrite (vec_pos_map f v p)
    | |- vec_plus ?x ?y = vec_plus ?y ?x => apply vec_plus_comm
  end; auto.

Tactic Notation "vec" "split" hyp(v) "with" ident(n) :=
  rewrite (vec_head_tail v); generalize (vec_head v) (vec_tail v); clear v; intros n v.

Tactic Notation "vec" "nil" hyp(v) := rewrite (vec_0_nil v).

Fact Forall2_vec_list X Y (R : X -> Y -> Prop) n v w : Forall2 R (@vec_list X n v) (vec_list w) <-> forall p, R (vec_pos v p) (vec_pos w p).
Proof.
  revert v w; induction n as [ | n IHn ]; intros v w.
  + vec nil v; vec nil w; split; simpl.
    * intros _ p; invert pos p.
    * constructor.
  + vec split v with x; vec split w with y.
    simpl vec_list; rewrite Forall2_cons_inv, IHn.
    split.
    * intros (H1 & H2) p; invert pos p; auto.
    * intros H; split.
      - apply (H pos0).
      - intro; apply (H (pos_nxt _)).
Qed.

Fact vec_zero_S n : @vec_zero (S n) = 0##vec_zero.
Proof. auto. Qed.

Fact vec_one_fst n : @vec_one (S n) pos0 = 1##vec_zero.
Proof. apply vec_pos_ext; intros p; pos_inv p; rew vec. Qed.

Lemma vec_change_comm {X} n v p q x y : p <> q ->
vec_change (@vec_change X n v p x) q y = vec_change (vec_change v q y) p x.
Proof.
  intros Hpq. apply vec_pos_ext; intros r.
  destruct (pos_eq_dec r p); destruct (pos_eq_dec r q); subst; now rew vec.
Qed.

Fact vec_one_nxt n p : @vec_one (S n) (pos_nxt p) = 0##vec_one p.
Proof.
  apply vec_pos_ext.
  unfold vec_one.
  intros q; rewrite vec_pos_set.
  pos_inv q.
  + simpl; auto.
  + rewrite <- vec_pos_tail.
    simpl vec_tail.
    rewrite vec_pos_set.
    destruct (pos_eq_dec p q) as [ | C ].
    * subst.
      destruct (pos_eq_dec (pos_nxt q) (pos_nxt q)) as [ | [] ]; auto.
    * destruct (pos_eq_dec (pos_nxt p) (pos_nxt q)) as [ | ]; auto.
      destruct C; apply pos_nxt_inj; auto.
Qed.

Fact vec_plus_cons n x v y w : @vec_plus (S n) (x##v) (y##w) = x+y ## vec_plus v w.
Proof.
  apply vec_pos_ext; unfold vec_plus.
  intros p; pos_inv p; repeat (rewrite vec_pos_set; simpl; auto).
Qed.

Fact vec_change_succ n v p : v[(S (v#>p))/p] = @vec_plus n (vec_one p) v.
Proof.
  apply vec_pos_ext.
  intros q.
  destruct (pos_eq_dec p q); rew vec;
  rewrite vec_pos_plus; rew vec; subst; auto.
Qed.

Fact vec_change_pred n v p u : v#>p = S u -> v = @vec_plus n (vec_one p) (v[u/p]).
Proof.
  intros Hu.
  apply vec_pos_ext.
  intros q.
  destruct (pos_eq_dec p q); rew vec;
  rewrite vec_pos_plus; rew vec; subst; auto.
Qed.

Fixpoint vec_sum n (v : vec nat n) := 
  match v with 
    | vec_nil => 0
    | x##w    => x + vec_sum w
  end.
  
Fact vec_sum_plus n v w : @vec_sum n (vec_plus v w) = vec_sum v + vec_sum w.
Proof.
  revert w; induction v; intros w.
  1: rewrite (vec_0_nil (vec_plus _ _)), (vec_0_nil w); auto.
  rewrite (vec_head_tail w), vec_plus_cons; simpl.
  rewrite IHv; lia.
Qed.

Fact vec_sum_zero n : @vec_sum n vec_zero = 0.
Proof. induction n; simpl; auto. Qed.

Fact vec_sum_one n p : @vec_sum n (vec_one p) = 1.
Proof.
  revert p; induction n as [ | n IHn ]; intros p.
  1: invert pos p.
  pos_inv p.
  + rewrite vec_one_fst.
    simpl; f_equal; apply vec_sum_zero.
  + rewrite vec_one_nxt.
    unfold vec_sum; fold vec_sum.
    rewrite IHn; auto.
Qed.
  
Fact vec_sum_is_zero n v : @vec_sum n v = 0 -> v = vec_zero.
Proof.
  induction v as [ | n x v IHv ]; simpl; auto.
  simpl; rewrite vec_zero_S; intros; f_equal.
  + lia.
  + apply IHv; lia.
Qed.

Fact vec_sum_is_nzero n v : 0 < @vec_sum n v -> { p : _ & { w | v = vec_plus (vec_one p) w } }.
Proof.
  induction v as [ | [ | x] n v IHv ]; intros Hv; simpl in Hv.
  + lia.
  + apply IHv in Hv.
    destruct Hv as (p & w & Hw).
    exists (pos_nxt p), (0##w); rewrite vec_one_nxt.
    rewrite vec_plus_cons; f_equal; auto.
  + exists pos0, (x##v).
    rewrite vec_one_fst, vec_plus_cons; rew vec.
Qed.

Section vec_nat_induction.

  (* Specialized induction on vec nat n, with constant n *)

  Variable (n : nat) (P : vec nat n -> Type).
  
  Hypothesis HP0 : P vec_zero.
  Hypothesis HP1 : forall p, P (vec_one p).
  Hypothesis HP2 : forall v w, P v -> P w -> P (vec_plus v w).
  
  Theorem vec_nat_induction v : P v.
  Proof using HP0 HP1 HP2.
    induction v as [ v IHv ] using (measure_rect (@vec_sum n)).
    case_eq (vec_sum v).
    + intros Hv; apply vec_sum_is_zero in Hv; subst; auto.
    + intros x Hx.
      destruct (vec_sum_is_nzero v) as (p & w & Hw).
      * lia.
      * subst.
        apply HP2; auto.
        apply IHv.
       rewrite vec_sum_plus, vec_sum_one; auto.
  Qed.
  
End vec_nat_induction.

Section vec_map_list.

  Variable X : Type.

  (* morphism between vec nat n and (list X)/~p *)

  Fixpoint vec_map_list X n v : (pos n -> X) -> list X :=
    match v in vec _ m return (pos m -> _) -> _ with
      | vec_nil => fun _ => nil
      | a##v    => fun f => list_repeat (f pos0) a ++ vec_map_list v (fun p => f (pos_nxt p))
    end.

  Fact vec_map_list_zero n f : vec_map_list (@vec_zero n) f = @nil X.
  Proof. revert f; induction n; intros f; simpl; auto. Qed.

  Fact vec_map_list_one n p f : vec_map_list (@vec_one n p) f = f p :: @nil X.
  Proof.
    revert f; induction p; intro.
    + rewrite vec_one_fst; simpl; rewrite vec_map_list_zero; auto.
    + rewrite vec_one_nxt; simpl; rewrite IHp; auto.
  Qed.

  (* The morphism *)

  Fact vec_map_list_plus n v w f : @vec_map_list X n (vec_plus v w) f ~p vec_map_list v f ++ vec_map_list w f.
  Proof.
    revert v w f; induction n as [ | n IHn ]; intros v w f.
    + rewrite (vec_0_nil (vec_plus v w)), (vec_0_nil v), (vec_0_nil w); simpl; auto.
    + rewrite (vec_head_tail v), (vec_head_tail w), vec_plus_cons.
      generalize (vec_head v) (vec_tail v) (vec_head w) (vec_tail w); clear v w; intros x v y w.
      simpl.
      rewrite list_repeat_plus.
      solve list eq; apply Permutation_app; auto.
      apply Permutation_trans with (list_repeat (f pos0) y 
                                 ++ vec_map_list v (fun p => f (pos_nxt p)) 
                                 ++ vec_map_list w (fun p => f (pos_nxt p))).
      * apply Permutation_app; auto.
      * do 2 rewrite <- app_ass.
        apply Permutation_app; auto.
       apply Permutation_app_comm.
  Qed.

End vec_map_list.

Fact map_vec_map_list X Y (f : X -> Y) n v g : map f (@vec_map_list _ n v g) = vec_map_list v (fun p => f (g p)).
Proof.
  revert g; induction v; intro; simpl; auto.
  rewrite map_app; f_equal; auto.
  rewrite map_list_repeat; auto.
Qed.

Section fun2vec.

  Variable X : Type.

  Fixpoint fun2vec i n f : vec X _ :=
    match n with 
      | 0   => vec_nil
      | S n => f i##fun2vec (S i) n f
    end.

  Fact fun2vec_id i n f : fun2vec i n f = vec_set_pos (fun p => f (i+pos2nat p)).
  Proof.
    revert i; induction n as [ | n IHn ]; intros i; simpl; f_equal; auto.
    rewrite IHn.
    apply vec_pos_ext; intros; do 2 rewrite vec_pos_set; f_equal.
    rewrite pos2nat_nxt; lia.
  Qed.

  Fact fun2vec_lift i n f : fun2vec i n (fun j => f (S j)) = fun2vec (S i) n f.
  Proof. revert i f; induction n; intros; simpl; f_equal; auto. Qed.

  Fact vec_pos_fun2vec i n f p : vec_pos (fun2vec i n f) p = f (i+pos2nat p).
  Proof. rewrite fun2vec_id, vec_pos_set; auto. Qed.

  Definition vec2fun n (v : vec X n) x i := 
    match le_lt_dec n i with
      | left  _ => x
      | right H => vec_pos v (nat2pos H)
    end.

  Fact fun2vec_vec2fun n v x : fun2vec 0 n (@vec2fun n v x) = v.
  Proof.
    apply vec_pos_ext.
    intros p; rewrite vec_pos_fun2vec; simpl.
    unfold vec2fun.
    generalize (pos2nat_prop p).
    destruct (le_lt_dec n (pos2nat p)); try lia. 
    rewrite nat2pos_pos2nat; auto.
  Qed.

  Fact vec2fun_fun2vec n f x i : i < n -> @vec2fun n (fun2vec 0 n f) x i = f i.
  Proof.
    intros H.
    unfold vec2fun.
    destruct (le_lt_dec n i); try lia.
    rewrite vec_pos_fun2vec, pos2nat_nat2pos; auto.
  Qed. 

End fun2vec.

Section map_vec_pos_equiv.

  Variable (X : Type) (R : X -> X -> Prop)
           (Y : Type) (T : Y -> Y -> Prop)
           (T_refl : forall y, T y y)
           (T_trans : forall x y z, T x y -> T y z -> T x z). 

  Theorem map_vec_pos_equiv n (f : vec X n -> Y) : 
           (forall p v x y, R x y -> T (f (v[x/p])) (f (v[y/p])))
        -> forall v w, (forall p, R (v#>p) (w#>p)) -> T (f v) (f w).
  Proof using T_refl T_trans.
    revert f; induction n as [ | n IHn ]; intros f Hf v w H.
    + vec nil v; vec nil w; auto.
    + apply T_trans with (y := f (v[(w#>pos0)/pos0])).
      * rewrite <- (vec_change_same v pos0) at 1; auto.
      * revert H.
        vec split v with a; vec split w with b; intros H; simpl.
        apply IHn with (f := fun v => f(b##v)).
        - intros p q x y Hxy.
          apply (Hf (pos_nxt p) (b##q)); auto.
        - intros p; apply (H (pos_nxt p)).
  Qed. 

End map_vec_pos_equiv.
