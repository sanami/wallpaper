defmodule Wallpaper.PoolTest do
  use AppCase
  alias Wallpaper.Pool

  @folder1 "priv/images"
  @result1 "priv/result"

  @tag timeout: :infinity
  test "run" do
    res = Pool.run @folder1, @result1
    pp res

    assert length(res) > 10
  end
end
