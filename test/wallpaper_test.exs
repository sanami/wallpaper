defmodule WallpaperTest do
  use AppCase

  @folder1 "priv/images"
  @result1 "priv/result"

  test "find_files" do
    res = Wallpaper.find_files @folder1
    pp res

    assert length(res) > 10
  end
end
