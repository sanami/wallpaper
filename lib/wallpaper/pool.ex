defmodule Wallpaper.Pool do
  require Logger

  @workers 8
  @batch @workers*1000

  def group_tasks(all_files, task_fn, batch \\ @batch) do
    {next_tasks, result} = all_files
    |> Stream.chunk_every(batch)
    |> Enum.reduce({[], []}, fn files, {prev_tasks, result} ->
      Logger.debug "prev_tasks #{length prev_tasks} files #{length files}"

      new_tasks = Enum.map(files, fn file_path ->
        Task.async(task_fn.(file_path))
      end)
      {cur_tasks, next_tasks} = Enum.split(new_tasks, div(batch, 2))
      Logger.debug "new_tasks #{length new_tasks} prev_tasks #{length prev_tasks} next_tasks #{length next_tasks}"

      result = [result, Task.await_many(prev_tasks, :infinity), Task.await_many(cur_tasks, :infinity)]

      {next_tasks, result}
    end)

    if Enum.empty?(next_tasks) do
      result
    else
      Logger.debug "next_tasks #{length next_tasks}"
      [result, Task.await_many(next_tasks, :infinity)]
    end
  end

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
    |> Stream.map(fn {_size, file_path} -> file_path end)
    |> group_tasks(fn file_path ->
      fn ->
        result_path = Path.join(result_dir, Path.relative_to(file_path, search_dir))
        :poolboy.transaction(:image_worker, &( GenServer.call(&1, {:process, file_path, result_path}, :infinity) ), :infinity)
      end
    end)

    Supervisor.stop(super_pid, :normal)

    res
  end
end
