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

  def e_closure(automaton, states) do
  closure(states, automaton, MapSet.new(states))
end

defp closure([], _automaton, visited) do
  MapSet.to_list(visited)
end

defp closure([current | rest], automaton, visited) do
  next =
    Map.get(automaton.transitions, {current, :epsilon}, [])
    |> Enum.filter(fn s -> not MapSet.member?(visited, s) end)

  new_visited =
    Enum.reduce(next, visited, fn s, acc -> MapSet.put(acc, s) end)

  closure(rest ++ next, automaton, new_visited)
end

def e_determinize(nfa) do
  start = e_closure(nfa, [nfa.start])
  process_e([start], [], %{}, nfa)
end

defp process_e([], states, transitions, nfa) do
  %Automata{
    states: states,
    alphabet: nfa.alphabet,
    transitions: transitions,
    start: e_closure(nfa, [nfa.start]),
    accept:
      Enum.filter(states, fn state_set ->
        Enum.any?(state_set, fn s -> s in nfa.accept end)
      end)
  }
end

defp process_e([current | rest], states, transitions, nfa) do
  states =
    if current in states do
      states
    else
      [current | states]
    end

  {new_transitions, new_queue} =
    Enum.reduce(nfa.alphabet, {transitions, rest}, fn symbol, {t_acc, q_acc} ->
      move_set = move(nfa, current, symbol)
      closure = e_closure(nfa, move_set)

      t_acc = Map.put(t_acc, {current, symbol}, closure)

      q_acc =
        cond do
          closure == [] -> q_acc
          closure in states -> q_acc
          closure in q_acc -> q_acc
          true -> [closure | q_acc]
        end

      {t_acc, q_acc}
    end)

  process_e(new_queue, states, new_transitions, nfa)
end
end
