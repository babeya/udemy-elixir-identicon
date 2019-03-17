defmodule Identicon do
  @square_size 50
  @nb_square_per_row 5
  @image_size @square_size * @nb_square_per_row

  def main(input) do 
    input 
    |> hash_input
    |> pick_color 
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image 
    |> save_image(input)
  end

  def hash_input(input) do 
    %Identicon.Image{ 
      hex: :crypto.hash(:md5, input) |> :binary.bin_to_list 
    }
  end

  def pick_color(%Identicon.Image{hex: [r, g, b | _tail]} = image) do 
    %Identicon.Image{image | color: {r, g, b }}
  end 

  def mirror_row([first, second, _tail] = row) do 
    row ++ [ second, first ]
  end

  def build_grid(%Identicon.Image{hex: hex} = image) do 
    %Identicon.Image{image | grid: 
      hex  
      |> Enum.chunk_every(3, 3, :discard)
      |> Enum.map(&mirror_row/1)
      |> List.flatten
      |> Enum.with_index
    }
  end

  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    %Identicon.Image{image | grid: Enum.filter(grid, 
      fn ({ code, _index }) ->
        rem(code, 2) == 0
      end
    )}    
  end

  def build_pixel_map(%Identicon.Image{grid: grid} = image) do 
    pixel_map = Enum.map grid, 
      fn ({ _code, index}) -> 
        horizontal = rem(index, @nb_square_per_row) * @square_size
        vertical = div(index, @nb_square_per_row) * @square_size

        {{ horizontal, vertical }, { horizontal + @square_size, vertical + @square_size }}
      end

    %Identicon.Image{ image | pixel_map: pixel_map }
  end

  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do 
    image = :egd.create(@image_size, @image_size)
    fill = :egd.color(color)

    Enum.each pixel_map, fn({ start, stop }) ->
      :egd.filledRectangle(image, start, stop, fill)
    end

    :egd.render(image)
  end

  def save_image(image, filename) do
    File.write("#{filename}.png", image)
  end 

end
