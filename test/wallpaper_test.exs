defmodule WallpaperTest do
  use ExUnit.Case

  test "run" do
    Wallpaper.run "priv/images", "priv/result"
  end
end
