defmodule WallpaperTest do
  use ExUnit.Case

  @folder1 "priv/images"
  @result1 "priv/result"

  test "find_files" do
    res = Wallpaper.find_files @folder1
    dbg res

    assert length(res) > 10
  end

  test "group_files" do
    res = Wallpaper.find_files(@folder1) |> Wallpaper.group_files
    dbg res

    assert length(res[0]) > 2
  end

  test "run" do
    Wallpaper.run @folder1, @result1
  end
end
