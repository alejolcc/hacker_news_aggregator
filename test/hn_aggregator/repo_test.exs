defmodule HnAggregator.RepoTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias HnAggregator.Repo

  @stories [%{"id" => 1}, %{"id" => 2}, %{"id" => 3}]

  test "stories can be pushed" do
    :ok = Repo.push_stories(@stories)
    assert :ets.tab2list(Stories)
  end

  test "lookup an story" do
    :ok = Repo.push_stories(@stories)
    assert %{"id" => 1} == Repo.get_story(1)
  end

  test "lookup an unexistent story return nil" do
    :ok = Repo.push_stories(@stories)
    assert nil == Repo.get_story(47)
  end

  test "get_stories/0 return all stories" do
    :ok = Repo.push_stories(@stories)
    assert 3 == Repo.get_stories() |> Enum.count()
  end

  test "get_stories/1 return the first n stories" do
    :ok = Repo.push_stories(@stories)

    stories = Repo.get_stories(2)
    assert 2 == Enum.count(stories)
    assert [%{"id" => 1}, %{"id" => 2}] == stories
  end
end
