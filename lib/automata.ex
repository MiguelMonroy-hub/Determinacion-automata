defmodule Automata do

  defstruct states: [],
            alphabet: [],
            transitions: %{},
            start: nil,
            accept: []


  def move(automaton, states, symbol) do
    states
    |> Enum.flat_map(fn state ->
      Map.get(automaton.transitions, {state, symbol}, [])
    end)
    |> Enum.uniq()
  end


  def determinize(nfa) do
    start = [nfa.start]

    process([start], [], %{}, nfa)
  end

  defp process([], states, transitions, nfa) do
    %Automata{
      states: states,
      alphabet: nfa.alphabet,
      transitions: transitions,
      start: [nfa.start],
      accept:
        Enum.filter(states, fn state_set ->
          Enum.any?(state_set, fn s -> s in nfa.accept end)
        end)
    }
  end

  defp process([current | rest], states, transitions, nfa) do

    states =
      if current in states do
        states
      else
        [current | states]
      end

    {new_transitions, new_queue} =
      Enum.reduce(nfa.alphabet, {transitions, rest}, fn symbol, {t_acc, q_acc} ->
        next = move(nfa, current, symbol)

        t_acc = Map.put(t_acc, {current, symbol}, next)

        q_acc =
          if next == [] or next in states or next in q_acc do
            q_acc
          else
            [next | q_acc]
          end

        {t_acc, q_acc}
      end)

    process(new_queue, states, new_transitions, nfa)
  end
end
