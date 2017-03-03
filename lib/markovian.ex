defmodule Markovian do
  @moduledoc """
  Markovian is a Q-learner for the BEAM.
  """

  defstruct alpha: 0.2, gamma: 0.9, q_table: %{}, current_state: nil, current_action: nil,
    random_action_rate: 0.4, random_action_decay: 0.99

  @type t :: %__MODULE__{}
  @type state :: term
  @type action :: term

  @doc """
  Creates a new MDP. To build a new MDP, you need to provide a set of states
  and actions as well an initial state.
  """
  @spec new(states::[state], actions::[action], initial_state::state) :: t
  def new(states, actions, initial_state) do
    state_space = for state <- states, into: %{} do
      action_space = for action <- actions, into: %{} do
        {action, 2 * :rand.uniform() - 1}
      end

      {state, action_space}
    end

    %__MODULE__{
      q_table: state_space,
      current_state: initial_state,
      current_action: actions |> Enum.random()
    }
  end

  @doc """
  Updates an MDP. It needs to get the reward and next state from the previous
  state and action.
  """
  @spec update(t, float, state) :: t
  def update(mdp, reward, next_state) do
    s_update = (1 - mdp.alpha) * get_in(mdp.q_table, [mdp.current_state, mdp.current_action])
    next_q = mdp.q_table[next_state] |> Map.values() |> Enum.max()
    s_prime_update = mdp.alpha * (reward + mdp.gamma * next_q)
    updated_q_table = put_in(mdp.q_table, [mdp.current_state, mdp.current_action], s_update + s_prime_update)
    %{mdp | q_table: updated_q_table, current_state: next_state}
    |> generate_action()
    |> decay()
  end

  defp generate_action(mdp) do
    random? = mdp.random_action_rate > :rand.uniform()
    action = do_generate_action(mdp.q_table[mdp.current_state], random?)
    %{mdp | current_action: action}
  end

  defp do_generate_action(current_state_actions, random?)
  defp do_generate_action(current_state_actions, false) do
    current_state_actions
    |> Map.to_list()
    |> Enum.max_by(&elem(&1, 1))
    |> elem(0)
  end
  defp do_generate_action(current_state_actions, true) do
    current_state_actions
    |> Map.keys()
    |> Enum.random()
  end

  defp decay(mdp) do
    Map.update!(mdp, :random_action_rate, &(&1 * mdp.random_action_decay))
  end
end
