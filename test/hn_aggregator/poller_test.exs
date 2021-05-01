defmodule HnAggregator.PollerTest do
  @moduledoc false

  use ExUnit.Case, async: false

  alias HnAggregator.Repo

  setup do
    bypass = Bypass.open(port: 9999)

    on_exit(fn ->
      Bypass.down(bypass)
    end)

    {:ok, bypass: bypass}
  end

  test "get_stories response 200", %{bypass: bypass} do
    test = self()
    stories_response = [1, 2, 3] |> Jason.encode!()

    Bypass.expect_once(bypass, "GET", "/v0/topstories.json", fn conn ->
      Plug.Conn.resp(
        conn,
        200,
        stories_response
      )
    end)

    Enum.each([1, 2, 3], fn item ->
      Bypass.expect_once(bypass, "GET", "/v0/item/#{item}.json", fn conn ->
        Process.send(test, {:received, item}, [])

        Plug.Conn.resp(
          conn,
          200,
          %{"id" => item} |> Jason.encode!()
        )
      end)
    end)

    # Send a msj to the poller to force to work and wait for message sended from bypass mock
    :ok = Process.send(HnAggregator.Poller, :work, [])
    assert_receive {:received, 1}, 5000
    assert_receive {:received, 2}, 5000
    assert_receive {:received, 3}, 5000

    # Wait for the poller to put data on the repo
    :timer.sleep(1000)
    assert [%{"id" => 1}, %{"id" => 2}, %{"id" => 3}] == Repo.get_stories()
  end
end
