defmodule KubeShell.History do
  @doc """
  Start history.
  """
  def start_link do
    Agent.start_link(fn -> [] end)
  end

  @doc """
  Add a thing to history.
  """
  def add(hist, item) do
    #f = fn hist, item -> [item|hist] end
    Agent.update(hist, fn hist -> [item|hist] end)
  end

  @doc """
  Get the entire history.
  """
  def all(hist) do
    Agent.get(hist, fn hist -> hist end)
  end

  @doc """
  Pop the last element off of history.
  """
  def pop(hist) do
    Agent.get_and_update(hist, fn hist ->
      h = hd(hist)
      tl(hist)
      {h, tl(hist)}
    end)
  end
end
