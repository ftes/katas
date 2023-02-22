defmodule Player do
  def score(frames) do
    frames
    |> Enum.map(&Frame.score/1)
    |> Enum.sum()
  end

  def parse(rolls), do: parse(rolls, 1)

  def parse([], _), do: []
  def parse([10], 10), do: [{:incomplete, [10], []}]
  def parse([x, y], 10) when x + y >= 10, do: [{:incomplete, [x, y], []}]
  def parse([x, y, z], 10) when x + y >= 10, do: [{:last, [x, y, z], []}]
  def parse([x, y], 10), do: [{:last, [x, y], []}]
  def parse([10 | rest], i), do: [{:strike, [10], next_two(rest)} | parse(rest, i+1)]
  def parse([x], _), do: [{:incomplete, [x], []}]
  def parse([x, y | rest], i) when x + y == 10, do: [{:spare, [x, y], next_one(rest)} | parse(rest, i+1)]
  def parse([x, y | rest], i), do: [{:regular, [x, y], []} | parse(rest, i+1)]

  defp next_one(rolls), do: Enum.take(rolls, 1)
  defp next_two(rolls), do: Enum.take(rolls, 2)
end

defmodule Frame do
  def score({:strike, [10], [bonus1, bonus2]}), do: 10 + bonus1 + bonus2
  def score({:spare, [x, y], [bonus]}), do: x + y + bonus
  def score({_, rolls, []}), do: Enum.sum(rolls)
end

ExUnit.start()
defmodule PlayerTest do
  use ExUnit.Case

  test "parse no rolls", do: assert Player.parse([]) == []
  test "parse one roll", do: assert Player.parse([3]) == [{:incomplete, [3], []}]
  test "parse two rolls", do: assert Player.parse([3, 4]) == [{:regular, [3, 4], []}]
  test "parse three rolls", do: assert Player.parse([3, 4, 2]) == [{:regular, [3, 4], []}, {:incomplete, [2], []}]
  test "parse strike", do: assert Player.parse([10]) == [{:strike, [10], []}]
  test "parse strike and one roll", do: assert Player.parse([10, 2]) == [{:strike, [10], [2]}, {:incomplete, [2], []}]
  test "parse spare", do: assert Player.parse([8, 2]) == [{:spare, [8, 2], []}]
  test "parse spare and one roll", do: assert Player.parse([8, 2, 4]) == [{:spare, [8, 2], [4]}, {:incomplete, [4], []}]
  test "parse last roll incomplete", do: assert Player.parse([1], 10) == [{:incomplete, [1], []}]
  test "parse last roll regular", do: assert Player.parse([1, 2], 10) == [{:last, [1, 2], []}]
  test "parse last roll strike incomplete", do: assert Player.parse([10], 10) == [{:incomplete, [10], []}]
  test "parse last roll spare incomplete", do: assert Player.parse([2, 8], 10) == [{:incomplete, [2, 8], []}]
  test "parse last roll 3 strikes", do: assert Player.parse([10, 10, 10], 10) == [{:last, [10, 10, 10], []}]
  test "parse last roll spare", do: assert Player.parse([8, 2, 3], 10) == [{:last, [8, 2, 3], []}]

  test "parse entire game" do
    assert Player.parse([
      1, 2,
      1, 2,
      10,
      0, 10,
      2, 8,
      3, 4,
      10,
      3, 0,
      9, 1,
      2, 8, 1
    ]) == [
      {:regular, [1, 2], []},
      {:regular, [1, 2], []},
      {:strike, [10], [0, 10]},
      {:spare, [0, 10], [2]},
      {:spare, [2, 8], [3]},
      {:regular, [3, 4], []},
      {:strike, [10], [3, 0]},
      {:regular, [3, 0], []},
      {:spare, [9, 1], [2]},
      {:last, [2, 8, 1], []},
    ]
  end

  test "score strike", do: assert Frame.score({:strike, [10], [2, 3]}) == 15
  test "score spare", do: assert Frame.score({:spare, [2, 8], [4]}) == 14
  test "score regular", do: assert Frame.score({:regular, [2, 3], []}) == 5
  test "score last three strikes", do: assert Frame.score({:last, [10, 10, 10], []}) == 30
  test "score last regular", do: assert Frame.score({:last, [2, 3], []}) == 5

  test "score entire game" do
    assert [
      1, 2,
      1, 2,
      10,
      0, 10,
      2, 8,
      3, 4,
      10,
      3, 0,
      9, 1,
      2, 8, 1
    ] |> Player.parse() |> Player.score() == 97
  end

  test "score entire game 2" do
    assert [1, 4, 4, 5, 6, 4, 5, 5, 10, 0, 1, 7, 3, 6, 4, 0, 10, 2, 8, 6]
      |> Player.parse()
      |> Player.score() == 115
  end
end
