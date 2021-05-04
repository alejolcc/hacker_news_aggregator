defmodule HnAggregatorWeb.StoriesChannelTest do
  @moduledoc false

  use HnAggregatorWeb.ChannelCase
  alias HnAggregator.Repo

  @stories [%{"id" => 1}, %{"id" => 2}, %{"id" => 3}]

  setup_all do
    :ok = Repo.push_stories(@stories)
  end

  defp join_and_subscribe do
    {:ok, _, socket} =
      HnAggregatorWeb.UserSocket
      |> socket("user_id", %{some: :assign})
      |> subscribe_and_join(HnAggregatorWeb.StoriesChannel, "stories:feed")

    %{socket: socket}
  end

  test "ping replies with status ok" do
    %{socket: socket} = join_and_subscribe()

    ref = push(socket, "ping", %{"hello" => "there"})
    assert_reply ref, :ok, %{"hello" => "there"}
  end

  test "stories are pushed uppon connect the socket" do
    %{socket: _socket} = join_and_subscribe()

    assert_push "new stories", %{stories: @stories}
  end

  test "stories are pushed when stories are updated" do
    %{socket: _socket} = join_and_subscribe()

    Phoenix.PubSub.broadcast(HnAggregator.PubSub, "stories", :new_stories)
    assert_push "new stories", %{stories: @stories}
  end
end
