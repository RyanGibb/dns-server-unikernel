(* (c) 2017, 2018 Hannes Mehnert, all rights reserved *)

open Mirage

let disk = generic_kv_ro "data"

let dns_handler =
  let packages = [
    package "logs" ;
    package ~min:"6.2.2" ~sublibs:["mirage"; "zone"] "dns-server";
    package "dns-tsig";
    package ~min:"2.0.0" "mirage-kv";
  ] in
  foreign
    ~packages
    "Unikernel.Main"
    (random @-> pclock @-> mclock @-> time @-> stackv4v6 @-> kv_ro @-> job)

let () =
  register "ocaml-dns"
    [dns_handler $ default_random $ default_posix_clock $ default_monotonic_clock $
     default_time $ generic_stackv4v6 default_network $ disk]

