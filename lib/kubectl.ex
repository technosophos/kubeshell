defmodule Kubectl do
  def exec(args) do
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

