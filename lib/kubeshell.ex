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
        ls(args, context)
      "cd" ->
        cd(args, context)
      "cat" ->
        cat_cmd(args, context)
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
      "ls: List the items in the current context."
    "cd" ->
      "cd: Change context."
    "cat" ->
      "cat: Display the contents of a resource."
    _ ->
      "No help for #{cmd}."
    end
  end

  def ls(args, _) do
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
    {out, code} = kubectl(["-o", "json", "get", "ns"])
    case code do
      x when x > 0 ->
        IO.puts "Failed with exit code #{x}"
      _->
        j = json_parse(out)
        ns = Enum.map(j["items"], fn(o)-> o["metadata"]["name"] end)
        IO.puts(Enum.join(ns, "\n"))
    end
  end

  def ls(path) do
    parts = Path.split(path)
    case parts do
      [ns, kind, name]->
        {out, code} = kubectl(["-o", "json", "--namespace", ns, "get", kind, name])
        case code do
          x when x > 0 ->
            IO.puts "Failed with exit code #{x}"
          _->
            j = json_parse(out)
            IO.puts j["metadata"]["name"]
        end
      [ns, kind]->
        {out, code} = kubectl(["-o", "json", "--namespace", ns, "get", kind])
        case code do
          x when x > 0 ->
            IO.puts "Failed with exit code #{x}"
          _->
            j = json_parse(out)
            names = Enum.map j["items"], fn(o)->
              o["metadata"]["name"]
            end
            IO.puts(Enum.join(names, "\n"))
        end
      [ns]->
        kinds = Enum.join(runnable_kinds(), ",")
        {out, code} = kubectl(["-o", "json", "--namespace", ns, "get", kinds])
        case code do
          x when x > 0 ->
            IO.puts "Failed with exit code #{x}"
          _->
            j = json_parse(out)
            names = Enum.map j["items"], fn(o)->
              k = o["kind"]
              n = o["metadata"]["name"]
              "#{k}/#{n}"
            end
            IO.puts(Enum.join(names, "\n"))
        end
    end
  end

  def cd(args, _) do
    case length args do
      0->
        "cd to top level context"
      _->
        dir = hd(args)
        "cd to #{dir}"
    end
  end

  def cat_cmd(args, _) when is_list(args) do
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
    {out, code} = kubectl(["-o", "yaml", "--namespace", ns, "get", kind, name])
    case code do
      0 ->
        IO.puts out
      _ ->
        IO.puts "No matches"
    end
  end

  def cat_all(ns, name) do
    kinds = Enum.join(runnable_kinds, ",")
    cat(ns, kinds, name)
  end

  def kubectl(args) do
    kcmd = System.get_env("KUBESHELL_KUBECTL") || "kubectl"
    pretty = Enum.join(args, " ")
    IO.puts IO.ANSI.blue()
    IO.puts "\t[ #{kcmd} #{pretty} ]"
    IO.puts IO.ANSI.default_color()
    System.cmd(kcmd, args)
  end

  def json_parse(str) do
    Poison.Parser.parse! str
  end

  def runnable_kinds() do
    # From kubectl 1.2:
    # Possible resource types include (case insensitive): pods (po), services (svc),
    # replicationcontrollers (rc), nodes (no), events (ev), limitranges (limits),
    # persistentvolumes (pv), persistentvolumeclaims (pvc), resourcequotas (quota),
    # namespaces (ns), serviceaccounts, horizontalpodautoscalers (hpa),
    # endpoints (ep) or secrets.
    # But from k describe, we get this list:
    # ⇒  k describe
    #You must specify the type of resource to describe. Valid resource types include:
     #* componentstatuses (aka 'cs')
     #* configmaps
     #* daemonsets (aka 'ds')
     #* deployments
     #* events (aka 'ev')
     #* endpoints (aka 'ep')
     #* horizontalpodautoscalers (aka 'hpa')
     #* ingress (aka 'ing')
     #* jobs
     #* limitranges (aka 'limits')
     #* nodes (aka 'no')
     #* namespaces (aka 'ns')
     #* pods (aka 'po')
     #* persistentvolumes (aka 'pv')
     #* persistentvolumeclaims (aka 'pvc')
     #* quota
     #* resourcequotas (aka 'quota')
     #* replicasets (aka 'rs')
     #* replicationcontrollers (aka 'rc')
     #* secrets
     #* serviceaccounts
     #* services (aka 'svc')
    ["po", "svc", "rc", "pv", "pvc", "hpa", "configmaps", "ds", "deployments", "ing", "jobs", "rs", "secrets"]
  end

end
