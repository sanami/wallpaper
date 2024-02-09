defmodule Wallpaper do
  require Logger

  alias Vix.Vips.{Image, Operation}

  @width 1920
  @height 1080
  @offset 30
  @min_size 100_000

  def find_files(search_dir) do
    search_dir
    |> Path.join("**/*.jpg")
    |> Path.wildcard()
    |> Enum.reduce([], fn path, list ->
      st = File.stat!(path)
      if st.type == :regular && st.size > @min_size do
        [{st.size, path} | list]
      else
        list
      end
    end)
  end

  def process_file(file_path, result_path) do
    Logger.debug "process_file #{file_path} -> #{result_path}"

    {:ok, img} = Image.new_from_file(file_path)

    scale = (@height - @offset) / Image.height(img)
    {:ok, img} = Operation.resize(img, scale)

    {:ok, img} =
      Operation.embed(img, 0, 0, Image.width(img), Image.height(img) + @offset,
        extend: :VIPS_EXTEND_BACKGROUND,
        background: [0]
      )

    File.mkdir_p(Path.dirname(result_path))
    :ok = Image.write_to_file(img, result_path)
  end

  # defdelegate run(search_dir, result_dir), to: Wallpaper.Task
  defdelegate run(search_dir, result_dir), to: Wallpaper.Pool
end
