defmodule Wallpaper.Worker do
  use GenServer
  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(_) do
    {:ok, nil}
  end

  def handle_cast({:process, file_path, result_path}, state) do
    # Logger.debug "Wallpaper.Worker.process #{file_path}"
    Wallpaper.process_file(file_path, result_path)

    :poolboy.checkin(:image_workers_pool, self())

    {:noreply, state}
  end
end
