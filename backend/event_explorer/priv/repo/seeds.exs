alias EventExplorer.Repo
alias EventExplorer.Cities.City
alias EventExplorer.Categories.Category
alias EventExplorer.Venues.Venue
alias EventExplorer.Events.Event
alias EventExplorer.Uploaders.Cloudinary

get_or_insert = fn schema, attrs ->
  Repo.get_by(schema, attrs) ||
    Repo.insert!(struct(schema, attrs), on_conflict: :nothing)
end

cities = [
  "Belgrade",
  "Tallinn",
  "London",
  "Amsterdam",
  "Milan",
  "Paris",
  "Cannes",
  "Zurich",
  "Barcelona",
  "Lisbon",
  "Copenhagen",
  "Rome",
  "Ibiza"
]

city_map =
  Enum.map(cities, fn name ->
    city = get_or_insert.(City, %{name: name})
    {name, city}
  end)
  |> Enum.into(%{})

categories = [
  "Technology",
  "Business",
  "Art",
  "Film",
  "Music",
  "Wellness",
  "Lifestyle",
  "Food"
]

category_map =
  Enum.map(categories, fn name ->
    category = get_or_insert.(Category, %{name: name})
    {name, category}
  end)
  |> Enum.into(%{})

venue_data = [
  {"Tech Innovation Hub", "Belgrade"},
  {"Security Tech Arena", "Tallinn"},
  {"Startup Hub", "London"},
  {"Dev Arena", "Amsterdam"},
  {"Art Studio", "Milan"},
  {"Blue Note Club", "Paris"},
  {"Cinema Center", "Cannes"},
  {"Finance Tech Center", "Zurich"},
  {"Beach Park", "Barcelona"},
  {"Marketing Lab", "Lisbon"},
  {"Green Innovation Center", "Copenhagen"},
  {"Central Square", "Rome"},
  {"Ocean Stage", "Ibiza"}
]

venue_map =
  Enum.map(venue_data, fn {name, city_name} ->
    venue =
      Repo.get_by(Venue, name: name) ||
        Repo.insert!(%Venue{
          name: name,
          city_id: city_map[city_name].id
        })

    {name, venue}
  end)
  |> Enum.into(%{})

create_event = fn attrs, category_names ->
  public_id = Cloudinary.extract_public_id(attrs.image)
  categories = Enum.map(category_names, &category_map[&1])

  existing = Repo.get_by(Event, title: attrs.title)

  if existing do
    existing
  else
    %Event{}
    |> Event.changeset(%{
      title: attrs.title,
      description: attrs.description,
      date: attrs.date,
      time: attrs.time,
      price: Decimal.new(attrs.price),
      featured: attrs.featured,
      image: attrs.image,
      public_id: public_id,
      city_id: attrs.city_id,
      venue_id: attrs.venue_id
    })
    |> Ecto.Changeset.put_assoc(:categories, categories)
    |> Repo.insert!()
  end
end

create_event.(
  %{
    title: "Film Directors Networking Night",
    description: "Connect with film directors and producers from around the world.",
    date: ~D[2026-06-14],
    time: ~T[17:00:00],
    price: "50",
    featured: false,
    image:
      "https://res.cloudinary.com/datqqcleg/image/upload/v1773918214/film-directors_k1huoa.png",
    city_id: city_map["Cannes"].id,
    venue_id: venue_map["Cinema Center"].id
  },
  ["Film", "Business"]
)

create_event.(
  %{
    title: "Gaming Tournament Arena",
    description: "Compete in high-stakes gaming tournaments.",
    date: ~D[2026-06-25],
    time: ~T[18:00:00],
    price: "20",
    featured: true,
    image: "https://res.cloudinary.com/datqqcleg/image/upload/v1773918222/gaming_oadhqt.png",
    city_id: city_map["Lisbon"].id,
    venue_id: venue_map["Marketing Lab"].id
  },
  ["Technology", "Business"]
)

create_event.(
  %{
    title: "Digital Photography Masterclass",
    description: "Master the art of digital photography with professional guidance.",
    date: ~D[2026-05-13],
    time: ~T[17:00:00],
    price: "50",
    featured: false,
    image: "https://res.cloudinary.com/datqqcleg/image/upload/v1773918217/photography_bbts6y.png",
    city_id: city_map["Milan"].id,
    venue_id: venue_map["Art Studio"].id
  },
  ["Art"]
)

create_event.(
  %{
    title: "Extreme Sports Showcase",
    description: "Witness thrilling extreme sports performances.",
    date: ~D[2026-06-13],
    time: ~T[22:30:00],
    price: "30",
    featured: true,
    image: "https://res.cloudinary.com/datqqcleg/image/upload/v1773918213/extreme_c4sr7o.png",
    city_id: city_map["Zurich"].id,
    venue_id: venue_map["Finance Tech Center"].id
  },
  ["Technology", "Lifestyle"]
)

create_event.(
  %{
    title: "Luxury Fashion Show",
    description: "Discover the latest trends in luxury fashion.",
    date: ~D[2026-05-14],
    time: ~T[18:00:00],
    price: "0",
    featured: true,
    image: "https://res.cloudinary.com/datqqcleg/image/upload/v1773918213/fashion_s1odfi.png",
    city_id: city_map["Copenhagen"].id,
    venue_id: venue_map["Green Innovation Center"].id
  },
  ["Lifestyle"]
)

