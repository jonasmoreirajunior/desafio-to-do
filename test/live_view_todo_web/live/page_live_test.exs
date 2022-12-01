defmodule LiveViewTodoWeb.PageLiveTest do
  use LiveViewTodoWeb.ConnCase
  alias LiveViewTodo.Item
  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "Todo"
    assert render(page_live) =~ "Todo"
  end

  test "connect and create a todo item", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")
    assert render_submit(view, :create, %{"text" => "Learn Elixir"}) =~ "Learn Elixir"
  end

  test "toggle an item", %{conn: conn} do
    {:ok, item} = Item.create_item(%{"text" => "Learn Elixir"})
    assert item.status == 0
    {:ok, view, _html} = live(conn, "/")

    assert view |> element("#item-#{item.id}") |> render_click()
  end

  test "delete an item", %{conn: conn} do
    {:ok, item} = Item.create_item(%{"text" => "Learn Elixir"})
    assert item.status == 0

    {:ok, view, _html} = live(conn, "/")
    assert view |> element("#delete-item-#{item.id}") |> render_click()

    updated_item = Item.get_item!(item.id)
    assert updated_item.status == 2
  end

  test "edit item", %{conn: conn} do
    {:ok, item} = Item.create_item(%{"text" => "Learn Elixir"})

    {:ok, view, _html} = live(conn, "/")
    assert view |> element("#edit-item-#{item.id}") |> render_click()
  end

  test "update an item", %{conn: conn} do
    {:ok, item} = Item.create_item(%{"text" => "Learn Elixir"})

    {:ok, view, _html} = live(conn, "/")
    assert view |> element("#edit-item-#{item.id}") |> render_click()

    assert view
           |> form("#form-update", %{"id" => item.id, "text" => "Learn more Elixir"})
           |> render_submit()

    updated_item = Item.get_item!(item.id)
    assert updated_item.text == "Learn more Elixir"
  end

  test "Filter item", %{conn: conn} do
    {:ok, _item1} = Item.create_item(%{"text" => "Learn Elixir", "status" => 1})
    {:ok, _item2} = Item.create_item(%{"text" => "Learn Phoenix"})

    # list only completed items
    {:ok, view, _html} = live(conn, "/?filter_by=completed")
    assert render(view) =~ "Learn Elixir"
    refute render(view) =~ "Learn Phoenix"

    # list only active items
    {:ok, view, _html} = live(conn, "/?filter_by=active")
    refute render(view) =~ "Learn Elixir"
    assert render(view) =~ "Learn Phoenix"

    # list all items
    {:ok, view, _html} = live(conn, "/?filter_by=all")
    assert render(view) =~ "Learn Elixir"
    assert render(view) =~ "Learn Phoenix"
  end

  test "clear completed items", %{conn: conn} do
    {:ok, _item1} = Item.create_item(%{"text" => "Learn Elixir", "status" => 1})
    {:ok, _item2} = Item.create_item(%{"text" => "Learn Phoenix"})

    # complete item1
    {:ok, view, _html} = live(conn, "/")
    assert render(view) =~ "Learn Elixir"
    assert render(view) =~ "Learn Phoenix"

    view = render_click(view, "clear-completed", %{})
    assert view =~ "Learn Phoenix"
    refute view =~ "Learn Elixir"
  end

  # This test is just to ensure coverage of the handle_info/2 function
  # It's not required but we like to have 100% coverage.
  # https://stackoverflow.com/a/60852290/1148249
  test "handle_info/2", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")
    {:ok, item} = Item.create_item(%{"text" => "Always Learning"})
    send(view.pid, %{event: "update", payload: %{items: Item.list_items()}})
    assert render(view) =~ item.text
  end
end
