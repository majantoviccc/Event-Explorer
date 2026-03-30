alias EventExplorer.Repo
alias EventExplorer.Cities.City
alias EventExplorer.Categories.Category
alias EventExplorer.Venues.Venue
alias EventExplorer.Events.Event

cities = [
  "Belgrade","Berlin","Tallinn","London","Amsterdam","Prague",
  "Milan","Cannes","Ibiza","Paris","Barcelona","Copenhagen",
  "Zurich","Lisbon","Rome"
]

cities
|> Enum.each(fn name ->
  %City{}
  |> City.changeset(%{name: name})
  |> Repo.insert!()
end)

categories = [
  "Technology","Business","Art","Film",
  "Music","Wellness","Lifestyle","Food"
]

categories
|> Enum.each(fn name ->
  %Category{}
  |> Category.changeset(%{name: name})
  |> Repo.insert!()
end)

cities_map =
  Repo.all(City)
  |> Map.new(&{&1.name, &1.id})

venues = [
  {"Tech Innovation Hub","Belgrade"},
  {"Innovation Center","Berlin"},
  {"Security Tech Arena","Tallinn"},
  {"Startup Hub","London"},
  {"Dev Arena","Amsterdam"},
  {"Code Club","Prague"},
  {"Art Studio","Milan"},
  {"Cinema Center","Cannes"},
  {"Ocean Stage","Ibiza"},
  {"Blue Note Club","Paris"},
  {"Beach Park","Barcelona"},
  {"Green Innovation Center","Copenhagen"},
  {"Finance Tech Center","Zurich"},
  {"Marketing Lab","Lisbon"},
  {"Central Square","Rome"}
]

venues
|> Enum.each(fn {name, city} ->
  %Venue{}
  |> Venue.changeset(%{
    name: name,
    city_id: cities_map[city]
  })
  |> Repo.insert!()
end)

venues_map =
  Repo.all(Venue)
  |> Map.new(&{&1.name, &1.id})

categories_map =
  Repo.all(Category)
  |> Map.new(&{&1.name, &1})

events = [
  {"React Global Summit", ["Technology","Business"], "Tech Innovation Hub",
   "The biggest global React conference bringing together developers and industry leaders.",
   "https://res.cloudinary.com/datqqcleg/image/upload/v1773918181/react-summit_e7epcd.png"},

  {"AI Future Conference", ["Technology"], "Innovation Center",
   "Explore the future of artificial intelligence, machine learning, and automation.",
   "https://res.cloudinary.com/datqqcleg/image/upload/v1773918214/ai-conference_ibb54q.png"},

  {"Cybersecurity Defense Summit", ["Technology","Business"], "Security Tech Arena",
   "Learn how to protect systems and data from modern cyber threats.",
   "https://res.cloudinary.com/datqqcleg/image/upload/v1773918212/cybersecurity-summit_pnwjml.png"},

  {"Startup Pitch Night", ["Business"], "Startup Hub",
   "Watch innovative startups pitch their ideas to investors and mentors.",
   "https://res.cloudinary.com/datqqcleg/image/upload/v1773918219/startup-pitch_xsvxkn.png"},

  {"24h Global Hackathon", ["Technology"], "Dev Arena",
   "Join developers worldwide in a 24-hour coding marathon.",
   "https://res.cloudinary.com/datqqcleg/image/upload/v1773918216/hackaton_g6qgkf.png"},

  {"Stand-Up Comedy Night", ["Lifestyle"], "Code Club",
   "An evening full of laughter with top stand-up comedians.",
   "https://res.cloudinary.com/datqqcleg/image/upload/v1773918211/comedy_pppaxb.png"},

  {"Digital Photography Masterclass", ["Art"], "Art Studio",
   "Master the art of digital photography with professional guidance.",
   "https://res.cloudinary.com/datqqcleg/image/upload/v1773918217/photography_bbts6y.png"},

  {"Film Directors Networking Night", ["Film","Business"], "Cinema Center",
   "Connect with film directors and producers from around the world.",
   "https://res.cloudinary.com/datqqcleg/image/upload/v1773918214/film-directors_k1huoa.png"},

  {"Electronic Music Festival", ["Music"], "Ocean Stage",
   "Experience top DJs and electronic music artists live.",
   "https://res.cloudinary.com/datqqcleg/image/upload/v1773918213/electronic-festival_a2fedq.png"},

  {"Jazz & Blues Night", ["Music"], "Blue Note Club",
   "Enjoy a relaxing night of jazz and blues performances.",
   "https://res.cloudinary.com/datqqcleg/image/upload/v1773918216/jazz-night_q4udwc.png"},

  {"Outdoor Yoga Festival", ["Wellness"], "Beach Park",
   "Relax your mind and body with yoga sessions in nature.",
   "https://res.cloudinary.com/datqqcleg/image/upload/v1773918302/yoga-festival_xdbiuq.png"},

  {"Luxury Fashion Show", ["Lifestyle"], "Green Innovation Center",
   "Discover the latest trends in luxury fashion.",
   "https://res.cloudinary.com/datqqcleg/image/upload/v1773918213/fashion_s1odfi.png"},

  {"Extreme Sports Showcase", ["Technology","Lifestyle"], "Finance Tech Center",
   "Witness thrilling extreme sports performances.",
   "https://res.cloudinary.com/datqqcleg/image/upload/v1773918213/extreme_c4sr7o.png"},

  {"Gaming Tournament Arena", ["Technology","Business"], "Marketing Lab",
   "Compete in high-stakes gaming tournaments.",
   "https://res.cloudinary.com/datqqcleg/image/upload/v1773918222/gaming_oadhqt.png"},

  {"International Street Food Festival", ["Food","Lifestyle"], "Central Square",
   "Taste amazing street food from all around the world.",
   "https://res.cloudinary.com/datqqcleg/image/upload/v1773918220/street-food_r3rtta.png"}
]

events
|> Enum.each(fn {title, categories, venue, description, image} ->

  category_structs =
    categories
    |> Enum.map(fn cat -> categories_map[cat] end)

  random_date =
    Date.add(~D[2026-05-01], Enum.random(0..60))

  random_time =
    Time.new!(Enum.random(16..22), Enum.random([0, 30]), 0)

  random_price =
    Enum.random([0, 10, 15, 20, 25, 30, 50, 100])

  random_featured =
    Enum.random([true, false])

  %Event{}
  |> Event.changeset(%{
    title: title,
    date: random_date,
    time: random_time,
    price: random_price,
    image: image,
    description: description,
    featured: random_featured,
    venue_id: venues_map[venue]
  })
  |> Ecto.Changeset.put_assoc(:categories, category_structs)
  |> Repo.insert!()
end)
