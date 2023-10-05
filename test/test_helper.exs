ExUnit.start()

defmodule AppCase do
  defmacro __using__(opts) do
    quote do
      use ExUnit.Case, unquote(opts)

      def pp(exp), do: IO.inspect(exp)
    end
  end
end
