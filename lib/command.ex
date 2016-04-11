defmodule Command do
  @callback exec(list, map) :: any
  @callback help() :: String.t
end

defmodule Cd do
  @behaviour Command

  def help() do
    "cd: Change context."
  end
  def exec(args, _context) do
    case length args do
      0->
        "cd to top level context"
      _->
        dir = hd(args)
        "cd to #{dir}"
    end
  end
end

defmodule Cat do
  @behaviour Command

  def help() do
    "cat: Display the contents of a resource."
  end
  def exec(args, _) when is_list(args) do
    case length args do
      0 ->
        IO.puts ""
      1 ->
        cat(hd(args))
      _ ->
        IO.puts "Usage: cat ns/kind/name"
    end
  end

  def cat(path) do
    parts = Path.split(path)
    case parts do
      [ns, kind, name] ->
        cat(ns, String.downcase(kind), name)
      [kind, name] ->
        cat("default", String.downcase(kind), name)
      [name] ->
        cat_all("default", name)
      _ ->
        IO.puts "Invalid format: #{path}"
    end
  end

  def cat(namespace, path) do
    parts = Path.split(path)
    case length parts do
      0 ->
        IO.puts ""
      1 ->
        cat_all namespace, hd(parts)
      2 ->
        kind = String.downcase(hd(parts))
        name = hd(tl(parts))
        cat(namespace, kind, name)
    end
  end

  def cat(ns, kind, name) do
    {out, code} = Kubectl.exec(["-o", "yaml", "--namespace", ns, "get", kind, name])
    case code do
      0 ->
        IO.puts out
      _ ->
        IO.puts "No matches"
    end
  end

  def cat_all(ns, name) do
    kinds = Enum.join(Kubectl.runnable_kinds, ",")
    cat(ns, kinds, name)
  end

end

defmodule Ls do
  @behaviour Command

  def help() do
    "ls: List the items in the current context."
  end

  def exec(args, _context) do
    case length args do
      0 ->
        ls
      1 ->
        ls(hd(args))
      _->
        IO.puts "No handler for multiple args yet."
    end
  end

  def ls() do
    {out, code} = Kubectl.exec(["-o", "json", "get", "ns"])
    case code do
      x when x > 0 ->
        IO.puts "Failed with exit code #{x}"
      _->
        j = Kubectl.json_parse(out)
        ns = Enum.map(j["items"], fn(o)-> o["metadata"]["name"] end)
        IO.puts(Enum.join(ns, "\n"))
    end
  end

  def ls(path) do
    parts = Path.split(path)
    case parts do
      [ns, kind, name]->
        {out, code} = Kubectl.exec(["-o", "json", "--namespace", ns, "get", kind, name])
        case code do
          x when x > 0 ->
            IO.puts "Failed with exit code #{x}"
          _->
            j = Kubectl.json_parse(out)
            IO.puts j["metadata"]["name"]
        end
      [ns, kind]->
        {out, code} = Kubectl.exec(["-o", "json", "--namespace", ns, "get", kind])
        case code do
          x when x > 0 ->
            IO.puts "Failed with exit code #{x}"
          _->
            j = Kubectl.json_parse(out)
            names = Enum.map j["items"], fn(o)->
              o["metadata"]["name"]
            end
            IO.puts(Enum.join(names, "\n"))
        end
      [ns]->
        kinds = Enum.join(Kubectl.runnable_kinds(), ",")
        {out, code} = Kubectl.exec(["-o", "json", "--namespace", ns, "get", kinds])
        case code do
          x when x > 0 ->
            IO.puts "Failed with exit code #{x}"
          _->
            j = Kubectl.json_parse(out)
            names = Enum.map j["items"], fn(o)->
              k = o["kind"]
              n = o["metadata"]["name"]
              "#{k}/#{n}"
            end
            IO.puts(Enum.join(names, "\n"))
        end
    end
  end

end
