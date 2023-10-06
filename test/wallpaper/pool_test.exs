defmodule Wallpaper.PoolTest do
  use AppCase
  alias Wallpaper.Pool

  @folder1 "priv/images"
  @result1 "priv/result"

  test "group_tasks" do
    res = Pool.group_tasks 100..110, fn n -> fn -> n*2 end end, 4
    res = List.flatten(res)
    pp res
  end

  @tag timeout: :infinity
  test "run" do
    res = Pool.run @folder1, @result1
    res = List.flatten(res)
    pp res

    assert length(res) > 10
  end
end
