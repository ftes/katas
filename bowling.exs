defmodule Frame do
  def score([10], [b1, b2 | _]), do: 10 + b1 + b2
  def score([a1, a2], [b1 | _]) when a1 + a2 == 10, do: a1 + a2 + b1
  def score(a, _), do: Enum.sum(a)
end

defmodule Player do
  def chunk(rolls) do
    Enum.chunk_while(
      rolls,
      {[], 1},
      fn
        _, {_, 11} -> raise("unexpected")
        r3, {[r2, r1], 10} -> {:halt, {[r1, r2, r3], 10}}
        r2, {[r1], 10} when r1 + r2 < 10 -> {:halt, {[r1, r2], 10}}
        r2, {r, 10} -> {:cont, {[r2 | r], 10}}
        10, {[], frame} -> {:cont, [10], {[], frame + 1}}
        r2, {[r1], frame} -> {:cont, [r1, r2], {[], frame + 1}}
        r1, {[], frame} -> {:cont, {[r1], frame}}
      end,
      fn
        {frame, _} -> {:cont, frame, []}
      end
    )
  end

  def score([i | _] = rolls) when is_integer(i), do: rolls |> chunk() |> score()

  def score([l | _] = frames) when is_list(l) do
    frames
    |> Enum.with_index()
    |> Enum.map(fn {f, i} ->
      Frame.score(f, frames |> Enum.slice((i + 1)..-1) |> List.flatten())
    end)
    # https://github.com/elixir-lang/elixir/issues/12416
    # |> Enum.chunk_every(3, 1, [[], []])
    # |> Enum.map(fn [f1, f2, f3] -> Frame.score(f1, f2 ++ f3) |> IO.inspect() end)
    |> Enum.sum()
  end
end

ExUnit.start()

defmodule Tests do
  use ExUnit.Case, async: true

  test "player score" do
    assert 1 == [1, 0] |> Player.score()
    assert 10 == [1, 9] |> Player.score()
    assert 20 == [1, 9, 5, 0] |> Player.score()
    assert 28 == [10, 5, 4] |> Player.score()
    assert 48 == [10, 10, 4, 3] |> Player.score()
    assert 115 == [1, 4, 4, 5, 6, 4, 5, 5, 10, 0, 1, 7, 3, 6, 4, 0, 10, 2, 8, 6] |> Player.score()
    assert 4 == [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 3] |> Player.score()
    assert 30 == [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 10, 10] |> Player.score()
  end
end
