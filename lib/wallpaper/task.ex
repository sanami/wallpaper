defmodule Wallpaper.Task do
  require Logger

  @workers 8

  def group_files(files) do
    files
    |> Enum.sort(&( elem(&1, 0) > elem(&2, 0)))
    |> Stream.with_index
    |> Enum.reduce(%{}, fn {{_size, path}, i}, file_groups ->
      key = rem(i, @workers)
      Map.update file_groups, key, [path], fn list -> [path | list] end
    end)
  end

  def process_files(search_dir, result_dir, files) do
    Logger.info "process_files #{length files}"
    for file_path <- files do
      try do
        result_path = Path.join(result_dir, Path.relative_to(file_path, search_dir))
        Wallpaper.process_file(file_path, result_path)
      rescue ex ->
        Logger.error ex
      end
    end
  end

  def run(search_dir, result_dir) do
    search_dir
    |> Wallpaper.find_files
    |> group_files()
    |> Enum.map(fn {_group, files} -> Task.async(Wallpaper.Task, :process_files, [search_dir, result_dir, files]) end)
    |> Enum.map(&Task.await(&1, :infinity))
  end
end