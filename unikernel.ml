(* (c) 2017, 2018 Hannes Mehnert, all rights reserved *)

open Lwt.Infix

module Main (R : Mirage_random.S) (P : Mirage_clock.PCLOCK) (M : Mirage_clock.MCLOCK) (T : Mirage_time.S) (S : Tcpip.Stack.V4V6) (KV : Mirage_kv.RO) = struct

  module D = Dns_server_mirage.Make(P)(M)(T)(S)

  let start _rng _pclock _mclock _time s kv =
    KV.get kv (Mirage_kv.Key.v "zone") >>= function
    | Error e ->
      Logs.err (fun m -> m "error reading zone file %a" KV.pp_error e);
      Lwt.fail_with "zone file read failed"
    | Ok data -> match Dns_zone.parse data with
      | Error (`Msg msg) ->
        Logs.err (fun m -> m "error parsing zone file %s" msg);
        Lwt.fail_with "zone file parsing failed"
      | Ok rrs ->
        let trie = Dns_trie.insert_map rrs Dns_trie.empty in
        match Dns_trie.check trie with
        | Error e ->
          Logs.err (fun m -> m "error %a during check()" Dns_trie.pp_zone_check e) ; exit 64
        | Ok () ->
          let t = Dns_server.Primary.create ~rng:R.generate trie in
          D.primary s t ;
          S.listen s
end
