defmodule Wallpaper.Pool do
  require Logger

  @workers 8

  def run(search_dir, result_dir) do
    Logger.info "Wallpaper.Pool.run"

    children = [
      :poolboy.child_spec(:image_worker, [
        name: {:local, :image_worker},
        worker_module: Wallpaper.Worker,
        size: @workers,
        max_overflow: 0
      ])
    ]
    # dbg children

    opts = [strategy: :one_for_one, name: Wallpaper.Supervisor]
    {:ok, super_pid} = Supervisor.start_link(children, opts)
    Logger.info "Wallpaper.Supervisor #{inspect super_pid}"

    res = search_dir
    |> Wallpaper.find_files
    |> Enum.map(fn {_size, file_path} ->
        Task.async(fn ->
          result_path = Path.join(result_dir, Path.relative_to(file_path, search_dir))
          :poolboy.transaction(:image_worker, &( GenServer.call(&1, {:process, file_path, result_path}, :infinity) ), :infinity)
        end)
      end)
    |> Task.await_many(:infinity)

    Supervisor.stop(super_pid, :normal)

    res
  end
end
