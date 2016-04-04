defmodule KubeShell.HistoryTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, hist} = KubeShell.History.start_link
    {:ok, hist: hist}
  end

  # This is just a lame practice test
  test "stores history", %{hist: hist} do
    assert KubeShell.History.all(hist) == []

    KubeShell.History.add(hist, "foo bar")
    assert KubeShell.History.all(hist) == ["foo bar"]
  end

  test "test accessors", %{hist: hist} do
    assert KubeShell.History.all(hist) == []

    KubeShell.History.add(hist, "first")
    KubeShell.History.add(hist, "second")
    KubeShell.History.add(hist, "third")
    assert length(KubeShell.History.all(hist)) == 3

    t2 = KubeShell.History.pop(hist)
    assert t2 == "third"
    assert length(KubeShell.History.all(hist)) == 2
  end
end
