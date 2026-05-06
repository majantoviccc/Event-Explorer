defmodule EventExplorer.EventsTest do
  use EventExplorer.DataCase

  alias EventExplorer.Events
  alias EventExplorer.Repo
  alias EventExplorer.Events.Event
  alias EventExplorer.Categories.Category
  alias EventExplorer.Cities.City
  alias EventExplorer.Venues.Venue

  test "list_events returns all events without filters" do
    {:ok, city} = Repo.insert(%City{name: "Podgorica"})
    {:ok, venue} = Repo.insert(%Venue{name: "V1", city_id: city.id})

    {:ok, e1} =
      Repo.insert(%Event{
        title: "Event 1",
        date: ~D[2025-01-01],
        time: ~T[12:00:00],
        venue_id: venue.id
      })

    {:ok, e2} =
      Repo.insert(%Event{
        title: "Event 2",
        date: ~D[2025-02-01],
        time: ~T[14:00:00],
        venue_id: venue.id
      })

    events = Events.list_events()

    assert length(events) == 2
    ids = Enum.map(events, & &1.id)
    assert e1.id in ids
    assert e2.id in ids
  end

  test "list_events filters events by city" do
    {:ok, city1} = Repo.insert(%City{name: "Podgorica"})
    {:ok, city2} = Repo.insert(%City{name: "Budva"})

    {:ok, venue1} = Repo.insert(%Venue{name: "V1", city_id: city1.id})
    {:ok, venue2} = Repo.insert(%Venue{name: "V2", city_id: city2.id})

    {:ok, e1} =
      Repo.insert(%Event{
        title: "Event 1",
        date: ~D[2025-01-01],
        time: ~T[12:00:00],
        venue_id: venue1.id
      })

    {:ok, _} =
      Repo.insert(%Event{
        title: "Event 2",
        date: ~D[2025-01-01],
        time: ~T[12:00:00],
        venue_id: venue2.id
      })

    events = Events.list_events(%{"city" => "Podgorica"})

    assert length(events) == 1
    assert hd(events).id == e1.id
    ids = Enum.map(events, & &1.id)
  end

  test "list_events returns empty list when city does not exist" do
    {:ok, city} = Repo.insert(%City{name: "Podgorica"})
    {:ok, venue} = Repo.insert(%Venue{name: "V1", city_id: city.id})

    Repo.insert!(%Event{
      title: "Event",
      date: ~D[2025-01-01],
      time: ~T[12:00:00],
      venue_id: venue.id
    })

    events = Events.list_events(%{"city" => "Niksic"})

    assert events == []
  end

  test "list_events returns all events when city is empty string" do
    {:ok, city} = Repo.insert(%City{name: "Podgorica"})
    {:ok, venue} = Repo.insert(%Venue{name: "V1", city_id: city.id})

    {:ok, e1} =
      Repo.insert(%Event{
        title: "Event 1",
        date: ~D[2025-01-01],
        time: ~T[12:00:00],
        venue_id: venue.id
      })

    {:ok, _e2} =
      Repo.insert(%Event{
        title: "Event 2",
        date: ~D[2025-01-01],
        time: ~T[12:00:00],
        venue_id: venue.id
      })

    events = Events.list_events(%{"city" => ""})

    assert length(events) == 2
  end

  test "list_events filters events by one category" do
    {:ok, city} = Repo.insert(%City{name: "Podgorica"})
    {:ok, venue} = Repo.insert(%Venue{name: "V1", city_id: city.id})

    {:ok, cat1} = Repo.insert(%Category{name: "Music"})
    {:ok, _} = Repo.insert(%Category{name: "Tech"})

    {:ok, e1} =
      Repo.insert(%Event{
        title: "Music event",
        date: ~D[2025-01-01],
        time: ~T[12:00:00],
        venue_id: venue.id
      })

    {:ok, _} =
      Repo.insert(%Event{
        title: "Tech event",
        date: ~D[2025-01-01],
        time: ~T[12:00:00],
        venue_id: venue.id
      })

    e1 = Repo.preload(e1, :categories)

    Events.update_event(e1, %{"category_ids" => [Integer.to_string(cat1.id)]})

    events = Events.list_events(%{"category" => ["Music"]})

    assert length(events) == 1
    assert hd(events).id == e1.id
  end

  test "list_events filters events that have all selected categories" do
    {:ok, city} = Repo.insert(%City{name: "Podgorica"})
    {:ok, venue} = Repo.insert(%Venue{name: "V1", city_id: city.id})

    {:ok, cat1} = Repo.insert(%Category{name: "Music"})
    {:ok, cat2} = Repo.insert(%Category{name: "Tech"})

    {:ok, e1} =
      Repo.insert(%Event{
        title: "Full event",
        date: ~D[2025-01-01],
        time: ~T[12:00:00],
        venue_id: venue.id
      })

    {:ok, e2} =
      Repo.insert(%Event{
        title: "Partial event",
        date: ~D[2025-01-01],
        time: ~T[12:00:00],
        venue_id: venue.id
      })

    e1 = Repo.preload(e1, :categories)
    e2 = Repo.preload(e2, :categories)

    Events.update_event(e1, %{
      "category_ids" => [Integer.to_string(cat1.id), Integer.to_string(cat2.id)]
    })

    Events.update_event(e2, %{"category_ids" => [Integer.to_string(cat1.id)]})

    events = Events.list_events(%{"category" => ["Music", "Tech"]})

    assert length(events) == 1
    assert hd(events).id == e1.id
  end

  test "list_events returns all events when category is empty string" do
    {:ok, city} = Repo.insert(%City{name: "Podgorica"})
    {:ok, venue} = Repo.insert(%Venue{name: "V1", city_id: city.id})

    Repo.insert!(%Event{
      title: "Event 1",
      date: ~D[2025-01-01],
      time: ~T[12:00:00],
      venue_id: venue.id
    })

    Repo.insert!(%Event{
      title: "Event 2",
      date: ~D[2025-01-01],
      time: ~T[12:00:00],
      venue_id: venue.id
    })

    events = Events.list_events(%{"category" => [""]})

    assert length(events) == 2
  end

  test "list_events returns all events when categories list is empty after cleanup" do
    {:ok, city} = Repo.insert(%City{name: "Podgorica"})
    {:ok, venue} = Repo.insert(%Venue{name: "V1", city_id: city.id})

    Repo.insert!(%Event{
      title: "Event",
      date: ~D[2025-01-01],
      time: ~T[12:00:00],
      venue_id: venue.id
    })

    events = Events.list_events(%{"category" => ["", ""]})

    assert length(events) == 1
  end

  test "list_events ignores empty values mixed with categories" do
    {:ok, city} = Repo.insert(%City{name: "Podgorica"})
    {:ok, venue} = Repo.insert(%Venue{name: "V1", city_id: city.id})

    {:ok, cat} = Repo.insert(%Category{name: "Music"})

    {:ok, event} =
      Repo.insert(%Event{
        title: "Music event",
        date: ~D[2025-01-01],
        time: ~T[12:00:00],
        venue_id: venue.id
      })

    event = Repo.preload(event, :categories)

    Events.update_event(event, %{
      "category_ids" => [Integer.to_string(cat.id)]
    })

    events = Events.list_events(%{"category" => ["Music", ""]})

    assert length(events) == 1
  end

  test "list_events returns empty list when category does not exist" do
    {:ok, city} = Repo.insert(%City{name: "Podgorica"})
    {:ok, venue} = Repo.insert(%Venue{name: "V1", city_id: city.id})

    Repo.insert!(%Event{
      title: "Event",
      date: ~D[2025-01-01],
      time: ~T[12:00:00],
      venue_id: venue.id
    })

    events = Events.list_events(%{"category" => ["Nepostojeca"]})

    assert events == []
  end

  test "list_events filters events by search term" do
    {:ok, city} = Repo.insert(%City{name: "Podgorica"})
    {:ok, venue} = Repo.insert(%Venue{name: "V1", city_id: city.id})

    {:ok, e1} =
      Repo.insert(%Event{
        title: "Rock concert",
        date: ~D[2025-01-01],
        time: ~T[12:00:00],
        venue_id: venue.id
      })

    {:ok, _} =
      Repo.insert(%Event{
        title: "Tech meetup",
        date: ~D[2025-01-01],
        time: ~T[12:00:00],
        venue_id: venue.id
      })

    events = Events.list_events(%{"search" => "Rock"})

    assert length(events) == 1
    assert hd(events).id == e1.id
  end

  test "list_events search returns no results for unknown term" do
    {:ok, city} = Repo.insert(%City{name: "Podgorica"})
    {:ok, venue} = Repo.insert(%Venue{name: "V1", city_id: city.id})

    Repo.insert!(%Event{
      title: "Rock concert",
      date: ~D[2025-01-01],
      time: ~T[12:00:00],
      venue_id: venue.id
    })

    Repo.insert!(%Event{
      title: "Tech meetup",
      date: ~D[2025-01-01],
      time: ~T[12:00:00],
      venue_id: venue.id
    })

    events = Events.list_events(%{"search" => "Unknown"})

    assert events == []
  end

  test "list_events returns all events when search is empty" do
    {:ok, city} = Repo.insert(%City{name: "Podgorica"})
    {:ok, venue} = Repo.insert(%Venue{name: "V1", city_id: city.id})

    Repo.insert!(%Event{
      title: "Event 1",
      date: ~D[2025-01-01],
      time: ~T[12:00:00],
      venue_id: venue.id
    })

    Repo.insert!(%Event{
      title: "Event 2",
      date: ~D[2025-01-01],
      time: ~T[12:00:00],
      venue_id: venue.id
    })

    events = Events.list_events(%{"search" => ""})

    assert length(events) == 2
  end

  test "list_events sorts events ascending" do
    {:ok, city} = Repo.insert(%City{name: "Podgorica"})
    {:ok, venue} = Repo.insert(%Venue{name: "V1", city_id: city.id})

    {:ok, e1} =
      Repo.insert(%Event{
        title: "Old",
        date: ~D[2025-01-01],
        time: ~T[12:00:00],
        venue_id: venue.id
      })

    {:ok, e2} =
      Repo.insert(%Event{
        title: "New",
        date: ~D[2025-02-01],
        time: ~T[12:00:00],
        venue_id: venue.id
      })

    events = Events.list_events(%{"sort" => "asc"})

    assert Enum.map(events, & &1.id) == [e1.id, e2.id]
  end

  test "list_events sorts events descending" do
    {:ok, city} = Repo.insert(%City{name: "Podgorica"})
    {:ok, venue} = Repo.insert(%Venue{name: "V1", city_id: city.id})

    {:ok, e1} =
      Repo.insert(%Event{
        title: "Old",
        date: ~D[2025-01-01],
        time: ~T[12:00:00],
        venue_id: venue.id
      })

    {:ok, e2} =
      Repo.insert(%Event{
        title: "New",
        date: ~D[2025-02-01],
        time: ~T[12:00:00],
        venue_id: venue.id
      })

    events = Events.list_events(%{"sort" => "desc"})

    assert Enum.map(events, & &1.id) == [e2.id, e1.id]
  end

  test "list_events filters featured events" do
    {:ok, city} = Repo.insert(%City{name: "Podgorica"})
    {:ok, venue} = Repo.insert(%Venue{name: "V1", city_id: city.id})

    {:ok, e1} =
      Repo.insert(%Event{
        title: "Featured",
        date: ~D[2025-01-01],
        time: ~T[12:00:00],
        venue_id: venue.id,
        featured: true
      })

    {:ok, _} =
      Repo.insert(%Event{
        title: "Normal",
        date: ~D[2025-01-01],
        time: ~T[12:00:00],
        venue_id: venue.id,
        featured: false
      })

    events = Events.list_events(%{"featured" => "true"})

    assert length(events) == 1
    assert hd(events).id == e1.id
  end

  test "list_events returns all events when featured is false" do
    {:ok, city} = Repo.insert(%City{name: "Podgorica"})
    {:ok, venue} = Repo.insert(%Venue{name: "V1", city_id: city.id})

    Repo.insert!(%Event{
      title: "Event",
      date: ~D[2025-01-01],
      time: ~T[12:00:00],
      venue_id: venue.id,
      featured: false
    })

    events = Events.list_events(%{"featured" => "false"})

    assert length(events) == 1
  end

  test "list_events filters events by city and category" do
    {:ok, city} = Repo.insert(%City{name: "Podgorica"})
    {:ok, venue} = Repo.insert(%Venue{name: "V1", city_id: city.id})

    {:ok, cat1} = Repo.insert(%Category{name: "Music"})
    {:ok, cat2} = Repo.insert(%Category{name: "Tech"})

    {:ok, e1} =
      Repo.insert(%Event{
        title: "Old",
        date: ~D[2025-01-01],
        time: ~T[12:00:00],
        venue_id: venue.id
      })

    {:ok, e2} =
      Repo.insert(%Event{
        title: "New",
        date: ~D[2025-02-01],
        time: ~T[12:00:00],
        venue_id: venue.id
      })

    e1 = Repo.preload(e1, :categories)
    e2 = Repo.preload(e2, :categories)

    Events.update_event(e1, %{"category_ids" => [Integer.to_string(cat1.id)]})
    Events.update_event(e2, %{"category_ids" => [Integer.to_string(cat2.id)]})

    events = Events.list_events(%{"city" => "Podgorica", "category" => ["Music"]})

    assert length(events) == 1
  end

  test "get_event returns event when it exists" do
    {:ok, city} = Repo.insert(%City{name: "Podgorica"})
    {:ok, venue} = Repo.insert(%Venue{name: "V1", city_id: city.id})

    {:ok, event} =
      Repo.insert(%Event{
        title: "Test",
        date: ~D[2025-01-01],
        time: ~T[12:00:00],
        venue_id: venue.id
      })

    {:ok, result} = Events.get_event(event.id)

    assert result.id == event.id
  end

  test "get_event returns error when event does not exist" do
    {:ok, city} = Repo.insert(%City{name: "Podgorica"})
    {:ok, venue} = Repo.insert(%Venue{name: "V1", city_id: city.id})

    {:ok, event} =
      Repo.insert(%Event{
        title: "Test",
        date: ~D[2025-01-01],
        time: ~T[12:00:00],
        venue_id: venue.id
      })

    non_existing_id = event.id + 1000

    assert {:error, :not_found} = Events.get_event(non_existing_id)
  end

  test "create_event creates event without image" do
    {:ok, city} = Repo.insert(%City{name: "Podgorica"})
    {:ok, venue} = Repo.insert(%Venue{name: "V1", city_id: city.id})

    attrs = %{
      "title" => "Event",
      "date" => ~D[2025-01-01],
      "time" => ~T[12:00:00],
      "venue_id" => venue.id
    }

    {:ok, event} = Events.create_event(attrs)

    assert event.title == "Event"
  end

  test "create_event returns error when required fields are missing" do
    assert {:error, _} = Events.create_event(%{})
  end

  test "create_event creates event with categories" do
    {:ok, city} = Repo.insert(%City{name: "Podgorica"})
    {:ok, venue} = Repo.insert(%Venue{name: "V1", city_id: city.id})
    {:ok, cat} = Repo.insert(%Category{name: "Music"})

    attrs = %{
      "title" => "Event",
      "date" => ~D[2025-01-01],
      "time" => ~T[12:00:00],
      "venue_id" => venue.id,
      "category_ids" => [Integer.to_string(cat.id)]
    }

    {:ok, event} = Events.create_event(attrs)

    assert length(event.categories) == 1
  end

  test "create_event creates event with image" do
    {:ok, city} = Repo.insert(%City{name: "Podgorica"})
    {:ok, venue} = Repo.insert(%Venue{name: "V1", city_id: city.id})

    attrs = %{
      "title" => "Event",
      "date" => ~D[2025-01-01],
      "time" => ~T[12:00:00],
      "venue_id" => venue.id,
      "image" => "http://image.jpg",
      "public_id" => "123"
    }

    {:ok, event} = Events.create_event(attrs)

    assert event.image == "http://image.jpg"
  end

  test "create_event returns error when price is negative" do
    {:ok, city} = Repo.insert(%City{name: "Podgorica"})
    {:ok, venue} = Repo.insert(%Venue{name: "V1", city_id: city.id})

    attrs = %{
      "title" => "Event",
      "date" => ~D[2025-01-01],
      "time" => ~T[12:00:00],
      "venue_id" => venue.id,
      "price" => -10
    }

    assert {:error, _} = Events.create_event(attrs)
  end

  test "create_event returns error when venue does not exist" do
    attrs = %{
      "title" => "Event",
      "date" => ~D[2025-01-01],
      "time" => ~T[12:00:00],
      "venue_id" => 9999
    }

    assert {:error, _} = Events.create_event(attrs)
  end

  test "create_event returns error when title is too long" do
    {:ok, city} = Repo.insert(%City{name: "Podgorica"})
    {:ok, venue} = Repo.insert(%Venue{name: "V1", city_id: city.id})

    long_title = String.duplicate("a", 256)

    attrs = %{
      "title" => long_title,
      "date" => ~D[2025-01-01],
      "time" => ~T[12:00:00],
      "venue_id" => venue.id
    }

    assert {:error, _} = Events.create_event(attrs)
  end

  test "create_event creates event when category_ids is nil" do
    {:ok, city} = Repo.insert(%City{name: "Podgorica"})
    {:ok, venue} = Repo.insert(%Venue{name: "V1", city_id: city.id})

    attrs = %{
      "title" => "Event",
      "date" => ~D[2025-01-01],
      "time" => ~T[12:00:00],
      "venue_id" => venue.id,
      "category_ids" => nil
    }

    {:ok, event} = Events.create_event(attrs)

    assert event.id
  end

  test "create_event creates event without category_ids key" do
    {:ok, city} = Repo.insert(%City{name: "Podgorica"})
    {:ok, venue} = Repo.insert(%Venue{name: "V1", city_id: city.id})

    attrs = %{
      "title" => "Event",
      "date" => ~D[2025-01-01],
      "time" => ~T[12:00:00],
      "venue_id" => venue.id
    }

    {:ok, event} = Events.create_event(attrs)

    assert event.id
  end

  test "update_event updates event without image" do
    {:ok, city} = Repo.insert(%City{name: "Podgorica"})
    {:ok, venue} = Repo.insert(%Venue{name: "V1", city_id: city.id})

    {:ok, event} =
      Repo.insert(%Event{
        title: "Old",
        date: ~D[2025-01-01],
        time: ~T[12:00:00],
        venue_id: venue.id
      })

    {:ok, updated} = Events.update_event(event, %{"title" => "New"})

    assert updated.title == "New"
  end

  test "update_event updates event categories" do
    {:ok, city} = Repo.insert(%City{name: "Podgorica"})
    {:ok, venue} = Repo.insert(%Venue{name: "V1", city_id: city.id})

    {:ok, cat1} = Repo.insert(%Category{name: "Music"})
    {:ok, cat2} = Repo.insert(%Category{name: "Tech"})

    {:ok, event} =
      Repo.insert(%Event{
        title: "Event",
        date: ~D[2025-01-01],
        time: ~T[12:00:00],
        venue_id: venue.id
      })

    {:ok, updated} =
      Events.update_event(event, %{
        "category_ids" => [Integer.to_string(cat1.id), Integer.to_string(cat2.id)]
      })

    assert length(updated.categories) == 2
  end

  test "update_event returns same event when no changes provided" do
    {:ok, city} = Repo.insert(%City{name: "Podgorica"})
    {:ok, venue} = Repo.insert(%Venue{name: "V1", city_id: city.id})

    {:ok, event} =
      Repo.insert(%Event{
        title: "Event",
        date: ~D[2025-01-01],
        time: ~T[12:00:00],
        venue_id: venue.id
      })

    {:ok, updated} = Events.update_event(event, %{})

    assert updated.id == event.id
  end

  test "delete_event deletes event" do
    {:ok, city} = Repo.insert(%City{name: "Podgorica"})
    {:ok, venue} = Repo.insert(%Venue{name: "V1", city_id: city.id})

    {:ok, event} =
      Repo.insert(%Event{
        title: "Event",
        date: ~D[2025-01-01],
        time: ~T[12:00:00],
        venue_id: venue.id
      })

    {:ok, _} = Events.delete_event(event)

    assert Repo.get(Event, event.id) == nil
  end

  test "change_event returns changeset" do
    {:ok, city} = Repo.insert(%City{name: "Podgorica"})
    {:ok, venue} = Repo.insert(%Venue{name: "V1", city_id: city.id})

    event = %Event{title: "Event", date: ~D[2025-01-01], time: ~T[12:00:00], venue_id: venue.id}

    changeset = Events.change_event(event)

    assert %Ecto.Changeset{} = changeset
  end

  test "related_events returns events from same city" do
    {:ok, city} = Repo.insert(%City{name: "Podgorica"})
    {:ok, venue} = Repo.insert(%Venue{name: "V1", city_id: city.id})
    {:ok, cat} = Repo.insert(%Category{name: "Music"})

    {:ok, e1} =
      Repo.insert(%Event{
        title: "Main",
        date: ~D[2025-01-01],
        time: ~T[12:00:00],
        venue_id: venue.id
      })

    {:ok, e2} =
      Repo.insert(%Event{
        title: "Related",
        date: ~D[2025-01-02],
        time: ~T[12:00:00],
        venue_id: venue.id
      })

    Events.update_event(e1, %{"category_ids" => [Integer.to_string(cat.id)]})
    Events.update_event(e2, %{"category_ids" => [Integer.to_string(cat.id)]})

    events = Events.related_events(e1)

    assert e2.id in Enum.map(events, & &1.id)
  end

  test "related_events returns events with same category" do
    {:ok, city1} = Repo.insert(%City{name: "Podgorica"})
    {:ok, city2} = Repo.insert(%City{name: "Budva"})

    {:ok, venue1} = Repo.insert(%Venue{name: "V1", city_id: city1.id})
    {:ok, venue2} = Repo.insert(%Venue{name: "V2", city_id: city2.id})

    {:ok, cat} = Repo.insert(%Category{name: "Music"})

    {:ok, e1} =
      Repo.insert(%Event{
        title: "Main",
        date: ~D[2025-01-01],
        time: ~T[12:00:00],
        venue_id: venue1.id
      })

    {:ok, e2} =
      Repo.insert(%Event{
        title: "Related",
        date: ~D[2025-01-02],
        time: ~T[12:00:00],
        venue_id: venue2.id
      })

    Events.update_event(e1, %{"category_ids" => [Integer.to_string(cat.id)]})
    Events.update_event(e2, %{"category_ids" => [Integer.to_string(cat.id)]})

    events = Events.related_events(e1)

    assert e2.id in Enum.map(events, & &1.id)
  end

  test "related_events does not return the same event" do
    {:ok, city} = Repo.insert(%City{name: "Podgorica"})
    {:ok, venue} = Repo.insert(%Venue{name: "V1", city_id: city.id})

    {:ok, event} =
      Repo.insert(%Event{
        title: "Event",
        date: ~D[2025-01-01],
        time: ~T[12:00:00],
        venue_id: venue.id
      })

    events = Events.related_events(event)

    refute event.id in Enum.map(events, & &1.id)
  end

  test "related_events returns at most 5 events" do
    {:ok, city} = Repo.insert(%City{name: "Podgorica"})
    {:ok, venue} = Repo.insert(%Venue{name: "V1", city_id: city.id})

    {:ok, main} =
      Repo.insert(%Event{
        title: "Main",
        date: ~D[2025-01-01],
        time: ~T[12:00:00],
        venue_id: venue.id
      })

    for i <- 1..6 do
      Repo.insert(%Event{
        title: "Event #{i}",
        date: ~D[2025-01-02],
        time: ~T[12:00:00],
        venue_id: venue.id
      })
    end

    events = Events.related_events(main)

    assert length(events) <= 5
  end

  test "related_events returns empty list when no related events" do
    {:ok, city} = Repo.insert(%City{name: "Podgorica"})
    {:ok, venue} = Repo.insert(%Venue{name: "V1", city_id: city.id})

    {:ok, event} =
      Repo.insert(%Event{
        title: "Solo",
        date: ~D[2025-01-01],
        time: ~T[12:00:00],
        venue_id: venue.id
      })

    events = Events.related_events(event)

    assert events == []
  end

  test "update_event returns error with invalid data" do
    {:ok, city} = Repo.insert(%City{name: "Podgorica"})
    {:ok, venue} = Repo.insert(%Venue{name: "V1", city_id: city.id})

    {:ok, event} =
      Events.create_event(%{
        "title" => "Valid title",
        "date" => ~D[2026-01-01],
        "time" => ~T[20:00:00],
        "city_id" => city.id,
        "venue_id" => venue.id
      })

    assert {:error, %Ecto.Changeset{}} =
             Events.update_event(event, %{
               "title" => nil
             })
  end
end
