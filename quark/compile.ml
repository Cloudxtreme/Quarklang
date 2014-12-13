open Semantic

(*********** Configs ***********)
(* g++ compilation flags *)
let gpp_command = "g++ -std=c++11 -O3"

(* where to find the libraries, relative to the executable *)
let relative_lib_path = "../lib"

(* detect OS and select the appropriate quark static library *)
let quark_static_lib = "quark_" ^ String.lowercase (Sys.os_type)

(*********** Main entry of Quark compiler ***********)
let _ =
  (* from http://rosettacode.org/wiki/Command-line_arguments#OCaml *)
  let srcfile = ref "" 
    and cppfile = ref "" 
    and exefile = ref "" in
  let speclist = [
      ("-s", Arg.String(fun src -> 
              let srclen = String.length src in
              if Sys.file_exists src then
                let ext = Preprocessor.extension in (* enforce .qk extension *)
                let extlen = String.length ext in
                if srclen > extlen && 
                  String.sub src (srclen - extlen) extlen = ext then
                  srcfile := src
                else
                  failwith @@ "Quark source file must have extension " ^ ext
              else
                failwith @@ "Source file doesn't exist: " ^ src),
        ": quark source file");

      ("-c", Arg.String(fun cpp -> cppfile := cpp), 
        ": generated C++ file. If unspecified, print generated code to stdout");

      ("-o", Arg.String(fun exe -> exefile := exe), 
        ": compile to executable. Requires g++ (version >= 4.7)");
  ] in
  let usage = "usage: quarkc -s source.qk [-c output.cpp ] [-o executable]" in
  let _ = Arg.parse speclist
    (* handle anonymous args *)
    (fun arg -> failwith @@ "Unrecognized arg: " ^ arg)
    usage
  in
  let _ = if !srcfile = "" then
      failwith "Please specify a source file with option -s"
  in
  (* Preprocessor: handles import and elif *)
  let processed_code = Preprocessor.process !srcfile in
  (* Scanner: converts processed code to stream of tokens *)
    (* let lexbuf = Lexing.from_channel stdin in *)
  let lexbuf = Lexing.from_string processed_code in
  (* Parser: converts scanned tokens to AST *)
  let ast = Parser.top_level Scanner.token lexbuf in
  (* Semantic checker: verifies and converts AST to SAST  *)
  let env = { 
    var_table = StrMap.empty; 
    func_table = StrMap.empty;
    func_current = "";
    depth = 0;
    is_returned = true;
    in_loop = false;
  } in 
  let _, sast = Semantic.gen_sast env ast in
  (* Code generator: converts SAST to C++ code *)
  let code = Generator.gen_code sast in
  let code = Generator.header_code ^ code in
  (* Output the generated code *)
  let _ = if !cppfile = "" then (* print to stdout *)
    print_endline code
  else
    let file_channel = open_out !cppfile in
      output_string file_channel code;
      close_out file_channel
  in
  (* Compile to binary executable with g++ *)
  if !exefile <> "" then
    if !cppfile = "" then
      failwith "Please specify -c <output.cpp> before compiling to executable"
    else
      let lib_folder = Filename.concat 
            (Filename.dirname Sys.argv.(0)) relative_lib_path in
      let lib_path name = Filename.concat lib_folder name in
      let lib_exists name = Sys.file_exists (lib_path name) in
      if Sys.file_exists lib_folder then
        begin
        if not (lib_exists "Eigen") then
          (* extract from Eigen.tar library *)
          if lib_exists "Eigen.tar" then
            let cmd = "tar xzf " 
              ^ lib_path "Eigen.tar" ^ " -C " ^ lib_folder in
            prerr_endline @@ "Extracting Eigen library from tar:\n" ^ cmd ^"\n";
            ignore @@ Sys.command cmd
          else
            failwith "Neither lib/Eigen/ nor lib/Eigen.tar found" 
        ;
        (* Invokes g++ *)
        let cmd = gpp_command ^ " -I " ^ lib_folder
            ^ " -static " ^ !cppfile ^ " -L " ^ lib_folder
            ^ " -l" ^ quark_static_lib ^ " -o " ^ !exefile in
        prerr_endline @@ "Invoking g++ command: \n" ^ cmd;
        ignore @@ Sys.command cmd;
        end
      else
        failwith "Library folder ../lib doesn't exist. Cannot compile to executable. "