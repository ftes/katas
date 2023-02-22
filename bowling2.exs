defmodule Player do
  def parse(rolls), do: parse(rolls, 1, [])

  def score(frames)
  def score([]), do: 0
  def score([frame | rest]), do: Frame.score(frame, next_rolls(rest)) + score(rest)

  defp parse(todo_rolls, frame_count, frame_rolls)
  defp parse([], _, []), do: []
  defp parse([], 10, [_, _, _] = frame), do: [{:last, frame}]
  defp parse([], 10, [r1, r2] = frame) when r1 + r2 < 10, do: [{:last, frame}]
  defp parse([r | rest], 10, frame), do: parse(rest, 10, frame ++ [r])
  # Not tail recursive. Last call is list prepend. But probably not an issue: https://www.erlang.org/doc/efficiency_guide/myths.html#id61840
  defp parse([10 | rest], i, []), do: [{:strike, [10]} | parse(rest, i+1, [])]
  defp parse([r | rest], i, []), do: parse(rest, i, [r])
  defp parse([r2 | rest], i, [r1]) when r1+r2==10, do: [{:spare, [r1, r2]} | parse(rest, i+1, [])]
  defp parse([r2 | rest], i, [r1]), do: [{:normal, [r1, r2]} | parse(rest, i+1, [])]

  defp next_rolls(frames)
  defp next_rolls([]), do: []
  defp next_rolls([{_, rolls} | rest]), do: rolls ++ next_rolls(rest)
end

defmodule Frame do
  def score(frame, next_rolls)
  def score({:strike, [10]}, [r1, r2 | _]), do: 10 + r1 + r2
  def score({:spare, [r1, r2]}, [r3 | _]), do: r1 + r2 + r3
  def score({_, rolls}, _), do: Enum.sum(rolls)
end

ExUnit.start()

defmodule Tests do
  use ExUnit.Case, async: true

  test "player score" do
    assert 1 == [1, 0] |> Player.parse() |> Player.score()
    assert 10 == [1, 9] |> Player.parse() |> Player.score()
    assert 20 == [1, 9, 5, 0] |> Player.parse() |> Player.score()
    assert 28 == [10, 5, 4] |> Player.parse() |> Player.score()
    assert 48 == [10, 10, 4, 3] |> Player.parse() |> Player.score()
    assert 115 == [1, 4, 4, 5, 6, 4, 5, 5, 10, 0, 1, 7, 3, 6, 4, 0, 10, 2, 8, 6] |> Player.parse() |> Player.score()
    assert 4 == [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 3] |> Player.parse() |> Player.score()
    assert 30 == [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 10, 10] |> Player.parse() |> Player.score()
  end
end
