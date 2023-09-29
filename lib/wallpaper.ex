defmodule Wallpaper do
  alias Vix.Vips.{Image, Operation}
  require Logger

  @width 1920
  @height 1080
  @offset 30

  def process_file(file_path, result_path) do
    Logger.info "process_file #{file_path} -> #{result_path}"

    {:ok, img} = Image.new_from_file(file_path)
    dbg(img)
    w = Image.width(img)
    h = Image.height(img)
    IO.puts("Width: #{w} Height: #{h}")

    scale = (@height - @offset) / Image.height(img)
    {:ok, img} = Operation.resize(img, scale)

    {:ok, img} =
      Operation.embed(img, 0, 0, Image.width(img), Image.height(img) + @offset,
        extend: :VIPS_EXTEND_BACKGROUND,
        background: [0]
      )

    IO.puts("Width: #{Image.width(img)} Height: #{Image.height(img)}")
    File.mkdir_p(Path.dirname(result_path))
    :ok = Image.write_to_file(img, result_path)
  end

  def run(search_dir, result_dir) do
    Enum.each Path.wildcard("#{search_dir}/**/*"), fn path ->
      unless File.dir?(path) do
        result_path = Path.join(result_dir, Path.relative_to(path, search_dir))
        process_file path, result_path
      end
    end
  end

end
