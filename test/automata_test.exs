defmodule AutomataTest do
  use ExUnit.Case
  doctest Automata

  test "determinize convierte NFA a DFA correctamente" do
    nfa = %Automata{
      states: [0, 1],
      alphabet: [:a],
      transitions: %{
        {0, :a} => [0, 1]
      },
      start: 0,
      accept: [1]
    }

    dfa = Automata.determinize(nfa)

    assert dfa.start == [0]

    assert Enum.sort(dfa.states) == Enum.sort([[0], [0, 1]])

    assert dfa.transitions[{[0], :a}] == [0, 1]
    assert dfa.transitions[{[0, 1], :a}] == [0, 1]

    assert dfa.accept == [[0, 1]]
  end

  test "epsilon closure works" do
  nfa = %Automata{
    states: [0,1,2],
    alphabet: [:a],
    transitions: %{
      {0, :epsilon} => [1],
      {1, :epsilon} => [2]
    },
    start: 0,
    accept: [2]
  }

  result = Automata.e_closure(nfa, [0])

  assert Enum.sort(result) == [0,1,2]
end
end
