defmodule KinoLiveAudio do
  @moduledoc """
  A Kino designed to record a raw audio stream (no client-side encoding) and emit events.

  When you consume the events, you can directly convert the audio to an `Nx` tensor.

  You may specify the sample rate of the audio and the frequency that events should be emmitted
  by specifying how many samples should accumulate before sending to the server.

  Refer to the sample [Livebook](notebooks/vad.livemd) for usage.
  """
  use Kino.JS, assets_path: "lib/assets/build"
  use Kino.JS.Live

  @exps [s: 1, ms: -3, mu: -6]

  @doc """
  Creates a new `KinoLiveAudio`

  ## Options

  * `:chunk_size` - Wait for this many samples before sending. Will send exactly this amount to the
      emmited event. Must be a positive integer. Defaults to 16_000.
  * `:sample_rate` - The sample rate of the audio stream. Defaults to 16_000.
  * `:unit` - The unit for the `:chunk_size` option. Can be any of the following:
    * `:samples` - Directly passes the `:chunk_size` parameter
    * `:s` - Seconds of audio before sending, according to the sample rate
    * `:ms` - Miliseconds of audio before sending, according to the sample rate
    * `:mu` - Microseconds of audio before sending, according to the sample rate
  """
  def new(opts \\ []) do
    opts = Keyword.validate!(opts, chunk_size: 16_000, sample_rate: 16_000, unit: :samples)

    if opts[:sample_rate] < 0 or not is_integer(opts[:sample_rate]),
      do:
        raise(
          ArgumentError,
          "Sample rate must be
           a positive integer, got #{inspect(opts[:sample_rate])}"
        )

    chunk_size =
      if opts[:unit] == :samples do
        opts[:chunk_size]
      else
        exp =
          @exps[opts[:unit]] ||
            raise ArgumentError,
                  ":unit opt must be in [:s, :ms, :ms, :samples], got #{inspect(opts[:unit])}"

        trunc(opts[:sample_rate] * (opts[:chunk_size] * 10 ** exp))
      end

    Kino.JS.Live.new(__MODULE__, {chunk_size, opts[:sample_rate]})
  end

  @impl true
  def init({chunk_size, sample_rate}, ctx) do
    {:ok, assign(ctx, sample_rate: sample_rate, chunk_size: chunk_size)}
  end

  @impl true
  def handle_connect(ctx) do
    {:ok, %{sampleRate: ctx.assigns.sample_rate, chunkSize: ctx.assigns.chunk_size}, ctx}
  end

  @impl true
  def handle_event("audio_chunk", chunk, ctx) do
    emit_event(ctx, %{event: :audio_chunk, chunk: chunk})
    {:noreply, ctx}
  end
end
