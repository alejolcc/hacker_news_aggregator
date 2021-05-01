defmodule HnAggregator.WebClientTest do
  @moduledoc false

  use ExUnit.Case, async: true

  setup do
    bypass = Bypass.open(port: 9999)

    on_exit(fn ->
      Bypass.down(bypass)
    end)

    {:ok, bypass: bypass}
  end

  test "get_stories response 200", %{bypass: bypass} do
    valid_response = [1, 2, 3] |> Jason.encode!()

    Bypass.expect_once(bypass, "GET", "/v0/topstories.json", fn conn ->
      Plug.Conn.resp(
        conn,
        200,
        valid_response
      )
    end)

    assert {:ok, [1, 2, 3]} == HnAggregator.WebClient.get_stories()
  end

  test "get_stories response 401", %{bypass: bypass} do
    response = %{"error" => "Permission denied"} |> Jason.encode!()

    Bypass.expect_once(bypass, "GET", "/v0/topstories.json", fn conn ->
      Plug.Conn.resp(
        conn,
        401,
        response
      )
    end)

    assert {:error, {:permission_denied, _}} = HnAggregator.WebClient.get_stories()
  end

  test "get_stories response 500", %{bypass: bypass} do
    response = %{"error" => "Permission denied"} |> Jason.encode!()

    Bypass.expect_once(bypass, "GET", "/v0/topstories.json", fn conn ->
      Plug.Conn.resp(
        conn,
        500,
        response
      )
    end)

    assert {:error, {:error, 500}} = HnAggregator.WebClient.get_stories()
  end

  test "get_stories response timeout", %{bypass: bypass} do
    valid_response = [1, 2, 3] |> Jason.encode!()

    Bypass.stub(bypass, "GET", "/v0/topstories.json", fn conn ->
      Plug.Conn.resp(
        conn,
        200,
        valid_response
      )
    end)

    assert {:error, :timeout} = HnAggregator.WebClient.get_stories(timeout: 0)
  end

  test "get_item response 200", %{bypass: bypass} do
    id = 26_990_957

    valid_response =
      %{
        "by" => "some author",
        "descendants" => 25,
        "id" => id,
        "kids" => [1, 2, 3, 4],
        "score" => 100,
        "time" => 1_619_770_677,
        "title" => "some title",
        "type" => "story",
        "url" => "some url"
      }
      |> Jason.encode!()

    Bypass.expect_once(bypass, "GET", "/v0/item/#{id}.json", fn conn ->
      Plug.Conn.resp(
        conn,
        200,
        valid_response
      )
    end)

    assert {:ok, item} = HnAggregator.WebClient.get_item(id)
    assert item["by"] == "some author"
    assert item["id"] == id
  end
end
