# KubeShell

KubeShell is an interactive shell for Kubernetes. You can use common
UNIX commands like `ls`, `cat`, and `cd` to move around your Kubernetes
namespaces and resources (much like in Linux you can navigate around the
`/proc` filesystem).

*KubeShell is a work in progress. It is nowhere near stable at the
moment.*

## Installation

KubeShell is an Elixir app, so you will need the Elixir runtime. You
also must have `kubectl` installed and configured.

1. Clone this repository
2. From the base directory `iex -S mix`
3. Run `KubeShell.interactive_shell`

(Yes, we will make this _much_ better as we go.)

## Why Elixir?

KubeShell is my project for learning Elixir. The code you see here may
not be strongly idiomatic, but it will hopefully get there as the
project matures.
