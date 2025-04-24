(* Calculate the mean of a list of integers *)
let mean lst =
  match lst with
  | [] -> 0.0
  | _ -> 
      let sum = List.fold_left (+) 0 lst in
      float_of_int sum /. float_of_int (List.length lst)

(* Calculate the median of a list of integers *)
let median lst =
  match lst with
  | [] -> 0.0
  | _ ->
      let sorted = List.sort compare lst in
      let len = List.length sorted in
      if len mod 2 = 1 then
        (* Odd number of elements *)
        float_of_int (List.nth sorted (len / 2))
      else
        (* Even number of elements *)
        let mid_right = List.nth sorted (len / 2) in
        let mid_left = List.nth sorted (len / 2 - 1) in
        float_of_int (mid_left + mid_right) /. 2.0

(* Calculate the mode of a list of integers *)
let mode lst =
  match lst with
  | [] -> []
  | _ ->
      (* Group consecutive equal elements and count them *)
      let sorted = List.sort compare lst in
      
      (* Helper function to count frequencies *)
      let count_frequencies lst =
        let rec helper l current_val current_count acc =
          match l with
          | [] -> (current_val, current_count) :: acc
          | hd :: tl ->
              if hd = current_val then
                helper tl current_val (current_count + 1) acc
              else
                helper tl hd 1 ((current_val, current_count) :: acc)
        in
        match lst with
        | [] -> []
        | hd :: tl -> helper tl hd 1 []
      in
      
      let frequencies = count_frequencies sorted in
      
      (* Find the maximum frequency *)
      let max_freq = 
        List.fold_left (fun acc (_, count) -> max acc count) 0 frequencies
      in
      
      (* If no value appears more than once, there is no mode *)
      if max_freq = 1 then []
      else
        (* Extract values with the maximum frequency *)
        List.fold_left 
          (fun acc (value, count) -> if count = max_freq then value :: acc else acc) 
          [] frequencies

(* String splitting function to replace Str.split *)
let split_string str =
  let is_whitespace c = c = ' ' || c = '\t' in
  let len = String.length str in
  let rec aux i j result =
    if i >= len then
      if i > j then (String.sub str j (i - j)) :: result
      else result
    else if is_whitespace str.[i] then
      if i > j then
        aux (i + 1) (i + 1) ((String.sub str j (i - j)) :: result)
      else
        aux (i + 1) (i + 1) result
    else
      aux (i + 1) j result
  in
  List.rev (aux 0 0 [])

(* String to int conversion with error handling *)
let safe_int_of_string s =
  try Some (int_of_string s)
  with Failure _ -> None

(* Main function *)
let () =
  Printf.printf "Ocaml => Enter integers separated by spaces (then press Enter): ";
  
  (* Read input line and split by whitespace *)
  let input_line = read_line () in
  let input_strings = split_string input_line in
  
  (* Convert strings to integers *)
  let numbers = 
    List.fold_left 
      (fun acc s -> 
        match safe_int_of_string s with
        | Some n -> n :: acc
        | None -> acc)
      [] input_strings
    |> List.rev
  in
  
  (* Calculate and display statistics *)
  Printf.printf "Input list: [%s]\n" 
    (String.concat ", " (List.map string_of_int numbers));
  
  Printf.printf "Mean: %.2f\n" (mean numbers);
  Printf.printf "Median: %.2f\n" (median numbers);
  
  let modes = mode numbers in
  match modes with
  | [] -> Printf.printf "Mode: No mode (all values appear equally often)\n"
  | _ -> 
      Printf.printf "Mode: [%s]\n" 
        (String.concat ", " (List.map string_of_int modes))