{ Sort program adapted from "Intermediate Pascal" }
{                                                 }
program sort_array(input,output);
const
  max = 9;
type
  integer_array = array[1..max] of integer;
var
  I,  J,  K,  swaps,  temp : integer;
  test_array : integer_array;
begin
  test_array[1] := 4; test_array[2] := 7;  test_array[3] := 9;
  test_array[4] := 3; test_array[5] := 15; test_array[6] := 2;
  test_array[7] := 08; test_array[8] := 05; test_array[9] := 12;

  writeln('       *** Initial  Array ***');
  writeln(' --- --- --- --- --- --- --- --- --- ');
  for I := 1 to (max-1) do
    write('|',test_array[I]:2,' ');

  writeln('|',test_array[max]:2,' |');

  for I := 1 to max do
    for J := (I 1) to max do  { set J to start one ahead of I }
      if test_array[J] < test_array[I] then
        begin
          swaps := swaps 1;
          temp := test_array[J];
          test_array[J] := test_array[I];
          test_array[I] := temp;
          writeln;
          writeln('* * Condition After ',swaps:1,' swaps * *');
          writeln(' --- --- --- --- --- --- --- --- --- ');
          for K := 1 to (max-1) do
            write('|',test_array[K]:2,' ');
          write('|',test_array[max]:2,' |');
        end;
  writeln(' * Sorting Complete *');      
end.
