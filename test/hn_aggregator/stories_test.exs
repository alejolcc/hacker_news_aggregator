defmodule HnAggregator.StoriesTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias HnAggregator.{Stories, Repo}

  @stories [%{"id" => 1}, %{"id" => 2}, %{"id" => 3}]

  setup do
    Repo.push_stories(@stories)
  end

  test "list_paginated_stories return correct pages" do
    assert {:ok, stories} = Stories.list_paginated_stories(1, 2)
    assert [%{"id" => 1}, %{"id" => 2}] == stories
  end

  test "list_paginated_stories with bad page param" do
    assert {:error, :bad_params} == Stories.list_paginated_stories(-1, 1)
  end

  test "list_paginated_stories with bad limit param" do
    assert {:error, :bad_params} == Stories.list_paginated_stories(-1, 1)
  end
end
