defmodule KubeShell do
  @doc """
  Begin an interactive shell.
  """
  def interactive_shell do
    ps1 = "k8s→ "
    r = IO.gets ps1
    prompt r, ps1
  end

  def prompt(cmd, _) when cmd == "exit\n" do
    IO.puts "Exiting"
  end

  @doc """
  Handle a command.
  """
  def prompt(cmd, ps1) do
    IO.puts exec(cmd)
    prompt IO.gets(ps1), ps1
  end

  def exec(cmd) do
    argv = String.split(cmd)
    case argv do
      _ when hd(argv) in ["help", "?", "man"] and length(argv) > 1->
        help hd(tl(argv))
      _ when hd(argv) in ["help", "?", "man"] ->
        help
      x when length(argv) > 0 ->
        pretty = Enum.join(x, ", ")
        "Got #{pretty}"
        exec_cmd(hd(argv), tl(argv), {})
      _ ->
        pretty = Enum.join(argv, " ")
        "Unknown command #{pretty}"
    end
  end

  def exec_cmd(cmd, args, context) do
    case cmd do
      "ls" ->
        Ls.exec(args, context)
      "cd" ->
        Cd.exec(args, context)
      "cat" ->
        Cat.exec(args, context)
      _ ->
        IO.puts "Command not found: #{cmd}"
    end
  end

  def help do
    "Show help text for commands."
  end

  def help(args) when is_list(args) do
    # For now, restrict to only single-name commands.
    cmd = hd(args)
    help cmd
  end

  def help(cmd) do
    case cmd do
    x when x in ["", "help", "?", "man"] ->
      "#{x}: Show help text for a command."
    "ls" ->
      Ls.help
    "cd" ->
      Cd.help
    "cat" ->
      Cat.help
    _ ->
      "No help for #{cmd}."
    end
  end
end
