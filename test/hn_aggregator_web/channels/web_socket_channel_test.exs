defmodule HnAggregatorWeb.WebSocketChannelTest do
  @moduledoc false

  use HnAggregatorWeb.ChannelCase
  alias HnAggregator.Repo

  @stories [%{"id" => 1}, %{"id" => 2}, %{"id" => 3}]

  setup_all do
    Application.ensure_all_started(:gun)
    :ok = Repo.push_stories(@stories)
  end

  test "stories are pushed uppon connect the socket" do
    test_pid = self()
    HnAggregatorWeb.WebSocketClient.start_link(test_pid: test_pid)

    assert_receive {:receive, {:text, msg}}, 1000
    assert @stories == Jason.decode!(msg)
  end

  test "stories are pushed when are refreshed" do
    test_pid = self()
    HnAggregatorWeb.WebSocketClient.start_link(test_pid: test_pid)
    assert_receive {:receive, _}, 1000

    Phoenix.PubSub.broadcast(HnAggregator.PubSub, "stories", :new_stories)
    assert_receive {:receive, {:text, msg}}, 1000
    assert @stories == Jason.decode!(msg)
  end
end
