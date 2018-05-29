defmodule MarkovianTest do
  use ExUnit.Case

  doctest Markovian
  @states [:s1, :s2]
  @actions [:a1, :a2]

  test "generating a new MDP adds the state space" do
    assert @states == @states |> Markovian.new(@actions, :s1) |> Map.get(:q_table) |> Map.keys()
  end

  test "generating a new MDP adds the actions" do
    actions =
      @states
      |> Markovian.new(@actions, :s1)
      |> Map.get(:q_table)
      |> Map.values()
      |> List.first()
      |> Map.keys()

    assert @actions == actions
  end

  test "generating a new MDP adds a random reward" do
    reward =
      @states
      |> Markovian.new(@actions, :s1)
      |> Map.get(:q_table)
      |> Map.values()
      |> List.first()
      |> Map.values()
      |> List.first()

    assert 0 != reward
  end

  test "updating the MDP changes the reward" do
    initial_mdp = @states |> Markovian.new(@actions, :s1)
    new_mdp = initial_mdp |> Markovian.update(100, :s2)
    inital_reward = initial_mdp.q_table |> Map.get(:s1) |> Map.values() |> Enum.sum()
    new_reward = new_mdp.q_table |> Map.get(:s1) |> Map.values() |> Enum.sum()
    assert new_reward > inital_reward
  end

  test "updating the MDP updates the state" do
    new_mdp =
      @states
      |> Markovian.new(@actions, :s1)
      |> Markovian.update(1, :s2)

    assert :s2 == new_mdp.current_state
  end

  test "updating the MDP updates the action" do
    initial_mdp =
      @states
      |> Markovian.new(@actions, :s1)

    action =
      put_in(initial_mdp.q_table[:s1][:a2], 100)
      |> Map.put(:current_action, :a1)
      |> Map.put(:random_action_rate, 0)
      |> Markovian.update(1, :s1)
      |> Map.get(:current_action)

    assert :a2 == action
  end

  test "updating the MDP decays the random_action_rate" do
    initial_mdp =
      @states
      |> Markovian.new(@actions, :s1)

    final_mdp = initial_mdp |> Markovian.update(1, :s2)
    assert initial_mdp.random_action_rate > final_mdp.random_action_rate
  end
end
