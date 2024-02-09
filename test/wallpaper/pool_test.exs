defmodule Wallpaper.PoolTest do
  use AppCase
  import Wallpaper.Pool

  @folder1 "priv/images"
  @result1 "priv/result"

  @tag timeout: :infinity
  test "run" do
    res = run @folder1, @result1
    pp res

    assert res == :ok
  end
end
