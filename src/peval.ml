open Printf
open Ptypes
open Putils

module SymbolTable = Map.Make(String)

(** Returns an integer as the value of an expression. *)
let rec eval_expr (expr: expr) (env: int SymbolTable.t): int =
  match expr with
	| Num integer -> integer
	| Var name -> SymbolTable.find name env
	| Op (op, expr1, expr2) -> eval_op op (eval_expr expr1 env) (eval_expr expr2 env)

(** Returns a boolean as the value of a condition. *)
let eval_cond (cond: cond) (env: int SymbolTable.t): bool =
  let (left_expr, comp, right_expr) = cond in
	eval_comp comp (eval_expr left_expr env) (eval_expr right_expr env)

(* Evaluates a Polish block. *)
let eval_block (block: block): int SymbolTable.t =

  let rec eval_block_rec (block: block) (env: int SymbolTable.t): int SymbolTable.t =
    match block with
    | [] -> env
    | (_, instr)::block' ->
      let env' =
	      match instr with
	      | Set (name, expr) -> SymbolTable.add name (eval_expr expr env) env
	      | Print (expr) -> printf "%i\n" (eval_expr expr env); env
	      | Read (name) -> printf "%s? " name; SymbolTable.add name (read_int ()) env
	      | If (cond, if_block, else_block) ->
	        let cond_res = eval_cond cond env in
		    if cond_res then eval_block_rec if_block env
		    else eval_block_rec else_block env
	      | While (cond, block) ->
		    let rec parcour_while block cond env =
			  let cond_res = eval_cond cond env in
			  if cond_res then parcour_while block cond (eval_block_rec block env)
			  else env in
			parcour_while block cond env in
      eval_block_rec block' env' in

  eval_block_rec block SymbolTable.empty