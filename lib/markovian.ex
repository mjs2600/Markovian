defmodule Markovian do
  defstruct alpha: 0.2, gamma: 0.9, q_table: %{}, current_state: nil, current_action: nil,
    random_action_rate: 0.4, random_action_decay: 0.99

  def new(states, actions, initial_state) do
    state_space = for state <- states, into: %{} do
      action_space = for action <- actions, into: %{} do
        {action, 2 * :rand.uniform - 1}
      end

      {state, action_space}
    end

    %__MODULE__{q_table: state_space, current_state: initial_state, current_action: actions |> Enum.random()}
  end

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
    action = if mdp.random_action_rate > :rand.uniform do
      mdp.q_table[mdp.current_state] |> Map.keys() |> Enum.random()
    else
      mdp.q_table[mdp.current_state] |> Map.to_list() |> Enum.max_by(&elem(&1, 1)) |> elem(0)
    end

    Map.put(mdp, :current_action, action)
  end

  defp decay(mdp) do
    Map.update!(mdp, :random_action_rate, &(&1 * mdp.random_action_decay))
  end
end
