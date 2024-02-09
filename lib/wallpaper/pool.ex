defmodule Wallpaper.Pool do
  require Logger

  def run(search_dir, result_dir) do
    Logger.info "Wallpaper.Pool.run"

    children = [
      :poolboy.child_spec(:image_workers_pool, [
        name: {:local, :image_workers_pool},
        worker_module: Wallpaper.Worker,
        size: :erlang.system_info(:logical_processors_available),
        max_overflow: 0
      ])
    ]

    opts = [strategy: :one_for_one, name: Wallpaper.Supervisor]
    {:ok, super_pid} = Supervisor.start_link(children, opts)
    Logger.info "Wallpaper.Supervisor #{inspect super_pid}"

    search_dir
    |> Wallpaper.find_files()
    |> Enum.map(fn {_size, file_path} ->
      result_path = Path.join(result_dir, Path.relative_to(file_path, search_dir))
      worker_pid = :poolboy.checkout(:image_workers_pool, true, :infinity)
      GenServer.cast(worker_pid, {:process, file_path, result_path})
    end)

    wait_workers(:image_workers_pool)

    Supervisor.stop(super_pid, :normal, :infinity)
  end

  def wait_workers(pool_id) do
    wait_workers(pool_id, :poolboy.status(pool_id))
  end

  def wait_workers(_pool_id, {_, _, 0, 0}), do: :ok

  def wait_workers(pool_id, pool_status = {_, _, _, _}) do
    Logger.debug "#{pool_id} #{inspect pool_status}"
    Process.sleep(100)
    wait_workers(pool_id, :poolboy.status(pool_id))
  end
end
