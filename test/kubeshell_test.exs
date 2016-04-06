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

  test "exec help" do 
    o = KubeShell.exec("help")
    assert o == "Show help text for commands."

    o = KubeShell.exec("help ?")
    assert o == "?: Show help text for a command."

    o = KubeShell.exec("help ? foo bar baz")
    assert o == "?: Show help text for a command."
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

  def check_start_end(_) do
  end
end
