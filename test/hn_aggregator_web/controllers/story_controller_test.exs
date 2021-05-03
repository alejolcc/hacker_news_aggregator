defmodule HnAggregator.StoryControllerTest do
  @moduledoc false

  alias HnAggregator.Repo

  use HnAggregatorWeb.ConnCase

  @stories [%{"id" => 1}, %{"id" => 2}, %{"id" => 3}]

  setup do
    Repo.push_stories(@stories)
  end

  test "List all stories", %{conn: conn} do
    conn = get(conn, "/api/stories")
    %{"stories" => stories} = json_response(conn, 200)
    assert @stories == stories
  end

  test "List stories paginated", %{conn: conn} do
    conn = get(conn, "/api/stories?page=1&limit=2")
    %{"stories" => stories} = json_response(conn, 200)
    assert [%{"id" => 1}, %{"id" => 2}] == stories
  end

  test "Get story", %{conn: conn} do
    conn = get(conn, "/api/stories/1")
    %{"stories" => stories} = json_response(conn, 200)
    assert %{"id" => 1} == stories
  end

  test "not_number param return 400", %{conn: conn} do
    conn = get(conn, "/api/stories?page=asd&limit=2")
    assert %{"error" => "Invalid Params"} = json_response(conn, 400)
  end

  test "bad page param return 400", %{conn: conn} do
    conn = get(conn, "/api/stories?page=-1&limit=2")
    assert %{"error" => "Invalid Params"} = json_response(conn, 400)
  end

  test "bad limit param return 400", %{conn: conn} do
    conn = get(conn, "/api/stories?page=1&limit=-2")
    assert %{"error" => "Invalid Params"} = json_response(conn, 400)
  end

  test "Get story return nil", %{conn: conn} do
    conn = get(conn, "/api/stories/47")
    %{"stories" => stories} = json_response(conn, 200)
    assert nil == stories
  end
end
