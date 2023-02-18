defmodule Frame do
  def score([10], [b1, b2 | _]), do: 10 + b1 + b2
  def score([a1, a2], [b1 | _]) when a1 + a2 == 10, do: a1 + a2 + b1
  def score(a, _), do: Enum.sum(a)
end

defmodule Player do
  def chunk(rolls) do
    Enum.chunk_while(rolls, {[], 1}, fn
      r3, {[r1, r2], 10} -> {:halt, {[r1, r2, r3], 10}}
      r2, {[r1], 10} when r1 + r2 < 10 -> {:halt, {[r1, r2], 10}}
      r2, {[r1], 10} -> {:cont, {[r1, r2], 10}}
      10, {[], frame} -> {:cont, [10], {[], frame + 1}}
      r2, {[r1], frame} -> {:cont, [r1, r2], {[], frame + 1}}
      r1, {[], frame} -> {:cont, {[r1], frame}}
    end, fn
      {frame, _} -> {:cont, frame, []}
    end)
  end

  def score(frames) do
    frames
    |> Enum.with_index()
    |> Enum.map(fn {f, i} -> Frame.score(f, frames |> Enum.slice(i+1..-1) |> List.flatten()) end)
    # https://github.com/elixir-lang/elixir/issues/12416
    # |> Enum.chunk_every(3, 1, [[], []])
    # |> Enum.map(fn [f1, f2, f3] -> Frame.score(f1, f2 ++ f3) |> IO.inspect() end)
    |> Enum.sum()
  end
end

[
  1, 4,
  4, 5,
  6, 4,
  5, 5,
  10,
  0, 1,
  7, 3,
  6, 4,
  0, 10,
  2, 8, 6
]
|> Player.chunk()
|> Player.score()
|> IO.inspect()
