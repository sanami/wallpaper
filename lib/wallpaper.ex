defmodule Wallpaper do
  require Logger

  alias Vix.Vips.{Image, Operation}

  @min_size 100_000
  @workers 8
  @width 1920
  @height 1080
  @offset 30

  def find_files(search_dir) do
    Enum.reduce Path.wildcard("#{search_dir}/**/*.jpg"), [], fn path, list ->
      st = File.stat!(path)
      if st.type == :regular && st.size > @min_size do
        [{st.size, path} | list]
      else
        list
      end
    end
  end

  def group_files(files) do
    files
    |> Enum.sort(&( elem(&1, 0) > elem(&2, 0)))
    |> Stream.with_index
    |> Enum.reduce(%{}, fn {{_size, path}, i}, file_groups ->
      key = rem(i, @workers)
      Map.update file_groups, key, [path], fn list -> [path | list] end
    end)
  end

  def run(search_dir, result_dir) do
    search_dir
    |> find_files()
    |> group_files()
    |> Enum.map(fn {_group, files} -> Task.async(Wallpaper, :process_files, [search_dir, result_dir, files]) end)
    |> Enum.map(&Task.await(&1, :infinity))
  end

  def process_files(search_dir, result_dir, files) do
    Logger.info "process_files #{length files}"
    for file_path <- files do
      try do
        result_path = Path.join(result_dir, Path.relative_to(file_path, search_dir))
        process_file(file_path, result_path)
      rescue ex ->
        Logger.error ex
      end
    end
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
end
