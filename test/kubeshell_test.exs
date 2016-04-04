defmodule KubeShellTest do
  use ExUnit.Case
  doctest KubeShell

  test "help text" do
    o = KubeShell.help
    assert o == "Show help text for commands."

    o = KubeShell.help("help")
    assert o == "help: Show help text for a command."

    commands = ["ls", "cd"]
    check_start_end(commands)
  end

  def check_start_end(cmd) when length(cmd) > 0 do
    c = hd(cmd)
    o = KubeShell.help(c)
    prompt = "#{c}: "
    assert String.starts_with? o, prompt
    assert String.ends_with? o, "."

    o = KubeShell.help([c, "foo", "bar"])
    assert String.starts_with? o, prompt
    assert String.ends_with? o, "."

    check_start_end(tl(cmd))
  end

  def check_start_end(cmd) do
  end

  # This is just a lame practice test
  test "has kubectl" do
    {_, r} = System.cmd "kubectl", ["version"]
    assert r == 0
  end
end
