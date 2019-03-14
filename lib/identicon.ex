defmodule Identicon do
  
  def main(input) do 
    input 
    |> hash_input 
  end

  def hash_input(input) do 
    %Identicon.Image{ 
      hex: :crypto.hash(:md5, input)
            |> :binary.bin_to_list 
    }
  end
  
end