create_event.(
  %{
    title: "Outdoor Yoga Festival",
    description: "Relax your mind and body with yoga sessions in nature.",
    date: ~D[2026-06-25],
    time: ~T[22:00:00],
    price: "0",
    featured: false,
    image:
      "https://res.cloudinary.com/datqqcleg/image/upload/v1773918302/yoga-festival_xdbiuq.png",
    city_id: city_map["Barcelona"].id,
    venue_id: venue_map["Beach Park"].id
  },
  ["Wellness"]
)

create_event.(
  %{
    title: "24h Global Hackathon",
    description: "Join developers worldwide in a 24-hour coding marathon.",
    date: ~D[2026-06-03],
    time: ~T[17:30:00],
    price: "50",
    featured: false,
    image: "https://res.cloudinary.com/datqqcleg/image/upload/v1773918216/hackaton_g6qgkf.png",
    city_id: city_map["Amsterdam"].id,
    venue_id: venue_map["Dev Arena"].id
  },
  ["Technology"]
)

create_event.(
  %{
    title: "Cybersecurity Defense Summit",
    description: "Learn how to protect systems and data from modern cyber threats.",
    date: ~D[2026-05-31],
    time: ~T[16:30:00],
    price: "70",
    featured: true,
    image:
      "https://res.cloudinary.com/datqqcleg/image/upload/v1773918212/cybersecurity-summit_pnwjml.png",
    city_id: city_map["Tallinn"].id,
    venue_id: venue_map["Security Tech Arena"].id
  },
  ["Technology"]
)

create_event.(
  %{
    title: "Jazz & Blues Night",
    description: "Enjoy a relaxing night of jazz and blues performances.",
    date: ~D[2026-05-05],
    time: ~T[22:00:00],
    price: "50",
    featured: true,
    image: "https://res.cloudinary.com/datqqcleg/image/upload/v1773918216/jazz-night_q4udwc.png",
    city_id: city_map["Paris"].id,
    venue_id: venue_map["Blue Note Club"].id
  },
  ["Music"]
)

create_event.(
  %{
    title: "International Street Food Festival",
    description: "Taste amazing street food from all around the world.",
    date: ~D[2026-06-16],
    time: ~T[18:30:00],
    price: "50",
    featured: false,
    image: "https://res.cloudinary.com/datqqcleg/image/upload/v1773918220/street-food_r3rtta.png",
    city_id: city_map["Rome"].id,
    venue_id: venue_map["Central Square"].id
  },
  ["Food", "Lifestyle"]
)

create_event.(
  %{
    title: "Electronic Music Festival",
    description: "Experience top DJs and electronic music artists live.",
    date: ~D[2026-05-23],
    time: ~T[20:00:00],
    price: "20",
    featured: false,
    image:
      "https://res.cloudinary.com/datqqcleg/image/upload/v1773918213/electronic-festival_a2fedq.png",
    city_id: city_map["Ibiza"].id,
    venue_id: venue_map["Ocean Stage"].id
  },
  ["Music"]
)

create_event.(
  %{
    title: "Startup Pitch Night",
    description: "Watch innovative startups pitch their ideas to investors and mentors.",
    date: ~D[2026-05-19],
    time: ~T[19:30:00],
    price: "15",
    featured: true,
    image:
      "https://res.cloudinary.com/datqqcleg/image/upload/v1773918219/startup-pitch_xsvxkn.png",
    city_id: city_map["London"].id,
    venue_id: venue_map["Startup Hub"].id
  },
  ["Business"]
)

create_event.(
  %{
    title: "React Global Summit",
    description:
      "The largest React conference bringing together developers from around the world.",
    date: ~D[2026-03-30],
    time: ~T[12:24:00],
    price: "20",
    featured: true,
    image:
      "https://res.cloudinary.com/datqqcleg/image/upload/v1775461424/Screenshot_2026-04-06_at_09.43.15_mfkaes.png",
    city_id: city_map["Belgrade"].id,
    venue_id: venue_map["Tech Innovation Hub"].id
  },
  ["Technology"]
)

create_event.(
  %{
    title: "Street Art Festival",
    description:
      "Experience live graffiti, urban art, and street performances from talented artists.",
    date: ~D[2026-06-18],
    time: ~T[16:00:00],
    price: "30",
    featured: false,
    image:
      "https://res.cloudinary.com/datqqcleg/image/upload/v1775461333/Screenshot_2026-04-06_at_09.35.20_rwiai8.png",
    city_id: city_map["London"].id,
    venue_id: venue_map["Startup Hub"].id
  },
  ["Art", "Lifestyle"]
)

create_event.(
  %{
    title: "Wine & Taste Experience",
    description:
      "Enjoy a premium selection of wines and culinary delights in a relaxing atmosphere.",
    date: ~D[2026-06-22],
    time: ~T[19:00:00],
    price: "60",
    featured: true,
    image:
      "https://res.cloudinary.com/datqqcleg/image/upload/v1775461316/Screenshot_2026-04-06_at_09.39.42_nkwdcy.png",
    city_id: city_map["Rome"].id,
    venue_id: venue_map["Central Square"].id
  },
  ["Food", "Lifestyle"]
)
