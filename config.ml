(* (c) 2017, 2018 Hannes Mehnert, all rights reserved *)

open Mirage

let disk = direct_kv_rw "data"

let axfr =
  let doc = Key.Arg.info ~doc:"Allow unauthenticated zone transfer." ["axfr"] in
  Key.(create "axfr" Arg.(flag doc))

let dns_handler =
  let packages =
    [
      package "logs" ;
      package ~sublibs:[ "zone" ; "mirage" ] "dns-server";
      package "dns-tsig";
      package ~min:"2.0.0" "mirage-kv";
    ]
  in
  foreign
    ~keys:[Key.abstract axfr]
    ~packages
    "Unikernel.Main"
    (random @-> pclock @-> mclock @-> time @-> stackv4v6 @-> kv_rw @-> job)

let () =
  register "primary"
    [dns_handler $ default_random $ default_posix_clock $ default_monotonic_clock $ default_time $ generic_stackv4v6 default_network $ disk ]
