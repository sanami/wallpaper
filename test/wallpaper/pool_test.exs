defmodule Wallpaper.PoolTest do
  use AppCase
  import Wallpaper.Pool

  @folder1 "priv/images"
  @result1 "priv/result"

  @tag timeout: :infinity
  test "run" do
    res = run @folder1, @result1
    res = List.flatten(res)
    pp res

    assert length(res) > 10
  end
end
