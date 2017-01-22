defmodule Benchee.Output.BenchmarkPrinter do
  @moduledoc """
  Printing happening during the Benchmark stage.
  """

  alias Benchee.Conversion.Duration

  def duplicate_benchmark_warning(name) do
    IO.puts "You already have a job defined with the name \"#{name}\", you can't add two jobs with the same name!"
  end

  def configuration_information(%{config: %{print: %{configuration: false}}}) do
    nil
  end
  def configuration_information(%{jobs: jobs, system: sys, config: config}) do
    system_information(sys)
    suite_information(jobs, config)
  end

  defp system_information(%{erlang: erlang_version, elixir: elixir_version}) do
    IO.puts "Elixir #{elixir_version}"
    IO.puts "Erlang #{erlang_version}"
  end

  defp suite_information(jobs, %{parallel: parallel,
                                 time:     time,
                                 warmup:   warmup,
                                 inputs:   inputs}) do
    warmup_seconds = time_precision Duration.scale(warmup, :second)
    time_seconds   = time_precision Duration.scale(time, :second)
    job_count      = map_size jobs
    exec_time      = warmup_seconds + time_seconds
    total_time     = time_precision(job_count * inputs_count(inputs) * exec_time)

    IO.puts "Benchmark suite executing with the following configuration:"
    IO.puts "warmup: #{warmup_seconds}s"
    IO.puts "time: #{time_seconds}s"
    IO.puts "parallel: #{parallel}"
    IO.puts "inputs: #{inputs_out(inputs)}"
    IO.puts "Estimated total run time: #{total_time}s"
    IO.puts ""
  end

  defp inputs_count(nil),    do: 1 # no input specified still executes
  defp inputs_count(inputs), do: map_size(inputs)

  defp inputs_out(nil), do: "none specified"
  defp inputs_out(inputs) do
    inputs
    |> Map.keys
    |> Enum.join(", ")
  end

  @round_precision 2
  defp time_precision(float) do
    Float.round(float, @round_precision)
  end

  def benchmarking(_, %{print: %{benchmarking: false}}), do: nil
  def benchmarking(name, _config) do
    IO.puts "Benchmarking #{name}..."
  end

  def fast_warning do
    IO.puts """
    Warning: The function you are trying to benchmark is super fast, making measures more unreliable! See: https://github.com/PragTob/benchee/wiki/Benchee-Warnings#fast-execution-warning
    """
  end

  def input_information(input_name) do
    if input_name != Benchee.Benchmark.no_input do
      IO.puts "\nBenchmarking with input #{input_name}:"
    end
  end

end