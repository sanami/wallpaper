defmodule Wallpaper.TaskTest do
  use AppCase
  alias Wallpaper.Task

  @folder1 "priv/images"
  @result1 "priv/result"

  test "group_files" do
    res = Wallpaper.find_files(@folder1) |> Task.group_files
    dbg res

    assert length(res[0]) > 2
  end

  test "run" do
    Task.run @folder1, @result1
  end
end
