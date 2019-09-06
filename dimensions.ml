#use "topfind";;
#require "fpath";;
#require "bos";;

type sponsor_level =
  | Platinum
  | Gold
  | Silver
  | Bronze

type dims = {
    width: int;
    height: int;
}

type input = {
    sponsor_level : sponsor_level;
    img: Fpath.t;
}

type output = dims

module Error_code = struct
  let invalid_sponsor = 1
  let invalid_image_path = 2
  let not_enough_args = 3
  let error_computing_image_dimensions = 4
end

let desired_height = function
  | Platinum -> 60
  | Gold -> 55
  | Silver -> 50
  | Bronze -> 45

let process get_dims (data : input) : output =
  let height = desired_height data.sponsor_level in
  let input_dims = get_dims data.img in
  let width = input_dims.width * height / input_dims.height in
  { height; width }

let get_dims img =
  let exit_err () = exit Error_code.error_computing_image_dimensions in
  let open Bos in
  let cmd = Cmd.(v "identify" % p img) in
  let output = match OS.Cmd.(run_out cmd |> to_string) with
    | Error _ ->
       Printf.eprintf "Error running 'identify'.\n%!";
       exit_err ()
    | Ok output -> output
  in
  (* example output:
     foo.png PNG 300x140 300x140+0+0 8-bit sRGB 883B 0.000u 0:00.000 *)
  Scanf.ksscanf output
    (fun _ _ ->
      Printf.eprintf "Unable to parse 'identify' output (%S)\n%!" output;
      exit_err ())
    " %_s %_s %dx%d"
    (fun width height -> { width; height })

let usage out =
  output_string out "Arguments: <sponsor-level> <img>\n";
  output_string out "Example: silver img/foo.png\n";
  flush out   
 
let () =
  (* no command-line arguments: print usage *)
  if Array.length Sys.argv = 0 then begin
    usage stdout;
    exit 0
  end else if Array.length Sys.argv < 3 then begin
    usage stderr;
    exit Error_code.not_enough_args
  end

let sponsor_level =
  let levels = [
      ("platinum", Platinum);
      ("gold", Gold);
      ("silver", Silver);
      ("bronze", Bronze);
    ] in
  let input = String.lowercase_ascii Sys.argv.(1) in
  try List.assoc input levels
  with Not_found ->
    Printf.eprintf "Unknown sponsor level %S. Use one of: %s.\n%!"
      input (String.concat ", " (List.map fst levels));
    exit Error_code.invalid_sponsor

let img =
  let input = Sys.argv.(2) in
  try Fpath.v input
  with _ ->
    Printf.eprintf "Invalid image %S\n%!" input;
    exit Error_code.invalid_image_path

let () =
  let input : input = { sponsor_level; img } in
  let output = process get_dims input in
  Printf.printf
{|<img src=%S
   alt=""
   style="width: %dpx; height: %dpx;" />
|}
    (Fpath.to_string img)
    output.width output.height;
  exit 0
