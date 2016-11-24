open Core.Std

module type TERM_LANG = sig
  type t
  type var
  val parse_var : string -> var
  val make_var : unit -> var
  val pp_var : Format.formatter -> var -> unit
  val pp_t : Format.formatter -> t -> unit
end

module type FORM_LANG = sig
  type t
  val parse_form : string -> t
  val pp_form : Format.formatter -> t -> unit
end

module type LOGIC = sig
  type term_var
  type term
  type form
  
  type hypos = (term_var * form) list
  type sequent = hypos * form
  
  type rule = (sequent -> sequent list) *
              ((sequent * term) list -> term)
  
  type proof = Sequent of sequent
             | Proof of sequent * rule * proof list
  type complete_proof
  
  exception InvalidLabel of term_var * hypos
  exception InvalidDecomposition of term_var option * sequent
  exception InvalidSubgoals of term_var option * (sequent * term) list
  
  val take_last : hypos -> int -> hypos
  val split : hypos -> term_var -> hypos * form * hypos
  val parse_sequent : string -> sequent
  val proof_of_sequent : sequent -> proof Or_error.t
  val apply_rule : rule -> sequent -> proof
  val complete : proof -> complete_proof option
  val extract_term : complete_proof -> term
  val pp_proof : Format.formatter -> proof -> unit
end

module Logic : functor (T : TERM_LANG) (F : FORM_LANG) ->
  LOGIC with type term_var = T.var and type term = T.t and type form = F.t

module type PROOF_SYSTEM = sig
  include LOGIC
  val parse_rule : string -> rule option
end
