defmodule Roman do
  @r2d [I: 1, V: 5, X: 10, L: 50, C: 100, D: 500, M: 1_000]
       |> Enum.map(fn {r, d} -> {Atom.to_string(r), d} end)
       |> Enum.reverse()

  for {r, d} <- @r2d do
    def d2r(unquote(d)), do: unquote(r)
    def r2d(unquote(r)), do: unquote(d)
  end

  for {{r1, d1}, i} <- Enum.with_index(@r2d), {r2, d2} <- Enum.slice(@r2d, (i + 1)..-1) do
    def d2r(unquote(d1 - d2)), do: unquote(r2 <> r1)
    def r2d(<<unquote(r2), unquote(r1), rest::binary>>), do: unquote(d1) - unquote(d2) + r2d(rest)
  end

  for {r, d} <- @r2d do
    def d2r(x) when x > unquote(d), do: unquote(r) <> d2r(x - unquote(d))
    def r2d(<<unquote(r), rest::binary>>), do: unquote(d) + r2d(rest)
  end

  def r2d(""), do: 0
end

ExUnit.start()
defmodule RomanTest do
  use ExUnit.Case

  test "decimal to roman" do
    assert Roman.d2r(1) == "I"
    assert Roman.d2r(2) == "II"
    assert Roman.d2r(3) == "III"
    assert Roman.d2r(4) == "IV"
    assert Roman.d2r(5) == "V"
    assert Roman.d2r(9) == "IX"
    assert Roman.d2r(21) == "XXI"
    assert Roman.d2r(24) == "XXIV"
    assert Roman.d2r(50) == "L"
    assert Roman.d2r(49) == "IL"
    assert Roman.d2r(1500) == "MD"
    assert Roman.d2r(1001) == "MI"
    assert Roman.d2r(80) == "LXXX"
    assert Roman.d2r(90) == "XC"
  end

  test "roman to decimal" do
    assert Roman.r2d("I") == 1
    assert Roman.r2d("II") == 2
    assert Roman.r2d("III") == 3
    assert Roman.r2d("IV") == 4
    assert Roman.r2d("V") == 5
    assert Roman.r2d("IX") == 9
    assert Roman.r2d("XXI") == 21
    assert Roman.r2d("XXIV") == 24
    assert Roman.r2d("L") == 50
    assert Roman.r2d("IL") == 49
    assert Roman.r2d("MD") == 1500
    assert Roman.r2d("MI") == 1001
    assert Roman.r2d("LXXX") == 80
    assert Roman.r2d("XC") == 90
  end
end
